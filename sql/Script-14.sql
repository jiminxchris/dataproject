--CREATE TABLE IF NOT EXISTS fms.env_cond
--(
--    farm character(1) COLLATE pg_catalog."default" NOT NULL,
--    date date NOT NULL,
--    temp smallint,
--    humid smallint,
--    light_hr smallint,
--    lux smallint
--)
--
--TABLESPACE pg_default;
--
--ALTER TABLE IF EXISTS fms.env_cond
--    OWNER to postgres;
--
--COMMENT ON TABLE fms.env_cond
--    IS '사육환경';
--
--COMMENT ON COLUMN fms.env_cond.farm
--    IS '사육장';
--
--COMMENT ON COLUMN fms.env_cond.date
--    IS '일자';
--
--COMMENT ON COLUMN fms.env_cond.temp
--    IS '기온';
--
--COMMENT ON COLUMN fms.env_cond.humid
--    IS '습도';
--
--COMMENT ON COLUMN fms.env_cond.light_hr
--    IS '점등시간';
--
--COMMENT ON COLUMN fms.env_cond.lux
--    IS '조도';

--CREATE TABLE IF NOT EXISTS fms.health_cond
--(
--    chick_no character(8) COLLATE pg_catalog."default" NOT NULL,
--    check_date date NOT NULL,
--    weight smallint NOT NULL,
--    body_temp numeric(3,1) NOT NULL,
--    breath_rate smallint NOT NULL,
--    feed_intake smallint NOT NULL,
--    diarrhea_yn character(1) COLLATE pg_catalog."default" NOT NULL,
--    note text COLLATE pg_catalog."default",
--    CONSTRAINT health_cond_chick_no_fkey FOREIGN KEY (chick_no)
--        REFERENCES fms.chick_info (chick_no) MATCH SIMPLE
--        ON UPDATE NO ACTION
--        ON DELETE NO ACTION
--)
--
--TABLESPACE pg_default;
--
--ALTER TABLE IF EXISTS fms.health_cond
--    OWNER to postgres;
--
--COMMENT ON TABLE fms.health_cond
--    IS '건강상태';
--
--COMMENT ON COLUMN fms.health_cond.chick_no
--    IS '육계번호';
--
--COMMENT ON COLUMN fms.health_cond.check_date
--    IS '검사일자';
--
--COMMENT ON COLUMN fms.health_cond.weight
--    IS '체중';
--
--COMMENT ON COLUMN fms.health_cond.body_temp
--    IS '체온';
--
--COMMENT ON COLUMN fms.health_cond.breath_rate
--    IS '호흡수';
--
--COMMENT ON COLUMN fms.health_cond.feed_intake
--    IS '사료섭취량';
--
--COMMENT ON COLUMN fms.health_cond.diarrhea_yn
--    IS '설사여부';
--
--COMMENT ON COLUMN fms.health_cond.note
--    IS '노트';

--CREATE TABLE IF NOT EXISTS fms.master_code
--(
--    column_nm character varying(15) COLLATE pg_catalog."default",
--    type character varying(10) COLLATE pg_catalog."default",
--    code character varying(10) COLLATE pg_catalog."default",
--    code_desc character varying(20) COLLATE pg_catalog."default"
--)
--
--TABLESPACE pg_default;
--
--ALTER TABLE IF EXISTS fms.master_code
--    OWNER to postgres;
--
--COMMENT ON TABLE fms.master_code
--    IS '마스터코드';
--
--COMMENT ON COLUMN fms.master_code.column_nm
--    IS '열이름';
--
--COMMENT ON COLUMN fms.master_code.type
--    IS '타입';
--
--COMMENT ON COLUMN fms.master_code.code
--    IS '코드';
--
--COMMENT ON COLUMN fms.master_code.code_desc
--    IS '코드의미';

--CREATE TABLE IF NOT EXISTS fms.prod_result
--(
--    chick_no character(8) COLLATE pg_catalog."default" NOT NULL,
--    prod_date date NOT NULL,
--    raw_weight smallint NOT NULL,
--    disease_yn character(1) COLLATE pg_catalog."default" NOT NULL,
--    size_stand smallint NOT NULL,
--    pass_fail character(1) COLLATE pg_catalog."default" NOT NULL,
--    CONSTRAINT prod_result_chick_no_fkey FOREIGN KEY (chick_no)
--        REFERENCES fms.chick_info (chick_no) MATCH SIMPLE
--        ON UPDATE NO ACTION
--        ON DELETE NO ACTION
--)
--
--TABLESPACE pg_default;
--
--ALTER TABLE IF EXISTS fms.prod_result
--    OWNER to postgres;
--
--COMMENT ON TABLE fms.prod_result
--    IS '생산실적';
--
--COMMENT ON COLUMN fms.prod_result.chick_no
--    IS '육계번호';
--
--COMMENT ON COLUMN fms.prod_result.prod_date
--    IS '생산일자';
--
--COMMENT ON COLUMN fms.prod_result.raw_weight
--    IS '생닭중량';
--
--COMMENT ON COLUMN fms.prod_result.disease_yn
--    IS '질병유무';
--
--COMMENT ON COLUMN fms.prod_result.size_stand
--    IS '호수';
--
--COMMENT ON COLUMN fms.prod_result.pass_fail
--    IS '적합여부';

--CREATE TABLE IF NOT EXISTS fms.ship_result
--(
--    chick_no character(8) COLLATE pg_catalog."default" NOT NULL,
--    order_no character(4) COLLATE pg_catalog."default" NOT NULL,
--    customer character varying(20) COLLATE pg_catalog."default" NOT NULL,
--    due_date date NOT NULL,
--    arrival_date date,
--    destination character varying(10) COLLATE pg_catalog."default" NOT NULL,
--    CONSTRAINT ship_result_chick_no_fkey FOREIGN KEY (chick_no)
--        REFERENCES fms.chick_info (chick_no) MATCH SIMPLE
--        ON UPDATE NO ACTION
--        ON DELETE NO ACTION
--)
--
--TABLESPACE pg_default;
--
--ALTER TABLE IF EXISTS fms.ship_result
--    OWNER to postgres;
--
--COMMENT ON TABLE fms.ship_result
--    IS '출하실적';
--
--COMMENT ON COLUMN fms.ship_result.chick_no
--    IS '육계번호';
--
--COMMENT ON COLUMN fms.ship_result.order_no
--    IS '주문번호';
--
--COMMENT ON COLUMN fms.ship_result.customer
--    IS '고객사';
--
--COMMENT ON COLUMN fms.ship_result.due_date
--    IS '납품기한일';
--
--COMMENT ON COLUMN fms.ship_result.arrival_date
--    IS '도착일';
--
--COMMENT ON COLUMN fms.ship_result.destination
--    IS '도착지';

CREATE TABLE IF NOT EXISTS fms.unit
(
    column_nm character varying(15) COLLATE pg_catalog."default",
    unit character varying(10) COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS fms.unit
    OWNER to postgres;

COMMENT ON TABLE fms.unit
    IS '단위';

COMMENT ON COLUMN fms.unit.column_nm
    IS '열이름';

COMMENT ON COLUMN fms.unit.unit
    IS '단위';