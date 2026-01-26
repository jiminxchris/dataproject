
--Primary Key 목록 조회
SELECT 
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu 
        ON tc.constraint_name = kcu.constraint_name
WHERE 
    tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema = 'fms'
ORDER BY tc.table_name;

SELECT * FROM pg_catalog.pg_constraint
ORDER BY oid asc;



--Foreign Key 목록 조회
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column,
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu 
        ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu 
        ON ccu.constraint_name = tc.constraint_name
WHERE 
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema = 'fms'
ORDER BY tc.table_name;

--information_schema에서 제약조건 전체 조회
-- 지원되는 constraint_type 목록:
--PRIMARY KEY
--FOREIGN KEY
--UNIQUE
--CHECK

SELECT 
    tc.constraint_type,
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM 
    information_schema.table_constraints AS tc
LEFT JOIN 
    information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE 
    tc.table_schema = 'fms'
ORDER BY 
    tc.table_name, tc.constraint_type;

--UNIQUE 제약조건만 따로
SELECT 
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM 
    information_schema.table_constraints tc
JOIN 
    information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE 
    tc.constraint_type = 'UNIQUE'
    AND tc.table_schema = 'fms';


