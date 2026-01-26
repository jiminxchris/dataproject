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


-- 1. 농장별 고객사별로 납품 횟수 View -> 함수로(함수만들기 복습)
-- 2. 함수를 스케줄러 잡으로 등록, 파일로 저장(스케줄러 등록 복습)
-- 3. 저장된 파일의 내용확인(파일로 저장하기 도전), 분마다 저장되는 파일 구분

SELECT * FROM func_farm_ship_summary('A');

COPY(SELECT * from fms.func_farm_ship_summary('A')) TO 'C:/Users/Public/farm_ship_summary.csv' CSV HEADER;


SELECT COUNT(*)
FROM fms.chick_info
WHERE breeds = 'C1';

CREATE TABLE IF NOT EXISTS fms.prod_log (
log_id SERIAL PRIMARY KEY,
chick_no VARCHAR(20) NOT NULL,
prod_date DATE NOT NULL,
old_weight NUMERIC,
new_weight NUMERIC,
logged_at TIMESTAMP
);

-- 프로시저 만들기(변경이력관리)
-- prod_result 테이블의 닭의 무게 변경시
-- 해당 테이블의 무게를 변경하면서 prod_log 테이블에 변경이력 로그를 남긴다.
B2300020	2023-02-02	1500	N	12	P
CALL fms.update_and_log_prod_weight('B2300020', '2023-02-02', 1136);

 체중 업데이트
UPDATE fms.prod_result
SET  raw_weight = 1136
WHERE chick_no = 'B2300020' AND prod_date = '2023-02-02';
UPDATE fms.prod_result
SET  raw_weight = p.raw_weight
WHERE chick_no = p.chick_no AND prod_date = p.prod_date;
 로그 테이블에 기록
INSERT fms.prod_log
(chick_no,prod_date,old_weight,new_weight,logged_at)
VALUES ('B2300020','2023-02-02', 1500, 1136, now() );

CREATE OR replace PROCEDURE update_and_log_prod_weight(
	p_chick_no VARCHAR,
	p_prod_date DATE,
	p_raw_weight NUMERIC
) AS $$
declare
	old_weight NUMERIC;
	log_message TEXT;
begin
	select raw_weight into old_weight
	from fms.prod_result
	where chick_no = p_chick_no AND prod_date = p_prod_date;

	if not found then
		-- 데이터가 없는 경우의 예외처리부분
		raise WARNING '경고: 해당하는 데이타가 없습니다. chick_no: %, prod_date: %', p_chick_no, p_prod_date;
		log_message := '업데이트 대상 행 없음:' || p_chick_no || '( ' || p_prod_date || ')';
		INSERT into fms.prod_log
	(chick_no,prod_date,old_weight,new_weight,logged_at)
	VALUES (p_chick_no,p_prod_date, NULL, NULL, now() );
		return;
	end if;
	
	UPDATE fms.prod_result
	SET  raw_weight = p_raw_weight
	WHERE chick_no = p_chick_no AND prod_date = p_prod_date;

	INSERT into fms.prod_log
	(chick_no,prod_date,old_weight,new_weight,logged_at)
	VALUES (p_chick_no,p_prod_date, old_weight, p_raw_weight, now() );
end;
$$ LANGUAGE plpgsql;

CALL fms.update_and_log_prod_weight('D2300020', '2023-02-02', 1136);

-- 트리거 
-- 데이터의 변경을 감지 로그 테이블 자동 기록
-- 건강테이블에 데이터가 변경될때마다 감지하는 트리거
-- 1. 로그테이블 health_cond( 건강상태 변경 이력로그)
-- 2. 함수(로그테이블에 이력을 저장)
-- 3. 트리거로 등록

-- 1. 로그테이블
CREATE TABLE fms.health_cond_audit (
	audit_id SERIAL PRIMARY KEY,
	chick_no VARCHAR(20) NOT NULL,
	old_body_temp NUMERIC(4,1),
	new_body_temp NUMERIC(4,1),
	check_date DATE,
	modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	operation VARCHAR(10)
);

-- 2. 트리거 함수
CREATE OR REPLACE FUNCTION fms.log_health_change()
RETURNS trigger AS $$
begin
	if TG_OP = 'UPDATE' then -- OLD, NEW
		raise notice 'UPDATE 트리거 실행중: % -> %', OLD.body_temp,
		NEW.body_temp;
		insert into fms.health_cond_audit
		(chick_no, old_body_temp, new_body_temp, check_date, operation)
		values(
		OLD.chick_no,
		OLD.body_temp,
		NEW.body_temp,
		NEW.check_date,
		TG_OP
		);
	end if;
	return NEW; -- 트리거 함수에서 업데이트된 행을 그대로 반환의 이미
end;
$$ LANGUAGE plpgsql;

-- 3. 트리거 등록
CREATE OR REPLACE TRIGGER health_audit_trigger
AFTER UPDATE ON fms.health_cond
FOR EACH ROW
EXECUTE FUNCTION fms.log_health_change();

UPDATE fms.health_cond
SET body_temp = 45
WHERE chick_no ='B2310019' AND check_date = '2023-01-10';

-- 1. 환경이상 로그 테이블
CREATE TABLE fms.env_anomaly (
anomaly_id SERIAL PRIMARY KEY,
farm CHAR(1),
check_date DATE,
temp NUMERIC(3,0),
humid NUMERIC(3,0),
reason TEXT,
detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO fms.env_cond 
(farm, date, temp, humid) 
VALUES ('B', '2023-01-25', 21, 60); -- 정상 데이터

INSERT INTO fms.env_cond 
(farm, date, temp, humid) 
VALUES ('B', '2023-01-25', 21, 85);  -- 이상치 데이터 입력시

-- 2. 트리거 함수 구현 습도 값이 허용 범위(55~75)
CREATE OR REPLACE FUNCTION fms.detect_env_abnomaly()
RETURNS trigger AS $$
begin
	if new.humid > 75 or new.humid < 55 then
		insert into fms.env_anomaly
			(farm,check_date,temp,humid,reason)
			values(
			NEW.farm,
			NEW.date,
			NEW.temp,
			NEW.humid,
			case 
				when new.humid > 75 then '습도 과다'
				else '습도 부족'
			end
		);
	end if;
	return NEW; -- 트리거 함수에서 업데이트된 행을 그대로 반환의 이미
end;
$$ LANGUAGE plpgsql;

-- 3. 트리거 함수 등록
CREATE OR REPLACE TRIGGER env_abnomaly_trigger
AFTER INSERT ON fms.env_cond
FOR EACH ROW
EXECUTE FUNCTION fms.detect_env_abnomaly();

SELECT event_object_table AS table_name, trigger_name
FROM information_schema.triggers
GROUP BY table_name, trigger_name
ORDER BY table_name, trigger_name;

SELECT b.DESTINATION, sum(a.RAW_WEIGHT)
FROM fms.prod_result a
join fms.ship_result b
ON a.CHICK_NO = b.CHICK_NO
WHERE a.size_stand >= 11
GROUP BY b.DESTINATION
HAVING (sum(a.RAW_WEIGHT)/1000) >= 5
ORDER BY sum(a.RAW_WEIGHT) DESC
LIMIT 3;

CREATE TABLE users (
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

-- User 77
EXPLAIN (ANALYZE, VERBOSE, buffers)
SELECT * FROM users WHERE name = 'User '||'77' ;

-- 적절한 인덱스 생성적용

SHOW max_parallel_workers_per_gather;
SHOW max_worker_processes;

SET max_parallel_workers_per_gather = 0;


CREATE TABLE IF NOT EXISTS public.bank
(
	client_no integer NOT NULL,
	age smallint,
	gender character(1),
	edu character varying(13),
	marital character varying(8),
	card_type character varying(8),
	CONSTRAINT bank_pkey PRIMARY KEY (client_no)
);

EXPLAIN SELECT * FROM bank;
EXPLAIN  ANALYZE SELECT * FROM bank;

EXPLAIN  ANALYZE SELECT * FROM bank
WHERE client_no between 850 AND 855;

EXPLAIN  (ANALYZE, Format json) 
SELECT * FROM bank
WHERE gender='F' AND age BETWEEN 66 AND 67;

CREATE INDEX bank_gender_idx ON bank(gender, age);

EXPLAIN  ANALYZE 
SELECT * FROM bank
WHERE gender='F';

EXPLAIN  ANALYZE 
SELECT * FROM bank
WHERE gender='F' AND age = 30;

EXPLAIN  ANALYZE 
SELECT * FROM bank
WHERE age = 30;

EXPLAIN  ANALYZE 
SELECT * FROM bank
WHERE age BETWEEN 66 AND 67 AND gender='F' ;

EXPLAIN (ANALYZE, Format json)
SELECT
a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
FROM
fms.prod_result a 
INNER JOIN fms.ship_result b
ON a.chick_no = b.chick_no;

CREATE INDEX prod_result_chick_no_idx ON fms.prod_result(chick_no);
CREATE INDEX ship_result_chick_no_idx ON fms.ship_result(chick_no);

ANALYZE fms.prod_result;
ANALYZE fms.ship_result;

-- 조류독감이 의심되는 개체를 필터링 하기 위해서
-- 온도를 기준으로 내림차순으로 정렬
SELECT * 
FROM fms.HEALTH_COND
ORDER BY body_temp DESC;

-- 조류독감이 의심되는 병아리들만 출력해주세요!! + 병아리 정보까지 함께...

SELECT a.*, b.* 
FROM
(
SELECT date, temp, humid
FROM fms.env_cond
WHERE farm = 'B'
) a
LEFT OUTER JOIN
(
SELECT chick_no, check_date, weight, body_temp, feed_intake
FROM fms.health_cond
WHERE chick_no = 'B2300009'
) b
ON a.date = b.check_date;




SELECT a.*, b.*
from
(SELECT *
FROM fms.env_cond
WHERE farm = 'B') a
LEFT join
(SELECT *
FROM fms.HEALTH_COND
WHERE chick_no = 'B2300009') b
ON a.date = b.check_date;

SELECT raw_weight FROM fms.prod_result
ORDER BY raw_weight DESC;

SELECT chick_no, raw_weight, row_number() over(ORDER BY raw_weight DESC) FROM fms.prod_result;


SELECT ROW_NUMBER() OVER( ORDER BY raw_weight DESC) FROM fms.prod_result;

CREATE OR REPLACE VIEW fms.total_result
AS 
SELECT
a.chick_no AS 육계번호,
(
	SELECT m.code_desc AS 품종
	FROM fms.master_code m 
	WHERE m.column_nm = 'breeds'
	AND m.code = a.breeds
)
,a.egg_weight||
(
	SELECT u.unit
	FROM fms.unit u 
	WHERE u.column_nm = 'egg_weight'
) AS 종란무게
,b.body_temp||
(
	SELECT u.unit
	FROM fms.unit u 
	WHERE u.column_nm = 'body_temp'
) AS 체온
,b.breath_rate||
(
	SELECT u.unit 
	FROM fms.unit u 
	WHERE u.column_nm = 'breath_rate'
) AS 호흡수
,(
	SELECT m.code_desc AS 호수 
	FROM fms.master_code m
	WHERE m.column_nm = 'size_stand' 
	AND TO_NUMBER(m.code,'99') = c.size_stand
)
,(
	SELECT m.code_desc AS 부적합여부
	FROM fms.master_code m 
	WHERE m.column_nm = 'pass_fail' 
	AND m.code = c.pass_fail
)
,d.order_no AS 주문번호
,d.customer AS 고객사 
,d.arrival_date AS 도착일
,d.destination AS 도착지
FROM
fms.chick_info a 
LEFT OUTER JOIN fms.health_cond b ON a.chick_no = b.chick_no
LEFT OUTER JOIN fms.prod_result c ON a.chick_no = c.chick_no
LEFT OUTER JOIN fms.ship_result d ON a.chick_no = d.chick_no
WHERE b.check_date = '2023-01-30';



SELECT chick_no, body_temp, (body_temp> 41)
FROM fms.health_cond;

SELECT
 tt.table_type
,isc.table_name
,tc.table_comment
,isc.column_name
,cc.column_comment
,isc.udt_name AS column_type
,CASE WHEN isc.character_maximum_length IS NULL THEN isc.numeric_precision 
 ELSE isc.character_maximum_length END AS length
,isc.is_nullable
,ct.constraint_type
FROM
(
	information_schema.columns isc
	LEFT OUTER JOIN --table_type(tt) join
	(
		SELECT
		 table_schema
		,table_name
		,table_type
		FROM information_schema.tables
	) tt 
	ON isc.table_schema = tt.table_schema
	AND isc.table_name = tt.table_name
	LEFT OUTER JOIN --table_comment(tc) join
	(
		SELECT 
		 pn.nspname AS schema_name
		,pc.relname AS table_name
		,OBJ_DESCRIPTION(pc.oid) AS table_comment
		FROM pg_catalog.pg_class pc
		INNER JOIN pg_catalog.pg_namespace pn
		ON pc.relnamespace = pn.oid 
		WHERE pc.relkind = 'r'
	) tc 
	ON isc.table_schema = tc.schema_name
	AND isc.table_name = tc.table_name
	LEFT OUTER JOIN --column_comment(cc) join
	(
		SELECT
		 ps.schemaname AS schema_name
		,ps.relname AS table_name
		,pa.attname AS column_name
		,pd.description AS column_comment
		FROM 
		pg_stat_all_tables ps,
		pg_catalog.pg_description pd,
		pg_catalog.pg_attribute pa
		WHERE ps.relid = pd.objoid
		AND pd.objsubid != 0
		AND pd.objoid = pa.attrelid
		AND pd.objsubid = pa.attnum
		ORDER BY ps.relname, pd.objsubid
	) cc
	ON isc.table_schema = cc.schema_name
	AND isc.table_name = cc.table_name
	AND isc.column_name = cc.column_name
	LEFT OUTER JOIN --constraint_type(ct) join
	(
		SELECT
		 isccu.table_schema
		,istc.table_name
		,isccu.column_name
		,istc.constraint_type
		,isccu.constraint_name
		FROM
		information_schema.table_constraints istc,
		information_schema.constraint_column_usage isccu
		WHERE istc.table_catalog = isccu.table_catalog
		AND istc.table_schema = isccu.table_schema
		AND istc.constraint_name = isccu.constraint_name
	) ct 
	ON isc.table_schema = ct.table_schema
	AND isc.table_name = ct.table_name
	AND isc.column_name = ct.column_name
)
WHERE isc.table_schema = 'fms'
ORDER BY tt.table_type, isc.table_name, isc.ordinal_position;



SELECT * FROM fms.total_result;

CREATE OR REPLACE FUNCTION fms.detect_unhealthy_chick(chick_id text)
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

SELECT fms.detect_unhealthy_chick('B2300009');

CREATE TABLE IF NOT EXISTS fms.health_report (
chick_no VARCHAR(20) NOT NULL,
check_date DATE NOT NULL,
body_temp NUMERIC(3,1),
feed_intake INT,
is_unhealthy BOOLEAN
);
--건강 이상 개체 자동 리포트 생성, 최근 건강 상태를 자동으로 리포트 테이블에 저장
CREATE OR REPLACE PROCEDURE generate_health_report()
AS $$
BEGIN
INSERT INTO fms.health_report(chick_no, check_date, body_temp, feed_intake, is_unhealthy)
SELECT chick_no, check_date, body_temp, feed_intake,
(body_temp > 41.7 OR feed_intake < 100) AS is_unhealthy
FROM fms.health_cond
WHERE check_date = (SELECT MAX(check_date) FROM fms.health_cond);
END;
$$ LANGUAGE plpgsql;

CALL generate_health_report();

CREATE TABLE IF NOT EXISTS fms.alert_log (
message VARCHAR(100),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE check_env_condition()
AS $$
BEGIN
IF EXISTS (SELECT 1 FROM fms.env_cond WHERE humid > 70 OR humid < 50 OR temp > 35 OR temp < 20) THEN
INSERT INTO fms.alert_log(message, created_at)
VALUES ('환경 조건 이상 발생!', CURRENT_TIMESTAMP);
END IF;
END;
$$ LANGUAGE plpgsql;

CALL check_env_condition();
