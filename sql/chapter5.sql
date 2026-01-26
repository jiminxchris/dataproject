/* Chapter 5. 데이터 수정하기 */

-- 1. 데이터 추가(INSERT)

-- 1-1. 데이터 한 건 추가하기
INSERT INTO fms.master_code(
	column_nm, type, code, code_desc)
	VALUES ('breeds', 'txt', 'R1', 'Ross');

SELECT * FROM fms.master_code WHERE column_nm = 'breeds';

-- 1-2. 데이터 여러 건 추가하기
INSERT INTO fms.master_code(
	column_nm, type, code, code_desc)
	VALUES 
	('breeds', 'txt', 'N1', 'New Hampshire Red'),
	('breeds', 'txt', 'R2', 'Rhode Island Red'),
	('breeds', 'txt', 'A1', 'Australorp');

-- 2. 데이터 수정(UPDATE)

-- 2-1. 데이터 수정하기
UPDATE fms.master_code
	SET code_desc='암컷'
	WHERE column_nm = 'gender' AND code = 'F';

SELECT * FROM fms.master_code WHERE column_nm = 'gender';

-- 3. 데이터 및 테이블 삭제(DELETE, DROP TABLE)

-- 3-1. 모든 데이터 삭제하기
DELETE FROM fms.master_code;
ROLLBACK;

-- 3-2. 특정 조건의 데이터 삭제하기
DELETE FROM fms.master_code 
WHERE column_nm = 'size_stand' AND TO_NUMBER(code, '99') < 10;


-- 트랜잭셕 테스트
SELECT * FROM fms.MASTER_CODE;

SELECT * FROM fms.MASTER_CODE WHERE column_nm='breeds';

INSERT INTO  fms.MASTER_CODE(COLUMN_NM, TYPE, code, code_desc)
VALUES ('size_stand', 'number', 9, '9호'),
('size_stand', 'number', 8, '8호'),
('size_stand', 'number', 7, '7호');

UPDATE fms.MASTER_CODE
SET code_desc='Female'
WHERE column_nm='gender' AND code='F';

INSERT INTO  fms.MASTER_CODE(COLUMN_NM, TYPE, code, code_desc)
VALUES ('breeds', 'txt', 'R1', 'Ross');

SELECT pid, state FROM pg_stat_activity 
WHERE query = 'UPDATE fms.MASTER_CODE ...';

SELECT pid, state FROM pg_stat_activity 
WHERE query = 'DELETE fms.MASTER_CODE ...';

-- 현재 트랜잭션 상태 조회
SELECT pid, state, query 
FROM pg_stat_activity 
WHERE pid = pg_backend_pid();

SELECT * FROM fms.MASTER_CODE;

BEGIN;
UPDATE fms.MASTER_CODE
SET code_desc='암컷'
WHERE column_nm='gender' AND code='F';
SAVEPOINT my_savepoint;
DELETE FROM fms.MASTER_CODE 
WHERE column_nm='size_stand' AND to_number(code, '99') < 10;
ROLLBACK TO my_savepoint;
COMMIT;

ROLLBACK;