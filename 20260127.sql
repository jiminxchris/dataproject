SELECT
	a.chick_no, a.breeds,
	b.code_desc "breeds_nm"
FROM
	fms.chick_info a,
	fms.master_code b
WHERE 
	a.breeds = b.code
	AND b.column_nm = 'breeds';

SELECT
  a.chick_no, a.breeds,
  b.code_desc AS "breeds_nm"
FROM
  fms.chick_info a
INNER JOIN
  fms.master_code b
ON
  a.breeds = b.code
WHERE
  b.column_nm = 'breeds';


SELECT code, code_desc
FROM fms.master_code
WHERE column_nm='breeds';

SELECT a.chick_no, a.breeds,
(
	SELECT m.code_desc
	FROM fms.master_code m
	WHERE m.column_nm='breeds'
	AND m.code = a.breeds
)
FROM fms.CHICK_INFo a;

SELECT a.chick_no, a.breeds, 
b.code_desc
FROM fms.CHICK_INFo a,
(
	SELECT code, code_desc
	FROM fms.master_code
	WHERE column_nm='breeds'
) b
WHERE a.breeds = b.code;


CREATE OR REPLACE VIEW test_view
(chick_no, breeds, code_desc)
AS
SELECT a.chick_no, a.breeds, 
b.code_desc
FROM fms.CHICK_INFo a,
(
	SELECT code, code_desc
	FROM fms.master_code
	WHERE column_nm='breeds'
) b
WHERE a.breeds = b.code;

SELECT * FROM test_view;


SELECT 
    TO_CHAR(prod_date, 'YYYYMM') AS prod_month,
    SUM(CASE WHEN breeds_nm = 'Cornish' THEN total_sum ELSE 0 END) AS "Cornish_Total",
    SUM(CASE WHEN breeds_nm = 'Cochin'  THEN total_sum ELSE 0 END) AS "Cochin_Total",
    SUM(CASE WHEN breeds_nm = 'Brahma'  THEN total_sum ELSE 0 END) AS "Brahma_Total",
    SUM(CASE WHEN breeds_nm = 'Dorking'  THEN total_sum ELSE 0 END) AS "Dorking_Total",
    SUM(total_sum) AS monthly_total
FROM fms.breeds_prod
GROUP BY TO_CHAR(prod_date, 'YYYYMM')
ORDER BY prod_month DESC;


SELECT to_char(prod_date, 'YYYYMM') AS prod_month, 
	sum(
	CASE 
		WHEN breeds_nm = 'Brahma' THEN total_sum 
		ELSE 0		
	END	
	) AS "Brahma total",
	round(sum(
	CASE 
		WHEN breeds_nm = 'Brahma' THEN total_sum 
		ELSE 0		
	END	
	)*100 / sum(total_sum), 1) || '%' AS "Brahma portion",
	sum(total_sum) AS total_sum
FROM breeds_prod
GROUP by to_char(prod_date, 'YYYYMM');


SELECT 
	sr.arrival_date,
	sr.customer,
	mc.code_desc,
	count(distinct(sr.order_no)),
	count(sr.chick_no)
FROM ship_result sr
JOIN chick_info ci
ON sr.chick_no = ci.chick_no
JOIN master_code mc
ON ci.breeds = mc.code AND mc.column_nm='breeds' 
GROUP BY sr.arrival_date, sr.customer, mc.code_desc;

SELECT 
	sr.arrival_date,
	sr.customer,
	mc.code_desc,
	count(distinct(sr.order_no)),
	count(sr.chick_no)
FROM ship_result sr
JOIN chick_info ci
ON sr.chick_no = ci.chick_no
JOIN master_code mc
ON ci.breeds = mc.code AND mc.column_nm='breeds' 
GROUP BY sr.arrival_date, sr.customer, mc.code_desc;

SELECT
    sr.arrival_date AS ship_date,  
    sr.customer AS customer_nm,
    mc.code_desc AS breeds_nm,
    COUNT(DISTINCT sr.order_no) AS total_orders, 
    COUNT(sr.chick_no) AS total_chicks          
FROM
    fms.ship_result sr
INNER JOIN
    fms.chick_info ci ON sr.chick_no = ci.chick_no 
INNER JOIN
    fms.master_code mc ON ci.breeds = mc.code AND mc.column_nm = 'breeds' 
GROUP BY
    sr.arrival_date, sr.customer, mc.code_desc
ORDER BY
    ship_date, customer_nm;

SELECT
	hatchday, gender, count(chick_no)
FROM fms.chick_info
GROUP BY hatchday, gender;


-- pivot
SELECT
	hatchday, 
	sum(CASE WHEN gender = 'M' THEN count ELSE 0 END) "Male", 
	sum(CASE WHEN gender = 'F' THEN count ELSE 0 END) "Female"
FROM 
( SELECT
	hatchday, gender, count(chick_no)
	FROM fms.chick_info
	GROUP BY hatchday, gender
	order BY hatchday, gender DESC
)
GROUP BY hatchday;


CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM public.crosstab
(
'SELECT
	hatchday, gender, count(chick_no)
	FROM fms.chick_info
	GROUP BY hatchday, gender
	order BY hatchday, gender DESC'
) AS pivot_r(hatchday date,"Male" bigint, "Female" bigint);

-- unpivot
SELECT chick_no, body_temp, breath_rate, feed_intake
FROM fms.health_cond;

SELECT chick_no, 'body_temp' AS health, body_temp AS cond
FROM fms.health_cond
union
SELECT chick_no, 'breath_rate' AS health, breath_rate AS cond
FROM fms.health_cond
union
SELECT chick_no, 'feed_intake' AS health, feed_intake AS cond
FROM fms.health_cond;

SELECT chick_no, 
unnest(ARRAY['body_temp','breath_rate', 'feed_intake' ]) AS health,
unnest(ARRAY[body_temp, breath_rate,feed_intake ]) AS cond
FROM health_cond;


-- insert, update, delete
INSERT INTO master_code
VALUES 
('breeds', 'txt', 'N1', 'Ross'),
('breeds', 'txt', 'X1', 'Ross'),
('breeds', 'txt', 'Y1', 'Ross'),
('breeds', 'txt', 'Z1', 'Ross');

SELECT * FROM master_code
WHERE column_nm='breeds';

UPDATE master_code
SET code_desc = '수컷'
WHERE column_nm= 'gender' AND code='M';

SELECT * FROM master_code
WHERE column_nm='gender';

DELETE from master_code
WHERE column_nm = 'breeds' AND code = 'R2';
COMMIT;
ROLLBACK;

DELETE from master_code;

-- 트랜잭션

BEGIN;
UPDATE master_code
SET code_desc = 'Male'
WHERE column_nm= 'gender' AND code='M';
SAVEPOINT my_savepoint;
DELETE from master_code
WHERE column_nm = 'breeds' AND code = 'R2';
ROLLBACK TO my_savepoint;
COMMIT;

-- 함수기본
CREATE OR REPLACE FUNCTION fms.get_chick_count()
RETURNS integer 
AS 
$$
	select count(*) from chick_info;
$$ 
LANGUAGE SQL;

SELECT get_chick_count();

-- 미션1
SELECT c.farm,
       COUNT(CASE WHEN p.pass_fail = 'P' THEN 1 END) * 100.0 / COUNT(*) AS pass_rate
FROM prod_result p
JOIN chick_info c ON p.chick_no = c.chick_no
GROUP BY c.farm;

-- 미션2
SELECT h.chick_no, h.body_temp, c.farm
FROM fms.health_cond h
JOIN fms.chick_info c ON h.chick_no = c.chick_no
WHERE h.body_temp > (
    SELECT AVG(body_temp)
    FROM fms.health_cond
);

-- 미션3
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

-- 미션4
SELECT 
    prod_date, 
    COALESCE("Farm A", 0) AS "Farm A", 
    COALESCE("Farm B", 0) AS "Farm B", 
    COALESCE("Farm C", 0) AS "Farm C"
FROM public.crosstab(
	'SELECT pr.prod_date, ci.farm, COUNT(*) 
	FROM fms.prod_result pr
	JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
	GROUP BY pr.prod_date, ci.farm
	ORDER BY pr.prod_date, ci.farm'
) AS pivot_table(
	prod_date DATE, "Farm A" bigint, "Farm B" bigint, "Farm C" bigint
);

SELECT *
FROM public.crosstab(
	'SELECT pr.prod_date, ci.farm, COUNT(*) 
	FROM fms.prod_result pr
	JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
	GROUP BY pr.prod_date, ci.farm
	ORDER BY pr.prod_date, ci.farm'
) AS pivot_table(
	prod_date DATE, "Farm A" bigint, "Farm B" bigint, "Farm C" bigint
);
