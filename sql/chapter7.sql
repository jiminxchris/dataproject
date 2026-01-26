/* Chapter 7. 사례기반 실습 */

-- 1. 조류독감이 의심되는 닭을 찾아보자

SELECT * FROM fms.health_cond ORDER BY body_temp DESC;
--조류독감의 특징으로 사료섭취량 감소 및 호흡수 증가, 체온 상승이 있다. 
--이런 데이터는 건강상태(headlth_cond) 테이블에 저장되어 있다. 
--건강상태는 10일에 한번씩 체크했기 때문에 동일한 육계번호에 총 3건의 데이터가 존재한다. 닭은 성장함에 따라 사료섭취량이 늘고, 호습수가 줄어들며, 40.6~41.7도의 체온 범위를 가진다. 
--이런 기초 지식하에 조류독감이 의심되는 닭을 찾아보도록 하자.
--아무래도 온도가 가장 큰 특징이기 때문에 체온을 기준으로 내림차순 정렬해 데이터를 살펴보도록 하자

--체온을 내림차순으로 정렬해 확인해 본 결과 41.7보다 높은 닭이 2마리 있는 것을 확인할 수 있다. 
--1월 30일 검사일자를 기준으로 해당 개체들의 사료섭취량이 다른 개체들보다 낮고, 호흡수는 높은 것을 알 수 있다. 특히 19번의 경우 설사 증상도 있고 노트에 체온이 45도를 넘어가고 호흡수가 빠르며 사료섭취량이 20%가량 줄었음 이라는 특이사항 또한 입력되어 있다. 
--ORDER BY 절을 이용한 간단한 쿼리로 빠르고 쉽게 조류독감이 의심되는 닭을 찾을 수 있었다. 하지만 차후 체온이 아닌 다른 특징들만 발현되었을 경우를 대비해 다양한 조건으로 필터링할 수 있는 조건을 필터링 해보자. 


-- 대략적으로 체온이 41.7도 보다 높거나 호흡수가 70보다 크거나, 사료섭취량이 100보다 작은 친구들을 필터링해서
-- 건강정보 테이블의 모든 컬럼과 백신을 맞았는지 출력
SELECT
	b.*,
	a.vaccination1, a.vaccination2
FROM
	fms.chick_info a,
	fms.health_cond b
WHERE a.chick_no = b.chick_no
	AND b.check_date = '2023-01-30'
	AND (b.body_temp > 41.7 OR b.breath_rate > 70 OR b.feed_intake < 100);

--다행히도 조류독감이 의심되던 닭 2마리 모두 단순 질병인 것으로 검사 결과가 나왔다. 그중 한마리는 2회의 예방접종을 하지 않았으나 다른 한 마리는 예방접종을 모두 했음에도 불구하고 건강상태가 나빠졌다. 왜 이런 일이 발생했는지 알아보자. 

-- 2. 건강상태가 나빠진 원인을 찾아보기
SELECT * FROM fms.health_cond ORDER BY body_temp DESC;

--B2300009의 경우 예방접종도 모두 했으나 1월 30일 검사결과 체온이 올라가고 사료 섭취량이 줄어드는 등 건강상태가 나빠졌다. 이런 문제가 발생한 것은 해당 병아리 자체의 유전적 요인 또는 기타 환경적 요인에 의한 것으로 추정된다. 유전적 요인은 파악이 어려우므로 환경적 요인에 대해서 조사해보도록 하자. 
--사육환경 테이블에는 사육장별로 매일 기온, 습도, 점등시간, 조도 데이터가 저장되어 있다. 
--사육장 환경이 병아리의 성장에 따라 적절히 조절되지 않으면 닭으로 성장하는데 문제가 발생할 수 있어 철저히 관리해야 한다. 
--특히 온도의 경우 처음에는 35도로 높게 시작했다가 병아리가 성장하면서 21도 수준으로 낮추어야 한다. 습도의 경우는 60% 수준으로 일정하게 유지되어야 한다. 이런 배경 지식하에 사육환경 테이블의 데이터를 전체적으로 한번 살펴보자. 

SELECT * FROM fms.env_cond;

--데이터 확인 결과 위의 그림과 같이 1월 25일의 경우 습도계와 조도계 데이터 전송에 문제가 있었는지 테이블에 데이터가 저장되지 않았고, 나머지는 데이터가 정상적으로 입력되어 있었다. 
--사육환경 테이블의 데이터를 기준으로 B2300009의 건강상태 데이터 일부만 JOIN시켜 살펴보도록 하자

-- env_cond 테이블과 health_cond 테이블 에서 
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

--데이터 확인 결과 위의 그림과 같이 육계번호 B2300009의 경우 1월 20일 검사 시점까지는 체온에 큰 변화가 없었으나 
--1월 30일 검사에서는 체온이 2.6도 올라갔음을 확인할 수 있다. 그리고 해당 시점 사이인 1월 23일과 24일에는 습도가 60%로 유지되지 못하고 80%, 70%가 되기도 했다. 확인할 수 있는 데이터의 한계로 건강상태가 나빠진 정확한 원인은 알 수 없지만 주어진 데이터를 기반으로 추정해 본다면 B2300019를 제외한 사육장 B에 있던 수많은 육계들 중 B2300009 혼자만 건강 상태가 나빠진 이유는 해당 개체가 습도에 민감한 유전적 문제를 가진 것이 아니었을까 생각된다. 


-- 3. 품종별 가장 무거운 닭 Top 3를 골라보자

--우리 양계장에서는 4가지 품종의 닭을 사육하고 있다. 육계 생산량을 늘리기 위해서는 종란무게, 사육환경, 품종별 특징 등의 변수를 적절히 관리해야 한다. 
--품종별로 중량이 많이 나가는 닭 3마리씩을 표본으로 뽑아서 해당 닭의 특징을 분석해 생산량을 늘릴 수 있는 방법에 대해서 고민해보자. 

--생산실적 prod_result 테이블에는 생닭중량 데이터가 있고, 유계정보 chick_info 테이블에는 품종코드가 존재한다. 먼저 두 테이블을 JOIN 시켜 원하는 열을 출력할 수 있게 쿼리를 작성해본다. 

-- 아래 쿼리는 걍 조인
SELECT
a.chick_no, a.breeds, b.raw_weight
FROM
fms.chick_info a,
fms.prod_result b
WHERE a.chick_no = b.chick_no;

-- 3. 품종별 가장 무거운 닭 Top 3를 골라보자
SELECT
a.chick_no, a.breeds, b.raw_weight
FROM
fms.chick_info a,
fms.prod_result b
WHERE a.chick_no = b.chick_no
AND a.breeds = 'B1'
ORDER BY b.raw_weight DESC
LIMIT 3;

이제 품종별로 생닭중량을 내림차순 정렬해 무거운 순서대로 3마리씩만 출력되게 만들어야 한다. 
그런데 LIMIT 절을 이용해 3을 지정하면 전체에서 TOP3만 선택되기 때문에 품종별로 생닭중량 Top 3를 뽑으려면 다음과 같이 특정 품종을 지정해 쿼리를 작성한 후 UNION을 이용해 4개 품종을 행을 기준으로 합쳐야 한다. 

이럴 경우를 위해 그룹별 순서를 저장할 수 있는 함수가 존재하며 사용법은 다음과 같다. 

원래 ROW_NUMBER() OVER() 함수는 행 번호를 생성해 주는 함수인데 여기서 PARTITION BY 뒤에 그룹 기준이 되는 열 이름을 지정하고, ORDER BY 뒤에 정렬 기준이 되는 열 이름을 지정하면 그룹별로 정렬 기준에 따라 순서대로 행 번호가 생성된다. 이후 WHERE  절에 행 번호의 제한을 걸면 원하는 결과를 얻을 수 있다. 실습에서 그룹 기준이 되는 열은 품종(breeds)이고, 정렬 기준이 되는 열은 생닭중량(raw_weight)이다. 단 생닭중량을 내림차순 정렬하는 것에 유의해 SQL을 작성하면 다음과 같다. 


SELECT x.*
FROM
(
	SELECT
	a.chick_no, a.breeds, b.raw_weight,
	ROW_NUMBER() OVER(PARTITION BY a.breeds ORDER BY b.raw_weight DESC) "rn"
	FROM
	fms.chick_info a,
	fms.prod_result b
	WHERE a.chick_no = b.chick_no
) x
WHERE x.rn <= 3;

-- 비슷하게 아래와 같이 작성 가능
SELECT chick_no, breeds, raw_weight, weight_rank
FROM (
  SELECT 
    ci.breeds,
    pr.chick_no,
    pr.raw_weight,
    ROW_NUMBER() OVER (PARTITION BY ci.breeds ORDER BY pr.raw_weight DESC) AS weight_rank
  FROM fms.prod_result pr
  JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
) AS ranked_chickens
WHERE weight_rank <= 3
ORDER BY breeds, weight_rank;

-- 4. 여러 테이블의 데이터를 연결해 종합실적을 조회하기

--여러 테이블의 데이터를 연결해 종합실적 조회하기
--
--이제 우리는 육계별 생산 및 출하 정보를 한번에 볼 수 있는 종합실적 모니터링 화면의 개발 필요성을 느꼈다. 다양한 테이블에 저장되어 있는 데이터를 연결시켜 죄종적으로 원하는 데이터를 한번에 볼 수 있도록 쿼리를 작성해 보자. 
--
--현재 실습을 위해 구성된 테이블 구조의 경우 목적에 따라 테이블이 분리되어 있기 때문에 종합적인 실적을 한번에 보기 위해서는 여러 테이블을 JOIN해야 한다. 그리고 마스터코드(master_code) 테이블이나 단위(unit) 테이블에서 코드의 의미나 데이터의 단위를 가져오기 위해서는 서브쿼리를 사용하는 것이 좋다. 
--먼저 육계정보(chick_info) 테이블의 육계번호(chick_no)를 기준으로 건강상태(health_cond), 생산실적(prod_result), 출하실적(ship_result)의 3개의 테이블을 LEFT JOIN 시키고, 육계정보(chick_no), 품종(breeds), 종란무게(egg_weight), 체온(body_temp), 호흡수(breath_rate), 호수(size_stand), 부적합여부(pass_fail), 주문번호(order_no), 고객사(customer), 도착일(arrival_date), 도착지(destination)가 출력될 수 있게 쿼리를 작성해보자. 단 건강상태 테이블에는 총 3번의 검사일자(check_date)가 존재하기 때문에 마지막 검사일자(2023-01-30)에 해당되는 값만 출력되도록 WHERE 절에 조건을 추가하자. 


SELECT
a.chick_no, a.breeds, a.egg_weight,
b.body_temp, b.breath_rate,
c.size_stand, c.pass_fail,
d.order_no, d.customer, d.arrival_date, d.destination
FROM
fms.chick_info a 
LEFT OUTER JOIN fms.health_cond b ON a.chick_no = b.chick_no
LEFT OUTER JOIN fms.prod_result c ON a.chick_no = c.chick_no
LEFT OUTER JOIN fms.ship_result d ON a.chick_no = d.chick_no
WHERE b.check_date = '2023-01-30';

-- 4. 여러 테이블의 데이터를 연결해 종합실적을 조회하기 2

--3개 이상의 테이블을 조인할 경우에는 기준이 되는 테이블을 두고, JOIN문으로 연결할 테이블들을 차례대로 입력하면된다. 이제 화면에 출력되는 열 이름을 한글로 변환하고, 코드의 의미나 단위를 마스터코드와 단위 테이블에서 가져오는 서브쿼리를 작성해 지금보다 알아보기 쉽게 표현해보자. 

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
-- 닭의 체온은 최종검사일 기준으로다가 저장~~

-- 5. 종합실적을 뷰 테이블로 만들어보기
--앞서 작성한 종합실적 쿼리로 뷰 테이블을 만들어 쉽고 빠르게 종합실적을 조회할 수 있도록 해보자.

CREATE OR REPLACE VIEW fms.total_result
 AS
 SELECT a.chick_no AS "육계번호",
    ( SELECT m.code_desc AS "품종"
           FROM fms.master_code m
          WHERE m.column_nm::text = 'breeds'::text AND m.code::bpchar = a.breeds) AS "품종",
    a.egg_weight || ((( SELECT u.unit
           FROM fms.unit u
          WHERE u.column_nm::text = 'egg_weight'::text))::text) AS "종란무게",
    b.body_temp || ((( SELECT u.unit
           FROM fms.unit u
          WHERE u.column_nm::text = 'body_temp'::text))::text) AS "체온",
    b.breath_rate || ((( SELECT u.unit
           FROM fms.unit u
          WHERE u.column_nm::text = 'breath_rate'::text))::text) AS "호흡수",
    ( SELECT m.code_desc AS "호수"
           FROM fms.master_code m
          WHERE m.column_nm::text = 'size_stand'::text AND to_number(m.code::text, '99'::text) = c.size_stand::numeric) AS "호수",
    ( SELECT m.code_desc AS "부적합여부"
           FROM fms.master_code m
          WHERE m.column_nm::text = 'pass_fail'::text AND m.code::bpchar = c.pass_fail) AS "부적합여부",
    d.order_no AS "주문번호",
    d.customer AS "고객사",
    d.arrival_date AS "도착일",
    d.destination AS "도착지"
   FROM fms.chick_info a
     LEFT JOIN fms.health_cond b ON a.chick_no = b.chick_no
     LEFT JOIN fms.prod_result c ON a.chick_no = c.chick_no
     LEFT JOIN fms.ship_result d ON a.chick_no = d.chick_no
  WHERE b.check_date = '2023-01-30'::date;

ALTER TABLE fms.total_result
    OWNER TO postgres;
COMMENT ON VIEW fms.total_result
    IS '종합실적';

-- 뷰 테이블 조회하기
select * from fms.total_result;

-----------------------------------------------------------------------
-- 건강 이상 탐지 함수
-- 체온이나 사료섭취량을 기준으로 건강 이상을 탐지합니다.
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

---------------------------------------------------------------

-- 건강 리포트 테이블 생성 (health_cond 데이터 기반)
CREATE TABLE IF NOT EXISTS fms.health_report (
    chick_no VARCHAR(20) NOT NULL,
    check_date DATE NOT NULL,
    body_temp NUMERIC(3,1),
    feed_intake INT,
    is_unhealthy BOOLEAN
);

--건강 이상 개체 자동 리포트 생성
-- 최근 건강 상태를 자동으로 리포트 테이블에 저장합니다.
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
-- health_report 테이블은 프로시저 실행 시 최근 검사일자(2023-01-30) 데이터만 저장

SELECT * FROM fms.health_report WHERE is_unhealthy=True;
DELETE FROM fms.health_report;
-----------------------------------------------------------
-- 환경 데이터 이상 시 경고 메시지 발송
--온도, 습도 등 환경 데이터가 기준을 벗어나면 경고 메시지를 기록합니다.

-- 환경 경고 로그 테이블 생성
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
-- alert_log는 환경 데이터(temp, humid)가 기준치 벗어날 때마다 기록

SELECT * FROM fms.alert_log;
DELETE FROM fms.alert_log;

------------------------------------------------------
3. 잡(Job) 예제
매일 건강 데이터 집계 및 리포트 자동화
예시: crontab 또는 DB 스케줄러(예: pgAgent, Oracle Scheduler 등)에서 매일 자정에 아래 쿼리 실행
CALL generate_health_report();
매일 자동으로 건강 리포트를 생성합니다.

주간 환경 데이터 점검
예시: 매주 월요일 아침에 아래 프로시저 실행
CALL check_env_condition();
주간 환경 점검을 자동화합니다.