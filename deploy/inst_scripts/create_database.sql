--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.4
-- Dumped by pg_dump version 9.3.4
-- Started on 2014-07-09 14:16:42 CEST

CREATE ROLE sensetrace LOGIN
SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;


CREATE ROLE sensetrace_read_only LOGIN
SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 6 (class 2615 OID 42226)
-- Name: avg15mpartitions; Type: SCHEMA; Schema: -; Owner: sensetrace
--

CREATE SCHEMA avg15mpartitions;


ALTER SCHEMA avg15mpartitions OWNER TO sensetrace;

--
-- TOC entry 2261 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA avg15mpartitions; Type: COMMENT; Schema: -; Owner: sensetrace
--

COMMENT ON SCHEMA avg15mpartitions IS '15m avg schema';


--
-- TOC entry 7 (class 2615 OID 42227)
-- Name: avg1hpartitions; Type: SCHEMA; Schema: -; Owner: sensetrace
--

CREATE SCHEMA avg1hpartitions;


ALTER SCHEMA avg1hpartitions OWNER TO sensetrace;

--
-- TOC entry 2263 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA avg1hpartitions; Type: COMMENT; Schema: -; Owner: sensetrace
--

COMMENT ON SCHEMA avg1hpartitions IS '1h avg schema';


--
-- TOC entry 8 (class 2615 OID 42228)
-- Name: avg1mpartitions; Type: SCHEMA; Schema: -; Owner: sensetrace
--

CREATE SCHEMA avg1mpartitions;


ALTER SCHEMA avg1mpartitions OWNER TO sensetrace;

--
-- TOC entry 2265 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA avg1mpartitions; Type: COMMENT; Schema: -; Owner: sensetrace
--

COMMENT ON SCHEMA avg1mpartitions IS '1m avg schema';


--
-- TOC entry 9 (class 2615 OID 42229)
-- Name: onesecondserrorpartitions; Type: SCHEMA; Schema: -; Owner: sensetrace
--

CREATE SCHEMA onesecondserrorpartitions;


ALTER SCHEMA onesecondserrorpartitions OWNER TO sensetrace;

--
-- TOC entry 2267 (class 0 OID 0)
-- Dependencies: 9
-- Name: SCHEMA onesecondserrorpartitions; Type: COMMENT; Schema: -; Owner: sensetrace
--

COMMENT ON SCHEMA onesecondserrorpartitions IS 'standard public schema';


--
-- TOC entry 11 (class 2615 OID 42231)
-- Name: rawdatapartitions; Type: SCHEMA; Schema: -; Owner: sensetrace
--

CREATE SCHEMA rawdatapartitions;


ALTER SCHEMA rawdatapartitions OWNER TO sensetrace;

--
-- TOC entry 2271 (class 0 OID 0)
-- Dependencies: 11
-- Name: SCHEMA rawdatapartitions; Type: COMMENT; Schema: -; Owner: sensetrace
--

COMMENT ON SCHEMA rawdatapartitions IS 'standard public schema';


--
-- TOC entry 222 (class 3079 OID 11803)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2273 (class 0 OID 0)
-- Dependencies: 222
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = avg15mpartitions, pg_catalog;

--
-- TOC entry 235 (class 1255 OID 42232)
-- Name: partition_avgs_15m_function(); Type: FUNCTION; Schema: avg15mpartitions; Owner: sensetrace
--

CREATE FUNCTION partition_avgs_15m_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  --_new_time int;
  _tablename text;
  --_date text;
  _year_date timestamp without time zone;
  _year text;
  _sensorid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _sensorid:=NEW."sensorid";

  _tablename := 'Data_15m_avg_'||_year||'_'||_sensorid;
 
  -- Check if the partition needed for the current record exists
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'avg15mpartitions';
 
 EXECUTE 'INSERT INTO avg15mpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
 RETURN NULL;
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
exception 
when undefined_table then
    EXECUTE 'CREATE TABLE avg15mpartitions.' || quote_ident(_tablename) || 
    ' (
      CHECK ( "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "sensorid"= '|| quote_literal(_sensorid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", sensorid)
       ) INHERITS (public."Data_15m_avg")';
 
  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.


  EXECUTE 'ALTER TABLE avg15mpartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE avg15mpartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO avg15mpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
RETURN NULL;
END;
$_$;


ALTER FUNCTION avg15mpartitions.partition_avgs_15m_function() OWNER TO sensetrace;

SET search_path = avg1hpartitions, pg_catalog;

--
-- TOC entry 236 (class 1255 OID 42233)
-- Name: partition_avgs_1h_function(); Type: FUNCTION; Schema: avg1hpartitions; Owner: sensetrace
--

CREATE FUNCTION partition_avgs_1h_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  --_new_time int;
  _tablename text;
  --_date text;
  _year_date timestamp without time zone;
  _year text;
  _sensorid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _sensorid:=NEW."sensorid";

  _tablename := 'Data_1h_avg_'||_year||'_'||_sensorid;
 -- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO avg1hpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
RETURN NULL;
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
exception 
when undefined_table then
    EXECUTE 'CREATE TABLE avg1hpartitions.' || quote_ident(_tablename) || 
    ' (
      CHECK ( "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "sensorid"= '|| quote_literal(_sensorid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", sensorid)
       ) INHERITS (public."Data_1h_avg")';
 
  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.


  EXECUTE 'ALTER TABLE avg1hpartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE avg1hpartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO avg1hpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
RETURN NULL;
END;
$_$;


ALTER FUNCTION avg1hpartitions.partition_avgs_1h_function() OWNER TO sensetrace;

SET search_path = avg1mpartitions, pg_catalog;

--
-- TOC entry 237 (class 1255 OID 42234)
-- Name: partition_avgs_1m_function(); Type: FUNCTION; Schema: avg1mpartitions; Owner: sensetrace
--

CREATE FUNCTION partition_avgs_1m_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  --_new_time int;
  _tablename text;
  --_date text;
  _year_date timestamp without time zone;
  _year text;
  _sensorid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _sensorid:=NEW."sensorid";

  _tablename := 'Data_1m_avg_'||_year||'_'||_sensorid;
 
  -- Check if the partition needed for the current record exists
EXECUTE 'INSERT INTO avg1mpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
RETURN NULL;
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
exception 
when undefined_table then
    EXECUTE 'CREATE TABLE avg1mpartitions.' || quote_ident(_tablename) || 
    ' (
      CHECK ( "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "sensorid"= '|| quote_literal(_sensorid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", sensorid)
       ) INHERITS (public."Data_1m_avg")';
 
  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.


  EXECUTE 'ALTER TABLE avg1mpartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE avg1mpartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';
EXECUTE 'INSERT INTO avg1mpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
RETURN NULL;
END;
$_$;


ALTER FUNCTION avg1mpartitions.partition_avgs_1m_function() OWNER TO sensetrace;

SET search_path = onesecondserrorpartitions, pg_catalog;

--
-- TOC entry 238 (class 1255 OID 42235)
-- Name: server_partition_function(); Type: FUNCTION; Schema: onesecondserrorpartitions; Owner: sensetrace
--

CREATE FUNCTION server_partition_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$DECLARE
  --_new_time int;
  _tablename text;
  --_date text;
  _year_date timestamp without time zone;
  _year text;
  _sensorid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _sensorid:=NEW."sensorid";
  _tablename := 'Error_'||_year||'_'||_sensorid;


-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO onesecondserrorpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
return null;
--END IF;
exception 
when undefined_table then
 EXECUTE 'CREATE TABLE onesecondserrorpartitions.' || quote_ident(_tablename) || 
    ' ( check(
       "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "sensorid"= '|| quote_literal(_sensorid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", sensorid)
       ) INHERITS (public."ErrorData")';
 


  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.
    EXECUTE 'ALTER TABLE onesecondserrorpartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE onesecondserrorpartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';
EXECUTE 'INSERT INTO onesecondserrorpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
return null;


END;

$_$;


ALTER FUNCTION onesecondserrorpartitions.server_partition_function() OWNER TO sensetrace;

SET search_path = public, pg_catalog;

--
-- TOC entry 239 (class 1255 OID 42236)
-- Name: getdays(timestamp with time zone); Type: FUNCTION; Schema: public; Owner: sensetrace
--

CREATE FUNCTION getdays(timestamp with time zone) RETURNS double precision
    LANGUAGE sql
    AS $_$
SELECT DATE_PART('days', 
        DATE_TRUNC('month',  $1) 
        + '1 MONTH'::INTERVAL 
        - DATE_TRUNC('month',  $1));
$_$;


ALTER FUNCTION public.getdays(timestamp with time zone) OWNER TO sensetrace;

--
-- TOC entry 240 (class 1255 OID 42237)
-- Name: server_partition_function(); Type: FUNCTION; Schema: public; Owner: sensetrace
--

CREATE FUNCTION server_partition_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$

DECLARE
  --_new_time int;
  _tablename text;
  --_date text;
  _year_date timestamp without time zone;
  _year text;
  _sensorid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _sensorid:=NEW."sensorid";

  _tablename := 'Rawdata_'||_year||'_'||_sensorid;

 --IF _year::integer<=2013 THEN
--EXECUTE 'INSERT INTO "Rawdataold"' || ' VALUES ($1.*)' USING NEW;
 --ELSE
 
  -- Check if 

   --For performance reasons i temporally commented out the part to create a new tablethe partition needed for the current record exists
   /*
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'rawdatapartitions';
 */
 EXECUTE 'INSERT INTO rawdatapartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
 return null;
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
exception 
when undefined_table then
    EXECUTE 'CREATE TABLE rawdatapartitions.' || quote_ident(_tablename) || 
    ' (
        "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "sensorid"= '|| quote_literal(_sensorid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", sensorid)
       ) INHERITS (public."Rawdata")';
 
  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.
  EXECUTE 'ALTER TABLE rawdatapartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE rawdatapartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';
 EXECUTE 'INSERT INTO rawdatapartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
 
 return null;


END;





$_$;


ALTER FUNCTION public.server_partition_function() OWNER TO sensetrace;

--
-- TOC entry 242 (class 1255 OID 42238)
-- Name: ts_round(timestamp with time zone, integer); Type: FUNCTION; Schema: public; Owner: sensetrace
--

CREATE FUNCTION ts_round(timestamp with time zone, integer) RETURNS timestamp with time zone
    LANGUAGE sql
    AS $_$
    SELECT 'epoch'::timestamptz + '1 second'::INTERVAL * ( $2 * ( extract( epoch FROM $1 )::INT4 / $2 ) );
$_$;


ALTER FUNCTION public.ts_round(timestamp with time zone, integer) OWNER TO sensetrace;

--
-- TOC entry 243 (class 1255 OID 42239)
-- Name: ts_round_month(timestamp with time zone, integer); Type: FUNCTION; Schema: public; Owner: sensetrace
--

CREATE FUNCTION ts_round_month(timestamp with time zone, integer) RETURNS timestamp with time zone
    LANGUAGE sql
    AS $_$
    SELECT 'epoch'::timestamptz + '1 second'::INTERVAL * ( $2 * ( extract( epoch FROM $1 )::INT4 / $2 ) );
$_$;


ALTER FUNCTION public.ts_round_month(timestamp with time zone, integer) OWNER TO sensetrace;

SET search_path = rawdatapartitions, pg_catalog;

--
-- TOC entry 241 (class 1255 OID 42241)
-- Name: server_partition_function(); Type: FUNCTION; Schema: rawdatapartitions; Owner: sensetrace
--

CREATE FUNCTION server_partition_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$

DECLARE
  --_new_time int;
  _tablename text;
  --_date text;
  _year_date timestamp without time zone;
  _year text;
  _sensorid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _sensorid:=NEW."sensorid";

  _tablename := 'Rawdata_'||_year||'_'||_sensorid;

 --IF _year::integer<=2013 THEN
--EXECUTE 'INSERT INTO "Rawdataold"' || ' VALUES ($1.*)' USING NEW;
 --ELSE
 
  -- Check if 

   --For performance reasons i temporally commented out the part to create a new tablethe partition needed for the current record exists
   /*
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'rawdatapartitions';
 */
 EXECUTE 'INSERT INTO rawdatapartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
 return null;
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
exception 
when undefined_table then
    EXECUTE 'CREATE TABLE rawdatapartitions.' || quote_ident(_tablename) || 
    ' (
      CHECK ("timestamp" >=' || quote_literal('2014-01-01 00:00:00') || '::timestamp without time zone
      AND
       "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "sensorid"= '|| quote_literal(_sensorid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", sensorid)
       ) INHERITS (public."Rawdata")';
 
  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.
  EXECUTE 'ALTER TABLE rawdatapartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE rawdatapartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';
 EXECUTE 'INSERT INTO rawdatapartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
 
 return null;


END;





$_$;


ALTER FUNCTION rawdatapartitions.server_partition_function() OWNER TO sensetrace;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 175 (class 1259 OID 42242)
-- Name: Classification; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification" OWNER TO sensetrace;

--
-- TOC entry 176 (class 1259 OID 42245)
-- Name: Classification_15m_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_15m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_15m_avg" OWNER TO sensetrace;

--
-- TOC entry 177 (class 1259 OID 42248)
-- Name: Classification_15m_avg_cover; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_15m_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_15m_avg_cover" OWNER TO sensetrace;

--
-- TOC entry 178 (class 1259 OID 42251)
-- Name: Classification_1d_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1d_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1d_avg" OWNER TO sensetrace;

--
-- TOC entry 179 (class 1259 OID 42254)
-- Name: Classification_1d_avg_cover; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1d_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1d_avg_cover" OWNER TO sensetrace;

--
-- TOC entry 180 (class 1259 OID 42257)
-- Name: Classification_1h_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1h_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1h_avg" OWNER TO sensetrace;

--
-- TOC entry 181 (class 1259 OID 42260)
-- Name: Classification_1h_avg_cover; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1h_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1h_avg_cover" OWNER TO sensetrace;

--
-- TOC entry 182 (class 1259 OID 42263)
-- Name: Classification_1m_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1m_avg" OWNER TO sensetrace;

--
-- TOC entry 183 (class 1259 OID 42266)
-- Name: Classification_1m_avg_cover; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1m_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1m_avg_cover" OWNER TO sensetrace;

--
-- TOC entry 184 (class 1259 OID 42269)
-- Name: Classification_1month_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1month_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1month_avg" OWNER TO sensetrace;

--
-- TOC entry 185 (class 1259 OID 42272)
-- Name: Classification_1month_avg_cover; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1month_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1month_avg_cover" OWNER TO sensetrace;

--
-- TOC entry 186 (class 1259 OID 42275)
-- Name: Classification_1y_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1y_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1y_avg" OWNER TO sensetrace;

--
-- TOC entry 187 (class 1259 OID 42278)
-- Name: Classification_1y_avg_cover; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Classification_1y_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


ALTER TABLE public."Classification_1y_avg_cover" OWNER TO sensetrace;

--
-- TOC entry 188 (class 1259 OID 42281)
-- Name: Data_15m_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Data_15m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."Data_15m_avg" OWNER TO sensetrace;

--
-- TOC entry 189 (class 1259 OID 42287)
-- Name: Data_1d_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Data_1d_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."Data_1d_avg" OWNER TO sensetrace;

--
-- TOC entry 190 (class 1259 OID 42290)
-- Name: Data_1h_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Data_1h_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."Data_1h_avg" OWNER TO sensetrace;

--
-- TOC entry 191 (class 1259 OID 42296)
-- Name: Data_1m_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Data_1m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."Data_1m_avg" OWNER TO sensetrace;

--
-- TOC entry 192 (class 1259 OID 42302)
-- Name: Data_1month_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Data_1month_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."Data_1month_avg" OWNER TO sensetrace;

--
-- TOC entry 193 (class 1259 OID 42305)
-- Name: Data_1y_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Data_1y_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."Data_1y_avg" OWNER TO sensetrace;

--
-- TOC entry 194 (class 1259 OID 42308)
-- Name: ErrorData; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "ErrorData" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value real
);


ALTER TABLE public."ErrorData" OWNER TO sensetrace;

--
-- TOC entry 195 (class 1259 OID 42311)
-- Name: ErrorData_15m_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "ErrorData_15m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."ErrorData_15m_avg" OWNER TO sensetrace;

--
-- TOC entry 196 (class 1259 OID 42314)
-- Name: ErrorData_1d_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "ErrorData_1d_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."ErrorData_1d_avg" OWNER TO sensetrace;

--
-- TOC entry 197 (class 1259 OID 42317)
-- Name: ErrorData_1h_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "ErrorData_1h_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."ErrorData_1h_avg" OWNER TO sensetrace;

--
-- TOC entry 198 (class 1259 OID 42320)
-- Name: ErrorData_1m_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "ErrorData_1m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."ErrorData_1m_avg" OWNER TO sensetrace;

--
-- TOC entry 199 (class 1259 OID 42323)
-- Name: ErrorData_1month_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "ErrorData_1month_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."ErrorData_1month_avg" OWNER TO sensetrace;

--
-- TOC entry 200 (class 1259 OID 42326)
-- Name: ErrorData_1y_avg; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "ErrorData_1y_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


ALTER TABLE public."ErrorData_1y_avg" OWNER TO sensetrace;

--
-- TOC entry 201 (class 1259 OID 42329)
-- Name: ErrorData_User; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "ErrorData_User" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value real
);


ALTER TABLE public."ErrorData_User" OWNER TO sensetrace;

--
-- TOC entry 202 (class 1259 OID 42332)
-- Name: LastImportDate; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "LastImportDate" (
    "timestamp" timestamp without time zone NOT NULL
);


ALTER TABLE public."LastImportDate" OWNER TO sensetrace;

--
-- TOC entry 203 (class 1259 OID 42335)
-- Name: Rawdata; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Rawdata" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value real
);


ALTER TABLE public."Rawdata" OWNER TO sensetrace;

--
-- TOC entry 204 (class 1259 OID 42345)
-- Name: Registry_LastEntries; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Registry_LastEntries" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value real
);


ALTER TABLE public."Registry_LastEntries" OWNER TO sensetrace;

--
-- TOC entry 205 (class 1259 OID 42348)
-- Name: Registry_Rules; Type: TABLE; Schema: public; Owner: sensetrace; Tablespace: 
--

CREATE TABLE "Registry_Rules" (
    rule text,
    clid smallint NOT NULL
);


ALTER TABLE public."Registry_Rules" OWNER TO sensetrace;

--
-- TOC entry 206 (class 1259 OID 42354)
-- Name: errorfilter15min; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW errorfilter15min AS
 SELECT u1.sensorid,
    u1."timestamp",
    r2.value,
    u1.value AS value_cor
   FROM ((         SELECT r1.sensorid,
                    r1."timestamp",
                    r1.value
                   FROM "Data_15m_avg" r1
                  WHERE (NOT (r1."timestamp" IN ( SELECT e1."timestamp"
                           FROM "ErrorData_15m_avg" e1
                          WHERE ((r1.sensorid = e1.sensorid) AND (r1."timestamp" = e1."timestamp")))))
        UNION
                 SELECT e2.sensorid,
                    e2."timestamp",
                    e2.value
                   FROM "ErrorData_15m_avg" e2) u1
   JOIN "Data_15m_avg" r2 ON (((u1."timestamp" = r2."timestamp") AND (u1.sensorid = r2.sensorid))));


ALTER TABLE public.errorfilter15min OWNER TO sensetrace;

--
-- TOC entry 207 (class 1259 OID 42359)
-- Name: avg15min; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW avg15min AS
 SELECT DISTINCT r1.sensorid,
    r1."timestamp",
    r1.value,
    r1.value_cor,
    COALESCE(c1.clid, (0)::smallint) AS clid,
    COALESCE(c2.clid, (0)::smallint) AS clid_cover
   FROM ((errorfilter15min r1
   LEFT JOIN "Classification_15m_avg" c1 ON ((r1."timestamp" = c1."timestamp")))
   LEFT JOIN "Classification_15m_avg_cover" c2 ON ((r1."timestamp" = c2."timestamp")));


ALTER TABLE public.avg15min OWNER TO sensetrace;

--
-- TOC entry 208 (class 1259 OID 42363)
-- Name: errorfilter1d; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW errorfilter1d AS
 SELECT u1.sensorid,
    u1."timestamp",
    r2.value,
    u1.value AS value_cor
   FROM ((         SELECT r1.sensorid,
                    r1."timestamp",
                    r1.value
                   FROM "Data_1d_avg" r1
                  WHERE (NOT (r1."timestamp" IN ( SELECT e1."timestamp"
                           FROM "ErrorData_1d_avg" e1
                          WHERE ((r1.sensorid = e1.sensorid) AND (r1."timestamp" = e1."timestamp")))))
        UNION
                 SELECT e2.sensorid,
                    e2."timestamp",
                    e2.value
                   FROM "ErrorData_1d_avg" e2) u1
   JOIN "Data_1d_avg" r2 ON (((u1."timestamp" = r2."timestamp") AND (u1.sensorid = r2.sensorid))));


ALTER TABLE public.errorfilter1d OWNER TO sensetrace;

--
-- TOC entry 209 (class 1259 OID 42368)
-- Name: avg1d; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW avg1d AS
 SELECT DISTINCT r1.sensorid,
    r1."timestamp",
    r1.value,
    r1.value_cor,
    COALESCE(c1.clid, (0)::smallint) AS clid,
    COALESCE(c2.clid, (0)::smallint) AS clid_cover
   FROM ((errorfilter1d r1
   LEFT JOIN "Classification_1d_avg_cover" c2 ON ((r1."timestamp" = c2."timestamp")))
   LEFT JOIN "Classification_1d_avg" c1 ON ((r1."timestamp" = c1."timestamp")));


ALTER TABLE public.avg1d OWNER TO sensetrace;

--
-- TOC entry 210 (class 1259 OID 42372)
-- Name: errorfilter1h; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW errorfilter1h AS
 SELECT u1.sensorid,
    u1."timestamp",
    r2.value,
    u1.value AS value_cor
   FROM ((         SELECT r1.sensorid,
                    r1."timestamp",
                    r1.value
                   FROM "Data_1h_avg" r1
                  WHERE (NOT (r1."timestamp" IN ( SELECT e1."timestamp"
                           FROM "ErrorData_1h_avg" e1
                          WHERE ((r1.sensorid = e1.sensorid) AND (r1."timestamp" = e1."timestamp")))))
        UNION
                 SELECT e2.sensorid,
                    e2."timestamp",
                    e2.value
                   FROM "ErrorData_1h_avg" e2) u1
   JOIN "Data_1h_avg" r2 ON (((u1."timestamp" = r2."timestamp") AND (u1.sensorid = r2.sensorid))));


ALTER TABLE public.errorfilter1h OWNER TO sensetrace;

--
-- TOC entry 211 (class 1259 OID 42377)
-- Name: avg1h; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW avg1h AS
 SELECT DISTINCT r1.sensorid,
    r1."timestamp",
    r1.value,
    r1.value_cor,
    COALESCE(c1.clid, (0)::smallint) AS clid,
    COALESCE(c2.clid, (0)::smallint) AS clid_cover
   FROM ((errorfilter1h r1
   LEFT JOIN "Classification_1h_avg_cover" c2 ON ((r1."timestamp" = c2."timestamp")))
   LEFT JOIN "Classification_1h_avg" c1 ON ((r1."timestamp" = c1."timestamp")));


ALTER TABLE public.avg1h OWNER TO sensetrace;

--
-- TOC entry 212 (class 1259 OID 42381)
-- Name: errorfilter1min; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW errorfilter1min AS
 SELECT u1.sensorid,
    u1."timestamp",
    r2.value,
    u1.value AS value_cor
   FROM ((         SELECT r1.sensorid,
                    r1."timestamp",
                    r1.value
                   FROM "Data_1m_avg" r1
                  WHERE (NOT (r1."timestamp" IN ( SELECT e1."timestamp"
                           FROM "ErrorData_1m_avg" e1
                          WHERE ((r1.sensorid = e1.sensorid) AND (r1."timestamp" = e1."timestamp")))))
        UNION
                 SELECT e2.sensorid,
                    e2."timestamp",
                    e2.value
                   FROM "ErrorData_1m_avg" e2) u1
   JOIN "Data_1m_avg" r2 ON (((u1."timestamp" = r2."timestamp") AND (u1.sensorid = r2.sensorid))));


ALTER TABLE public.errorfilter1min OWNER TO sensetrace;

--
-- TOC entry 213 (class 1259 OID 42386)
-- Name: avg1min; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW avg1min AS
 SELECT DISTINCT r1.sensorid,
    r1."timestamp",
    r1.value,
    r1.value_cor,
    COALESCE(c1.clid, (0)::smallint) AS clid,
    COALESCE(c2.clid, (0)::smallint) AS clid_cover
   FROM ((errorfilter1min r1
   LEFT JOIN "Classification_1m_avg" c1 ON ((r1."timestamp" = c1."timestamp")))
   LEFT JOIN "Classification_1m_avg_cover" c2 ON ((r1."timestamp" = c2."timestamp")));


ALTER TABLE public.avg1min OWNER TO sensetrace;

--
-- TOC entry 214 (class 1259 OID 42390)
-- Name: errorfilter1month; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW errorfilter1month AS
 SELECT u1.sensorid,
    u1."timestamp",
    r2.value,
    u1.value AS value_cor
   FROM ((         SELECT r1.sensorid,
                    r1."timestamp",
                    r1.value
                   FROM "Data_1month_avg" r1
                  WHERE (NOT (r1."timestamp" IN ( SELECT e1."timestamp"
                           FROM "ErrorData_1month_avg" e1
                          WHERE ((r1.sensorid = e1.sensorid) AND (r1."timestamp" = e1."timestamp")))))
        UNION
                 SELECT e2.sensorid,
                    e2."timestamp",
                    e2.value
                   FROM "ErrorData_1month_avg" e2) u1
   JOIN "Data_1month_avg" r2 ON (((u1."timestamp" = r2."timestamp") AND (u1.sensorid = r2.sensorid))));


ALTER TABLE public.errorfilter1month OWNER TO sensetrace;

--
-- TOC entry 215 (class 1259 OID 42395)
-- Name: avg1month; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW avg1month AS
 SELECT DISTINCT r1.sensorid,
    r1."timestamp",
    r1.value,
    r1.value_cor,
    COALESCE(c1.clid, (0)::smallint) AS clid,
    COALESCE(c2.clid, (0)::smallint) AS clid_cover
   FROM ((errorfilter1month r1
   LEFT JOIN "Classification_1month_avg_cover" c2 ON ((r1."timestamp" = c2."timestamp")))
   LEFT JOIN "Classification_1month_avg" c1 ON ((r1."timestamp" = c1."timestamp")));


ALTER TABLE public.avg1month OWNER TO sensetrace;

--
-- TOC entry 216 (class 1259 OID 42399)
-- Name: errorfilter1y; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW errorfilter1y AS
 SELECT u1.sensorid,
    u1."timestamp",
    r2.value,
    u1.value AS value_cor
   FROM ((         SELECT r1.sensorid,
                    r1."timestamp",
                    r1.value
                   FROM "Data_1y_avg" r1
                  WHERE (NOT (r1."timestamp" IN ( SELECT e1."timestamp"
                           FROM "ErrorData_1y_avg" e1
                          WHERE ((r1.sensorid = e1.sensorid) AND (r1."timestamp" = e1."timestamp")))))
        UNION
                 SELECT e2.sensorid,
                    e2."timestamp",
                    e2.value
                   FROM "ErrorData_1y_avg" e2) u1
   JOIN "Data_1y_avg" r2 ON (((u1."timestamp" = r2."timestamp") AND (u1.sensorid = r2.sensorid))));


ALTER TABLE public.errorfilter1y OWNER TO sensetrace;

--
-- TOC entry 217 (class 1259 OID 42404)
-- Name: avg1year; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW avg1year AS
 SELECT DISTINCT r1.sensorid,
    r1."timestamp",
    r1.value,
    r1.value_cor,
    COALESCE(c1.clid, (0)::smallint) AS clid,
    COALESCE(c2.clid, (0)::smallint) AS clid_cover
   FROM ((errorfilter1y r1
   LEFT JOIN "Classification_1y_avg_cover" c2 ON ((r1."timestamp" = c2."timestamp")))
   LEFT JOIN "Classification_1y_avg" c1 ON ((r1."timestamp" = c1."timestamp")));


ALTER TABLE public.avg1year OWNER TO sensetrace;

--
-- TOC entry 218 (class 1259 OID 42408)
-- Name: errorfilter; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW errorfilter AS
 SELECT u1.sensorid,
    u1."timestamp",
    u1.value,
    u1.value_cor
   FROM (         SELECT r1.sensorid,
                    r1."timestamp",
                    r1.value,
                    r1.value AS value_cor
                   FROM "Rawdata" r1
                  WHERE (NOT (r1."timestamp" IN ( SELECT e1."timestamp"
                           FROM "ErrorData" e1
                          WHERE ((r1.sensorid = e1.sensorid) AND (r1."timestamp" = e1."timestamp")))))
        UNION
                 SELECT e2.sensorid,
                    e2."timestamp",
                    r2.value,
                    e2.value AS value_cor
                   FROM "ErrorData" e2,
                    "Rawdata" r2
                  WHERE ((r2.sensorid = e2.sensorid) AND (e2."timestamp" = r2."timestamp"))) u1;


ALTER TABLE public.errorfilter OWNER TO sensetrace;

--
-- TOC entry 219 (class 1259 OID 42413)
-- Name: meas_in_cl; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW meas_in_cl AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
    r2.clid
   FROM "Rawdata" r1,
    "Classification" r2
  WHERE (r1."timestamp" = r2."timestamp");


ALTER TABLE public.meas_in_cl OWNER TO sensetrace;

--
-- TOC entry 220 (class 1259 OID 42417)
-- Name: meas_not_in_cl; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW meas_not_in_cl AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
    r2.*::"Classification" AS r2,
    r2.clid
   FROM "Rawdata" r1,
    "Classification" r2
  WHERE ((r1."timestamp" IN (         SELECT "Rawdata"."timestamp"
                   FROM "Rawdata"
        EXCEPT
                 SELECT "Classification"."timestamp"
                   FROM "Classification")) AND (r2.clid = 1));


ALTER TABLE public.meas_not_in_cl OWNER TO sensetrace;

--
-- TOC entry 221 (class 1259 OID 42421)
-- Name: measurement; Type: VIEW; Schema: public; Owner: sensetrace
--

CREATE VIEW measurement AS
 SELECT DISTINCT r1.sensorid,
    r1."timestamp",
    r1.value,
    r1.value_cor,
    COALESCE(c1.clid, (0)::smallint) AS clid
   FROM (errorfilter r1
   LEFT JOIN "Classification" c1 ON ((r1."timestamp" = c1."timestamp")));


ALTER TABLE public.measurement OWNER TO sensetrace;

--
-- TOC entry 2073 (class 2606 OID 42435)
-- Name: PkClassification; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification"
    ADD CONSTRAINT "PkClassification" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2075 (class 2606 OID 42437)
-- Name: PkClassification_15m_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_15m_avg"
    ADD CONSTRAINT "PkClassification_15m_avg" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2077 (class 2606 OID 42439)
-- Name: PkClassification_15m_avg_cover; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_15m_avg_cover"
    ADD CONSTRAINT "PkClassification_15m_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2079 (class 2606 OID 42441)
-- Name: PkClassification_1d_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1d_avg"
    ADD CONSTRAINT "PkClassification_1d_avg" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2081 (class 2606 OID 42443)
-- Name: PkClassification_1d_avg_cover; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1d_avg_cover"
    ADD CONSTRAINT "PkClassification_1d_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2083 (class 2606 OID 42445)
-- Name: PkClassification_1h_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1h_avg"
    ADD CONSTRAINT "PkClassification_1h_avg" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2085 (class 2606 OID 42447)
-- Name: PkClassification_1h_avg_cover; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1h_avg_cover"
    ADD CONSTRAINT "PkClassification_1h_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2087 (class 2606 OID 42449)
-- Name: PkClassification_1m_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1m_avg"
    ADD CONSTRAINT "PkClassification_1m_avg" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2089 (class 2606 OID 42451)
-- Name: PkClassification_1m_avg_cover; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1m_avg_cover"
    ADD CONSTRAINT "PkClassification_1m_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2091 (class 2606 OID 42453)
-- Name: PkClassification_1month_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1month_avg"
    ADD CONSTRAINT "PkClassification_1month_avg" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2093 (class 2606 OID 42455)
-- Name: PkClassification_1month_avg_cover; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1month_avg_cover"
    ADD CONSTRAINT "PkClassification_1month_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2095 (class 2606 OID 42457)
-- Name: PkClassification_1y_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1y_avg"
    ADD CONSTRAINT "PkClassification_1y_avg" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2097 (class 2606 OID 42459)
-- Name: PkClassification_1y_avg_cover; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Classification_1y_avg_cover"
    ADD CONSTRAINT "PkClassification_1y_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- TOC entry 2127 (class 2606 OID 42461)
-- Name: PkRawdata; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Rawdata"
    ADD CONSTRAINT "PkRawdata" PRIMARY KEY ("timestamp", sensorid) WITH (fillfactor=30);


--
-- TOC entry 2099 (class 2606 OID 42467)
-- Name: PrimaryKeyData_15m_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Data_15m_avg"
    ADD CONSTRAINT "PrimaryKeyData_15m_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- TOC entry 2101 (class 2606 OID 42471)
-- Name: PrimaryKeyData_1d_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Data_1d_avg"
    ADD CONSTRAINT "PrimaryKeyData_1d_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- TOC entry 2103 (class 2606 OID 42473)
-- Name: PrimaryKeyData_1h_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Data_1h_avg"
    ADD CONSTRAINT "PrimaryKeyData_1h_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- TOC entry 2105 (class 2606 OID 42477)
-- Name: PrimaryKeyData_1m_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Data_1m_avg"
    ADD CONSTRAINT "PrimaryKeyData_1m_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- TOC entry 2107 (class 2606 OID 42481)
-- Name: PrimaryKeyData_1month_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Data_1month_avg"
    ADD CONSTRAINT "PrimaryKeyData_1month_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- TOC entry 2109 (class 2606 OID 42483)
-- Name: PrimaryKeyData_1y_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "Data_1y_avg"
    ADD CONSTRAINT "PrimaryKeyData_1y_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- TOC entry 2125 (class 2606 OID 42485)
-- Name: PrimaryKeyEErrorData_User; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_User"
    ADD CONSTRAINT "PrimaryKeyEErrorData_User" PRIMARY KEY ("timestamp", sensorid);


--
-- TOC entry 2111 (class 2606 OID 42487)
-- Name: PrimaryKeyErrorData; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "ErrorData"
    ADD CONSTRAINT "PrimaryKeyErrorData" PRIMARY KEY ("timestamp", sensorid);


--
-- TOC entry 2113 (class 2606 OID 42489)
-- Name: PrimaryKeyErrorData_15m_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_15m_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_15m_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- TOC entry 2115 (class 2606 OID 42491)
-- Name: PrimaryKeyErrorData_1d_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1d_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1d_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- TOC entry 2117 (class 2606 OID 42493)
-- Name: PrimaryKeyErrorData_1h_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1h_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1h_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- TOC entry 2119 (class 2606 OID 42495)
-- Name: PrimaryKeyErrorData_1m_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1m_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1m_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- TOC entry 2121 (class 2606 OID 42497)
-- Name: PrimaryKeyErrorData_1month_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1month_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1month_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- TOC entry 2123 (class 2606 OID 42499)
-- Name: PrimaryKeyErrorData_1y_avg; Type: CONSTRAINT; Schema: public; Owner: sensetrace; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1y_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1y_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- TOC entry 2128 (class 2620 OID 42500)
-- Name: data_15m_avg_trigger; Type: TRIGGER; Schema: public; Owner: sensetrace
--

CREATE TRIGGER data_15m_avg_trigger BEFORE INSERT ON "Data_15m_avg" FOR EACH ROW EXECUTE PROCEDURE avg15mpartitions.partition_avgs_15m_function();


--
-- TOC entry 2129 (class 2620 OID 42501)
-- Name: data_1h_avg_trigger; Type: TRIGGER; Schema: public; Owner: sensetrace
--

CREATE TRIGGER data_1h_avg_trigger BEFORE INSERT ON "Data_1h_avg" FOR EACH ROW EXECUTE PROCEDURE avg1hpartitions.partition_avgs_1h_function();


--
-- TOC entry 2130 (class 2620 OID 42502)
-- Name: data_1m_avg_trigger; Type: TRIGGER; Schema: public; Owner: sensetrace
--

CREATE TRIGGER data_1m_avg_trigger BEFORE INSERT ON "Data_1m_avg" FOR EACH ROW EXECUTE PROCEDURE avg1mpartitions.partition_avgs_1m_function();


--
-- TOC entry 2131 (class 2620 OID 42503)
-- Name: errordata_trigger; Type: TRIGGER; Schema: public; Owner: sensetrace
--

CREATE TRIGGER errordata_trigger BEFORE INSERT ON "ErrorData" FOR EACH ROW EXECUTE PROCEDURE onesecondserrorpartitions.server_partition_function();


--
-- TOC entry 2132 (class 2620 OID 42504)
-- Name: rawdata_trigger; Type: TRIGGER; Schema: public; Owner: sensetrace
--

CREATE TRIGGER rawdata_trigger BEFORE INSERT ON "Rawdata" FOR EACH ROW EXECUTE PROCEDURE rawdatapartitions.server_partition_function();


--
-- TOC entry 2262 (class 0 OID 0)
-- Dependencies: 6
-- Name: avg15mpartitions; Type: ACL; Schema: -; Owner: sensetrace
--

REVOKE ALL ON SCHEMA avg15mpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA avg15mpartitions FROM sensetrace;
GRANT ALL ON SCHEMA avg15mpartitions TO sensetrace;
GRANT ALL ON SCHEMA avg15mpartitions TO PUBLIC;


--
-- TOC entry 2264 (class 0 OID 0)
-- Dependencies: 7
-- Name: avg1hpartitions; Type: ACL; Schema: -; Owner: sensetrace
--

REVOKE ALL ON SCHEMA avg1hpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA avg1hpartitions FROM sensetrace;
GRANT ALL ON SCHEMA avg1hpartitions TO sensetrace;
GRANT ALL ON SCHEMA avg1hpartitions TO PUBLIC;


--
-- TOC entry 2266 (class 0 OID 0)
-- Dependencies: 8
-- Name: avg1mpartitions; Type: ACL; Schema: -; Owner: sensetrace
--

REVOKE ALL ON SCHEMA avg1mpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA avg1mpartitions FROM sensetrace;
GRANT ALL ON SCHEMA avg1mpartitions TO sensetrace;
GRANT ALL ON SCHEMA avg1mpartitions TO PUBLIC;


--
-- TOC entry 2268 (class 0 OID 0)
-- Dependencies: 9
-- Name: onesecondserrorpartitions; Type: ACL; Schema: -; Owner: sensetrace
--

REVOKE ALL ON SCHEMA onesecondserrorpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA onesecondserrorpartitions FROM sensetrace;
GRANT ALL ON SCHEMA onesecondserrorpartitions TO sensetrace;
GRANT ALL ON SCHEMA onesecondserrorpartitions TO PUBLIC;


--
-- TOC entry 2270 (class 0 OID 0)
-- Dependencies: 10
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO sensetrace;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 2272 (class 0 OID 0)
-- Dependencies: 11
-- Name: rawdatapartitions; Type: ACL; Schema: -; Owner: sensetrace
--

REVOKE ALL ON SCHEMA rawdatapartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA rawdatapartitions FROM sensetrace;
GRANT ALL ON SCHEMA rawdatapartitions TO sensetrace;
GRANT ALL ON SCHEMA rawdatapartitions TO PUBLIC;


--
-- TOC entry 2274 (class 0 OID 0)
-- Dependencies: 242
-- Name: ts_round(timestamp with time zone, integer); Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON FUNCTION ts_round(timestamp with time zone, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION ts_round(timestamp with time zone, integer) FROM sensetrace;
GRANT ALL ON FUNCTION ts_round(timestamp with time zone, integer) TO sensetrace;
GRANT ALL ON FUNCTION ts_round(timestamp with time zone, integer) TO PUBLIC;


--
-- TOC entry 2275 (class 0 OID 0)
-- Dependencies: 243
-- Name: ts_round_month(timestamp with time zone, integer); Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON FUNCTION ts_round_month(timestamp with time zone, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION ts_round_month(timestamp with time zone, integer) FROM sensetrace;
GRANT ALL ON FUNCTION ts_round_month(timestamp with time zone, integer) TO sensetrace;
GRANT ALL ON FUNCTION ts_round_month(timestamp with time zone, integer) TO PUBLIC;


--
-- TOC entry 2276 (class 0 OID 0)
-- Dependencies: 175
-- Name: Classification; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification" FROM sensetrace;
GRANT ALL ON TABLE "Classification" TO sensetrace;
GRANT SELECT ON TABLE "Classification" TO sensetrace_read_only;


--
-- TOC entry 2277 (class 0 OID 0)
-- Dependencies: 176
-- Name: Classification_15m_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_15m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_15m_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_15m_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_15m_avg" TO sensetrace_read_only;


--
-- TOC entry 2278 (class 0 OID 0)
-- Dependencies: 177
-- Name: Classification_15m_avg_cover; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_15m_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_15m_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_15m_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_15m_avg_cover" TO sensetrace_read_only;


--
-- TOC entry 2279 (class 0 OID 0)
-- Dependencies: 178
-- Name: Classification_1d_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1d_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1d_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1d_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1d_avg" TO sensetrace_read_only;


--
-- TOC entry 2280 (class 0 OID 0)
-- Dependencies: 179
-- Name: Classification_1d_avg_cover; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1d_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1d_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1d_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1d_avg_cover" TO sensetrace_read_only;


--
-- TOC entry 2281 (class 0 OID 0)
-- Dependencies: 180
-- Name: Classification_1h_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1h_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1h_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1h_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1h_avg" TO sensetrace_read_only;


--
-- TOC entry 2282 (class 0 OID 0)
-- Dependencies: 181
-- Name: Classification_1h_avg_cover; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1h_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1h_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1h_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1h_avg_cover" TO sensetrace_read_only;


--
-- TOC entry 2283 (class 0 OID 0)
-- Dependencies: 182
-- Name: Classification_1m_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1m_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1m_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1m_avg" TO sensetrace_read_only;


--
-- TOC entry 2284 (class 0 OID 0)
-- Dependencies: 183
-- Name: Classification_1m_avg_cover; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1m_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1m_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1m_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1m_avg_cover" TO sensetrace_read_only;


--
-- TOC entry 2285 (class 0 OID 0)
-- Dependencies: 184
-- Name: Classification_1month_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1month_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1month_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1month_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1month_avg" TO sensetrace_read_only;


--
-- TOC entry 2286 (class 0 OID 0)
-- Dependencies: 185
-- Name: Classification_1month_avg_cover; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1month_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1month_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1month_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1month_avg_cover" TO sensetrace_read_only;


--
-- TOC entry 2287 (class 0 OID 0)
-- Dependencies: 186
-- Name: Classification_1y_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1y_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1y_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1y_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1y_avg" TO sensetrace_read_only;


--
-- TOC entry 2288 (class 0 OID 0)
-- Dependencies: 187
-- Name: Classification_1y_avg_cover; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Classification_1y_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1y_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1y_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1y_avg_cover" TO sensetrace_read_only;


--
-- TOC entry 2289 (class 0 OID 0)
-- Dependencies: 188
-- Name: Data_15m_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Data_15m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_15m_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_15m_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_15m_avg" TO sensetrace_read_only;


--
-- TOC entry 2290 (class 0 OID 0)
-- Dependencies: 189
-- Name: Data_1d_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Data_1d_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1d_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1d_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1d_avg" TO sensetrace_read_only;


--
-- TOC entry 2291 (class 0 OID 0)
-- Dependencies: 190
-- Name: Data_1h_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Data_1h_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1h_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1h_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1h_avg" TO sensetrace_read_only;


--
-- TOC entry 2292 (class 0 OID 0)
-- Dependencies: 191
-- Name: Data_1m_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Data_1m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1m_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1m_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1m_avg" TO sensetrace_read_only;


--
-- TOC entry 2293 (class 0 OID 0)
-- Dependencies: 192
-- Name: Data_1month_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Data_1month_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1month_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1month_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1month_avg" TO sensetrace_read_only;


--
-- TOC entry 2294 (class 0 OID 0)
-- Dependencies: 193
-- Name: Data_1y_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Data_1y_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1y_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1y_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1y_avg" TO sensetrace_read_only;


--
-- TOC entry 2295 (class 0 OID 0)
-- Dependencies: 194
-- Name: ErrorData; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "ErrorData" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData" TO sensetrace_read_only;


--
-- TOC entry 2296 (class 0 OID 0)
-- Dependencies: 195
-- Name: ErrorData_15m_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "ErrorData_15m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_15m_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_15m_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_15m_avg" TO sensetrace_read_only;


--
-- TOC entry 2297 (class 0 OID 0)
-- Dependencies: 196
-- Name: ErrorData_1d_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "ErrorData_1d_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1d_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1d_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1d_avg" TO sensetrace_read_only;


--
-- TOC entry 2298 (class 0 OID 0)
-- Dependencies: 197
-- Name: ErrorData_1h_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "ErrorData_1h_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1h_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1h_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1h_avg" TO sensetrace_read_only;


--
-- TOC entry 2299 (class 0 OID 0)
-- Dependencies: 198
-- Name: ErrorData_1m_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "ErrorData_1m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1m_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1m_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1m_avg" TO sensetrace_read_only;


--
-- TOC entry 2300 (class 0 OID 0)
-- Dependencies: 199
-- Name: ErrorData_1month_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "ErrorData_1month_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1month_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1month_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1month_avg" TO sensetrace_read_only;


--
-- TOC entry 2301 (class 0 OID 0)
-- Dependencies: 200
-- Name: ErrorData_1y_avg; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "ErrorData_1y_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1y_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1y_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1y_avg" TO sensetrace_read_only;


--
-- TOC entry 2302 (class 0 OID 0)
-- Dependencies: 201
-- Name: ErrorData_User; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "ErrorData_User" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_User" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_User" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_User" TO sensetrace_read_only;


--
-- TOC entry 2303 (class 0 OID 0)
-- Dependencies: 202
-- Name: LastImportDate; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "LastImportDate" FROM PUBLIC;
REVOKE ALL ON TABLE "LastImportDate" FROM sensetrace;
GRANT ALL ON TABLE "LastImportDate" TO sensetrace;
GRANT SELECT ON TABLE "LastImportDate" TO sensetrace_read_only;


--
-- TOC entry 2304 (class 0 OID 0)
-- Dependencies: 203
-- Name: Rawdata; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Rawdata" FROM PUBLIC;
REVOKE ALL ON TABLE "Rawdata" FROM sensetrace;
GRANT ALL ON TABLE "Rawdata" TO sensetrace;
GRANT SELECT ON TABLE "Rawdata" TO sensetrace_read_only;


--
-- TOC entry 2305 (class 0 OID 0)
-- Dependencies: 204
-- Name: Registry_LastEntries; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Registry_LastEntries" FROM PUBLIC;
REVOKE ALL ON TABLE "Registry_LastEntries" FROM sensetrace;
GRANT ALL ON TABLE "Registry_LastEntries" TO sensetrace;
GRANT SELECT ON TABLE "Registry_LastEntries" TO sensetrace_read_only;


--
-- TOC entry 2306 (class 0 OID 0)
-- Dependencies: 205
-- Name: Registry_Rules; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE "Registry_Rules" FROM PUBLIC;
REVOKE ALL ON TABLE "Registry_Rules" FROM sensetrace;
GRANT ALL ON TABLE "Registry_Rules" TO sensetrace;
GRANT SELECT ON TABLE "Registry_Rules" TO sensetrace_read_only;


--
-- TOC entry 2307 (class 0 OID 0)
-- Dependencies: 206
-- Name: errorfilter15min; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE errorfilter15min FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter15min FROM sensetrace;
GRANT ALL ON TABLE errorfilter15min TO sensetrace;
GRANT SELECT ON TABLE errorfilter15min TO sensetrace_read_only;


--
-- TOC entry 2308 (class 0 OID 0)
-- Dependencies: 207
-- Name: avg15min; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE avg15min FROM PUBLIC;
REVOKE ALL ON TABLE avg15min FROM sensetrace;
GRANT ALL ON TABLE avg15min TO sensetrace;
GRANT SELECT ON TABLE avg15min TO sensetrace_read_only;


--
-- TOC entry 2309 (class 0 OID 0)
-- Dependencies: 208
-- Name: errorfilter1d; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE errorfilter1d FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1d FROM sensetrace;
GRANT ALL ON TABLE errorfilter1d TO sensetrace;
GRANT SELECT ON TABLE errorfilter1d TO sensetrace_read_only;


--
-- TOC entry 2310 (class 0 OID 0)
-- Dependencies: 209
-- Name: avg1d; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE avg1d FROM PUBLIC;
REVOKE ALL ON TABLE avg1d FROM sensetrace;
GRANT ALL ON TABLE avg1d TO sensetrace;
GRANT SELECT ON TABLE avg1d TO sensetrace_read_only;


--
-- TOC entry 2311 (class 0 OID 0)
-- Dependencies: 210
-- Name: errorfilter1h; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE errorfilter1h FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1h FROM sensetrace;
GRANT ALL ON TABLE errorfilter1h TO sensetrace;
GRANT SELECT ON TABLE errorfilter1h TO sensetrace_read_only;


--
-- TOC entry 2312 (class 0 OID 0)
-- Dependencies: 211
-- Name: avg1h; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE avg1h FROM PUBLIC;
REVOKE ALL ON TABLE avg1h FROM sensetrace;
GRANT ALL ON TABLE avg1h TO sensetrace;
GRANT SELECT ON TABLE avg1h TO sensetrace_read_only;


--
-- TOC entry 2313 (class 0 OID 0)
-- Dependencies: 212
-- Name: errorfilter1min; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE errorfilter1min FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1min FROM sensetrace;
GRANT ALL ON TABLE errorfilter1min TO sensetrace;
GRANT SELECT ON TABLE errorfilter1min TO sensetrace_read_only;


--
-- TOC entry 2314 (class 0 OID 0)
-- Dependencies: 213
-- Name: avg1min; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE avg1min FROM PUBLIC;
REVOKE ALL ON TABLE avg1min FROM sensetrace;
GRANT ALL ON TABLE avg1min TO sensetrace;
GRANT SELECT ON TABLE avg1min TO sensetrace_read_only;


--
-- TOC entry 2315 (class 0 OID 0)
-- Dependencies: 214
-- Name: errorfilter1month; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE errorfilter1month FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1month FROM sensetrace;
GRANT ALL ON TABLE errorfilter1month TO sensetrace;
GRANT SELECT ON TABLE errorfilter1month TO sensetrace_read_only;


--
-- TOC entry 2316 (class 0 OID 0)
-- Dependencies: 215
-- Name: avg1month; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE avg1month FROM PUBLIC;
REVOKE ALL ON TABLE avg1month FROM sensetrace;
GRANT ALL ON TABLE avg1month TO sensetrace;
GRANT SELECT ON TABLE avg1month TO sensetrace_read_only;


--
-- TOC entry 2317 (class 0 OID 0)
-- Dependencies: 216
-- Name: errorfilter1y; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE errorfilter1y FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1y FROM sensetrace;
GRANT ALL ON TABLE errorfilter1y TO sensetrace;
GRANT SELECT ON TABLE errorfilter1y TO sensetrace_read_only;


--
-- TOC entry 2318 (class 0 OID 0)
-- Dependencies: 217
-- Name: avg1year; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE avg1year FROM PUBLIC;
REVOKE ALL ON TABLE avg1year FROM sensetrace;
GRANT ALL ON TABLE avg1year TO sensetrace;
GRANT SELECT ON TABLE avg1year TO sensetrace_read_only;


--
-- TOC entry 2319 (class 0 OID 0)
-- Dependencies: 218
-- Name: errorfilter; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE errorfilter FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter FROM sensetrace;
GRANT ALL ON TABLE errorfilter TO sensetrace;
GRANT SELECT ON TABLE errorfilter TO sensetrace_read_only;


--
-- TOC entry 2320 (class 0 OID 0)
-- Dependencies: 219
-- Name: meas_in_cl; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE meas_in_cl FROM PUBLIC;
REVOKE ALL ON TABLE meas_in_cl FROM sensetrace;
GRANT ALL ON TABLE meas_in_cl TO sensetrace;
GRANT SELECT ON TABLE meas_in_cl TO sensetrace_read_only;


--
-- TOC entry 2321 (class 0 OID 0)
-- Dependencies: 220
-- Name: meas_not_in_cl; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE meas_not_in_cl FROM PUBLIC;
REVOKE ALL ON TABLE meas_not_in_cl FROM sensetrace;
GRANT ALL ON TABLE meas_not_in_cl TO sensetrace;
GRANT SELECT ON TABLE meas_not_in_cl TO sensetrace_read_only;


--
-- TOC entry 2322 (class 0 OID 0)
-- Dependencies: 221
-- Name: measurement; Type: ACL; Schema: public; Owner: sensetrace
--

REVOKE ALL ON TABLE measurement FROM PUBLIC;
REVOKE ALL ON TABLE measurement FROM sensetrace;
GRANT ALL ON TABLE measurement TO sensetrace;
GRANT SELECT ON TABLE measurement TO sensetrace_read_only;

--
-- PostgreSQL database dump complete
--

