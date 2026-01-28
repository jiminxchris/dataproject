
-- 일일 배송 요약 테이블 (Report Table)
-- 날짜별, 고객사별, 지역별로 몇 마리가 나갔는지 저장
CREATE TABLE IF NOT EXISTS fms.daily_ship_summary (
    summary_id SERIAL PRIMARY KEY,
    ship_date DATE,
    customer VARCHAR(50),
    destination VARCHAR(50),
    total_count INT,        -- 출하 마릿수
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE PROCEDURE fms.sp_test_log_shipping()
AS $$
BEGIN
    INSERT INTO fms.daily_ship_summary (ship_date, customer, destination, total_count)
    SELECT 
        arrival_date, 
        customer, 
        destination, 
        COUNT(*)
    FROM fms.ship_result
    GROUP BY arrival_date, customer, destination;
END;
$$ LANGUAGE plpgsql;

CALL fms.sp_test_log_shipping();

SELECT * FROM fms.daily_ship_summary ORDER BY created_at DESC;


DO $$
DECLARE
    jid integer;
    scid integer;
BEGIN
    -- Job 생성
    INSERT INTO pgagent.pga_job (
        jobjclid, jobname, jobdesc, jobhostagent, jobenabled
    ) VALUES (
        1::integer, 'test_shipping_log_job', '배송 로그 적재 테스트', '', true
    ) RETURNING jobid INTO jid;

    -- Step 생성 (테스트용 프로시저 호출)
    INSERT INTO pgagent.pga_jobstep (
        jstjobid, jstname, jstenabled, jstkind,
        jstconnstr, jstdbname, jstonerror,
        jstcode, jstdesc
    ) VALUES (
        jid, 'step_log_insert', true, 's',
        '', 'postgres', 'f',
        'CALL fms.sp_test_log_shipping();', ''
    );

    -- Schedule 생성 (시간 설정)
    INSERT INTO pgagent.pga_schedule (
        jscjobid, jscname, jscdesc, jscenabled,
        jscstart, jscend, -- 시작 및 종료 시간 지정
        jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
    ) VALUES (
        jid, 'test_schedule_5min', '오늘 18:10~15분 사이 매분 실행', true,
        '2026-01-28 18:10:00+09'::timestamp with time zone, -- 시작 시간
        '2026-01-28 18:15:59+09'::timestamp with time zone, -- 종료 시간
        -- 분, 시, 요일 등은 모두 True로 열어두고 start/end 시간으로 제어합니다.
        '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::boolean[],
        -- Hours
	    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
	    -- Week days
	    '{f,f,f,f,f,f,f}'::bool[]::boolean[],
	    -- Month days
	    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
	    -- Months
	    '{f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[]
    ) RETURNING jscid INTO scid;

    RAISE NOTICE '테스트 스케줄러 등록 완료. Job ID: %', jid;
END;
$$;