-- 함수

CREATE OR REPLACE FUNCTION fms.get_chickinfo(chick_no varchar)
	RETURNS integer
AS $$
	select egg_weight from fms.chick_info where fms.chick_info.chick_no =get_chickinfo.chick_no;
$$ LANGUAGE SQL;

SELECT fms.get_chickinfo('A2510016');

CREATE OR REPLACE FUNCTION fms.add_num_plpgsql(x integer, y integer)
	RETURNS int4
AS $$
begin
	return x + y;
end;
$$ LANGUAGE plpgsql;

SELECT fms.add_num_plpgsql(5, 6);

SET search_path TO fms;


CREATE OR REPLACE FUNCTION weight_pass(weight integer)
	RETURNS text
AS $$
	select case
		when weight >= 40 then '합격'
		else '불합격'
	end;
$$ LANGUAGE SQL;

SELECT weight_pass(39);

CREATE OR REPLACE FUNCTION weight_pass_plpgsql(weight integer)
	RETURNS text
AS $$
declare
	result text;
begin
	if weight >= 40 then 
		result := '합격';
	else 
		result := '불합격';
	end if;
	return result;
end;
$$ LANGUAGE plpgsql;

SELECT weight_pass_plpgsql(41);


CREATE OR REPLACE FUNCTION print_loop(n integer)
	RETURNS void
AS $$
declare
	i integer :=2;
begin
	while i <= n loop
		raise notice 'Loop: %', i;
		i := i +1;
	end loop;
end;
$$ LANGUAGE plpgsql;

SELECT print_loop(5);

DROP FUNCTION multivalue(integer);
CREATE OR REPLACE FUNCTION multivalue(in integer)
	RETURNS table(f1 int, f2 text)
AS $$
begin
	return QUERY
	select $1, cast($1 as text) || 'is text';
end;
$$ LANGUAGE plpgsql;

SELECT * from multivalue(4);

-- 뷰를 함수로
CREATE OR REPLACE VIEW fms.view_farm_ship_summary AS
	SELECT 
	ci.farm,
	sr.customer,
	COUNT(*) AS shipped_count
	FROM fms.prod_result pr
	JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
	JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
	WHERE pr.pass_fail = 'P'
	GROUP BY ci.farm, sr.customer;

SELECT * 
FROM fms.view_farm_ship_summary
WHERE farm = 'B';

CREATE OR REPLACE FUNCTION fms.get_farm_ship_summary(farm_param varchar)
	RETURNS table(
	farm varchar,
	customer varchar,
	shipped_count bigint
	)
AS $$
	SELECT 
	ci.farm,
	sr.customer,
	COUNT(*) AS shipped_count
	FROM fms.prod_result pr
	JOIN fms.chick_info ci ON pr.chick_no = ci.chick_no
	JOIN fms.ship_result sr ON pr.chick_no = sr.chick_no
	WHERE pr.pass_fail = 'P'
		and ci.farm = farm_param
	GROUP BY ci.farm, sr.customer;
$$ LANGUAGE SQL;

SELECT * FROM fms.get_farm_ship_summary('A');
SELECT * FROM fms.get_farm_ship_summary('B');

DROP FUNCTION get_farm_ship_summary_plpgsql(character varying);
CREATE OR REPLACE FUNCTION fms.get_farm_ship_summary_plpgsql(farm_param VARCHAR)
RETURNS TABLE (
    farm character(1),
    customer VARCHAR,
    shipped_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ci.farm,
        sr.customer,
        COUNT(*) AS shipped_count
    FROM
        fms.prod_result pr
    JOIN
        fms.chick_info ci ON pr.chick_no = ci.chick_no
    JOIN
        fms.ship_result sr ON pr.chick_no = sr.chick_no
    WHERE
        pr.pass_fail = 'P'
        AND ci.farm = farm_param
    GROUP BY
        ci.farm, sr.customer;
        
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fms.get_farm_ship_summary_plpgsql('A');


DROP FUNCTION decode_chick_info(character varying);

CREATE OR REPLACE FUNCTION decode_chick_info(p_chick_no VARCHAR)
RETURNS TABLE (
    farm varchar, 
    birth_year INT,
    gender text 
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUBSTRING(p_chick_no, 1, 1)::varchar,
        CAST('20' || SUBSTRING(p_chick_no, 2, 2) AS INT),
        CASE
            WHEN CAST(RIGHT(p_chick_no, 1) AS INT) % 2 = 1 THEN 'Male'
            ELSE 'Female'
        END;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM decode_chick_info('A2300009');

DROP TABLE IF EXISTS fms.breeds_prod_tbl;

CREATE TABLE fms.breeds_prod_tbl (
prod_date date NOT NULL,
breeds_nm character(20) NOT NULL,
total_sum bigint NOT NULL,
save_time timestamp without time zone NOT NULL
);

COMMENT ON TABLE fms.breeds_prod_tbl IS '품종별 생산실적';

SELECT * FROM fms.breeds_prod_tbl;

INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
(
	SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
	FROM fms.breeds_prod
	WHERE prod_date = '2023-02-01'
);

CREATE OR REPLACE PROCEDURE fms.breeds_prod_proc()
AS $$
	INSERT INTO fms.breeds_prod_tbl(prod_date, breeds_nm, total_sum, save_time)
(
	SELECT prod_date, breeds_nm, total_sum, CURRENT_TIMESTAMP AS save_time
	FROM fms.breeds_prod
	WHERE prod_date = '2023-01-31'
);
$$ LANGUAGE SQL;

CALL fms.breeds_prod_proc();


SELECT * FROM fms.func_farm_ship_summary('B');


CREATE TABLE IF NOT EXISTS fms.prod_log (
	log_id SERIAL PRIMARY KEY,
	chick_no VARCHAR(20) NOT NULL,
	prod_date DATE NOT NULL,
	old_weight NUMERIC,
	new_weight NUMERIC,
	memo TEXT,
	logged_at TIMESTAMP
);

ALTER TABLE fms.prod_log ADD COLUMN IF NOT EXISTS memo TEXT;

-- 프로시저 생성
CREATE OR REPLACE PROCEDURE fms.update_and_log_prod_weight(
    p_chick_no VARCHAR,
    p_prod_date DATE,
    p_raw_weight NUMERIC
) AS $$
DECLARE
    v_old_weight NUMERIC;
    v_log_message TEXT;
BEGIN

    RAISE NOTICE '프로시저 시작: %, %', p_chick_no, p_prod_date;

    SELECT raw_weight INTO v_old_weight
    FROM fms.prod_result
    WHERE chick_no = p_chick_no AND prod_date = p_prod_date;

    -- 데이터가 없는 경우
    IF NOT FOUND THEN        
        v_log_message := '대상 없음: ' || p_chick_no;

        INSERT INTO fms.prod_log (chick_no, prod_date, old_weight, new_weight, logged_at, memo)
        VALUES (p_chick_no, p_prod_date, NULL, NULL, NOW(), v_log_message);

        COMMIT; 
        
        RAISE NOTICE '실패 로그 저장 및 커밋 완료';
        RETURN; 
    END IF;

    -- 정상 업데이트
    UPDATE fms.prod_result
    SET raw_weight = p_raw_weight
    WHERE chick_no = p_chick_no AND prod_date = p_prod_date;

    -- 정상 로그 기록
    INSERT INTO fms.prod_log (chick_no, prod_date, old_weight, new_weight, logged_at, memo)
    VALUES (p_chick_no, p_prod_date, v_old_weight, p_raw_weight, NOW(), '정상 업데이트');
    
    COMMIT; -- 커밋
    RAISE NOTICE '업데이트 완료 및 커밋';

END;
$$ LANGUAGE plpgsql;

CALL fms.update_and_log_prod_weight('C2310014', '2023-01-25', 1500); -- 없는번호 
CALL fms.update_and_log_prod_weight('B2300020', '2023-02-02', 1500);



