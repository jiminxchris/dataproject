-- 몸풀기퀴즈

--1. 기본 조회
-- chick_info 테이블의 모든 데이터 조회
SELECT * FROM fms.chick_info; 

--2. 조건 필터링
-- 성별이 암컷(F)인 병아리 정보 조회
SELECT * FROM fms.chick_info WHERE gender = 'F'; 

--3. 정렬 및 제한
-- 계란 무게(egg_weight)가 68g 이상인 데이터를 무거운 순으로 7개 출력
SELECT * FROM fms.chick_info WHERE egg_weight >= 68 ORDER BY egg_weight DESC LIMIT 7 OFFSET 1;

--4. 날짜 범위
-- 2023-01-01 ~ 2023-01-02 사이에 부화한 병아리 조회
SELECT * FROM fms.chick_info WHERE hatchday BETWEEN '2023-01-01' AND '2023-01-02'; 

--5. NULL 처리
-- env_cond 테이블에서 습도(humid)가 NULL인 레코드 조회
SELECT * FROM fms.env_cond WHERE humid IS NULL; 

--6. 패턴 검색
-- 품종(breeds)이 'C'로 시작하는 병아리 조회
SELECT * FROM fms.chick_info WHERE breeds LIKE 'C%'; 

--7. 조인 활용
-- chick_info와 health_cond를 조인해 2023-01-30 건강검진 데이터 조회
SELECT a.chick_no, b.body_temp FROM fms.chick_info a JOIN fms.health_cond b ON a.chick_no = b.chick_no WHERE b.check_date = '2023-01-30'; 

--8. 집계 함수
-- 농장(farm)별 평균 계란 무게 계산
SELECT farm, ROUND(AVG(egg_weight),2) AS avg_weight FROM fms.chick_info GROUP BY farm;

--9. 그룹 필터링
-- 고객사(customer)별 출하량이 10마리 이상인 데이터 조회
SELECT customer, COUNT(*) 
FROM fms.ship_result 
GROUP BY customer HAVING COUNT(*) >= 10;

--10. 서브쿼리
-- 평균 계란 무게보다 큰 병아리 조회
SELECT * FROM fms.chick_info 
WHERE egg_weight > (SELECT AVG(egg_weight) FROM fms.chick_info);

--11. CASE 문
-- 생닭 무게(raw_weight)를 기준으로 등급 분류 (1000g 미만: S, 1000~1100: M, 1100~: L)
SELECT chick_no, raw_weight,
  CASE 
    WHEN raw_weight < 1000 THEN 'S'
    WHEN raw_weight BETWEEN 1000 AND 1100 THEN 'M'
    ELSE 'L' 
  END AS grade
FROM fms.prod_result;

--12. UNION
-- A농장의 수컷과 B농장의 암컷 데이터 통합 조회
SELECT * FROM fms.chick_info 
WHERE farm='A' AND gender='M'
UNION
SELECT * FROM fms.chick_info 
WHERE farm='B' AND gender='F';

--13. 날짜 함수
-- 부화일(hatchday)을 'YYYY년 MM월 DD일' 형식으로 변환 출력
SELECT chick_no, TO_CHAR(hatchday, 'YYYY년 MM월 DD일') 
FROM fms.chick_info;

--14. 복합 조인
-- chick_info, prod_result, ship_result를 조인해 부산으로 출하된 생닭 정보 조회
SELECT s.* 
FROM fms.ship_result s
JOIN fms.prod_result p ON s.chick_no = p.chick_no
WHERE s.destination = '부산' AND p.pass_fail = 'P';

--15. 뷰 생성
-- 품종별 주간 생산량 집계 뷰 생성
CREATE VIEW fms.breeds_stats AS
SELECT breeds, COUNT(*) AS total, AVG(raw_weight) AS avg_weight
FROM fms.prod_result p
JOIN fms.chick_info c ON p.chick_no = c.chick_no
GROUP BY breeds;

SELECT * FROM fms.breeds_stats;

--16. 문자열 함수
-- chick_no에서 첫 글자(A/B)를 농장명으로 변환해 출력
SELECT chick_no, 
  CASE SUBSTR(chick_no,1,1)
    WHEN 'A' THEN 'A농장'
    WHEN 'B' THEN 'B농장'
  END AS farm_name
FROM fms.chick_info;

--17. 종합 쿼리
/* 2023-01-30일 기준 체온 + 호흡수 + 사료섭취량 결합 지표 계산
   (체온 41℃ 초과시 '주의', 45℃ 초과시 '위험' 표시) */
SELECT h.chick_no,
  CASE 
    WHEN body_temp > 45 THEN '위험'
    WHEN body_temp > 41 THEN '주의' 
    ELSE '정상'
  END AS status
FROM fms.health_cond h
WHERE check_date = '2023-01-30';

