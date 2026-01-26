DO $$
DECLARE
    jid integer;
    scid integer;
BEGIN
-- Creating a new job
INSERT INTO pgagent.pga_job(
    jobjclid, jobname, jobdesc, jobhostagent, jobenabled
) VALUES (
    1::integer, 'func_farm_ship_summary_tocsv'::text, ''::text, ''::text, true
) RETURNING jobid INTO jid;

-- Steps
-- Inserting a step (jobid: NULL)
INSERT INTO pgagent.pga_jobstep (
    jstjobid, jstname, jstenabled, jstkind,
    jstconnstr, jstdbname, jstonerror,
    jstcode, jstdesc
) VALUES (
    jid, 'stepcsv'::text, true, 's'::character(1),
    'host=localhost port=5432 dbname=my_postgres user=postgres password=''dada@1229Chr'''::text, ''::name, 'f'::character(1),
    'COPY(SELECT * from fms.func_farm_ship_summary(''A'')) TO ''C:/Users/Public/farm_ship_summary.csv'' CSV HEADER;'::text, ''::text
) ;

-- Schedules
-- Inserting a schedule
INSERT INTO pgagent.pga_schedule(
    jscjobid, jscname, jscdesc, jscenabled,
    jscstart, jscend,    jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
) VALUES (
    jid, 'everytimecsv'::text, ''::text, true,
--    '2025-10-17 20:10:00+09'::timestamp with time zone, '2025-10-17 20:15:00+09'::timestamp with time zone,
	(now() + INTERVAL '5 minute')::timestamp with time zone,
	(now() + INTERVAL '10 minute')::timestamp with time zone, 
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

SELECT * FROM pgagent.PGA_JOBlog
JOIN pgagent.pga_job ON jlgjobid=JOBID 
WHERE jobname = 'func_farm_ship_summary_tocsv'
ORDER by jlgstart desc;