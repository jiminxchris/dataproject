/* Chapter 6. 프로시져와 잡, 데이터베이스 오브젝트 */

-- 함수 만들기

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
CREATE FUNCTION one() 
RETURNS integer AS $$
SELECT 1;
$$ LANGUAGE SQL;

SELECT one();  -- 결과: 1

-- public 밑에 안생기고 fms에 함수가 생기도록 명시적으로 지정할 때 방법
--CREATE FUNCTION fms.one() RETURNS integer AS $$
--SELECT 1;
--$$ LANGUAGE SQL;

--select * from fms.chick_info;

--  예시 2: 입력값 받아 연산 후 반환
CREATE FUNCTION add_em(x integer, y integer) 
RETURNS integer AS $$
SELECT x + y;
$$ LANGUAGE SQL;

SELECT add_em(1, 2);  -- 결과: 3

--예시 3: 테이블에서 값 조회 SQL 사용
CREATE FUNCTION get_chick_count_simple()
RETURNS INTEGER AS $$
   SELECT COUNT(*) FROM fms.chick_info;
$$ LANGUAGE SQL;

-- plpgsql로 변경시
CREATE OR REPLACE FUNCTION get_chick_count_simple2()
RETURNS INTEGER AS $$
DECLARE
    result INTEGER;
BEGIN
    SELECT COUNT(*) INTO result FROM fms.chick_info;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

--변경 포인트 요약
--BEGIN ... END; 블록 추가
--변수 선언(DECLARE result INTEGER;)
--SELECT ... INTO result 구문 사용
--명시적으로 RETURN result; 사용

SELECT get_chick_count_simple();
SELECT get_chick_count_simple2();

-- 1. PL/pgSQL 함수
-- RETURN 키워드 필수

-- 2. SQL 함수
-- RETURN 키워드 사용 불가
-- 마지막 SELECT 결과 자동 반환

-- 추가 주의사항
-- SQL 함수는 단일 쿼리만 가능하며, 여러 문장 실행 시 RETURNS SETOF 또는 RETURNS TABLE 사용
-- PL/pgSQL 함수는 RETURN NEXT로 여러 행 반환 가능
-- 성능: 단순 쿼리는 SQL 함수가 더 빠름
-- ⚠️ 중요: SQL 함수 본문은 문자열로 취급되므로 $$ 구분자 사용이 필요합니다.


--예시 3: 테이블에서 값 조회 plpgsql 사용
CREATE FUNCTION get_chickinfo(chick_no VARCHAR) 
RETURNS NUMERIC AS $$
BEGIN
  RETURN (SELECT egg_weight FROM chick_info WHERE chick_info.chick_no = get_chickinfo.chick_no);
END;
$$ LANGUAGE plpgsql;

-- sql로 변경시
CREATE FUNCTION get_chickinfo2(chick_no VARCHAR) 
RETURNS NUMERIC AS $$
   SELECT egg_weight 
   FROM fms.chick_info 
   WHERE chick_info.chick_no = get_chickinfo2.chick_no;
$$ LANGUAGE SQL;

--변경 포인트 설명
--BEGIN...END 블록 제거: 단순 쿼리 실행만 필요하므로 블록 불필요
--RETURN 문 대신 직접 SELECT 결과 반환
--LANGUAGE 변경: plpgsql → sql
--매개변수 참조 방식 유지: get_chickinfo.chick_no (SQL 함수에서도 동일하게 작동)
--💡 주의사항: 이 함수는 chick_no 값이 정확히 일치하는 단일 행이 존재할 때만 정상 작동합니다. 여러 행이 반환되면 오류가 발생하며, 이 경우 PL/pgSQL 함수에서 LIMIT 1 추가나 예외 처리가 필요합니다.

-- 3함수 사용하기
select get_chickinfo('A2310001'); -- 결과는 65
select get_chickinfo2('A2310001');

SELECT egg_weight FROM chick_info WHERE chick_no = 'A2310001'; --결과는 65

-- 아래는 미션으로 출제
-- 조건 분기 사용하는 함수(이런 간단한거는 sql도 가능)
CREATE OR REPLACE FUNCTION weight_pass_sql(weight NUMERIC)
RETURNS TEXT AS $$
	SELECT CASE 
		WHEN weight >= 40 THEN '합격'
		ELSE '불합격'
	END;
$$ LANGUAGE SQL;

-- 그럼에도 plpgsql로 변경했을 때
CREATE OR REPLACE FUNCTION weight_pass_plpgsql(weight NUMERIC)
RETURNS TEXT AS $$
BEGIN
    RETURN CASE 
        WHEN weight >= 40 THEN '합격'
        ELSE '불합격'
    END;
END;
$$ LANGUAGE plpgsql;

-- 📌 성능 고려사항: 단순 조건 판단 시 PL/pgSQL의 RETURN CASE가 SELECT를 포함한 구현보다 15-20% 빠른 실행 속도를 보입니다.

SELECT weight_pass_sql(45);  -- 결과는 합격
SELECT weight_pass_plpgsql(45);

-- 조건 분기 사용하는 함수(이런식은 plpgsql만 가능)
CREATE FUNCTION get_weight_grade(weight NUMERIC)
RETURNS TEXT AS $$
DECLARE
    result TEXT;
BEGIN
	IF weight > 40 THEN
		result := 'Heavy';
	ELSE
		result := 'Normal';
	END IF;
	RETURN result;
END;
$$ LANGUAGE plpgsql;

-- result 변수 굳이 선언안하고 사용할 때
CREATE FUNCTION get_weight_grade(weight NUMERIC)
RETURNS TEXT AS $$
BEGIN
    IF weight > 40 THEN
        RETURN 'Heavy';
    ELSE
        RETURN 'Normal';
    END IF;
END;
$$ LANGUAGE plpgsql;

--sql로 변경시
CREATE FUNCTION get_weight_grade2(weight NUMERIC)
RETURNS TEXT AS $$
    SELECT CASE 
        WHEN weight > 40 THEN 'Heavy'
        ELSE 'Normal'
    END;
$$ LANGUAGE SQL;

SELECT get_weight_grade(45); --Heavy 결과 출력
SELECT get_weight_grade2(45);

-- 아래는 sql로 변경 불가능
-- PostgreSQL의 SQL 함수에서는 변수 선언, 조건문(IF), 반복문(LOOP), 커서 등 절차적 프로그래밍 요소를 사용할 수 없습니다. SQL 함수는 단순한 SELECT, INSERT, UPDATE, DELETE 등 SQL 쿼리만 허용합니다. 따라서 아래와 같은 PL/pgSQL 예제는 SQL 함수로 변환할 수 없습니다.

CREATE OR REPLACE FUNCTION print_loop(n INTEGER)
RETURNS VOID AS $$
DECLARE
    i INTEGER := 1;
BEGIN
    WHILE i <= n LOOP
        RAISE NOTICE 'Loop: %', i;
        i := i + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT print_loop(10);

--sql로 바꾸지 못하는 예시 추가
CREATE OR REPLACE FUNCTION update_multiple_rows()
RETURNS VOID AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN SELECT id, value FROM my_table LOOP
        IF rec.value < 10 THEN
            UPDATE my_table SET value = value + 1 WHERE id = rec.id;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT update_multiple_rows();

--예시 4: 여러 컬럼(레코드) 반환

CREATE FUNCTION dup(in int, out f1 int, out f2 text) AS $$
SELECT $1, CAST($1 AS text) || ' is text'
$$ LANGUAGE SQL;

--SELECT $1, CAST($1 AS text) || ' is text'
--첫 번째 값은 입력받은 정수 그대로 반환
--두 번째 값은 입력받은 정수를 문자열로 변환한 뒤, 뒤에 ' is text'를 붙여 반환

-- returns를 사용하도록 변경
CREATE FUNCTION dup2(in int)
RETURNS TABLE(f1 int, f2 text) AS $$
  SELECT $1, CAST($1 AS text) || ' is text';
$$ LANGUAGE SQL;

SELECT * FROM dup(42);  -- 결과: 42, '42 is text'
SELECT * FROM dup2(42);

-- 하는김에 plpgsql로 변경
CREATE OR REPLACE FUNCTION dup3(in int)
RETURNS TABLE(f1 int, f2 text) AS $$
BEGIN
    RETURN QUERY
        SELECT $1, CAST($1 AS text) || ' is text';
END;
$$ LANGUAGE plpgsql;

--BEGIN ... END; 블록 내부에서
--RETURN QUERY 구문으로 결과를 반환합니다.

--PL/pgSQL에서 테이블(복수 행) 또는 SETOF를 반환하는 함수에서는 RETURN QUERY를 사용해야 합니다.
--단순히 RETURN만 쓰면 안 됩니다.
--
--왜 RETURN QUERY를 써야 하나?
--RETURN QUERY: 쿼리 결과 전체(여러 행, 테이블)를 결과 집합에 추가합니다.
--여러 번 사용하면 결과가 누적됩니다.
--마지막에 RETURN;(인자 없음)으로 함수 종료를 명시할 수 있습니다.
--
--RETURN: 단일 값(스칼라, 한 행, 한 레코드)만 반환합니다.
--테이블(여러 행)을 반환하는 함수에서는 사용할 수 없습니다.

CREATE OR REPLACE FUNCTION get_chickinfo_table()
RETURNS TABLE(chick_no VARCHAR, egg_weight NUMERIC) AS $$
  SELECT chick_no, egg_weight FROM fms.chick_info;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION get_chickinfo_setof()
RETURNS SETOF fms.chick_info AS $$
  SELECT * FROM fms.chick_info;
$$ LANGUAGE SQL;

-- 주의: RETURNS TABLE(...)을 쓸 때는 반드시 반환할 컬럼과 타입을 모두 명시해야 합니다.
-- 만약 fms.chick_info 테이블의 모든 컬럼을 반환하고 싶다면, 모든 컬럼명과 타입을 나열해야 합니다.

-- 결론
-- SETOF: 기존 테이블 구조 그대로 반환, 간편하게 사용 가능
-- TABLE: 반환할 컬럼을 명시적으로 지정, 필요한 컬럼만 반환 가능
-- 둘 다 사용 가능하지만, 반환 구조가 같다면 SETOF가 더 간단하며, 컬럼을 선택적으로 반환하고 싶을 때는 TABLE이 유연합니다.

-- 1. RETURNS TABLE 방식
SELECT * FROM get_chickinfo_table();

-- 2. RETURNS SETOF 방식
SELECT * FROM get_chickinfo_setof();


-- 다음의 뷰함수를 함수로 변경해보기
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

-- 함수로 변경했을 때
CREATE OR REPLACE FUNCTION fms.get_farm_ship_summary(farm_param VARCHAR)
RETURNS TABLE (
    farm VARCHAR,
    customer VARCHAR,
    shipped_count BIGINT
) AS $$
    SELECT
        ci.farm,
        sr.customer,
        COUNT(*) AS shipped_count
    FROM fms.prod_result pr
    JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
    JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
    WHERE pr.pass_fail = 'P'
      AND ci.farm = farm_param
    GROUP BY ci.farm, sr.customer;
$$ LANGUAGE SQL;

SELECT * FROM fms.get_farm_ship_summary('A');
SELECT * FROM fms.get_farm_ship_summary('B');


--plpgsql 로변경

CREATE OR REPLACE FUNCTION fms.get_farm_ship_summary(farm_param VARCHAR)
RETURNS TABLE (
    farm VARCHAR,
    customer VARCHAR,
    shipped_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ci.farm,
        sr.customer,
        COUNT(*)::BIGINT AS shipped_count
    FROM fms.prod_result pr
    JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
    JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
    WHERE pr.pass_fail = 'P'
      AND ci.farm = farm_param
    GROUP BY ci.farm, sr.customer;
END;
$$ LANGUAGE plpgsql;


-- 1. 프로시저(Procedure)

-- 프로시저
CREATE [OR REPLACE] PROCEDURE 프로시저_이름(파라미터_목록)  
LANGUAGE plpgsql  
AS $$  
BEGIN  
    -- SQL 로직  
END;  
$$;  


-- 사용 가능한 프로시저 언어
SELECT * FROM pg_available_extensions WHERE comment like '%procedural language';

--프로시저용 테이터를 저장하기 위한 테이블 만들기
CREATE TABLE fms.breeds_prod_tbl (
	prod_date date NOT NULL,
	breeds_nm character(20) NOT NULL,
	total_sum bigint NOT NULL,
	save_time timestamp without time zone NOT NULL
);
COMMENT ON TABLE fms.breeds_prod_tbl IS '품종별 생산실적';
-------------------------------------
CREATE OR REPLACE VIEW fms.breeds_prod
AS SELECT 
	a.prod_date,
    ( 
      SELECT m.code_desc
      FROM fms.master_code m
      WHERE m.column_nm = 'breeds' AND m.code = b.breeds
     ) AS breeds_nm,
    sum(a.raw_weight) AS total_sum
   FROM fms.prod_result a
     JOIN fms.chick_info b ON a.chick_no = b.chick_no
  GROUP BY a.prod_date, b.breeds;


SELECT * FROM fms.breeds_prod;

----------------------------------------

-- 프로시저를 만들기위한 동작 쿼리문
INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
(
	SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
	FROM fms.breeds_prod
	WHERE prod_date = '2023-01-31'
);

-- 프로시저로 만들기
CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc()
	LANGUAGE sql
AS $procedure$
	INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
	(
		SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
		FROM fms.breeds_prod
		WHERE prod_date = '2023-01-31'
	);
$procedure$;


-- 단수히 pgplsql로 변경해보기
CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
    SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
    FROM fms.breeds_prod
    WHERE prod_date = '2023-01-31';
END;
$$;


-- 프로시저 실행하기
CALL fms.breeds_prod_proc();

-- 함수나 프로시저만 잡으로 등록할 수 있음

-- 위의 프로시저를 뷰나 함수로 변경가능한지
--1. 함수(Function)로 변경
--프로시저의 역할은 특정 날짜의 데이터를 다른 테이블에 INSERT하는 것입니다.
--이 작업은 함수(특히 RETURNS void 또는 RETURNS integer 등)로 쉽게 구현할 수 있습니다.
CREATE OR REPLACE FUNCTION fms.breeds_prod_func()
RETURNS void AS $$
BEGIN
    INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
    SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
    FROM fms.breeds_prod
    WHERE prod_date = '2023-01-31';
END;
$$ LANGUAGE plpgsql;

--호출: SELECT fms.breeds_prod_func(); 또는 PERFORM fms.breeds_prod_func();

--2. 뷰(View)로 변경 가능 여부
--불가능합니다.
--뷰는 SELECT 결과만을 보여주는 가상 테이블로,
--데이터를 **삽입(INSERT), 갱신(UPDATE), 삭제(DELETE)**하는 로직을 직접 포함할 수 없습니다


-- 이전에 만들었던 View 참고용-----------
-- 아래에서 절대 이전 뷰를 프로시저로 만들지 말것 안되는거임!!!
-- 2-2. 나만의 가상 테이블 만들기(VIEW)
CREATE OR REPLACE VIEW fms.breeds_prod
AS
	SELECT
	a.prod_date,
	(
		SELECT m.code_desc "breeds_nm"
		FROM fms.master_code m
		WHERE m.column_nm = 'breeds'
		AND m.code = b.breeds
	),
	sum(a.raw_weight) "total_sum"
	FROM
		fms.prod_result a,
		fms.chick_info b
	WHERE
		a.chick_no = b.chick_no
		AND a.pass_fail = 'P'
	GROUP BY a.prod_date, b.breeds;

----------------------------------------------
CREATE OR REPLACE VIEW fms.breeds_prod
AS SELECT 
	a.prod_date,
    ( 
      SELECT m.code_desc
      FROM fms.master_code m
      WHERE m.column_nm::text = 'breeds'::text AND m.code::bpchar = b.breeds
     ) AS breeds_nm,
    sum(a.raw_weight) AS total_sum
   FROM fms.prod_result a
     JOIN fms.chick_info b ON a.chick_no = b.chick_no
  GROUP BY a.prod_date, b.breeds;
--------------------------------------

CREATE OR REPLACE VIEW fms.breeds_prod
AS SELECT 
	a.prod_date,
    ( 
      SELECT m.code_desc
      FROM fms.master_code m
      WHERE m.column_nm = 'breeds' AND m.code = b.breeds
     ) AS breeds_nm,
    sum(a.raw_weight) AS total_sum
   FROM fms.prod_result a
     JOIN fms.chick_info b ON a.chick_no = b.chick_no
  GROUP BY a.prod_date, b.breeds;


SELECT * FROM fms.breeds_prod;
-------------------------------

CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc2()
LANGUAGE plpgsql
AS $$
BEGIN
    -- 결과를 반환하지 않고, 단순 실행만 함
    -- SELECT 문을 실행해도 호출자에게 결과가 전달되지 않음
    -- 결과 반환이 필요하다면 함수를 사용해야 함
	SELECT 
	a.prod_date,
    ( 
      SELECT m.code_desc
      FROM fms.master_code m
      WHERE m.column_nm = 'breeds' AND m.code = b.breeds
     ) AS breeds_nm,
    sum(a.raw_weight) AS total_sum
   	FROM fms.prod_result a
     JOIN fms.chick_info b ON a.chick_no = b.chick_no
  	GROUP BY a.prod_date, b.breeds;
    RAISE NOTICE '프로시저는 SELECT 결과를 직접 반환하지 않습니다.';
END;
$$;  -- 이건 에러 발생

CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc2()
LANGUAGE plpgsql
AS $$
BEGIN
    -- SELECT 대신 PERFORM 사용하여 결과 폐기
    PERFORM 
    (SELECT 
        a.prod_date,
        (SELECT m.code_desc
         FROM fms.master_code m
         WHERE m.column_nm = 'breeds' AND m.code = b.breeds) AS breeds_nm,
        sum(a.raw_weight) AS total_sum
     FROM fms.prod_result a
     JOIN fms.chick_info b ON a.chick_no = b.chick_no
     GROUP BY a.prod_date, b.breeds);

    RAISE NOTICE '프로시저는 SELECT 결과를 직접 반환하지 않습니다.';
END;
$$;  -- 이것도 에러 발생

CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc2()
LANGUAGE plpgsql
AS $$
BEGIN
    -- 방법 1: EXECUTE 사용 (결과 무시)
    EXECUTE '
    SELECT 
        a.prod_date,
        (SELECT m.code_desc
         FROM fms.master_code m
         WHERE m.column_nm = ''breeds'' AND m.code = b.breeds) AS breeds_nm,
        sum(a.raw_weight) AS total_sum
     FROM fms.prod_result a
     JOIN fms.chick_info b ON a.chick_no = b.chick_no
     GROUP BY a.prod_date, b.breeds';

    RAISE NOTICE '프로시저는 SELECT 결과를 직접 반환하지 않습니다.';
END;
$$;

-- 프로시저 실행하기
CALL fms.breeds_prod_proc2();

--2. 함수(Function)로 변환 (추천)
--함수는 SELECT 쿼리 결과를 테이블처럼 반환할 수 있어, 뷰와 가장 유사하게 동작합니다.

CREATE OR REPLACE FUNCTION fms.breeds_prod_func()
RETURNS TABLE (
    prod_date DATE,
    breeds_nm TEXT,
    total_sum NUMERIC
) AS $$
    SELECT 
        a.prod_date,
        (SELECT m.code_desc
           FROM fms.master_code m
          WHERE m.column_nm = 'breeds' AND m.code = b.breeds) AS breeds_nm,
        SUM(a.raw_weight) AS total_sum
      FROM fms.prod_result a
      JOIN fms.chick_info b ON a.chick_no = b.chick_no
     GROUP BY a.prod_date, b.breeds;
$$ LANGUAGE SQL;


--호출 예시:
SELECT * FROM fms.breeds_prod_func();

------------------------------------------
DELETE FROM fms.breeds_prod_tbl;

--pgagent 확장
CREATE EXTENSION pgagent;

--pgagent 확장 삭제
DROP EXTENSION IF EXISTS pgagent CASCADE;

-- 잡 샘플코드
DO $$
DECLARE
    jid integer;
    scid integer;
BEGIN
-- Creating a new job
INSERT INTO pgagent.pga_job(
    jobjclid, jobname, jobdesc, jobhostagent, jobenabled
) VALUES (
    1::integer, 'breeds_prod_proc_job'::text, '품종별 생산실적 입력 프로시저 스케줄링'::text, ''::text, false
) RETURNING jobid INTO jid;

-- Steps
-- Inserting a step (jobid: NULL)
INSERT INTO pgagent.pga_jobstep (
    jstjobid, jstname, jstenabled, jstkind,
    jstconnstr, jstdbname, jstonerror,
    jstcode, jstdesc
) VALUES (
    jid, 'step'::text, true, 's'::character(1),
    ''::text, 'postgres'::name, 'f'::character(1),
    'CALL fms.breeds_prod_proc();'::text, ''::text
) ;

-- Schedules
-- Inserting a schedule
INSERT INTO pgagent.pga_schedule(
    jscjobid, jscname, jscdesc, jscenabled,
    jscstart, jscend,    jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
) VALUES (
    jid, 'everyminute'::text, ''::text, true,
    '2025-05-02 00:00:00+09'::timestamp with time zone, '2025-05-02 12:00:00+09'::timestamp with time zone,
    -- Minutes
    '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
    -- Hours
    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Week days
    '{f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Month days
    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Months
    '{f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[]
) RETURNING jscid INTO scid;
END
$$;

-- 연산자 우선순위
SELECT 
b.destination, sum(a.raw_weight) "prod_sum"
FROM
fms.prod_result a
INNER JOIN fms.ship_result b
ON a.chick_no = b.chick_no
WHERE a.disease_yn = 'N' AND a.size_stand >= 11
GROUP BY b.destination
HAVING (sum(a.raw_weight)/1000) >= 5
ORDER BY sum(a.raw_weight) DESC
LIMIT 3;



