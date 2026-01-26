
-- 이것슨 주석표시입니다.
SELECT * FROM fms.chick_info;

-- 액티브 스키마 설정
SET search_path TO fms;

SELECT chick_no AS no, breeds 품종 FROM chick_info;

SELECT chick_no, hatchday, egg_weight from chick_info ORDER BY egg_weight DESC, hatchday LIMIT 6 OFFSET 2;

SELECT count(*) FROM chick_info;
SELECT distinct(breeds) FROM chick_info;
SELECT count(distinct(breeds)) FROM chick_info;

SELECT now() - INTERVAL '1 day';
SELECT now() + INTERVAL '1 hour';

SELECT * from chick_info WHERE hatchday BETWEEN '2023-01-01' AND '2023-01-02';

SELECT * from chick_info WHERE breeds  = 'C1' OR breeds  = 'C2';

SELECT * from chick_info WHERE breeds  LIKE 'C%';

SELECT * from chick_info WHERE breeds  in ('C1', 'D1');

SELECT * FROM health_cond WHERE note IS not NULL;

UPDATE health_cond SET note= NULL WHERE trim(note) = '';

INSERT INTO 테이블명 ('A')
UPDATE env_cond SET humind = NULL 
WHERE farm='A' AND date = '2023-01-26';

SELECT chick_no, LEFT(chick_no, 1) 출신농장 FROM chick_info LIMIT 5;
SELECT farm || gender || breeds AS id
FROM chick_info;
SELECT chick_no, REPLACE(REPLACE(gender, 'M', 'Male'), 'F', 'Female') "성별" FROM chick_info;

SELECT breeds,
sum(egg_weight) total_weight,  avg(egg_weight) avg_weight,
max(egg_weight) max_weight,
min(egg_weight) min_weight,
count(*) AS total_count
FROM fms.chick_info
GROUP BY breeds;

SELECT prod_date,
avg(raw_weight) total_avg
FROM prod_result
GROUP BY prod_date
ORDER BY prod_date desc;

SELECT customer, count(*)
FROM ship_result
GROUP BY customer
HAVING count(*) >= 10;

-- arrival date가 2025-02-05 이후인 데이터에 대해서 출하건수가 8건 이상인 고객사만 필터링
SELECT customer, count(*)
FROM ship_result
WHERE arrival_date >= to_date('2023-02-05', 'YYYY-MM-DD')
GROUP BY customer
HAVING count(*) >= 8
ORDER BY customer desc;

SELECT now();

SELECT to_char(timestamp '2026-02-01', 'Dy');

SELECT hatchday, to_char(hatchday, 'Day')
FROM chick_info;

SELECT chick_no, egg_weight,
CASE
	WHEN egg_weight> 69 THEN 'L'
	WHEN egg_weight> 65 THEN 'M'
	ELSE 'S'
END "등급"
FROM chick_info;

SELECT chick_no, gender,
CASE gender
	WHEN 'M' THEN '수컷'
	WHEN 'F' THEN '암컷'
	ELSE '성별미상'
END "성별"
FROM chick_info;

-- 1. 
SELECT *
FROM chick_info
ORDER BY egg_weight DESC
limit 5;

-- 2. 
SELECT *
FROM health_cond
WHERE weight > 800 AND body_temp < 41
ORDER BY weight;

-- 3.
SELECT hatchday, count(*)
FROM chick_info
GROUP BY hatchday
HAVING count(*) >= 12;

-- 4. 
SELECT farm, count(DISTINCT date) AS high_lux_days
FROM env_cond
WHERE lux >= 10
GROUP BY farm;

-- 5. 
SELECT chick_no, coalesce(note, '없음')
FROM health_cond;

SELECT chick_no,
CASE
	WHEN note IS NULL OR note = '' THEN '없음'
	ELSE note
END
FROM health_cond;

-- 6. 
SELECT avg(egg_weight) FROM chick_info;

SELECT * FROM chick_info
WHERE egg_weight > 66.75;

-- 8.
SELECT customer, count(*),
CASE 
	WHEN count(*) > 12 THEN 'VVIP'
	WHEN count(*) > 10 THEN 'VIP'
	ELSE 'GOLD'
END grade
FROM ship_result
GROUP BY customer;

SELECT pr.chick_no, pr.pass_fail, 
pr.raw_weight, 
sr.order_no, sr.customer
FROM prod_result pr
INNER join ship_result sr
ON pr.chick_no = sr.chick_no;

SELECT pr.chick_no, pr.pass_fail, 
pr.raw_weight, 
sr.order_no, sr.customer
from prod_result pr, ship_result sr
WHERE pr.chick_no = sr.chick_no;

(
SELECT chick_no, gender, hatchday
FROM chick_info
)
UNION
(
SELECT 'C2610001', 'F', '2026-01-05'
)
UNION
(
SELECT 'C2610002', 'F', '2026-01-05'
)
UNION
(
SELECT 'C2610003', 'F', '2026-01-05'
);

SELECT a.gender, avg(b.raw_weight) AS avg_weight
FROM chick_info a
JOIN prod_result b
ON a.chick_no = b.chick_no
GROUP BY a.gender;

SELECT a.chick_no, a.farm, b.check_date, b.diarrhea_yn
FROM chick_info a
JOIN health_cond b
ON a.chick_no = b.chick_no
WHERE b.diarrhea_yn = 'Y'
ORDER BY b.check_date desc;
