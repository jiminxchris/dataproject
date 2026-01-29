

CREATE OR REPLACE FUNCTION fms.log_health_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. 비정상 온도 감지 로직 (예: 43도 초과 또는 35도 미만)
    IF NEW.body_temp > 43.0 OR NEW.body_temp < 35.0 THEN
        
        -- 알람 메시지 출력
        RAISE NOTICE '[경고!] %의 체온이 비정상적으로 높거나 낮습니다: %도', NEW.chick_no, NEW.body_temp;
        
        -- 로그 테이블에 'DANGER'라는 태그 기록
        INSERT INTO fms.health_cond_audit 
        (chick_no, old_body_temp, new_body_temp, check_date, operation)
        VALUES (
            OLD.chick_no, 
            OLD.body_temp, 
            NEW.body_temp, 
            NEW.check_date, 
            'DANGER'
        );

    ELSE
        -- 2. 정상 범위인 경우 일반 기록
        INSERT INTO fms.health_cond_audit 
        (chick_no, old_body_temp, new_body_temp, check_date, operation)
        VALUES (
            OLD.chick_no, 
            OLD.body_temp, 
            NEW.body_temp, 
            NEW.check_date, 
            TG_OP -- 'UPDATE'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 실행 결과:
UPDATE fms.health_cond 
SET body_temp = 40.6 
WHERE chick_no = 'B2310019' AND check_date = '2023-01-10';

-- 이전 프로시저 업그레이드

CREATE OR REPLACE FUNCTION fms.log_prod_weight_auto()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. 비정상 범위 감지 (예: 3kg 초과 또는 100g 미만)
    -- 닭 무게가 3000g을 넘거나 100g보다 작으면 '위험'으로 간주
    IF NEW.raw_weight > 3000 OR NEW.raw_weight < 100 THEN
        
        -- 경고 (옵션)
        RAISE NOTICE '[경고] %의 무게가 비정상적입니다: %g', NEW.chick_no, NEW.raw_weight;

        -- 로그에 'DANGER'로 기록
        INSERT INTO fms.prod_log (
            chick_no, prod_date, old_weight, new_weight, logged_at, memo
        ) VALUES (
            NEW.chick_no, 
            NEW.prod_date, 
            OLD.raw_weight, 
            NEW.raw_weight, 
            NOW(), 
            'DANGER' -- 위험 태그
        );

    -- 2. 정상 범위인 경우
    ELSE
        -- 값이 실제로 변했을 때만 기록
        IF OLD.raw_weight IS DISTINCT FROM NEW.raw_weight THEN
            INSERT INTO fms.prod_log (
                chick_no, prod_date, old_weight, new_weight, logged_at, memo
            ) VALUES (
                NEW.chick_no, 
                NEW.prod_date, 
                OLD.raw_weight, 
                NEW.raw_weight, 
                NOW(), 
                '정상 업데이트' -- 정상 태그
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. 트리거 부착
CREATE TRIGGER trg_prod_weight_auto_log
AFTER UPDATE ON fms.prod_result
FOR EACH ROW
EXECUTE FUNCTION fms.log_prod_weight_auto();

CREATE OR REPLACE PROCEDURE fms.update_prod_weight_safe(
    p_chick_no VARCHAR,
    p_prod_date DATE,
    p_raw_weight NUMERIC
) AS $$
BEGIN
    -- 일단 업데이트를 시도
    -- (데이터가 있으면 -> 트리거가 발동해서 성공 로그 자동 저장됨)
    -- (데이터가 없으면 -> 아무 일도 안 일어남)
    UPDATE fms.prod_result
    SET raw_weight = p_raw_weight
    WHERE chick_no = p_chick_no AND prod_date = p_prod_date;

    -- 대상 없음
    IF NOT FOUND THEN
        -- 실패 로그는 트리거가 못 하므로 여기서 직접 남기기.
        INSERT INTO fms.prod_log (
            chick_no, prod_date, logged_at, memo
        ) VALUES (
            p_chick_no, p_prod_date, NOW(), '대상 없음: ' || p_chick_no
        );
        
        RAISE NOTICE '대상 데이터가 없어 실패 로그를 남겼습니다.';
    ELSE
        RAISE NOTICE '업데이트 성공 (로그는 트리거가 자동 저장함)';
    END IF;

    -- 트랜잭션 확정
    COMMIT;
    
END;
$$ LANGUAGE plpgsql;


-- Case 1: 없는 번호 (프로시저가 '대상 없음' 로그 남김)
CALL fms.update_prod_weight_safe('C2310014', '2023-01-25', 1500);

-- Case 2: 있는 번호 (업데이트 성공 -> 트리거가 '정상 업데이트' 로그 남김)
CALL fms.update_prod_weight_safe('B2300020', '2023-02-02', 1155);



CREATE TABLE public.users (
id SERIAL PRIMARY KEY,
name VARCHAR(100),
email VARCHAR(100),
signup_date DATE
);

INSERT INTO users (name, email, signup_date)
SELECT
'User ' || ((i % 100) + 1)::text,
'user' || i || '@example.com',
NOW() - (random() * (365 * 5) || ' days')::interval
FROM generate_series(1, 1000000) AS s(i);

EXPLAIN (ANALYZE, VERBOSE, buffers)
SELECT * FROM users WHERE name = 'User ' ||'77';

-- 병렬 처리 비활성화 (실습 환경 통일)
SHOW max_parallel_workers_per_gather; -- 2
SET max_parallel_workers_per_gather = 0;

EXPLAIN (ANALYZE, VERBOSE, buffers)
SELECT * FROM users WHERE id = 77;

EXPLAIN (ANALYZE, VERBOSE, buffers)
SELECT * FROM users WHERE id BETWEEN 77 AND 88;

EXPLAIN ANALYZE
SELECT * FROM users;

CREATE INDEX idx_users_name ON users (name);

CREATE INDEX IF NOT EXISTS idx_users_name_signup_date
    ON users("name", signup_date);

EXPLAIN (ANALYZE, VERBOSE, buffers)
SELECT * FROM users WHERE name = 'User ' ||'77' AND signup_date BETWEEN '2021-01-30' AND '2021-02-01';

EXPLAIN (ANALYZE, VERBOSE, buffers)
SELECT * FROM users WHERE signup_date BETWEEN '2021-01-30' AND '2021-02-01' AND name = 'User ' ||'77';

DROP INDEX IF EXISTS idx_users_name;

EXPLAIN ANALYZE
SELECT * FROM users WHERE name = 'User ' ||'77' AND signup_date BETWEEN '2021-01-30' AND '2021-02-01';


SELECT r.* from
(SELECT 
a.chick_no, 
a.breeds, 
b.RAW_WEIGHT,
row_number() over(PARTITION BY a.breeds ORDER BY b.RAW_WEIGHT desc) rn
FROM fms.chick_info a, fms.prod_result b
WHERE a.chick_no = b.chick_no) r
WHERE r.rn <= 3;

