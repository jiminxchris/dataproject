SELECT * FROM fms.chick_info;

-- 특정 컬럼만 조회하기
SELECT chick_no as cn, hatchday "부화날짜", egg_weight  
FROM fms.chick_info 
order by egg_weight desc
limit 7  offset 1;

-- prod_result 테이블에서 생닭무게가 무거운 순으로 7개 추출

select distinct(hatchday) from fms.chick_info;

select * from fms.chick_info where gender='M';

select * from fms.chick_info where egg_weight >= 68;

select * from fms.chick_info 
where hatchday between '2023-01-01' and '2023-01-02';

-- 계란 무게가 65이상 69이하인 대상 조회

-- 계란 무게가 65미만 69초과인 대상 조회

-- NULL이 있는 데이터 조회

select * from fms.env_cond where humid is NULL;


select * from fms.chick_info 
where breeds like 'C%';

select * from fms.chick_info 
where breeds in ('C1', 'C2');


-- 출하실적테이블에서 도착지가 부산 혹은 울산인 기록 조회

select * from fms.health_cond 
where note is not NULL;


select length(chick_no) from fms.chick_info;

select replace(gender,'M', 'Male') 
from fms.chick_info
limit 5;

-- chick_info 테이블에서 성별컬럼의 글자를 소문자로 변경하기

select farm||gender||breeds as fgb
from fms.chick_info;

-- 날짜별 생산갯수, 전체 중량, 평균중량, 최대중량, 최소중량
select prod_date, sum(raw_weight)
from fms.prod_result
group by prod_date;

-- 출하테이블에서 고객사별로 몇마리가 납품됐는지 
select customer, count(chick_no) as "수량"
from fms.ship_result
group by customer
having count(chick_no) >= 10;

-- 출하테이블에서 고객사별로 몇마리가 납품됐는지, 2023년 2월 4일 이후인것만 
select customer, count(chick_no) as "수량"
from fms.ship_result
where arrival_date > '2023-02-04'
group by customer;

-- 2023년 2월 4일 이후에 출하된 상품중
-- 고객사별로 출하량이 7이상인 고객만 조회해서 출하량이 많은순으로 정렬해주세요
select customer, count(chick_no) as "수량"
from fms.ship_result
where arrival_date > '2023-02-04'
group by customer
having count(chick_no) >= 7
order by count(chick_no) desc;

select hatchday, TO_CHAR(hatchday, 'Month') 
from fms.chick_info;


select farm, date, humid, coalesce(humid, 60)
from fms.env_cond
where date between '2023-01-24'and '2023-01-26'
and farm='A';

select farm, date, humid, nullif(humid, 60)
from fms.env_cond
where date between '2023-01-24'and '2023-01-26'
and farm='A';

select chick_no, egg_weight, 
case
	when egg_weight >= 69 then 'L'
	when egg_weight >= 67 then 'M'
	else 'S'
end w_grade
from fms.chick_info;


update fms.health_cond set note = null where  TRIM(note)='';


select a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
from prod_result a, ship_result b
where a.chick_no = b.chick_no;

select a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
from prod_result a
left join ship_result b
on a.chick_no = b.chick_no;


(select chick_no , gender , hatchday  from chick_info
where farm='A' and gender='F' and hatchday='2023-01-01')
union
(select 'A2400001', 'M', '2024-01-01');


select avg(egg_weight)  from chick_info;

select chick_no, egg_weight 
from chick_info
where egg_weight > (select avg(egg_weight)  from chick_info);

select a.chick_no, a.breeds, b.code_desc
from chick_info a, master_code b
where
a.breeds = b.code and b.column_nm ='breeds';


select a.chick_no, a.breeds, 
(select code_desc 
from master_code m
where column_nm ='breeds' and m.code= a.breeds)
from chick_info a;


select code_desc 
from master_code
where column_nm ='breeds';




select a.prod_date, 
(
select m.code_desc 
from master_code m
where m.column_nm ='breeds'
and m.code= b.breeds
) as breeds_nm, 
sum(a.raw_weight) as total_sum
from prod_result a 
join chick_info b on a.chick_no = b.chick_no
group by a.prod_date , b.breeds;


create or replace view fms.breeds_prod as
select a.prod_date, 
(
select m.code_desc 
from master_code m
where m.column_nm ='breeds'
and m.code= b.breeds
) as breeds_nm, 
sum(a.raw_weight) as total_sum
from prod_result a 
join chick_info b on a.chick_no = b.chick_no
group by a.prod_date , b.breeds;


select * from fms.breeds_prod;

select hatchday, 
sum(case when gender='M' then 1 else 0 end) as Male, 
sum(case when gender='F' then 1 else 0 end) as Female
from chick_info
group by hatchday;



select hatchday, gender, count(chick_no )::int as cnt
from chick_info
group by hatchday, gender;



create extension tablefunc;

SELECT * 
FROM crosstab
(
'SELECT hatchday, gender, count(chick_no)::int AS cnt
FROM fms.chick_info
GROUP BY hatchday, gender
ORDER BY hatchday, gender DESC'
)
AS pivot_r(hatchday date, "Male" int, "Female" int);


-- 열을 행으로 바꾸기
select chick_no, body_temp , breath_rate , feed_intake  
from health_cond
where check_date ='2023-1-10'
and chick_no like 'A%';






-- 도전미션 코드

--fms.health_cond 테이블에서 노트가 없는 경우 '없음'으로 표시하여 조회하세요.
SELECT chick_no, 
       COALESCE(note, '없음') AS note_text
FROM fms.health_cond;


--fms.chick_info 테이블에서 평균 종란 무게보다 높은 육계를 조회하세요.
--
--1단계: 평균종란무게 구하기
--2단계: 평균보다 큰 병아리 조회하기

SELECT AVG(egg_weight) FROM fms.chick_info; --66.75
SELECT * 
FROM fms.chick_info
WHERE egg_weight > 66.75;

--생산 합격 여부(pass_fail)를 기준으로 상태 분류

SELECT chick_no, prod_date,
       CASE pass_fail
           WHEN 'P' THEN '합격'
           WHEN 'F' THEN '불합격'
           ELSE '미확인'
       END AS result_status
FROM prod_result;



--ship_result 테이블을 사용하여 고객사별 출하 주문 건수를 3단계 계층으로 분류하는 쿼리를 작성하시오.
--10건 이상: 'A등급'
--5~9건: 'B등급'
--5건 미만: 'C등급‘

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


--prod_result, chick_info 생산 결과와 병아리 정보 조인하여 성별별 평균 중량 구하기
SELECT c.gender, 
       ROUND(AVG(p.raw_weight), 1) AS avg_weight
FROM prod_result p
JOIN chick_info c ON p.chick_no = c.chick_no
GROUP BY c.gender;



--건강 상태에서 설사(diarrhea_yn='Y')가 있었던 병아리 리스트

select h.chick_no, c.farm, h.check_date
FROM health_cond h
JOIN chick_info c ON h.chick_no = c.chick_no
WHERE h.diarrhea_yn = 'Y'
ORDER BY h.check_date DESC;
