

--1. 기본 조회
SELECT * FROM fms.chick_info; 

--2. 조건 필터링
SELECT * FROM fms.chick_info WHERE gender = 'F'; 

--3. 정렬 및 제한
SELECT * FROM fms.chick_info WHERE egg_weight >= 68 ORDER BY egg_weight DESC LIMIT 7 OFFSET 1;

--4. 날짜 범위
SELECT * FROM fms.chick_info WHERE hatchday BETWEEN '2023-01-01' AND '2023-01-02'; 

--5. NULL 처리
SELECT * FROM fms.env_cond WHERE humid IS NULL; 

--6. 패턴 검색
SELECT * FROM fms.chick_info WHERE breeds LIKE 'C%'; 

--7. 조인 활용
SELECT a.chick_no, b.body_temp FROM fms.chick_info a JOIN fms.health_cond b ON a.chick_no = b.chick_no WHERE b.check_date = '2023-01-30'; 

--8. 집계 함수
SELECT farm, ROUND(AVG(egg_weight),2) AS avg_weight FROM fms.chick_info GROUP BY farm;

--9. 그룹 필터링
SELECT customer, COUNT(*) 
FROM fms.ship_result 
GROUP BY customer HAVING COUNT(*) >= 10;

--10. 서브쿼리
SELECT * FROM fms.chick_info 
WHERE egg_weight > (SELECT AVG(egg_weight) FROM fms.chick_info);

--11. CASE 문
SELECT chick_no, raw_weight,
  CASE 
    WHEN raw_weight < 1000 THEN 'S'
    WHEN raw_weight BETWEEN 1000 AND 1100 THEN 'M'
    ELSE 'L' 
  END AS grade
FROM fms.prod_result;

--12. UNION
SELECT * FROM fms.chick_info 
WHERE farm='A' AND gender='M'
UNION
SELECT * FROM fms.chick_info 
WHERE farm='B' AND gender='F';

--13. 날짜 함수
SELECT chick_no, TO_CHAR(hatchday, 'YYYY년 MM월 DD일') 
FROM fms.chick_info;

--14. 복합 조인
SELECT s.* 
FROM fms.ship_result s
JOIN fms.prod_result p ON s.chick_no = p.chick_no
WHERE s.destination = '부산' AND p.pass_fail = 'P';

--15. 뷰 생성
CREATE VIEW fms.breeds_stats AS
SELECT breeds, COUNT(*) AS total, AVG(raw_weight) AS avg_weight
FROM fms.prod_result p
JOIN fms.chick_info c ON p.chick_no = c.chick_no
GROUP BY breeds;

SELECT * FROM fms.breeds_stats;

--16. 문자열 함수
SELECT chick_no, 
  CASE SUBSTR(chick_no,1,1)
    WHEN 'A' THEN 'A농장'
    WHEN 'B' THEN 'B농장'
  END AS farm_name
FROM fms.chick_info;

--17. 종합 쿼리
/* 2023-01-30일 기준
   (체온 41℃ 초과시 '주의', 45℃ 초과시 '위험' 표시) */
SELECT h.chick_no,
  CASE 
    WHEN body_temp > 45 THEN '위험'
    WHEN body_temp > 41 THEN '주의' 
    ELSE '정상'
  END AS status
FROM fms.health_cond h
WHERE check_date = '2023-01-30';

--18. 병아리 생산 합격률 계산
SELECT c.farm,
       COUNT(CASE WHEN p.pass_fail = 'P' THEN 1 END) * 100.0 / COUNT(*) AS pass_rate
FROM prod_result p
JOIN chick_info c ON p.chick_no = c.chick_no
GROUP BY c.farm;

--19. 특정 농장 생산 합격 생닭제품의 출하 목적지별 합계 보기
CREATE OR REPLACE VIEW fms.view_farm_ship_summary AS
SELECT 
ci.farm,
sr.customer,
COUNT(*) AS shipped_count
FROM fms.prod_result pr
JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
WHERE pr.pass_fail = 'P'
GROUP BY ci.farm, sr.customer;

SELECT * 
FROM fms.view_farm_ship_summary
WHERE farm = 'A';

-- 20
SELECT
prod_date,
SUM(CASE WHEN farm = 'A' THEN 1 ELSE 0 END) AS "Farm A",
SUM(CASE WHEN farm = 'B' THEN 1 ELSE 0 END) AS "Farm B",
SUM(CASE WHEN farm = 'C' THEN 1 ELSE 0 END) AS "Farm C"
FROM (
SELECT pr.prod_date, ci.farm
FROM fms.prod_result pr
JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
) AS sub
GROUP BY prod_date
ORDER BY prod_date;


CREATE VIEW fms.brees_state AS
SELECT breeds, count(*) AS total, AVG(raw_weight) AS avg_weight
FROM fms.CHICK_INFO c
JOIN fms.PROD_RESULT p ON c.CHICK_NO=p.CHICK_NO
GROUP BY breeds;


-- 트랜잭셕 테스트
SELECT * FROM fms.MASTER_CODE;

SELECT * FROM fms.MASTER_CODE WHERE column_nm='breeds';

INSERT INTO  fms.MASTER_CODE(COLUMN_NM, TYPE, code, code_desc)
VALUES ('size_stand', 'number', 9, '9호'),
('size_stand', 'number', 8, '8호'),
('size_stand', 'number', 7, '7호');

UPDATE fms.MASTER_CODE
SET code_desc='Female'
WHERE column_nm='gender' AND code='F';

INSERT INTO  fms.MASTER_CODE(COLUMN_NM, TYPE, code, code_desc)
VALUES ('breeds', 'txt', 'R1', 'Ross');


SELECT * FROM fms.MASTER_CODE;

BEGIN;
UPDATE fms.MASTER_CODE
SET code_desc='암컷'
WHERE column_nm='gender' AND code='F';
SAVEPOINT my_savepoint;
DELETE FROM fms.MASTER_CODE 
WHERE column_nm='size_stand' AND to_number(code, '99') < 10;
ROLLBACK TO my_savepoint;
COMMIT;

ROLLBACK;


-- 함수
CREATE OR REPLACE FUNCTION one()
RETURNS integer AS $$
 select 1;
$$ LANGUAGE SQL;

SELECT one();

CREATE OR REPLACE FUNCTION add_num(x integer, y integer)
RETURNS integer AS $$
 select x+y;
$$ LANGUAGE SQL;

SELECT add_num(3,4);


CREATE OR REPLACE FUNCTION fms.get_chick_count()
RETURNS integer AS $$
 select count(*) from fms.chick_info;   -- 테이블의 전체 닭 개수를 리턴
$$ LANGUAGE SQL;

SELECT get_chick_count();

CREATE OR REPLACE FUNCTION fms.get_chick_count2()
RETURNS integer AS $$
DECLARE
result integer;
BEGIN
 select count(*) into result from fms.chick_info;   -- 테이블의 전체 닭 개수를 리턴
RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT get_chick_count2();


CREATE OR REPLACE FUNCTION fms.get_chickinfo(chick_no varchar)
RETURNS NUMERIC AS $$
	select egg_weight 
	from fms.chick_info
	where chick_info.chick_no = get_chickinfo.chick_no;   -- 특정 닭에 대한 종란 무게 리턴
$$ LANGUAGE SQL;

SELECT get_chickinfo('A2300004');

CREATE OR REPLACE FUNCTION fms.get_chickinfo2(chick_no varchar)
RETURNS NUMERIC AS $$
BEGIN
	RETURN(select egg_weight 
	from fms.chick_info
	where chick_info.chick_no = get_chickinfo2.chick_no);   -- 특정 닭에 대한 종란 무게 리턴
END;
$$ LANGUAGE plpgsql;

SELECT get_chickinfo2('A2300004');


CREATE OR REPLACE FUNCTION fms.weight_pass(weight NUMERIC)
RETURNS TEXT AS $$
BEGIN
	RETURN case
			when weight >= 40 then '합격'
			else '불합격'
			end;
END;
$$ LANGUAGE plpgsql;

SELECT weight_pass(39);


CREATE OR REPLACE FUNCTION fms.weight_grade(weight NUMERIC)
RETURNS TEXT AS $$
DECLARE 
result TEXT;
BEGIN
	if weight > 40 then
		result := 'Heavy';
	else
		result := 'Normal';
	end if;
	RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT weight_grade(39);


CREATE OR REPLACE FUNCTION print_loop(n INTEGER)
RETURNS VOID AS $$
DECLARE 
i INTEGER :=1;
BEGIN
	while i <= n loop
		raise notice 'Loop: %', i;
		i := i +1;
	end loop;
END;
$$ LANGUAGE plpgsql;

SELECT print_loop(10);




CREATE OR REPLACE FUNCTION multi_return(in_no INTEGER)
RETURNS TABLE(num1 INTEGER, num2 TEXT) AS $$

BEGIN
	RETURN QUERY SELECT in_no, CAST(in_no as text) || 'is text';
END;
$$ LANGUAGE plpgsql;

SELECT multi_return(10);


CREATE OR REPLACE FUNCTION fms.get_chickinfo_table2()
RETURNS TABLE (chick_no VARCHAR, egg_weight NUMERIC) AS $$
BEGIN
	RETURN QUERY (select chick_no, egg_weight from fms.chick_info);   -- 특정 닭에 대한 종란 무게 리턴
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_chickinfo_table2();


CREATE OR REPLACE VIEW fms.view_farm_ship_summary AS
SELECT 
ci.farm,
sr.customer,
COUNT(*) AS shipped_count
FROM fms.prod_result pr
JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
WHERE pr.pass_fail = 'P'
GROUP BY ci.farm, sr.customer;

SELECT * 
FROM fms.view_farm_ship_summary
WHERE farm = 'A';


CREATE OR REPLACE FUNCTION fms.func_farm_ship_summary(farm_param varchar)
RETURNS TABLE(farm varchar, customer varchar, shipped_count BIGINT) AS $$
	SELECT 
	ci.farm,
	sr.customer,
	COUNT(*) AS shipped_count
	FROM fms.prod_result pr
	JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
	JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
	WHERE pr.pass_fail = 'P' and ci.farm = farm_param
	GROUP BY ci.farm, sr.customer;   
$$ LANGUAGE SQL;

SELECT * from fms.func_farm_ship_summary('A');
SELECT * from fms.func_farm_ship_summary('B');


DO $$
DECLARE
 file_path text;
BEGIN
	file_path := 'C:/Users/Public/farm_ship_summary_' || to_char(now(),'YYYYMMDD_HH24MISS') || '.csv';
	EXECUTE format(
		'COPY (SELECT * from fms.func_farm_ship_summary(''A'')) TO %L CSV HEADER', file_path
	);
END
$$;

-- 특정 품종의 병아리 수 카운트 하는 함수
SELECT count(*)
FROM fms.chick_info
WHERE breeds = 'C1';

SELECT fms.count_by_breeds('C1'); -- 40


--------------------------------------------------
CREATE TABLE fms.health_cond_audit(
audit_id SERIAL PRIMARY KEY,
chick_no varchar(20) NOT null,
old_body_temp NUMERIC(4, 1),
new_body_temp NUMERIC(4, 1),
check_date date,
modified_at timestamp DEFAULT CURRENT_TIMESTAMP,
operation varchar(10)
);


CREATE OR REPLACE FUNCTION fms.log_health_changes()
RETURNS TRIGGER AS $$
BEGIN
	RAISE NOTICE '트리거 호출됨. TG_OP = %', TG_OP;

	IF TG_OP = 'UPDATE' THEN
		RAISE NOTICE 'UPDATE 트리거 실행 중: % -> %', OLD.body_temp, NEW.body_temp;
		insert into fms.health_cond_audit
		(chick_no, old_body_temp, new_body_temp, check_date, operation)
		VALUES(
		OLD.chick_no, 
		OLD.body_temp, 
		NEW.body_temp, 
		NEW.check_date,
		TG_OP
		);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER health_audit_trigger
AFTER UPDATE ON fms.health_cond
FOR EACH ROW
EXECUTE FUNCTION fms.log_health_changes();


UPDATE fms.health_cond
SET body_temp = 40.1
WHERE chick_no = 'A2300013' AND check_date = '2023-01-10';


-- 트리거 만들기
env_cond 환경을 관리하는 테이블에 이상 데이터가 입력될 때 이러한 이상치를 감지 하는 트리거

예를 들어
INSERT INTO fms.env_cond 
(farm, date, temp, humid) 
VALUES ('B', '2023-01-25', 21, 60); --> 로그기록안됨

INSERT INTO fms.env_cond 
(farm, date, temp, humid) 
VALUES ('B', '2023-01-25', 21, 85);
와 같이 너무 높은 습도가 입력이 되면 트리거함수가 동작하면서 
이상치를 감지하는 테이블에 아래와 같이 데이터가 입력된다. 
reason 컬럼에는 조건문을 통해 특정 습도보다 높으면 '습도 과다'
혹은 특정 온도보다 높으면 '고온 다습'

anomaly_id  farm 	check_date 	temp 	humid 	reason 		detected_at
(자동증가)		'B' 	2023-01-25 	21 		85 		'습도 과다' 	(현재 시각, 자동 입력)


CREATE OR REPLACE FUNCTION detect_unhealthy_chick(chick_id text)
RETURNS boolean AS $$
DECLARE
temp_check numeric;
feed_check numeric;
BEGIN
SELECT body_temp, feed_intake INTO temp_check, feed_check
FROM fms.health_cond
WHERE chick_no = chick_id
ORDER BY check_date DESC LIMIT 1;
RETURN (temp_check > 41.7 OR feed_check < 100);
END;
$$ LANGUAGE plpgsql;

SELECT detect_unhealthy_chick('B2300009');



SELECT * FROM fms.total_result;

SELECT datname, pg_encoding_to_char(encoding), datcollate, datctype FROM pg_database;

SHOW server_encoding;

SHOW data_directory;


-- 프로시저
INSERT INTO fms.BREEDS_PROD_TBL(prod_date, breeds_nm, total_sum,save_time)
(
SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time 
FROM fms.breeds_prod
WHERE prod_date = '2023-01-31'
);


CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc()
AS $$
	INSERT INTO fms.BREEDS_PROD_TBL(prod_date, breeds_nm, total_sum,save_time)
	(
	SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time 
	FROM fms.breeds_prod
	WHERE prod_date = '2023-02-01'
	);
$$ LANGUAGE SQL;

CALL fms.breeds_prod_proc();



------------------------------------------------------------------------
-------------------------------------------------------------------------
-- 품종 이름을 기준으로 병아리 수를 반환
CREATE OR REPLACE FUNCTION fms.count_by_breed(breed_name VARCHAR)
RETURNS INTEGER AS $$
DECLARE
  count_result INTEGER;
BEGIN
  SELECT COUNT(*) INTO count_result
  FROM fms.chick_info
  WHERE breeds = breed_name;

  RETURN count_result;
END;
$$ LANGUAGE plpgsql;

SELECT fms.count_by_breed('C1');



-- 원래 프로시저는 위와 같았는데 아래처럼 바꾸었음

CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc(date_param date)
AS $$
	INSERT INTO fms.BREEDS_PROD_TBL(prod_date, breeds_nm, total_sum,save_time)
	(
	SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time 
	FROM fms.breeds_prod
	WHERE prod_date = date_param
	);
$$ LANGUAGE SQL;

CALL fms.breeds_prod_proc('2023-02-01');

-- 위의 프로시저를 굳이 함수로 바꾸어보자. 이때 테이블에 집어넣는거 말고 걍 조회한 데이터를 리턴하도록 수정한다. 

CREATE OR REPLACE FUNCTION fms.breeds_prod_func(date_param date)
RETURNS VOID
AS $$
	INSERT INTO fms.BREEDS_PROD_TBL(prod_date, breeds_nm, total_sum,save_time)
	(
	SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time 
	FROM fms.breeds_prod
	WHERE prod_date = date_param
	);
$$ LANGUAGE SQL;

select fms.breeds_prod_func('2023-02-01');
select fms.breeds_prod_func(CURRENT_DATE);

-- 위의 프로시저를 굳이 함수로 바꾸어보자. 이때 테이블에 집어넣는거 말고 걍 조회한 데이터를 리턴하도록 수정한다. 

--  오류: 이미 있는 함수의 리턴 자료형은 바꿀 수 없습니다
--  Detail: OUT 매개 변수에 정의된 행 형식이 다릅니다.
--  Hint: 먼저 DROP FUNCTION fms.breeds_prod_functocsv(date) 명령을 사용하세요.
DROP FUNCTION fms.breeds_prod_functocsv(date);

CREATE OR REPLACE FUNCTION fms.breeds_prod_functocsv(date_param date)
RETURNS TABLE (prod_date date, breeds_nm varchar, total_sum bigint, save_time timestamp)
AS $$
	SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time 
	FROM fms.breeds_prod
	WHERE prod_date = date_param;
$$ LANGUAGE SQL;

SELECT * from fms.breeds_prod_functocsv('2023-02-01');

-- 오늘 생산된 품종별 합계
SELECT CURRENT_DATE;
select * FROM fms.breeds_prod_functocsv(CURRENT_DATE);

-- 아래의 코드를 잡 스케줄러 코드 부분에 집어 넣으면 SELECT 한 결과값이 파일로 저장된다.
-- 단 파일경로는 Permission Denied를 고려해 C:/Users/Public으로 지정했다. 
COPY(SELECT * from fms.breeds_prod_functocsv('2023-02-01')) TO 'C:/Users/Public/breeds_prod_summary.csv' CSV HEADER;

-----------------------------------------------------------
-- 저장되는 파일에 날자 붙이기 

DO $$
DECLARE
    file_path text;
BEGIN
    file_path := 'C:/Users/Public/breeds_prod_summary_' || to_char(now(), 'YYYYMMDD_HH24MISS') || '.csv';
    EXECUTE format(
        'COPY (SELECT * FROM fms.breeds_prod_functocsv(''2023-02-01'')) TO %L CSV HEADER',
        file_path
    );
END$$;


-- 오늘날짜에 생산된 품종별 데이터를 저장하도록 하기 
DO $$
DECLARE
    file_path text;
    today_str text;
BEGIN
    -- 현재 날짜를 'YYYY-MM-DD' 형식의 문자열로 변환
    today_str := to_char(CURRENT_DATE, 'YYYY-MM-DD');
    -- 파일명에 현재 날짜+시간을 붙임
    file_path := 'C:/Users/Public/breeds_prod_summary_' || to_char(now(), 'YYYYMMDD_HH24MISS') || '.csv';
    -- 함수 호출 시 today_str 사용
    EXECUTE format(
        'COPY (SELECT * FROM fms.breeds_prod_functocsv(''%s'')) TO %L CSV HEADER',
        today_str, file_path
    );
END$$;

--설명
--today_str := to_char(CURRENT_DATE, 'YYYY-MM-DD'):
--오늘 날짜를 'YYYY-MM-DD' 형식의 문자열로 변환합니다.
--
--file_path:
--파일명에 현재 날짜+시간을 붙여서 고유한 파일명을 만듭니다.
--
--EXECUTE format(...):
--함수 파라미터와 파일 경로를 동적으로 지정합니다.
-- 만약 "어제" 데이터를 처리하고 싶다면 today_str := to_char(CURRENT_DATE - INTERVAL '1 day', 'YYYY-MM-DD')로 변경하면 됩니다

--오늘(2025-05-07)을 기준으로 오늘까지 최근 7일(즉, 2025-05-01부터 2025-05-07까지)의 데이터를 저장하려면,
--prod_date가 CURRENT_DATE - INTERVAL '6 days' 이상, CURRENT_DATE 이하인 데이터를 추출
DO $$
DECLARE
    file_path text;
    start_date date := CURRENT_DATE - INTERVAL '6 days';
    end_date date := CURRENT_DATE;
BEGIN
    file_path := 'C:/Users/Public/breeds_prod_summary_' 
                 || to_char(start_date, 'YYYYMMDD') 
                 || '_' 
                 || to_char(end_date, 'YYYYMMDD') 
                 || '.csv';
    EXECUTE format(
        $$COPY (
            SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
            FROM fms.breeds_prod
            WHERE prod_date BETWEEN '%s' AND '%s'
        ) TO %L CSV HEADER$$,
        start_date, end_date, file_path
    );
END$$;


-- 함수코드는 단순한데 스케줄러 등록 코드가 너무 복잡해서 변경중
CREATE OR REPLACE FUNCTION fms.breeds_prod_functocsvdays(
    start_date date, 
    end_date date
)
RETURNS TABLE (
    prod_date date, 
    breeds_nm varchar, 
    total_sum bigint, 
    save_time timestamp
) AS $$
    SELECT 
        prod_date, 
        breeds_nm, 
        total_sum, 
        CURRENT_TIMESTAMP AS save_time 
    FROM fms.breeds_prod
    WHERE prod_date BETWEEN start_date AND end_date; -- 기간 검색으로 변경
$$ LANGUAGE SQL;

SELECT * from fms.breeds_prod_functocsvdays('2023-01-31','2023-02-02' );

-- 잡 스케줄러 코드
DO $$
DECLARE
    file_path text;
BEGIN
    file_path := 'C:/Users/Public/breeds_prod_summary_' 
                 || to_char(CURRENT_DATE - 6, 'YYYYMMDD')  -- 7일 전
                 || '_' 
                 || to_char(CURRENT_DATE, 'YYYYMMDD')      -- 오늘
                 || '.csv';
    EXECUTE format(
        'COPY (SELECT * FROM fms.breeds_prod_functocsvdays(''%s''::date, ''%s''::date)) TO %L CSV HEADER',
        CURRENT_DATE - 6,  -- 시작일 (7일 전)
        CURRENT_DATE,      -- 종료일 (오늘)
        file_path
    );
END$$;


-- 아래는 어쩔 수 없는 테스트 용
DO $$
DECLARE
    file_path text;
BEGIN
    file_path := 'C:/Users/Public/breeds_prod_summary_' 
                 || to_char(CURRENT_DATE - 6, 'YYYYMMDD')  -- 7일 전
                 || '_' 
                 || to_char(CURRENT_DATE, 'YYYYMMDD')      -- 오늘
                 || '.csv';
    EXECUTE format(
        'COPY (SELECT * FROM fms.breeds_prod_functocsvdays(''%s''::date, ''%s''::date)) TO %L CSV HEADER',
        '2023-01-31',  -- 시작일 (7일 전)
        '2023-02-02',      -- 종료일 (오늘)
        file_path
    );
END$$;

-- 정리하기
--2. 잡 스케줄러 등록 시 효율성 비교
--A. 함수 사용
--장점:
--단순 데이터 조회, 집계, 결과 반환에 적합.
--잡에서 COPY (SELECT * FROM 함수(…)) TO ...로 바로 사용 가능.
--
--단점:
--파일명에 동적으로 날짜를 붙이거나, 파일 저장 로직을 함수 내부에 넣을 수 없음.
--함수 내부에서 직접적으로 파일로 저장(COPY TO)은 불가.
--
--B. 프로시저 사용
--장점:
--프로시저 내부에서 동적 파일명 생성, COPY TO 등 파일 저장 로직을 구현할 수 있음.
--트랜잭션 제어, 로깅, 에러 처리 등 복잡한 작업 가능.
--잡 스케줄러에는 CALL 프로시저명(…)만 등록하면 끝!
--
--단점:
--결과를 직접 반환하지 않으므로, 단순 조회에는 부적합.
--SELECT로 결과를 바로 볼 수 없음.
--
--3. 결론 및 추천
--단순히 데이터 조회 결과를 잡에서 파일로 저장(COPY)할 때:
--→ 함수 + 잡에서 COPY 사용이 간단하고 효율적입니다.
--
--파일명에 날짜 붙이기, 동적 파일명, 파일 저장 로직, 트랜잭션 제어, 에러처리 등 복잡한 작업이 필요할 때:
--→ 프로시저 내부에서 파일 저장까지 처리하는 것이 효율적입니다.

-- 프로시저 예시
CREATE OR REPLACE PROCEDURE fms.breeds_prod_export_proc(start_date date, end_date date)
LANGUAGE plpgsql
AS $$
DECLARE
    file_path text;
BEGIN
    file_path := 'C:/Users/Public/breeds_prod_summary_' 
                 || to_char(start_date, 'YYYYMMDD') 
                 || '_' 
                 || to_char(end_date, 'YYYYMMDD') 
                 || '.csv';
    EXECUTE format(
        'COPY (SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
               FROM fms.breeds_prod
               WHERE prod_date BETWEEN %L AND %L) TO %L CSV HEADER',
        start_date, end_date, file_path
    );
END;
$$;

CALL fms.breeds_prod_export_proc('2023-01-31','2023-02-02');

-- 잡 스케줄러 등록:
CALL fms.breeds_prod_export_proc(CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE);

--요약
--단순 데이터 추출 및 파일 저장: 함수 + 잡에서 COPY (간단, 빠름)
--동적 파일명, 파일 저장 로직, 트랜잭션 등: 프로시저 (더 유연, 복잡한 로직 가능)
--복잡한 파일 저장 및 자동화가 필요하다면 프로시저가 더 효율적입니다!
--단순 저장이면 함수+COPY로도 충분합니다.

-- 이걸로 진행
-- 이번에는 기존에 뷰를 함수로 만들었던 함수를 잡 스케줄러로 등록해보자
CREATE OR REPLACE FUNCTION fms.func_farm_ship_summary(farm_param varchar)
RETURNS TABLE(farm varchar, customer varchar, shipped_count BIGINT) AS $$
	SELECT 
	ci.farm,
	sr.customer,
	COUNT(*) AS shipped_count
	FROM fms.prod_result pr
	JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
	JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
	WHERE pr.pass_fail = 'P' and ci.farm = farm_param
	GROUP BY ci.farm, sr.customer;   
$$ LANGUAGE SQL;

SELECT * from fms.func_farm_ship_summary('A');
SELECT * from fms.func_farm_ship_summary('B');

---------------------------------------------
-- 아래의 코드를 잡 스케줄러 코드 부분에 집어 넣으면 SELECT 한 결과값이 파일로 저장된다.
-- 단 파일경로는 Permission Denied를 고려해 C:/Users/Public으로 지정했다. 
COPY(SELECT * from fms.func_farm_ship_summary('A')) TO 'C:/Users/Public/farm_ship_summary.csv' CSV HEADER;

--날짜/시간이 파일명에 붙도록 처리한 코드
-- 'A'는 함수 인자이므로 홑 따옴표 두번(''A'')로 이스케이프 처리함
DO $$
DECLARE
    file_path text;
BEGIN
    file_path := 'C:/Users/Public/farm_ship_summary_' || to_char(now(), 'YYYYMMDD_HH24MISS') || '.csv';
    EXECUTE format(
        'COPY (SELECT * FROM fms.func_farm_ship_summary(''A'')) TO %L CSV HEADER',
        file_path
    );
END
$$;

---------------------------------------
--아래와 같이 동적 파일명 생성과 농장(A, B)별 CSV 저장을 처리하는 PL/pgSQL 코드를 작성할 수 있습니다.
--잡 스케줄러에 이 코드를 등록하면 매 실행 시점에 오늘 날짜와 시간이 포함된 파일명으로 데이터가 저장됩니다.

DO $$
DECLARE
    file_path text;
    current_time_str text := to_char(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS');
    farm_list text[] := ARRAY['A', 'B']; -- 농장 리스트
    farm_name text;
BEGIN
    FOREACH farm_name IN ARRAY farm_list LOOP
        -- 파일 경로 생성 (예: C:/Users/Public/farm_A_20250507_143015.csv)
        file_path := 'C:/Users/Public/farm_' || farm_name || '_' || current_time_str || '.csv';
        
        -- 동적 COPY 실행
        EXECUTE format(
            $COPY$
                COPY (
                    SELECT * 
                    FROM fms.func_farm_ship_summary('%s')
                ) TO '%s' CSV HEADER;
            $COPY$,
            farm_name, file_path
        );
    END LOOP;
END$$;

--코드 설명
--동적 파일명 생성
--current_time_str 변수에 현재 날짜와 시간을 YYYYMMDD_HH24MISS 형식으로 저장합니다.
--(예: 20250507_143015)
--file_path에 농장명(farm_name)과 타임스탬프를 조합해 파일 경로를 생성합니다.
--
--농장별 처리
--farm_list 배열에 저장된 농장('A', 'B')을 순회하며 각각의 데이터를 추출합니다.
--동적 COPY 실행
--EXECUTE format(...)을 사용해 농장명과 파일 경로를 동적으로 전달합니다.
--
--실행 결과 예시
--파일명:
--C:/Users/Public/farm_A_20250507_143015.csv
--C:/Users/Public/farm_B_20250507_143015.csv

--주의사항
--파일 경로 권한: PostgreSQL 서비스 계정이 C:/Users/Public/에 쓰기 권한이 있는지 확인합니다.
--타임존: CURRENT_TIMESTAMP는 서버의 타임존을 기준으로 합니다. 필요시 AT TIME ZONE으로 조정합니다.
--농장 리스트 확장: farm_list 배열에 농장을 추가하면 자동으로 확장됩니다.
--이 코드를 잡 스케줄러에 등록하면 매일 지정된 시간에 농장별 데이터가 CSV로 저장됩니다!
---------------------------------------
CREATE OR REPLACE VIEW fms.view_farm_ship_summary AS
SELECT 
ci.farm,
sr.customer,
COUNT(*) AS shipped_count
FROM fms.prod_result pr
JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
WHERE pr.pass_fail = 'P'
GROUP BY ci.farm, sr.customer;

SELECT * 
FROM fms.view_farm_ship_summary
WHERE farm = 'A';
---------------------------------------------------

-- 기존 뷰를 함수로 변경했던거 말고 걍 뷰를 함수 내부에서 호출해서 사용하도록 
CREATE OR REPLACE FUNCTION fms.get_farm_ship_summary_view(farm_param VARCHAR)
RETURNS TABLE (
    farm VARCHAR,
    customer VARCHAR,
    shipped_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.farm,
        v.customer,
        v.shipped_count
    FROM fms.view_farm_ship_summary v  -- 뷰 호출
    WHERE v.farm = farm_param;
END;
$$ LANGUAGE plpgsql;

-- 함수 호출
SELECT * FROM fms.get_farm_ship_summary_view('A');
------------------------------------------------------

CREATE OR REPLACE FUNCTION fms.get_farm_ship_summary_view(farm_param VARCHAR)
RETURNS TABLE (
    farm VARCHAR,
    customer VARCHAR,
    shipped_count BIGINT
) 
AS $$
    SELECT 
        v.farm,
        v.customer,
        v.shipped_count
    FROM fms.view_farm_ship_summary v  -- 뷰 호출
    WHERE v.farm = farm_param;
$$ LANGUAGE SQL;

SELECT * FROM fms.get_farm_ship_summary_view('A');

--3. 기존 함수와의 차이점
--기존 함수: 테이블 3개를 직접 조인.
--뷰 기반 함수: 뷰를 통해 이미 정의된 쿼리 재사용.
--장점: 뷰의 쿼리 변경 시 함수 코드 수정 없이 자동 반영.
--
--4. 성능 고려사항
--뷰 성능: 뷰는 매번 쿼리를 실행하므로, 대량 데이터 시 MATERIALIZED VIEW 사용 권장.
--인덱스 추가: 뷰의 기반 테이블에 farm 컬럼 인덱스 생성.
--
--CREATE INDEX idx_farm ON fms.chick_info(farm);
--
--5. 확장성
--동적 필터링: 뷰를 기반으로 추가 조건(예: customer LIKE 'C%')을 쉽게 추가할 수 있습니다.
--권한 관리: 뷰를 통해 특정 컬럼만 노출시켜 보안 강화 가능.
--
--결론
--뷰를 함수에서 호출하는 것은 코드 재사용성과 유지보수성 측면에서 유리합니다.
--단, 대량 데이터 처리 시에는 MATERIALIZED VIEW 또는 인덱스 최적화가 필요합니다.

--주의사항
--뷰 존재 여부: view_farm_ship_summary 뷰가 미리 생성되어 있어야 합니다.
--성능: 뷰 쿼리가 복잡하면 함수 실행 속도에 영향을 줄 수 있습니다.
--(필요시 MATERIALIZED VIEW 사용 권장)

--벗 그러나 하지만 위의 경우에는 뷰함수로 사용하건 함수로 만들건 함수에서 뷰를 불러서 사용하건 성능의 차이는 어짜피 없음
--함수 vs. 뷰 기반 함수: 실행 방식
--1. 기존 함수 (직접 조인)
--CREATE FUNCTION func_farm_ship_summary(...) 
--AS $$
--    SELECT ... FROM prod_result, chick_info, ship_result -- 매번 3개 테이블 조인
--$$ LANGUAGE SQL;
--
--실행 과정:
--함수 호출 → 3개 테이블 조인 → 결과 반환
--→ 매번 모든 테이블을 조인합니다.
--
--2. 뷰 기반 함수
--CREATE VIEW view_farm_ship_summary AS 
--    SELECT ... FROM prod_result, chick_info, ship_result; -- 뷰 정의
--
--CREATE FUNCTION func_using_view(...) 
--AS $$
--    SELECT * FROM view_farm_ship_summary -- 뷰 조회
--$$ LANGUAGE SQL;
--
--실행 과정:
--함수 호출 → 뷰 쿼리 실행(3개 테이블 조인) → 결과 반환
--→ 뷰도 매번 3개 테이블을 조인합니다.
--
--차이점: 쿼리 실행 횟수 ❌, 코드 관리 ⭕
--1. 실행 성능
--동일합니다.
--두 방식 모두 매번 실제 테이블에서 데이터를 조회합니다.
--(뷰는 쿼리의 별칭일 뿐, 성능에 직접적인 영향 없음)
--
--2. 차이 발생 조건
--뷰 쿼리 변경 시:
--뷰 기반 함수는 뷰 정의만 수정하면 모든 함수에 반영됩니다.
--
--기존 함수는 각 함수의 쿼리를 직접 수정해야 합니다.
--→ 유지보수성에서 차이가 납니다.
--
--성능 최적화 방법 (공통)
--1. 인덱스 추가
--두 방식 모두 기반 테이블의 인덱스가 중요합니다.
--예: prod_result.pass_fail, chick_info.farm 컬럼에 인덱스 생성.
--
--2. MATERIALIZED VIEW
--자주 변경되지 않는 데이터라면,
--뷰 또는 함수 대신 MATERIALIZED VIEW를 생성해 결과를 캐싱할 수 있습니다.
--(주기적 Refresh 필요)
--
--3. 파티셔닝
--대량 데이터의 경우 테이블을 파티셔닝해 성능을 개선할 수 있습니다.
--
--결론
--뷰 사용 이유: 코드 중복 제거, 유지보수성 향상.
--성능 개선: 인덱스/MATERIALIZED VIEW로 해결.
--
--함수 vs. 뷰 선택:
--단순 조회: 뷰 기반 함수 (유지보수 용이)
--복잡한 로직: 직접 조인 함수 (유연성 높음)
--둘 다 매번 쿼리를 실행하므로, 성능 차이는 인덱스 최적화에 달려 있습니다!
-------------------------------------------------------

SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time 
FROM fms.breeds_prod
WHERE prod_date = '2023-02-01';

DELETE FROM fms.BREEDS_PROD_TBL;

--------------------------------------------------------
-- 트리거를 사용해 보자
1. 건강 상태 변경 감지 트리거
기능: health_cond 테이블 업데이트 시 변경 이력 자동 기록

2. 생산 불합격 자동 알림 트리거
기능: prod_result 테이블에 불합격(F) 발생 시 관리자 알림

3. 환경 데이터 이상 감지 트리거
기능: env_cond 테이블 삽입 시 습도 이상 자동 감지

실습진행시 3번으로 진행하자!!!

--1. 건강 상태 변경 감지 트리거
--기능: health_cond 테이블 업데이트 시 변경 이력 자동 기록

-- 1. 감사 로그 테이블 생성
CREATE TABLE fms.health_cond_audit (
    audit_id SERIAL PRIMARY KEY,
    chick_no VARCHAR(20) NOT NULL,
    old_body_temp NUMERIC(4,1),
    new_body_temp NUMERIC(4,1),
    check_date DATE,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation VARCHAR(10)
);

-- 2. 트리거 함수 정의
CREATE OR REPLACE FUNCTION fms.log_health_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO fms.health_cond_audit 
        (chick_no, old_body_temp, new_body_temp, check_date, operation)
        VALUES (
            OLD.chick_no, 
            OLD.body_temp, 
            NEW.body_temp, 
            NEW.check_date, 
            TG_OP
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. 트리거 등록
CREATE TRIGGER health_audit_trigger
AFTER UPDATE ON fms.health_cond
FOR EACH ROW
EXECUTE FUNCTION fms.log_health_changes();


-- 실행 결과 예시
UPDATE fms.health_cond 
SET body_temp = 41.8 
WHERE chick_no = 'B2310019' AND check_date = '2023-01-30';

SELECT * FROM fms.health_cond_audit;

2. 생산 불합격 자동 알림 트리거
기능: prod_result 테이블에 불합격(F) 발생 시 관리자 알림

-- 1. 알림 테이블 생성
CREATE TABLE fms.prod_alert (
    alert_id SERIAL PRIMARY KEY,
    chick_no VARCHAR(20),
    prod_date DATE,
    raw_weight NUMERIC(6,2),
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 트리거 함수 정의
CREATE OR REPLACE FUNCTION fms.notify_prod_fail()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pass_fail = 'F' THEN
        INSERT INTO fms.prod_alert 
        (chick_no, prod_date, raw_weight, reason)
        VALUES (
            NEW.chick_no,
            NEW.prod_date,
            NEW.raw_weight,
            '품질 검사 불합격: ' || 
            (SELECT code_desc FROM fms.master_code 
             WHERE column_nm = 'pass_fail' AND code = NEW.pass_fail)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. 트리거 등록
CREATE TRIGGER prod_fail_trigger
AFTER INSERT OR UPDATE ON fms.prod_result
FOR EACH ROW
EXECUTE FUNCTION fms.notify_prod_fail();


--실행 결과 예시
UPDATE fms.prod_result 
SET pass_fail = 'F' 
WHERE chick_no = 'B2310019';

SELECT * FROM fms.prod_alert;


3. 환경 데이터 이상 감지 트리거
기능: env_cond 테이블 삽입 시 습도 이상 자동 감지

-- 1. 이상 로그 테이블 생성
CREATE TABLE fms.env_anomaly (
    anomaly_id SERIAL PRIMARY KEY,
    farm CHAR(1),
    check_date DATE,
    temp NUMERIC(3,0),
    humid NUMERIC(3,0),
    reason TEXT,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 트리거 함수 정의
CREATE OR REPLACE FUNCTION fms.detect_env_anomaly()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.humid > 75 OR NEW.humid < 55 THEN
        INSERT INTO fms.env_anomaly 
        (farm, check_date, temp, humid, reason)
        VALUES (
            NEW.farm,
            NEW.date,
            NEW.temp,
            NEW.humid,
            CASE 
                WHEN NEW.humid > 75 THEN '습도 과다' 
                ELSE '습도 부족' 
            END
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. 트리거 등록
CREATE TRIGGER env_anomaly_trigger
BEFORE INSERT OR UPDATE ON fms.env_cond
FOR EACH ROW
EXECUTE FUNCTION fms.detect_env_anomaly();

실행 결과 예시:

INSERT INTO fms.env_cond 
(farm, date, temp, humid) 
VALUES ('B', '2023-01-25', 21, 85);

SELECT * FROM fms.env_anomaly;

--트리거 활용 팁
--성능 영향 분석: EXPLAIN ANALYZE로 트리거 실행 계획 확인
--중첩 트리거 방지: SET session_replication_role = replica;로 임시 비활성화
--에러 처리: EXCEPTION 블록 추가해 오류 로깅 가능
--트리거 목록 조회: SELECT * FROM pg_trigger WHERE tgname = 'trigger_name';
--
--⚠️ 트리거 내에서는 동일 테이블 수정 시 무한 루프 발생 가능성 있으므로 주의 필요


-- 데이터베이스 내 모든 트리거 목록 조회:
SELECT event_object_table AS table_name, trigger_name
FROM information_schema.triggers
GROUP BY table_name, trigger_name
ORDER BY table_name, trigger_name;

-- 트리거 삭제 기본 구문:
DROP TRIGGER [IF EXISTS] 트리거명 ON 테이블명 [CASCADE | RESTRICT];

DROP TRIGGER IF EXISTS env_anomaly_trigger ON fms.env_cond;
DROP TRIGGER IF EXISTS health_audit_trigger ON fms.health_cond;
DROP TRIGGER IF EXISTS prod_fail_trigger ON fms.prod_result;

UPDATE fms.health_cond
SET body_temp=45.2 WHERE chick_no='B2310019'AND check_date='2023-01-30';

UPDATE fms.health_cond
SET body_temp=41.7 WHERE chick_no='B2310019' AND check_date='2023-01-20';

UPDATE fms.health_cond
SET body_temp=40.6 WHERE chick_no='B2310019' AND check_date='2023-01-10';

UPDATE fms.MASTER_CODE
SET code_desc='Female'
WHERE column_nm='gender' AND code='F';