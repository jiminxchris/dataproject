SELECT 
  customer,
  COUNT(*) AS order_cnt,
  CASE
    WHEN COUNT(*) >= 10 THEN 'A등급'
    WHEN COUNT(*) BETWEEN 5 AND 9 THEN 'B등급'
    ELSE 'C등급'
  END AS grade
FROM fms.ship_result
GROUP BY customer;


SELECT 
  h.chick_no,
  e.temp,
  e.humid,
  h.body_temp,
  h.breath_rate
FROM fms.health_cond h
JOIN fms.env_cond e 
  ON h.check_date = e.date 
  AND LEFT(h.chick_no,1) = e.farm
WHERE h.check_date = '2023-01-20';

SELECT 
  farm,
  EXTRACT(WEEK FROM date) AS week_num,
  ROUND(AVG(temp),1) AS avg_temp
FROM fms.env_cond
WHERE date BETWEEN '2023-01-01' AND '2023-01-31'
GROUP BY farm, week_num
ORDER BY farm, week_num;

SELECT * FROM fms.chick_info ORDER BY egg_weight DESC LIMIT 5;

SELECT farm, AVG(egg_weight) AS avg_weight FROM fms.chick_info GROUP BY farm;

SELECT hatchday, COUNT(*) AS count FROM fms.chick_info GROUP BY hatchday HAVING COUNT(*) >= 10;


SELECT * 
FROM fms.chick_info
WHERE egg_weight > (
    SELECT AVG(egg_weight) FROM fms.chick_info
);

SELECT ci.chick_no, ci.farm, sr.customer
FROM fms.chick_info ci
JOIN fms.ship_result sr ON ci.chick_no = sr.chick_no;

SELECT
  a.prod_date,
  c.code_desc AS breeds_name,
  SUM(a.raw_weight) AS total_raw_weight
FROM
  fms.prod_result a
JOIN
  fms.chick_info b ON a.chick_no = b.chick_no
JOIN
  fms.master_code c ON b.breeds = c.code
WHERE
  c.column_nm = 'breeds'
GROUP BY
  a.prod_date, c.code_desc;






