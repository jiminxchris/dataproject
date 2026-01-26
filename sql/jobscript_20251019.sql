--DO $$
--DECLARE
--    jid integer;
--    scid integer;
--BEGIN
---- Creating a new job
--INSERT INTO pgagent.pga_job(
--    jobjclid, jobname, jobdesc, jobhostagent, jobenabled
--) VALUES (
--    1::integer, 'breeds_prod_proc_job_remote2'::text, ''::text, ''::text, true
--) RETURNING jobid INTO jid;
--
---- Steps
---- Inserting a step (jobid: NULL)
--INSERT INTO pgagent.pga_jobstep (
--    jstjobid, jstname, jstenabled, jstkind,
--    jstconnstr, jstdbname, jstonerror,
--    jstcode, jstdesc
--) VALUES (
--    jid, 'steps2'::text, true, 's'::character(1),
--    'host=localhost port=5432 dbname=my_postgres user=postgres password=''dada@1229Chr'''::text, ''::name, 'f'::character(1),
--    'CALL fms.breeds_prod_proc();'::text, ''::text
--) ;
--
---- Schedules
---- Inserting a schedule
--INSERT INTO pgagent.pga_schedule(
--    jscjobid, jscname, jscdesc, jscenabled,
--    jscstart, jscend,    jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
--) VALUES (
--    jid, 'everytime2'::text, ''::text, true,
--
---- 아래 주석처리
----    '2025-10-17 20:10:00+09'::timestamp with time zone, '2025-10-17 20:15:00+09'::timestamp with time zone,
---- 아래로 변경
--	-- [수정된 부분]: 현재 시간 + 5분
--	(NOW() + INTERVAL '5 minute')::timestamp with time zone, 
--	-- [수정된 부분]: 현재 시간 + 10분
--	(NOW() + INTERVAL '10 minute')::timestamp with time zone,
--    -- Minutes
--    '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
--    -- Hours
--    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
--    -- Week days
--    '{f,f,f,f,f,f,f}'::bool[]::boolean[],
--    -- Month days
--    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
--    -- Months
--    '{f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[]
--) RETURNING jscid INTO scid;
--END
--$$;

SELECT jobname, jobid, jobenabled
FROM pgagent.pga_job
WHERE jobname = 'breeds_prod_proc_job_remote2';

SELECT
    jlgjobid,
    jobname,
    jlgstatus, -- 's'는 성공(success), 'f'는 실패(failure)
    jlgstart,
    jlgduration
FROM
    pgagent.pga_joblog
JOIN
    pgagent.pga_job ON jlgjobid = jobid
WHERE
    jobname = 'breeds_prod_proc_job_remote2'
ORDER BY
    jlgstart DESC;
---------------------------------------------------

DO $$
DECLARE
    jid integer;
    scid integer;
BEGIN
-- Creating a new job
INSERT INTO pgagent.pga_job(
    jobjclid, jobname, jobdesc, jobhostagent, jobenabled
) VALUES (
    1::integer, 'breeds_prod_proc_job_functocsv'::text, ''::text, ''::text, true
) RETURNING jobid INTO jid;

-- Steps
-- Inserting a step (jobid: NULL)
INSERT INTO pgagent.pga_jobstep (
    jstjobid, jstname, jstenabled, jstkind,
    jstconnstr, jstdbname, jstonerror,
    jstcode, jstdesc
) VALUES (
    jid, 'stepfunctocsv'::text, true, 's'::character(1),
    'host=localhost port=5432 dbname=my_postgres user=postgres password=''dada@1229Chr'''::text, ''::name, 'f'::character(1),
    'COPY(SELECT * from fms.breeds_prod_functocsv(''2023-02-01'')) TO 
''C:/Users/Public/breeds_prod_summary.csv'' CSV HEADER'::text, ''::text
) ;

-- Schedules
-- Inserting a schedule
INSERT INTO pgagent.pga_schedule(
    jscjobid, jscname, jscdesc, jscenabled,
    jscstart, jscend,    jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
) VALUES (
    jid, 'everyminutefunctocsv'::text, ''::text, true,

-- 아래 주석처리
--    '2025-10-17 20:10:00+09'::timestamp with time zone, '2025-10-17 20:15:00+09'::timestamp with time zone,
-- 아래로 변경
	-- [수정된 부분]: 현재 시간 + 5분
	(NOW() + INTERVAL '5 minute')::timestamp with time zone, 
	-- [수정된 부분]: 현재 시간 + 10분
	(NOW() + INTERVAL '10 minute')::timestamp with time zone,
    -- Minutes
    '{t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t}'::bool[]::boolean[],
    -- Hours
    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Week days
    '{f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Month days
    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Months
    '{f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[]
) RETURNING jscid INTO scid;
END
$$;

SELECT
    jlgjobid,
    jobname,
    jlgstatus, -- 's'는 성공(success), 'f'는 실패(failure)
    jlgstart,
    jlgduration
FROM
    pgagent.pga_joblog
JOIN
    pgagent.pga_job ON jlgjobid = jobid
WHERE
    jobname = 'breeds_prod_proc_job_functocsv'
ORDER BY
    jlgstart DESC;

