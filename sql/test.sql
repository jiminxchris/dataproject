-- ✅ 초급 예제 1. 전체 병아리 정보 조회
SELECT * FROM fms.chick_info;
-- chick_info 테이블의 모든 컬럼과 모든 레코드를 출력함.

-- ✅ 초급 예제 2. egg_weight가 60g 이상인 병아리
SELECT * FROM fms.chick_info WHERE egg_weight >= 60;
-- WHERE 절을 사용하여 egg_weight가 60 이상인 병아리만 필터링함.

-- ✅ 초급 예제 3. 수컷 병아리 조회
SELECT * FROM fms.chick_info WHERE gender = 'M';
-- 성별이 'M'인 병아리만 출력.

-- ✅ 초급 예제 4. 2024년 1월 이후 부화한 병아리
SELECT * FROM fms.chick_info WHERE hatchday >= '2024-01-01';
-- 날짜 필터 조건을 문자열로 지정해도 날짜형으로 자동 변환됨.

-- ✅ 초급 예제 5. egg_weight 내림차순 정렬
SELECT * FROM fms.chick_info ORDER BY egg_weight DESC;
-- DESC: 내림차순, ASC: 오름차순

-- ✅ 초급 예제 6. 병아리 총 수
SELECT COUNT(*) FROM fms.chick_info;
-- COUNT(*)는 전체 레코드 수를 반환함.

-- ✅ 초급 예제 7. 암컷 병아리 수
SELECT COUNT(*) FROM fms.chick_info WHERE gender = 'F';
-- 조건을 걸고 COUNT

-- ✅ 초급 예제 8. 평균 egg_weight
SELECT AVG(egg_weight) FROM fms.chick_info;
-- AVG: 평균 집계 함수

-- ✅ 초급 예제 9. hatchday, farm을 한글 별칭으로 출력
SELECT hatchday AS "부화일자", farm AS "농장" FROM fms.chick_info;
-- AS "한글"은 PostgreSQL에서 컬럼명에 공백/한글 허용을 위해 큰따옴표 사용해야 함

-- ✅ 초급 예제 10. 농장별 병아리 수
SELECT farm, COUNT(*) AS "병아리 수" FROM fms.chick_info GROUP BY farm;
-- GROUP BY로 farm별로 묶고 집계함

-- ✅ 초급 예제 11. vaccination1을 받은 병아리
SELECT * FROM fms.chick_info WHERE vaccination1 IS NOT NULL;
-- NULL 여부는 IS NOT NULL 또는 IS NULL로 판별

-- ✅ 초급 예제 12. 중복되지 않는 품종 목록
SELECT DISTINCT breeds FROM fms.chick_info;
-- DISTINCT는 중복 제거

-- ✅ 초급 예제 13. 최대 egg_weight
SELECT MAX(egg_weight) FROM fms.chick_info;
-- MAX: 최대값 집계 함수

-- ✅ 초급 예제 14. 평균보다 무거운 병아리
SELECT * FROM fms.chick_info
WHERE egg_weight > (SELECT AVG(egg_weight) FROM fms.chick_info);
-- 서브쿼리로 평균을 먼저 구한 뒤 비교함.

-- ✅ 초급 예제 15. egg_weight가 NULL인 병아리 수
SELECT COUNT(*) FROM fms.chick_info WHERE egg_weight IS NULL;
-- NULL 비교는 = 이 아닌 IS NULL 사용해야 함.

-- ✅ 중급 예제 16. 병아리와 건강검진 JOIN
SELECT ci.chick_no, hc.check_date, hc.body_temp
FROM fms.chick_info ci
JOIN fms.health_cond hc ON ci.chick_no = hc.chick_no;
-- JOIN은 기본적으로 INNER JOIN이며, 동일한 chick_no를 기준으로 연결됨.
-- 병아리 번호, 검진일자, 체온을 출력함.