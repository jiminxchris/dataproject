-- pk 테스트
INSERT INTO user_info (user_id, user_name, jumin_no, tel_co, tel_no)
VALUES ('jimin3', '박지민', '951013123456', 'SK', '01011111111');
-- check 테스트
-- fk 테스트
INSERT INTO arrival (id, addr_name, addr)
VALUES ('jungkuk', '집2', '서울시 용산구');

-- 데이터 삭제
DELETE FROM USER_INFO 
WHERE user_id='jimin3';

---------------------------------------------------
CREATE SCHEMA fms;

CREATE TABLE IF NOT EXISTS fms.chick_info (
    chick_no CHAR(8) PRIMARY KEY,
    breeds CHAR(2) NOT NULL,
    gender CHAR(1) NOT NULL,
    hatchday DATE NOT NULL,
    egg_weight SMALLINT NOT NULL,
    vaccination1 SMALLINT,
    vaccination2 SMALLINT,
    farm CHAR(1) NOT NULL
);

COMMENT ON SCHEMA fms
    IS '농장관리시스템(Farm Management System) DB';

COMMENT ON TABLE fms.chick_info
    IS '육계정보';

COMMENT ON COLUMN fms.chick_info.chick_no
    IS '육계번호';

COMMENT ON COLUMN fms.chick_info.breeds
    IS '품종';

COMMENT ON COLUMN fms.chick_info.gender
    IS '성별';

COMMENT ON COLUMN fms.chick_info.hatchday
    IS '부화일자';

COMMENT ON COLUMN fms.chick_info.egg_weight
    IS '종란무게';

COMMENT ON COLUMN fms.chick_info.vaccination1
    IS '예방접종1';

COMMENT ON COLUMN fms.chick_info.vaccination2
    IS '예방접종2';

COMMENT ON COLUMN fms.chick_info.farm
    IS '사육장';

-------------------------------------------------------

CREATE TABLE IF NOT EXISTS fms.env_cond (
    farm CHAR(1) NOT NULL,
    date DATE NOT NULL,
    temp SMALLINT,
     humid SMALLINT,
    light_hr SMALLINT,
    lux SMALLINT
);

COMMENT ON TABLE fms.env_cond IS '사육환경';
COMMENT ON COLUMN fms.env_cond.farm IS '사육장';
COMMENT ON COLUMN fms.env_cond.date IS '일자';
COMMENT ON COLUMN fms.env_cond.temp IS '기온';
COMMENT ON COLUMN fms.env_cond.humid IS '습도';
COMMENT ON COLUMN fms.env_cond.light_hr IS '점등시간';
COMMENT ON COLUMN fms.env_cond.lux IS '조도';
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS fms.health_cond (
    chick_no CHAR(8) NOT NULL,
    check_date DATE NOT NULL,
    weight SMALLINT NOT NULL,
    body_temp NUMERIC(3,1) NOT NULL,
    breath_rate SMALLINT NOT NULL,
    feed_intake SMALLINT NOT NULL,
    diarrhea_yn CHAR(1) NOT NULL,
    note TEXT,
    FOREIGN KEY (chick_no) REFERENCES fms.chick_info (chick_no)
);

COMMENT ON TABLE fms.health_cond IS '건강상태';
COMMENT ON COLUMN fms.health_cond.chick_no IS '육계번호';
COMMENT ON COLUMN fms.health_cond.check_date IS '검사일자';
COMMENT ON COLUMN fms.health_cond.weight IS '체중';
COMMENT ON COLUMN fms.health_cond.body_temp IS '체온';
COMMENT ON COLUMN fms.health_cond.breath_rate IS '호흡수';
COMMENT ON COLUMN fms.health_cond.feed_intake IS '사료섭취량';
COMMENT ON COLUMN fms.health_cond.diarrhea_yn IS '설사여부';
COMMENT ON COLUMN fms.health_cond.note IS '노트';

----------------------------------------------------

CREATE TABLE IF NOT EXISTS fms.master_code (
    column_nm VARCHAR(15),
    type VARCHAR(10),
    code VARCHAR(10),
    code_desc VARCHAR(20)
);

COMMENT ON TABLE fms.master_code IS '마스터코드';
COMMENT ON COLUMN fms.master_code.column_nm IS '열이름';
COMMENT ON COLUMN fms.master_code.type IS '타입';
COMMENT ON COLUMN fms.master_code.code IS '코드';
COMMENT ON COLUMN fms.master_code.code_desc IS '코드의미';
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS fms.prod_result (
    chick_no CHAR(8) NOT NULL,
    prod_date DATE NOT NULL,
    raw_weight SMALLINT NOT NULL,
    disease_yn CHAR(1) NOT NULL,
    size_stand SMALLINT NOT NULL,
    pass_fail CHAR(1) NOT NULL,
    FOREIGN KEY (chick_no) REFERENCES fms.chick_info (chick_no)
);

COMMENT ON TABLE fms.prod_result IS '생산실적';
COMMENT ON COLUMN fms.prod_result.chick_no IS '육계번호';
COMMENT ON COLUMN fms.prod_result.prod_date IS '생산일자';
COMMENT ON COLUMN fms.prod_result.raw_weight IS '생닭중량';
COMMENT ON COLUMN fms.prod_result.disease_yn IS '질병유무';
COMMENT ON COLUMN fms.prod_result.size_stand IS '호수';
COMMENT ON COLUMN fms.prod_result.pass_fail IS '적합여부';
----------------------------------------------------------
CREATE TABLE IF NOT EXISTS fms.ship_result (
    chick_no CHAR(8) NOT NULL,
    order_no CHAR(4) NOT NULL,
    customer VARCHAR(20) NOT NULL,
    due_date DATE NOT NULL,
    arrival_date DATE,
    destination VARCHAR(10) NOT NULL,
    FOREIGN KEY (chick_no) REFERENCES fms.chick_info (chick_no)
);

COMMENT ON TABLE fms.ship_result IS '출하실적';
COMMENT ON COLUMN fms.ship_result.chick_no IS '육계번호';
COMMENT ON COLUMN fms.ship_result.order_no IS '주문번호';
COMMENT ON COLUMN fms.ship_result.customer IS '고객사';
COMMENT ON COLUMN fms.ship_result.due_date IS '납품기한일';
COMMENT ON COLUMN fms.ship_result.arrival_date IS '도착일';
COMMENT ON COLUMN fms.ship_result.destination IS '도착지';

----------------------------------------------------------
CREATE TABLE IF NOT EXISTS fms.unit (
    column_nm VARCHAR(15),
    unit VARCHAR(10)
);

COMMENT ON TABLE fms.unit IS '단위';
COMMENT ON COLUMN fms.unit.column_nm IS '열이름';
COMMENT ON COLUMN fms.unit.unit IS '단위';
----------------------------------------------------------




SELECT * FROM fms.chick_info;

SELECT chick_no AS cn, breeds "품종" FROM fms.chick_info;

SELECT count(*) FROM fms.chick_info;

SELECT CURRENT_DATE; 
select current_timestamp;
SELECT NOW(); 


SELECT chick_no, hatchday, egg_weight FROM fms.chick_info ORDER BY egg_weight DESC, hatchday ASC;

SELECT chick_no, hatchday, egg_weight 
FROM fms.chick_info 
ORDER BY egg_weight DESC, hatchday ASC
LIMIT 7 OFFSET 2;

SELECT DISTINCT(egg_weight) 
FROM fms.chick_info;

------------------------------------------------------
-- 무게별 갯수 확인
SELECT egg_weight, COUNT(*) AS count
FROM fms.chick_info
GROUP BY egg_weight
ORDER BY egg_weight; -- 무게 순으로 정렬 (보기 편하게)

-- A. 많이 나온 순서대로 정렬 (인기 순)
SELECT egg_weight, COUNT(*) AS count
FROM fms.chick_info
GROUP BY egg_weight
ORDER BY count DESC; -- 개수가 많은 것부터 내림차순

-- B. 비율(%)까지 함께 보기
SELECT 
    egg_weight, 
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM fms.chick_info
GROUP BY egg_weight;

-- C. 특정 개수 이상인 것만 필터링 (HAVING)
-- 데이터가 너무 많을 때, 10개 이상 존재하는 무게만 골라내고 싶다면 HAVING을 씁니다.
SELECT egg_weight, COUNT(*)
FROM fms.chick_info
GROUP BY egg_weight
HAVING COUNT(*) >= 10;
------------------------------------------------------
-- 68초과이거나 63 미만이거나
SELECT chick_no, egg_weight 
FROM fms.chick_info
WHERE egg_weight > 68 or egg_weight < 63;

-- hatchday가 1-1과 1-2인 종란만 필터링
SELECT * FROM fms.chick_info 
WHERE hatchday BETWEEN '2025-01-01' AND '2025-01-02';


-- 품종이 C로 시작하는 병아리들만 필터링
SELECT chick_no, breeds 
FROM fms.chick_info
WHERE breeds LIKE 'C%';

-- 품종이 C1, D1에 속하는 병아리들만 필터링
SELECT chick_no, breeds 
FROM fms.chick_info
WHERE breeds in ('C1', 'D1');

SELECT *
FROM fms.env_cond
WHERE humid IS NULL;

INSERT INTO fms.env_cond (farm, "date", "temp", humid, light_hr, lux)
VALUES ('A', '2026-01-26', 25, NULL, 12, 500);

-- humid와 lux를 쏙 빼고 입력해 봅시다.
INSERT INTO fms.env_cond (farm, "date", "temp")
VALUES ('B', '2026-01-26', 22);

-- (응용) 기존 데이터를 NULL로 바꾸고 싶다면?
-- 이미 들어가 있는 멀쩡한 데이터를 테스트를 위해 결측치로 만들고 싶을 때는 UPDATE를 씁니다.
-- A 사육장의 오늘 데이터를 강제로 결측치로 변경
UPDATE fms.env_cond
SET humid = NULL
WHERE farm = 'A' AND "date" = '2026-01-26';

SELECT *
FROM fms.health_cond
WHERE note IS NULL;

-- NULL과 ''은 다름
UPDATE fms.health_cond 
SET note=NULL
WHERE trim(note)='';

-- chick_no로 부터 출신농장, 출생연도, 성별 추출, 일련번호 
-- 5개만 출력 B 2023 1 0013
SELECT
chick_no,left(chick_no,1) "출신농장"
FROM fms.chick_info;

-- 출신농장, 성별, 품종을 합쳐주세요 fgb
SELECT
farm||gender||BREEDS AS id
FROM fms.chick_info;

-- 성별 M을 'Male'로 변환해서 출력하기
SELECT
chick_no,REPLACE(replace(gender, 'M','Male'),'F', 'Female') "성별"
FROM fms.chick_info;

SELECT count(*) FROM fms.chick_info;
SELECT * FROM fms.chick_info;

SELECT 
sum(egg_weight),
avg(egg_weight),
min(egg_weight),
max(egg_weight)
FROM fms.chick_info;

SELECT breeds, chick_no
FROM fms.chick_info
GROUP BY breeds, chick_no; -- 품종과 번호가 모두 같아야 그룹화됨

SELECT 
breeds,avg(egg_weight)
FROM fms.chick_info
GROUP BY breeds;

-- prod_result 테이블에서 생산일자별 생닭 중량의 평균, 합계 출력
SELECT
prod_date, 
avg(raw_weight) AS total_avg, 
sum(raw_weight) total_sum
from fms.prod_result
GROUP BY prod_date
ORDER BY prod_date;

-- ship_result에서 고객사별로 출하된 마리수 출력
SELECT
*
FROM fms.ship_result;

SELECT
customer,count(chick_no)
FROM fms.ship_result
GROUP BY customer
having count(chick_no)>=10;

-- 특정 날짜 이후의 데이터만 출력하고자 한다면...
-- arrival_date가 2023-02-05이후인 데이터에 대해서만

SELECT
arrival_date,customer
FROM fms.ship_result
WHERE arrival_date >= '2023-02-05';

SELECT
customer,count(chick_no)
FROM fms.ship_result
WHERE arrival_date >= '2023-02-05'
GROUP BY customer
having count(chick_no)>=8;

SELECT now();
SELECT current_date;
SELECT current_timestamp;
SELECT current_timestamp::Date;

-- '2025-04-28'
SELECT to_char(timestamp '2025-04-28','YYYY');

SELECT 
hatchday, 
to_char(hatchday,'YYYY')
FROM fms.chick_info;

SELECT 
hatchday, 
to_char(hatchday,'Mon')
FROM fms.chick_info;

SELECT *
FROM fms.env_cond
WHERE humid IS NULL;

SELECT farm, date, 
humid, coalesce(humid, 60)
FROM fms.env_cond
WHERE date BETWEEN '2023-01-23' AND '2023-01-27';
AND farm='A';

SELECT 
chick_no,
gender,
CASE gender
	WHEN 'M' THEN '수컷'
	WHEN 'F' THEN '암컷'
	ELSE '성별미상'
END "성별"
FROM fms.chick_info;

-----------------------------------------------

SELECT AVG(egg_weight) 
FROM fms.chick_info; -- 66.75

SELECT * 
FROM fms.chick_info
WHERE egg_weight > 66.75;

SELECT p.chick_no, p.raw_weight, p.pass_fail,
s.order_no, s.customer
FROM 
fms.prod_result p,
fms.ship_result s
WHERE 
p.chick_no = s.chick_no;

SELECT p.chick_no, p.raw_weight, p.pass_fail,
s.order_no, s.customer
FROM 
fms.prod_result p
cross JOIN fms.ship_result s;


SELECT chick_no, gender, hatchday 
FROM fms.chick_info
union
SELECT 'C2500012', 'F', '2025-10-16';
-----------------------------------------------
SELECT AVG(egg_weight) 
FROM fms.chick_info; -- 66.75

SELECT * 
FROM fms.chick_info
WHERE egg_weight > (SELECT AVG(egg_weight) FROM fms.chick_info);

SELECT
a.chick_no, a.breeds,
b.code_desc "breeds_nm"
FROM
fms.chick_info a
JOIN fms.master_code b
on 
a.breeds = b.code
where b.column_nm = 'breeds';

-- 스칼라 서브쿼리
SELECT a.chick_no, 
a.breeds,
(
	SELECT b.code_desc 
	FROM fms.master_code b
	WHERE b.column_nm = 'breeds'
	AND b.code = a.breeds
)
FROM fms.chick_info a;

SELECT code, code_desc 
FROM fms.master_code
WHERE column_nm = 'breeds';

-- 인라인 뷰
SELECT 
a.chick_no, a.breeds,
b.code_desc
FROM fms.chick_info a,
(
	SELECT code, code_desc 
	FROM fms.master_code
	WHERE column_nm = 'breeds'
) b
WHERE a.breeds = b.code;

CREATE OR REPLACE VIEW fms.breeds_prod
(
prod_data, breed_nm, total_sum
)
AS SELECT
a.prod_date,
(
	SELECT m.code_desc AS breed_nm
	FROM fms.master_code m
	WHERE m.column_nm = 'breeds'
	AND m.code = b.breeds
),
sum(a.raw_weight) AS total_sum
from
fms.prod_result a,
fms.chick_info b
WHERE
a.chick_no = b.chick_no
AND a.pass_fail='P'
GROUP BY a.prod_date, b.breeds;

SELECT *
FROM fms.breeds_prod;



SELECT
a.prod_date,
(
	SELECT m.code_desc AS breed_nm
	FROM fms.master_code m
	WHERE m.column_nm = 'breeds'
	AND m.code = b.breeds
),
sum(a.raw_weight) AS total_sum
from
fms.prod_result a,
fms.chick_info b
WHERE
a.chick_no = b.chick_no
AND a.pass_fail='P'
GROUP BY a.prod_date, b.breeds;

SELECT * FROM fms.chick_info 
WHERE farm='A' AND gender='M'
UNION
SELECT * FROM fms.chick_info 
WHERE farm='B' AND gender='F';


SELECT s.* 
FROM fms.ship_result s
JOIN fms.prod_result p ON s.chick_no = p.chick_no
WHERE s.destination = '부산' AND p.pass_fail = 'P';

SELECT
    s.*,
    p.raw_weight,
    p.pass_fail,
    ci.breeds
FROM
    fms.ship_result s
INNER JOIN
    fms.prod_result p
ON
    s.chick_no = p.chick_no
INNER JOIN
    fms.chick_info ci
ON
    s.chick_no = ci.chick_no
WHERE
    s.destination = '부산' AND p.pass_fail = 'P';

CREATE VIEW fms.breeds_stats 
AS
SELECT breeds, COUNT(*) AS total, AVG(raw_weight) AS avg_weight
FROM fms.prod_result p
JOIN fms.chick_info c ON p.chick_no = c.chick_no
GROUP BY breeds;

SELECT * FROM fms.breeds_stats;


SELECT breeds, COUNT(*) AS total, AVG(raw_weight) AS avg_weight
FROM fms.prod_result p
JOIN fms.chick_info c ON p.chick_no = c.chick_no
GROUP BY breeds;

--------------------------------------------------

CREATE OR REPLACE VIEW fms.daily_shipment_summary (
    ship_date, 
    customer_nm, 
    breeds_nm, 
    total_orders, 
    total_chicks
)
AS
SELECT
    sr.arrival_date AS ship_date,  -- 도착일을 출하일로 간주
    sr.customer AS customer_nm,
    mc.code_desc AS breeds_nm,
    COUNT(DISTINCT sr.order_no) AS total_orders, -- 주문 건수
    COUNT(sr.chick_no) AS total_chicks           -- 출하된 병아리 총 개수
FROM
    fms.ship_result sr
INNER JOIN
    fms.chick_info ci ON sr.chick_no = ci.chick_no -- 육계 정보 조인
INNER JOIN
    fms.master_code mc ON ci.breeds = mc.code AND mc.column_nm = 'breeds' -- 품종명 가져오기
GROUP BY
    sr.arrival_date, sr.customer, mc.code_desc
ORDER BY
    ship_date, customer_nm;

COMMENT ON VIEW fms.daily_shipment_summary IS '일별, 고객사별, 품종별 출하 요약 정보';


-- 뷰의 전체 내용 조회 (복잡한 조인 및 집계 쿼리가 숨겨짐)
SELECT * FROM fms.daily_shipment_summary;

-- 뷰를 이용한 특정 조건 조회
SELECT 
    ship_date,
    breeds_nm,
    total_chicks
FROM 
    fms.daily_shipment_summary
WHERE 
    customer_nm = 'YESYES' 
    AND ship_date >= '2023-02-04';
-------------------------------------------------

SELECT
hatchday,
sum(CASE WHEN gender = 'M' THEN cnt ELSE 0 END) "Male",
sum(CASE WHEN gender = 'F' THEN cnt ELSE 0 END) "Female"
FROM
(SELECT hatchday, gender, count(chick_no) cnt
FROM fms.chick_info
GROUP BY hatchday, gender 
ORDER BY hatchday, gender)
GROUP BY hatchday;

SELECT hatchday, gender, count(chick_no) cnt
FROM fms.chick_info
GROUP BY hatchday, gender 
ORDER BY hatchday, gender;

CREATE EXTENSION tablefunc;

SELECT *
FROM crosstab(
'SELECT hatchday, gender, count(chick_no)::int cnt
FROM fms.chick_info
GROUP BY hatchday, gender 
ORDER BY hatchday, gender DESC')
AS ct(hatchday date, "Male" int, "Female" int);

아래와 같이 수정해도 정상동작

SELECT * 
FROM crosstab
(
'SELECT hatchday, gender, count(chick_no) AS cnt
FROM fms.chick_info
GROUP BY hatchday, gender
ORDER BY hatchday, gender DESC'
)
AS pivot_rr(hatchday date, "Male" bigint, "Female" bigint);


SELECT
hatchday,
sum(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS Male,
sum(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS Female
FROM fms.chick_info
GROUP BY hatchday;


SELECT chick_no, body_temp, breath_rate, feed_intake
FROM fms.health_cond
WHERE check_date = '2023-01-20' 
AND chick_no LIKE 'A%';


SELECT chick_no, health, cond 
FROM 
(
SELECT chick_no, 'body_temp' AS health, body_temp AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
union
SELECT chick_no, 'breath_rate' AS health, breath_rate AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
union
SELECT chick_no, 'feed_intake' AS health, feed_intake AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
)
ORDER BY CHICK_NO, HEALTH;

SELECT chick_no, 'body_temp' AS health, body_temp AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
union
SELECT chick_no, 'breath_rate' AS health, breath_rate AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
union
SELECT chick_no, 'feed_intake' AS health, feed_intake AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
ORDER BY CHICK_NO, HEALTH;

SELECT chick_no, 
UNNEST(ARRAY['body_temp' , 'breath_rate', 'feed_intake']) AS health, 
UNNEST(ARRAY[body_temp , breath_rate, feed_intake]) AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-20' AND chick_no LIKE 'A%'
ORDER BY CHICK_NO, HEALTH;



SELECT
	hatchday,
	sum(CASE WHEN gender = 'M' THEN cnt ELSE 0 END) "Male",
	sum(CASE WHEN gender = 'F' THEN cnt ELSE 0 END) "Female"
FROM
	(SELECT hatchday, gender, count(chick_no) AS cnt
	FROM fms.chick_info
	GROUP BY hatchday, gender 
	ORDER BY hatchday, gender)
GROUP BY hatchday;

SELECT
hatchday,
SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS Male,
SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS Female
FROM fms.chick_info
GROUP BY hatchday;


SELECT * FROM fms.master_code WHERE column_nm = 'breeds';

INSERT INTO fms.master_code(column_nm, type, code, code_desc)
VALUES ('breeds', 'txt', 'R1', 'Ross');

DELETE FROM fms.MASTER_CODE
WHERE code = 'R1';

SELECT * FROM fms.master_code WHERE code = 'R1';

BEGIN;
UPDATE fms.MASTER_CODE
SET code_desc='암컷'
WHERE column_nm='gender' AND code='F';
SAVEPOINT my_savepoint;
DELETE FROM fms.MASTER_CODE 
WHERE column_nm='size_stand' AND to_number(code, '99') < 10;
ROLLBACK TO my_savepoint;
COMMIT;

SELECT *
FROM fms.MASTER_CODE
where code_desc='암컷';

BEGIN;
SAVEPOINT my_savepoint;
UPDATE fms.MASTER_CODE
SET code_desc='Female'
WHERE column_nm='gender' AND code='F';
--SAVEPOINT my_savepoint;
DELETE FROM fms.MASTER_CODE 
WHERE column_nm='size_stand' AND to_number(code, '99') < 10;
ROLLBACK TO my_savepoint;
COMMIT;

SELECT *
FROM fms.MASTER_CODE
where code_desc='암컷';

BEGIN;
UPDATE fms.MASTER_CODE
SET code_desc='Female'
WHERE column_nm='gender' AND code='F';
SAVEPOINT my_savepoint;
DELETE FROM fms.MASTER_CODE 
WHERE column_nm='size_stand' AND to_number(code, '99') < 10;
ROLLBACK TO my_savepoint;
COMMIT;

SELECT *
FROM fms.MASTER_CODE
where code_desc='암컷';

SELECT * FROM fms.MASTER_CODE 
WHERE column_nm='size_stand' AND to_number(code, '99') < 10;

DELETE FROM fms.MASTER_CODE 
WHERE column_nm='size_stand' AND to_number(code, '99') < 10;

---------------------------------------
-- sequence 관련

-- 1. fms 스키마에 시퀀스 객체 생성
-- 이 시퀀스는 로그 ID 번호를 1부터 1씩 증가시키며 생성할 것입니다.
CREATE SEQUENCE IF NOT EXISTS fms.system_log_id_seq
    INCREMENT BY 1
    MINVALUE 1
    START WITH 1
    CACHE 10; -- 성능 향상을 위해 10개의 값을 메모리에 미리 캐시합니다.

-- 2. 시퀀스를 사용하는 테이블 생성
CREATE TABLE IF NOT EXISTS fms.system_log (
    -- log_id 컬럼에 시퀀스를 연결하여 기본 키 값을 자동 생성하도록 설정합니다.
    log_id INTEGER PRIMARY KEY DEFAULT nextval('fms.system_log_id_seq'),
    log_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    log_level VARCHAR(10) NOT NULL, -- INFO, WARN, ERROR 등
    message TEXT -- 로그 내용
);

COMMENT ON TABLE fms.system_log IS 'fms 시스템 주요 이벤트 및 오류 기록';

-- 1. 데이터 삽입: log_id 값을 생략하면 시퀀스가 작동합니다.
INSERT INTO fms.system_log (log_level, message)
VALUES
    ('INFO', '사용자 A가 fms.ship_result 테이블을 조회했습니다.'),
    ('ERROR', '데이터베이스 연결 풀에서 예기치 않은 오류가 발생했습니다.'),
    ('WARN', '재고 데이터 불일치 가능성이 발견되었습니다.');

-- 2. 결과 확인
SELECT * FROM fms.system_log ORDER BY log_id;

-- 3. 현재 시퀀스 값 확인
-- 현재까지 시퀀스가 생성한 마지막 번호를 확인할 수 있습니다.
SELECT last_value FROM fms.system_log_id_seq;

------------------------------------------------------
1단계: 조건문 (IF-THEN-ELSE) 및 데이터 무결성 검사 함수
이 함수는 prod_result 테이블에 새로운 생산 실적을 기록하기 전, 입력된 **생산량(raw_weight)**이 품종별 최소 기준을 충족하는지 검사합니다.

코드 작성: 생산량 유효성 검사 함수

CREATE OR REPLACE FUNCTION fms.check_production_validity(
    p_chick_no VARCHAR,
    p_raw_weight NUMERIC
)
RETURNS BOOLEAN AS $$
DECLARE
    -- 품종 코드를 저장할 변수
    v_breeds VARCHAR;
    -- 해당 품종의 최소 생산량 기준(가정치)을 저장할 변수
    v_min_weight NUMERIC := 1200.00; -- 기본 최소 기준 설정
BEGIN
    -- 1. chick_info 테이블에서 품종(breeds) 정보 조회
    SELECT breeds INTO v_breeds
    FROM fms.chick_info
    WHERE chick_no = p_chick_no;

    -- 품종 정보가 없으면 예외 발생
    IF NOT FOUND THEN
        RAISE EXCEPTION '병아리 번호(%)에 해당하는 품종 정보가 없습니다.', p_chick_no;
    END IF;

    -- 2. 품종 코드에 따른 최소 생산량 기준 설정 (IF-THEN-ELSIF)
    IF v_breeds = 'C1' THEN
        v_min_weight := 1500.00;
    ELSIF v_breeds = 'B1' THEN
        v_min_weight := 1300.00;
    ELSE
        -- 기타 품종은 기본값 1200.00 유지
    END IF;

    -- 3. 입력된 생산량과 최소 기준 비교 후 반환
    IF p_raw_weight >= v_min_weight THEN
        RETURN TRUE;
    ELSE
        RAISE NOTICE '생산량(%)이 품종 (%)의 최소 기준(%)보다 낮습니다.', p_raw_weight, v_breeds, v_min_weight;
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

실행 및 결과 확인 (가정 데이터)
-- 실행 예시 (fms.chick_info에 'A2310001'이 있고 breeds가 'BR01'이라고 가정)
-- 기준: BR01 최소 1500.00
SELECT fms.check_production_validity('A2310001', 1550.00); -- 결과: TRUE
SELECT fms.check_production_validity('A2310001', 1450.00); -- 결과: FALSE (RAISE NOTICE 출력)

2단계: 반복문 (FOR LOOP) 및 집계 연습
이 함수는 특정 **농장(farm)**을 입력받아, 해당 농장의 출하 예정 병아리(pass_fail = 'P')들을 순회하며 평균 체중을 계산하여 반환합니다.

코드 작성: 농장별 합격 병아리 평균 체중 계산 함수

CREATE OR REPLACE FUNCTION fms.get_farm_avg_pass_weight(
    p_farm VARCHAR
)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    -- 합격한 병아리 정보를 저장할 레코드 변수
    r_prod_result RECORD;
    -- 총 체중 합계
    v_total_weight NUMERIC(10, 2) := 0.00;
    -- 합격한 병아리 수
    v_pass_count INTEGER := 0;
BEGIN
    -- 1. 해당 농장의 합격 병아리(pass_fail='P')만 순회하는 FOR LOOP
    FOR r_prod_result IN 
        SELECT pr.raw_weight
        FROM fms.prod_result pr
        INNER JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
        WHERE ci.farm = p_farm AND pr.pass_fail = 'P'
    LOOP
        -- 2. 총합과 카운트 업데이트
        v_total_weight := v_total_weight + r_prod_result.raw_weight;
        v_pass_count := v_pass_count + 1;
    END LOOP;

    -- 3. 평균 계산 및 반환
    IF v_pass_count > 0 THEN
        RETURN v_total_weight / v_pass_count;
    ELSE
        -- 합격 병아리가 없으면 NULL 또는 0 반환
        RETURN 0.00;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 실행 예시 (fms.chick_info와 fms.prod_result에 'B-Farm' 데이터가 있다고 가정)
SELECT fms.get_farm_avg_pass_weight('B'); 

-- 실행 예시 (합격 병아리가 없는 'Z-Farm' 가정)
SELECT fms.get_farm_avg_pass_weight('A');

3단계: 트랜잭션 및 예외 처리 (EXCEPTION) 연습
이 프로시저는 출하 처리를 수행합니다.

prod_result 테이블에서 해당 병아리의 상태를 **'S'(Shipped)**로 변경합니다.

ship_result 테이블에 출하 기록을 추가합니다.

이 두 작업 중 하나라도 실패하면 롤백하고 예외를 처리합니다.

코드 작성: 출하 처리 프로시저

CREATE OR REPLACE PROCEDURE fms.process_shipment(
    p_chick_no VARCHAR,
    p_ship_date DATE,
    p_destination VARCHAR
) AS $$
DECLARE
    v_prod_count INTEGER;
BEGIN
    -- 1. prod_result 테이블에 해당 병아리가 있는지 확인
    SELECT COUNT(*) INTO v_prod_count
    FROM fms.prod_result
    WHERE chick_no = p_chick_no;

    IF v_prod_count = 0 THEN
        RAISE EXCEPTION '생산 실적에 병아리 번호(%)가 없습니다.', p_chick_no;
    END IF;

    -- 2. prod_result 상태 업데이트 (S: Shipped)
    UPDATE fms.prod_result
    SET pass_fail = 'S'
    WHERE chick_no = p_chick_no
      AND pass_fail = 'P'; -- 합격된 병아리만 출하 가능

    -- 3. ship_result에 출하 기록 삽입
    INSERT INTO fms.ship_result (chick_no, order_no, customer, due_date, destination)
    VALUES (p_chick_no,'T001', 'CHRIS', p_ship_date, p_destination);

    -- 4. 성공 시 커밋 (프로시저는 기본적으로 트랜잭션을 사용)
    COMMIT;
    RAISE NOTICE '출하 처리 완료: 병아리 %가 %에 출하되었습니다.', p_chick_no, p_destination;

EXCEPTION
    WHEN others THEN
        -- 오류 발생 시 롤백 (명시적 ROLLBACK은 필요하지 않으나, 로직 흐름상 알림)
        RAISE WARNING '출하 처리 중 오류 발생: % (롤백됨)', SQLERRM;
        -- 다시 예외를 던져 호출자에게 알림
        RAISE EXCEPTION '출하 처리 실패: 병아리 %', p_chick_no;
END;
$$ LANGUAGE plpgsql;

-- 예시 1: 성공적인 출하 처리 (chick_no 'A2310001'가 prod_result에 'P'로 존재한다고 가정)
CALL fms.process_shipment(
    p_chick_no := 'A2510001', 
    p_ship_date := '2025-02-05', 
    p_destination := '부산'
);

-- 예시 2: 존재하지 않는 병아리 번호로 실패 (EXCEPTION 처리 테스트)
CALL fms.process_shipment(
    p_chick_no := 'INVALID999', 
    p_ship_date := '2025-10-17', 
    p_destination := 'Test'
);

---------------------------------------------------------

SELECT 
hatchday, gender, count(chick_no) cnt
FROM fms.chick_info
GROUP BY hatchday, gender
order BY hatchday, gender;

SELECT hatchday,
sum(CASE WHEN gender ='M' THEN cnt ELSE 0 END) Male,
sum(CASE WHEN gender ='F' THEN cnt ELSE 0 END) female
FROM
(
SELECT 
hatchday, gender, count(chick_no) cnt
FROM fms.chick_info
GROUP BY hatchday, gender)
GROUP BY hatchday;

CREATE EXTENSION IF NOT EXISTS tablefunc;

crosstab(src_sql text) AS (컬럼정의)

SELECT *
FROM crosstab
(
'SELECT 
hatchday, gender, count(chick_no) cnt
FROM fms.chick_info
GROUP BY hatchday, gender
order by hatchday, gender desc'
) AS pv(hatchday date, male bigint, female bigint);

SELECT CHICK_NO, BODY_TEMP, BREATH_RATE, FEED_INTAKE 
FROM fms.health_cond
WHERE check_date = '2023-01-10'
AND chick_no LIKE 'A%';

SELECT CHICK_NO, 'body_temp' AS health, body_temp AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-10'
AND chick_no LIKE 'A%'
union
SELECT CHICK_NO, 'breath_rate' AS health, breath_rate AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-10'
AND chick_no LIKE 'A%'
union
SELECT CHICK_NO, 'feed_intake' AS health, feed_intake AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-10'
AND chick_no LIKE 'A%'
ORDER BY chick_no, health;

select
	chick_no,
	unnest(ARRAY['body_temp', 'breath_rate','feed_intake']) AS health,
	unnest(ARRAY[body_temp, breath_rate, feed_intake]) AS cond
FROM fms.health_cond
WHERE check_date = '2023-01-10'
AND chick_no LIKE 'A%'
ORDER BY chick_no, health;


INSERT INTO fms.master_code(column_nm, type, code, code_desc)
VALUES ('breeds', 'txt', 'R1', 'Ross');

INSERT INTO fms.master_code
VALUES ('breeds', 'txt', 'R2', 'Ross2');

UPDATE fms.master_code
SET code_desc='암컷'
WHERE column_nm = 'gender' AND code = 'F';

SELECT * FROM fms.master_code WHERE  code = 'R1';

DELETE FROM fms.master_code
WHERE code = 'R1';


BEGIN;
UPDATE fms.master_code
SET code_desc='Female'
WHERE column_nm = 'gender' AND code = 'F';
--SAVEPOINT my_savepoint;
DELETE FROM fms.master_code
WHERE code = 'R1';
--ROLLBACK TO my_savepoint;
COMMIT;


SELECT ci.farm, pr.pass_fail
 
from fms.chick_info ci
JOIN fms.prod_result pr
ON ci.chick_no = pr.chick_no;

SET search_path TO fms;

CREATE OR REPLACE FUNCTION fms.one()
RETURNS integer AS $$
	select 1;
$$ LANGUAGE SQL;

SELECT fms.one();

CREATE OR REPLACE FUNCTION fms.two(x integer, y integer)
RETURNS integer AS $$
	select x + y;
$$ LANGUAGE SQL;

SELECT fms.two(3, 4);

CREATE OR REPLACE FUNCTION fms.get_chickinfo(chick_no varchar)
RETURNS integer AS $$
	SELECT egg_weight
	FROM fms.chick_info
	WHERE chick_info.chick_no = get_chickinfo.chick_no;
$$ LANGUAGE SQL;

SELECT fms.get_chickinfo('A2310002');

SELECT egg_weight
FROM fms.chick_info
WHERE chick_no = 'A2310001';

SELECT * FROM pg_available_extensions WHERE comment like '%procedural language';

CREATE OR REPLACE FUNCTION fms.get_chickinfo2(chick_no varchar)
RETURNS numeric AS $$
begin
	return (SELECT egg_weight
	FROM fms.chick_info
	WHERE chick_info.chick_no = get_chickinfo2.chick_no);
end;
$$ LANGUAGE plpgsql;

SELECT fms.get_chickinfo2('A2310002');

CREATE OR REPLACE FUNCTION fms.three(IN int)
RETURNS TABLE(f1 int, f2 text) AS $$
	select $1, cast($1 as text) || ' is text';
$$ LANGUAGE SQL;

SELECT * FROM three(29);

CREATE OR REPLACE FUNCTION fms.four(IN int)
RETURNS TABLE(f1 int, f2 text) AS $$
begin
return query 
	select $1, cast($1 as text) || ' is text';
end;
$$ LANGUAGE plpgsql;

SELECT * FROM fms.four(29);


CREATE OR REPLACE FUNCTION fms.get_weight(weight NUMERIC)
RETURNS TEXT AS $$
	select
	case 
		when weight >= 1000 then '합격'
		else '불합격'
	end;
$$ LANGUAGE SQL;

SELECT get_weight(1000);


CREATE OR REPLACE FUNCTION fms.get_weight_pass(weight NUMERIC)
RETURNS TEXT AS $$
declare
	result text;
begin
	case 
		when weight >= 1000 then 
			result := '합격';
		else 
			result := '불합격';
	end case;
	return result;
end;
$$ LANGUAGE plpgsql;

SELECT get_weight_pass(800);

-- if 조건문 사용
CREATE OR REPLACE FUNCTION fms.get_weight_pass2(weight NUMERIC)
RETURNS TEXT AS $$
declare
	result text;
begin
	if weight >= 1000 then 
		result := '합격';
	else 
		result := '불합격';
	end if;
	return result;
end;
$$ LANGUAGE plpgsql;

SELECT get_weight_pass2(800);

-- 반복문
CREATE OR REPLACE FUNCTION fms.print_loop(n integer)
RETURNS void AS $$
declare
	i integer :=1 ;
begin
	while i <= n LOOP
	raise notice 'Loop: %', i;
	i := i + 1;
	end loop;
end;
$$ LANGUAGE plpgsql;

SELECT print_loop(10);


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


SELECT 
    ci.farm,
    sr.customer,
    COUNT(*) AS shipped_count
FROM fms.prod_result pr
JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
WHERE pr.pass_fail = 'P'
GROUP BY ci.farm, sr.customer;


CREATE OR REPLACE FUNCTION fms.get_farm_ship_summary(farm_name VARCHAR)
RETURNS TABLE(
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
		and ci.farm = farm_name -- 매개변수에 따라서 동작하도록 추가
	GROUP BY ci.farm, sr.customer;
$$ LANGUAGE SQL;

SELECT * FROM get_farm_ship_summary('B');

SELECT 
	    ci.farm,
	    sr.customer,
	    COUNT(*) AS shipped_count
	FROM fms.prod_result pr
	JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
	JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
	WHERE pr.pass_fail = 'P'
		and ci.farm = 'B'
	GROUP BY ci.farm, sr.customer;

CREATE OR REPLACE FUNCTION decode_chick_info(p_chick_no VARCHAR)
RETURNS TABLE (
    farm VARCHAR,  -- 
    birth_year INT,
    gender VARCHAR  --
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUBSTRING(p_chick_no, 1, 1)::VARCHAR,
        CAST('20' || SUBSTRING(p_chick_no, 2, 2) AS INT),
        CASE
            WHEN CAST(RIGHT(p_chick_no, 1) AS INT) % 2 = 1 THEN 'Male'::VARCHAR
            ELSE 'Female'::VARCHAR
        END;
END;
$$ LANGUAGE plpgsql;

-- 실행 예시:
SELECT * FROM decode_chick_info('A2300009');


CREATE TABLE fms.breeds_prod_tbl (
prod_date date NOT NULL,
breeds_nm character(20) NOT NULL,
total_sum bigint NOT NULL,
save_time timestamp without time zone NOT NULL
);

COMMENT ON TABLE fms.breeds_prod_tbl IS '품종별 생산실적';

SELECT prod_data, breed_nm, total_sum, CURRENT_TIMESTAMP AS save_time
FROM fms.breeds_prod
WHERE prod_data = '2023-01-31'

INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
(
	SELECT prod_data, breed_nm, total_sum, CURRENT_TIMESTAMP AS save_time
	FROM fms.breeds_prod
	WHERE prod_data = '2023-01-31'
);


CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc()
LANGUAGE SQL
AS $$
	INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
	(
		SELECT prod_data, breed_nm, total_sum, CURRENT_TIMESTAMP AS save_time
		FROM fms.breeds_prod
		WHERE prod_data = '2023-01-31'
	);
$$;

CALL fms.breeds_prod_proc();

CREATE EXTENSION pgagent;

------------------------------------------------------
------------------------------------------------------
--Day4

------------------------------------------------------
-- 여기서부터
------------------------------------------------------

-- 함수로 변경

--CREATE OR REPLACE FUNCTION fms.breeds_prod_func()
--RETURNS void AS $$
--BEGIN
--	INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
--		SELECT prod_data, breed_nm, total_sum, CURRENT_TIMESTAMP AS save_time
--		FROM fms.breeds_prod
--		WHERE prod_data = '2023-01-31';
--END;
--$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fms.breeds_prod_func(date_param date)
RETURNS void AS $$
BEGIN
	INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
		SELECT prod_data, breed_nm, total_sum, CURRENT_TIMESTAMP AS save_time
		FROM fms.breeds_prod
		WHERE prod_data = date_param; -- '2023-01-31';
END;
$$ LANGUAGE plpgsql;

-- 실행 예시:
--SELECT * FROM fms.breeds_prod_func();

SELECT * FROM fms.breeds_prod_func('2023-02-01');
SELECT * FROM fms.breeds_prod_func(CURRENT_DATE);

---------------------------------------------
CREATE OR REPLACE FUNCTION fms.breeds_prod_functocsv(date_param date)
RETURNS TABLE (prod_date date, breeds_nm varchar, total_sum bigint, save_time timestamp)
AS $$
	SELECT prod_data, breed_nm, total_sum, CURRENT_TIMESTAMP AS save_time 
	FROM fms.breeds_prod
	WHERE prod_data = date_param;
$$ LANGUAGE SQL;

SELECT * from fms.breeds_prod_functocsv('2023-02-01');

----------------------------------------------------------------------
SELECT
    ci.farm,
    sr.customer,
    COUNT(*) AS shipped_count
FROM fms.prod_result pr
JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
WHERE pr.pass_fail = 'P' AND ci.farm = 'A'
GROUP BY ci.farm, sr.customer;


CREATE OR REPLACE FUNCTION fms.func_farm_ship_summary_to_file(
    farm_param varchar,
    file_path_param varchar
)
RETURNS void AS $$
DECLARE
    v_sql text;
BEGIN
    -- 쿼리 결과를 CSV 형식으로 서버 파일 시스템에 저장하는 동적 SQL 생성
    v_sql := 'COPY (
        SELECT
            ci.farm,
            sr.customer,
            COUNT(*) AS shipped_count
        FROM fms.prod_result pr
        JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
        JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
        WHERE pr.pass_fail = ''P'' AND ci.farm = ' || quote_literal(farm_param) || '
        GROUP BY ci.farm, sr.customer
    ) TO ' || quote_literal(file_path_param) || ' WITH (FORMAT CSV, HEADER TRUE, DELIMITER '','');';
    
    -- 동적 SQL 실행
    EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

SELECT fms.func_farm_ship_summary_to_file('A', 'C:/Users/Public/farm_a_summary.csv');


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
-----------------------------------------------------

CREATE OR REPLACE PROCEDURE fms.proc_count_by_breed(
    IN breed_name VARCHAR,
    OUT count_result INTEGER  -- OUT 파라미터를 사용하여 결과 반환
) AS $$
BEGIN
    -- 결과를 OUT 파라미터에 직접 할당
    SELECT COUNT(*) INTO count_result
    FROM fms.chick_info
    WHERE breeds = breed_name;
    
    -- 프로시저는 RETURN 문을 사용하여 값을 반환하지 않습니다.
    -- 대신 OUT 파라미터에 값이 할당된 상태로 프로시저가 종료됩니다.
END;
$$ LANGUAGE plpgsql;

--프로시저 호출
CALL fms.proc_count_by_breed('C1', NULL);
------------------------------------------------------
-- 아래 프로시저를 테스트하기 위한 테스트용 데이터 입력

SELECT * FROM fms.chick_info;
-- 1. 먼저 fms.chick_info 테이블에 'B2510001' 닭 정보를 삽입합니다.
-- (chick_info 테이블의 실제 컬럼 구조에 맞게 수정해야 합니다.)

INSERT INTO fms.chick_info (chick_no, breeds, gender, hatchday, egg_weight, vaccination1, vaccination2, farm ) 
VALUES ('B2510001', 'D1', 'M', '2025-09-19', 65, 1, 1, 'B'); 

----------------------------------------------------------------------

-- 2. chick_info에 삽입 후, prod_result에 데이터 삽입합니다.
INSERT INTO fms.prod_result (chick_no, prod_date, raw_weight, disease_yn, size_stand, pass_fail)
VALUES ('B2510001', '2025-10-19', 1100, 'N', 11, 'P');

-- 3. 생산된 닭을 출하하는 프로세스 생성
CREATE OR REPLACE PROCEDURE fms.process_shipment(
    IN p_chick_no VARCHAR,      -- 병아리 번호
    IN p_ship_date DATE,        -- 출고 날짜
    IN p_customer VARCHAR       -- 고객사
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. 검수 결과 확인 (pass_fail = 'P'인지)
    PERFORM 1 
    FROM fms.prod_result 
    WHERE chick_no = p_chick_no 
      AND pass_fail = 'P';
    
    IF NOT FOUND THEN
		-- 오류 메시지를 서버 로그에 기록 (선택적)
        RAISE LOG 'ERROR: 검수 불합격된 병아리 출고 시도. chick_no: %, customer: %', p_chick_no, p_customer;
        RAISE EXCEPTION '등록되지 않은 병아리거나 검수 불합격된 병아리입니다. chick_no: %', p_chick_no;
    END IF;

    -- 2. ship_result 테이블에 출고 정보 삽입
    INSERT INTO fms.ship_result (chick_no, order_no, customer, due_date, destination )
    VALUES (p_chick_no, 'N001', p_customer, p_ship_date, '안양');

    -- 3. ship_result 테이블의 arrival_date 상태를 due_date로 업데이트
    UPDATE fms.ship_result
    SET arrival_date = p_ship_date
    WHERE chick_no = p_chick_no;

EXCEPTION
    WHEN OTHERS THEN
		-- 예상치 못한 다른 모든 오류를 서버 로그에 기록
        RAISE LOG 'UNEXPECTED ERROR: 출고 처리 중 예상치 못한 오류 발생. chick_no: %, SQLSTATE: %, MESSAGE: %', 
            p_chick_no, SQLSTATE, SQLERRM;
        RAISE;
END;
$$;
-- 오류가 발생하는 콜
CALL fms.process_shipment('B2310019', '2025-10-20', 'NONO'); -- Fail난 병아리
CALL fms.process_shipment('B2310100', '2025-10-20', 'NONO'); -- 없는 병아리

-- 정상적인 콜
CALL fms.process_shipment(
    p_chick_no := 'B2510001', 
    p_ship_date := '2025-10-20', 
    p_customer := 'NONO'
);

--SELECT * FROM fms.ship_result;

SHOW log_directory;  -- 로그 파일이 저장되는 디렉토리
SHOW log_filename;   -- 로그 파일 이름 형식
SHOW data_directory; -- PostgreSQL 데이터 디렉토리의 기본 경로
-----------------------------------------------
-- 로그 테이블이 없으면 먼저 생성
CREATE TABLE IF NOT EXISTS fms.prod_log (
    log_id SERIAL PRIMARY KEY,
    chick_no VARCHAR(20) NOT NULL,
    prod_date DATE NOT NULL,
    old_weight NUMERIC,
    new_weight NUMERIC,
    logged_at TIMESTAMP
);

-- 프로시저 생성
CREATE OR REPLACE PROCEDURE fms.update_and_log_prod_weight(
    p_chick_no VARCHAR,
    p_prod_date DATE,
    p_raw_weight NUMERIC
) AS $$
DECLARE
    v_old_weight NUMERIC;
	v_log_message TEXT;
BEGIN
    -- 현재 체중 조회
    SELECT raw_weight INTO v_old_weight
    FROM fms.prod_result
    WHERE chick_no = p_chick_no AND prod_date = p_prod_date;

	IF NOT FOUND THEN
        -- 1. PostgreSQL 서버 로그에 남기기
        RAISE WARNING '경고: 업데이트 대상 행이 없습니다. chick_no: %, prod_date: %', p_chick_no, p_prod_date;
        
        -- 2. prod_log 테이블에 '업데이트 실패' 로그 남기기
        v_log_message := '업데이트 대상 행 없음: ' || p_chick_no || ' (' || p_prod_date || ')';
        
        -- fms.prod_log 테이블을 재활용하여 로그 기록 (new_weight에는 NULL을 남김)
        INSERT INTO fms.prod_log (chick_no, prod_date, old_weight, new_weight, logged_at)
        VALUES (p_chick_no, p_prod_date, NULL, NULL, NOW());
        
        -- **필요하다면** 여기서 EXIT; 또는 RETURN; 을 사용하여 프로시저 종료
        RETURN; 
    END IF;

    -- 체중 업데이트
    UPDATE fms.prod_result
    SET raw_weight = p_raw_weight
    WHERE chick_no = p_chick_no AND prod_date = p_prod_date;

    -- 로그 테이블에 기록
    INSERT INTO fms.prod_log (chick_no, prod_date, old_weight, new_weight, logged_at)
    VALUES (p_chick_no, p_prod_date, v_old_weight, p_raw_weight, NOW());

END;
$$ LANGUAGE plpgsql;

-- 실행 예시: B2300020, 2023-02-02
CALL fms.update_and_log_prod_weight('C2310014', '2023-01-25', 1500); -- 없는번호
CALL fms.update_and_log_prod_weight('B2300020', '2023-02-02', 1500);

SHOW log_min_messages;

SELECT datname, pg_encoding_to_char(encoding), datcollate, datctype FROM pg_database;
SHOW server_encoding;
SHOW data_directory;
SHOW config_file;
----------------------------------
-- 트리거 관련

-- 트리거 동작시 사용할 테이블 생성 health_cond 테이블 업데이트 시 변경 이력 자동 기록
-- 1. 감사 로그 테이블 생성
CREATE TABLE fms.health_cond_audit(
	audit_id SERIAL PRIMARY KEY,
	chick_no varchar(20) NOT null,
	old_body_temp NUMERIC(4, 1),
	new_body_temp NUMERIC(4, 1),
	check_date date,
	modified_at timestamp DEFAULT CURRENT_TIMESTAMP,
	operation varchar(10)
);

-- 2. 트리거 함수 정의
CREATE OR REPLACE FUNCTION fms.log_health_changes()
RETURNS TRIGGER AS $$
BEGIN
	RAISE NOTICE '트리거 호출됨. TG_OP = %', TG_OP;

	IF TG_OP = 'UPDATE' THEN -- 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE' 중 하나의 문자열 값
		RAISE NOTICE 'UPDATE 트리거 실행 중: % -> %', OLD.body_temp, NEW.body_temp;
		-- OLD: 트리거 이벤트가 발생하기 전(변경되기 전)의 행(Row) 데이터를 참조하는 특수 레코드 변수
		-- NEW: 트리거 이벤트가 발생한 후(변경될 예정인) 행 데이터를 참조하는 특수 레코드 변수
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
	RETURN NEW; -- 행 수준(FOR EACH ROW) 트리거 함수는 항상 레코드 값을 반환해야 합니다.
	-- UPDATE 또는 INSERT 트리거에서 NEW 레코드를 반환하면, PostgreSQL은 이 반환된 레코드를 데이터베이스에 최종적으로 저장합니다.
	-- 만약 RETURN NULL을 반환하면, 해당 이벤트로 인한 행 변경 작업은 취소됩니다.
END;
$$ LANGUAGE plpgsql;



-- 3. 트리거 등록
CREATE TRIGGER health_audit_trigger2
AFTER UPDATE ON fms.health_cond
FOR EACH ROW
EXECUTE FUNCTION fms.log_health_change();


UPDATE fms.health_cond
SET body_temp = 45
WHERE chick_no ='B2310019' AND check_date = '2023-01-10';




CREATE TRIGGER health_changes_trigger
AFTER UPDATE ON fms.health_cond -- health_cond 테이블의 UPDATE 이벤트 발생 후
 -- AFTER: 실제 데이터베이스 테이블에 변경 사항이 적용된 후에 함수를 실행합니다. (BEFORE는 변경 전에 실행되어 데이터를 수정하거나 작업을 취소할 수 있습니다.)
FOR EACH ROW                      -- 행 단위로 트리거 실행, 트리거 함수를 실행할 단위를 정의
-- - FOR EACH ROW: UPDATE 명령으로 인해 변경된 행 하나하나마다 fms.log_health_changes() 함수를 실행합니다. (이전 함수에서 OLD와 NEW를 사용했기 때문에 필수적인 설정입니다.)
-- (FOR EACH STATEMENT: 명령문 한 번 실행당 함수를 한 번만 실행합니다. 행 단위 변경을 추적할 때는 부적합합니다.)
EXECUTE FUNCTION fms.log_health_changes(); -- 트리거가 발동되었을 때 실제로 수행할 작업을 지정
-- fms.log_health_changes(): 이전에 정의한 트리거 함수를 실행합니다. 이 함수는 자동으로 OLD와 NEW 변수를 받아 감사 로그 테이블(fms.health_cond_audit)에 변경 이력을 INSERT하는 역할을 수행합니다.

-- 실행 결과 예시
UPDATE fms.health_cond
SET body_temp = 40.1
WHERE chick_no = 'A2300013' AND check_date = '2023-01-10';

SELECT * FROM fms.health_cond_audit;


-- 트리거 만들기
env_cond 환경을 관리하는 테이블에 이상 데이터가 입력될 때(습도 값이 허용 범위(55~75)를 벗어나면) 이러한 이상치를 감지 하는 트리거

예를 들어
INSERT INTO fms.env_cond 
(farm, date, temp, humid) 
VALUES ('B', '2023-01-25', 21, 60); --> 로그기록안됨

INSERT INTO fms.env_cond 
(farm, date, temp, humid) 
VALUES ('B', '2023-01-25', 21, 85);
-- 위와 같이 너무 높은 습도가 입력이 되면 트리거함수가 동작하면서 
--이상치를 감지하는 테이블에 아래와 같이 데이터가 입력된다. 
--reason 컬럼에는 조건문을 통해 특정 습도보다 높으면 '습도 과다'
--혹은 특정 온도보다 높으면 '고온 다습'

anomaly_id  farm 	check_date 	temp 	humid 	reason 		detected_at
(자동증가)		'B' 	2023-01-25 	21 		85 		'습도 과다' 	(현재 시각, 자동 입력)

-------------------------------------------------
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
--------------------------------------------------------
CREATE OR REPLACE FUNCTION get_chickinfo_table()
RETURNS TABLE(chick_no VARCHAR, egg_weight NUMERIC) AS $$
SELECT chick_no, egg_weight FROM fms.chick_info;
$$ LANGUAGE SQL;

SELECT * FROM get_chickinfo_table();

---------------------------------------
-- 인덱스 관련

-- 1. 테이블 생성
CREATE TABLE users (
id SERIAL PRIMARY KEY,
name VARCHAR(100),
email VARCHAR(100),
signup_date DATE
);

-- 2. 데이터 삽입 (100만 행)
INSERT INTO users (name, email, signup_date)
SELECT
'User ' || ((i % 100) + 1)::text,
'user' || i || '@example.com',
NOW() - (random() * (365 * 5) || ' days')::interval
FROM generate_series(1, 1000000) AS s(i);

SELECT * FROM users WHERE name = 'User '||'77' ;

EXPLAIN (ANALYZE, VERBOSE, BUFFERS)
SELECT * FROM users WHERE name = 'User '||'77' ;

SHOW max_parallel_workers_per_gather;
SHOW max_worker_processes;

-- 3. 병렬 처리 비활성화 (실습 환경 통일)
SET max_parallel_workers_per_gather = 0;

-- 인덱스 실습을 위한 테이블 새로 생성

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

SELECT relname, relkind, reltuples, relpages FROM pg_class WHERE relname = 'bank';

EXPLAIN ANALYZE SELECT * FROM bank;

EXPLAIN ANALYZE SELECT * FROM bank
WHERE client_no BETWEEN 850 AND 855;

EXPLAIN ANALYZE 
SELECT * FROM bank
WHERE gender='F' AND age BETWEEN 66 AND 67;

CREATE INDEX bank_gender_idx ON bank(gender, age);

EXPLAIN ANALYZE 
SELECT * FROM bank
WHERE gender='F' AND age BETWEEN 66 AND 67;

EXPLAIN (ANALYZE, format json) 
SELECT * FROM bank
WHERE gender='F' AND age BETWEEN 66 AND 67;