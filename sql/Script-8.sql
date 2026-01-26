-- 연산자 우선순위
SELECT 
b.destination, sum(a.raw_weight) "prod_sum"
FROM
fms.prod_result a
INNER JOIN fms.ship_result b
ON a.chick_no = b.chick_no
WHERE a.disease_yn = 'N' AND a.size_stand  >= 11
GROUP BY b.destination
HAVING (sum(a.raw_weight)/1000) >= 5
ORDER BY sum(a.raw_weight) DESC
LIMIT 3;




--뷰
CREATE OR REPLACE VIEW fms.breeds_prod
(
prod_date, breeds_nm, total_sum
)
AS
SELECT
a.prod_date,
(
SELECT m.code_desc "breeds_nm" FROM fms.master_code m
WHERE m.column_nm = 'breeds' AND m.code = b.breeds
),
sum(a.raw_weight) "total_sum"
FROM
fms.prod_result a,
fms.chick_info b
WHERE
a.chick_no = b.chick_no
AND a.pass_fail = 'P'
GROUP BY a.prod_date, b.breeds;




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

EXPLAIN SELECT * FROM public.bank;

SELECT relname, relkind, reltuples, relpages FROM pg_class WHERE relname='테이블명';

SELECT * FROM pg_class WHERE relname = 'bank';

SELECT relname, relkind, reltuples, relpages FROM pg_class WHERE relname = 'bank';

EXPLAIN ANALYZE SELECT * FROM public.bank;

EXPLAIN ANALYZE SELECT * FROM public.bank
WHERE client_no BETWEEN 850 AND 855;

EXPLAIN ANALYZE 
SELECT * FROM public.bank
WHERE gender = 'F' AND age BETWEEN 66 AND 67;


CREATE INDEX bank_idx
ON public.bank USING btree
(gender ASC NULLS LAST, age ASC NULLS last);

COMMENT ON INDEX public.bank_idx
IS '성별과 나이를 이용한 인덱스';

EXPLAIN ANALYZE 
SELECT * FROM public.bank
WHERE gender = 'F' AND age BETWEEN 66 AND 67;



EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT * FROM public.bank
WHERE gender = 'F' AND age BETWEEN 66 AND 67;


EXPLAIN ANALYZE
SELECT
a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
FROM
fms.prod_result a
JOIN fms.ship_result b
ON a.chick_no = b.chick_no;

EXPLAIN (ANALYZE, FORMAT JSON)
SELECT
a.chick_no, a.pass_fail, a.raw_weight,
b.order_no, b.customer
FROM
fms.prod_result a
JOIN fms.ship_result b
ON a.chick_no = b.chick_no;




--잡
DO $$
DECLARE
    jid integer;
    scid integer;
BEGIN
-- Creating a new job
INSERT INTO pgagent.pga_job(
    jobjclid, jobname, jobdesc, jobhostagent, jobenabled
) VALUES (
    1::integer, 'breeds_prod_job'::text, ''::text, ''::text, true
) RETURNING jobid INTO jid;

-- Steps
-- Inserting a step (jobid: NULL)
INSERT INTO pgagent.pga_jobstep (
    jstjobid, jstname, jstenabled, jstkind,
    jstconnstr, jstdbname, jstonerror,
    jstcode, jstdesc
) VALUES (
    jid, 'step'::text, true, 's'::character(1),
    'user=''postgres'' password = ''1111'' host = ''localhost'' port = ''5432'' dbname = ''chicken'''::text, ''::name, 'f'::character(1),
    'CALL fms.breeds_prod_proc();'::text, ''::text
) ;

-- Schedules
-- Inserting a schedule
INSERT INTO pgagent.pga_schedule(
    jscjobid, jscname, jscdesc, jscenabled,
    jscstart, jscend,    jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
) VALUES (
    jid, 'everyminute'::text, ''::text, true,
    '2023-01-05 21:10:00 +09:00'::timestamp with time zone, '2023-01-07 21:10:00 +09:00'::timestamp with time zone,
    -- Minutes
    ARRAY[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]::boolean[],
    -- Hours
    ARRAY[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]::boolean[],
    -- Week days
    ARRAY[true,true,true,true,true,true,true]::boolean[],
    -- Month days
    ARRAY[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]::boolean[],
    -- Months
    ARRAY[true,true,true,true,true,true,true,true,true,true,true,true]::boolean[]
) RETURNING jscid INTO scid;
END
$$;

--프로시져
CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc(
	)
LANGUAGE 'sql'
AS $BODY$
INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
(
SELECT prod_date, breeds_nm, total_sum, current_timestamp AS save_time
FROM fms.breeds_prod
WHERE prod_date = '2023-01-31'
);
$BODY$;
ALTER PROCEDURE fms.breeds_prod_proc()
    OWNER TO postgres;

COMMENT ON PROCEDURE fms.breeds_prod_proc()
    IS '품종별생산실적 입력 프로시져';

-- 데이블
CREATE TABLE IF NOT EXISTS fms.breeds_prod_tbl
(
    prod_date date,
    breeds_nm character(20) COLLATE pg_catalog."default",
    total_sum bigint,
    save_time timestamp without time zone
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS fms.breeds_prod_tbl
    OWNER to postgres;

COMMENT ON TABLE fms.breeds_prod_tbl
    IS '품종별생산실적';

COMMENT ON COLUMN fms.breeds_prod_tbl.prod_date
    IS '생산일자';

COMMENT ON COLUMN fms.breeds_prod_tbl.breeds_nm
    IS '품종명';

COMMENT ON COLUMN fms.breeds_prod_tbl.total_sum
    IS '생산량합계';

COMMENT ON COLUMN fms.breeds_prod_tbl.save_time
    IS '저장일시';