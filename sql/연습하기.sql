SELECT 
    SUM(egg_weight) AS total_weight,
    AVG(egg_weight) AS average_weight,
    MAX(egg_weight) AS max_weight,
    MIN(egg_weight) AS min_weight
FROM 
    fms.chick_info;


SELECT * FROM fms.chick_info;

SET search_path TO fms;

--트랜잭션
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100 WHERE name = 'Wally';
COMMIT;


--COMMIT 혹은 ROLLBACK으로 트랜잭션을 종료하지 않으면, 해당 업데이트 건은 데이터베이스에 적용되지 않는다.
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
COMMIT;

-- 현재 세션의 search_path 확인하고 설정하기
SHOW search_path;
SET search_path TO fms;

--함수의 구본 구조와 생성 예시
CREATE [OR REPLACE] FUNCTION 함수이름(파라미터 목록)
RETURNS 반환타입 AS $$
DECLARE
  -- 변수 선언
BEGIN
  -- 함수 로직
  RETURN 결과값;
END;
$$ LANGUAGE plpgsql;

-- 예시 1: 입력값 없이 정수 반환
CREATE FUNCTION one() RETURNS integer AS $$
SELECT 1;
$$ LANGUAGE SQL;

SELECT one();  -- 결과: 1

--CREATE FUNCTION fms.one() RETURNS integer AS $$
--SELECT 1;
--$$ LANGUAGE SQL;

--select * from fms.chick_info;

--  예시 2: 입력값 받아 연산 후 반환

CREATE FUNCTION add_em(x integer, y integer) RETURNS integer AS $$
SELECT x + y;
$$ LANGUAGE SQL;

SELECT add_em(1, 2);  -- 결과: 3

--예시 3: 테이블에서 값 조회
CREATE FUNCTION get_chickinfo(chick_no VARCHAR) RETURNS NUMERIC AS $$
BEGIN
  RETURN (SELECT egg_weight FROM chick_info WHERE chick_info.chick_no = get_chickinfo.chick_no);
END;
$$ LANGUAGE plpgsql;

select get_chickinfo('A2310001');

SELECT egg_weight FROM chick_info WHERE chick_no = 'A2310001';

--예시 4: 여러 컬럼(레코드) 반환

CREATE FUNCTION dup(in int, out f1 int, out f2 text) AS $$
SELECT $1, CAST($1 AS text) || ' is text'
$$ LANGUAGE SQL;

SELECT * FROM dup(42);  -- 결과: 42, '42 is text'

-- 프로시저
CREATE [OR REPLACE] PROCEDURE 프로시저_이름(파라미터_목록)  
LANGUAGE plpgsql  
AS $$  
BEGIN  
    -- SQL 로직  
END;  
$$;  












