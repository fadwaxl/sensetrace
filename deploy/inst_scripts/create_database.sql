--This script creates the database schema for Sensetrace


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
-- Name: avg15mpartitions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA avg15mpartitions;


--
-- Name: SCHEMA avg15mpartitions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA avg15mpartitions IS '15m avg schema';


--
-- Name: avg1hpartitions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA avg1hpartitions;


--
-- Name: SCHEMA avg1hpartitions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA avg1hpartitions IS '1h avg schema';


--
-- Name: avg1mpartitions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA avg1mpartitions;


--
-- Name: SCHEMA avg1mpartitions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA avg1mpartitions IS '1m avg schema';


--
-- Name: oneminuteclcoverpartitions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA oneminuteclcoverpartitions;


--
-- Name: SCHEMA oneminuteclcoverpartitions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA oneminuteclcoverpartitions IS 'here are the 1-s-classificationdata';


--
-- Name: oneminutesclpartitions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA oneminutesclpartitions;


--
-- Name: SCHEMA oneminutesclpartitions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA oneminutesclpartitions IS 'here are the 1-s-classificationdata';


--
-- Name: onesecondclpartitions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA onesecondclpartitions;


--
-- Name: SCHEMA onesecondclpartitions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA onesecondclpartitions IS 'here are the 1-s-classificationdata';


--
-- Name: onesecondserrorpartitions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA onesecondserrorpartitions;


--
-- Name: SCHEMA onesecondserrorpartitions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA onesecondserrorpartitions IS 'standard public schema';


--
-- Name: queries; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA queries;



--
-- Name: rawdatapartitions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA rawdatapartitions;


--
-- Name: SCHEMA rawdatapartitions; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA rawdatapartitions IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = avg15mpartitions, pg_catalog;

--
-- Name: partition_avgs_15m_function(); Type: FUNCTION; Schema: avg15mpartitions; Owner: -
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
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
  IF NOT FOUND THEN
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

  -- Indexes are defined per child, so we assign a default index that uses the partition columns
  --EXECUTE 'CREATE Primary Key ' || quote_ident(_tablename||'_indx1') || ' ON avg15mpartitions.' || quote_ident(_tablename) || ' (timestamp, sensorid)';
END IF;

 
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO avg15mpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
RETURN NULL;
END;
$_$;


SET search_path = avg1hpartitions, pg_catalog;

--
-- Name: partition_avgs_1h_function(); Type: FUNCTION; Schema: avg1hpartitions; Owner: -
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
 
  -- Check if the partition needed for the current record exists
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'avg1hpartitions';
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
  IF NOT FOUND THEN
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

  -- Indexes are defined per child, so we assign a default index that uses the partition columns
  --EXECUTE 'CREATE Primary Key ' || quote_ident(_tablename||'_indx1') || ' ON avg1hpartitions.' || quote_ident(_tablename) || ' (timestamp, sensorid)';
END IF;

 
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO avg1hpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
RETURN NULL;
END;
$_$;


SET search_path = avg1mpartitions, pg_catalog;

--
-- Name: partition_avgs_1m_function(); Type: FUNCTION; Schema: avg1mpartitions; Owner: -
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
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'avg1mpartitions';
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
  IF NOT FOUND THEN
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

  -- Indexes are defined per child, so we assign a default index that uses the partition columns
  --EXECUTE 'CREATE Primary Key ' || quote_ident(_tablename||'_indx1') || ' ON avg1mpartitions.' || quote_ident(_tablename) || ' (timestamp, sensorid)';
END IF;

 
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO avg1mpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
RETURN NULL;
END;
$_$;


SET search_path = oneminuteclcoverpartitions, pg_catalog;

--
-- Name: server_partition_function(); Type: FUNCTION; Schema: oneminuteclcoverpartitions; Owner: -
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
  _clid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _clid:=NEW."clid";

  _tablename := 'Classification'||_year||'_'||_clid;

 --IF _year::integer<=2013 THEN
--EXECUTE 'INSERT INTO "Rawdataold"' || ' VALUES ($1.*)' USING NEW;
 --ELSE
 
  -- Check if the partition needed for the current record exists
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'oneminuteclcoverpartitions';
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
  IF NOT FOUND THEN
    EXECUTE 'CREATE TABLE oneminuteclcoverpartitions.' || quote_ident(_tablename) || 
    ' ( check(
       "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "clid"= '|| quote_literal(_clid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", clid)
       ) INHERITS (public."Classification_1m_avg_cover")';
 


  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.
  EXECUTE 'ALTER TABLE oneminuteclcoverpartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE oneminuteclcoverpartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';

  -- Indexes are defined per child, so we assign a default index that uses the partition columns
--  EXECUTE 'CREATE INDEX ' || quote_ident(_tablename||'_indx1') || ' ON sensorpartitions.' || quote_ident(_tablename) || ' (timestamp, sensorid)';
END IF;
 
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO oneminuteclcoverpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
--END IF;
RETURN NULL;

END;

$_$;


SET search_path = oneminutesclpartitions, pg_catalog;

--
-- Name: server_partition_function(); Type: FUNCTION; Schema: oneminutesclpartitions; Owner: -
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
  _clid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _clid:=NEW."clid";

  _tablename := 'Classification'||_year||'_'||_clid;

 --IF _year::integer<=2013 THEN
--EXECUTE 'INSERT INTO "Rawdataold"' || ' VALUES ($1.*)' USING NEW;
 --ELSE
 
  -- Check if the partition needed for the current record exists
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'oneminutesclpartitions';
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
  IF NOT FOUND THEN
    EXECUTE 'CREATE TABLE oneminutesclpartitions.' || quote_ident(_tablename) || 
    ' ( check(
       "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "clid"= '|| quote_literal(_clid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", clid)
       ) INHERITS (public."Classification_1m_avg")';
 


  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.
  EXECUTE 'ALTER TABLE oneminutesclpartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE oneminutesclpartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';

  -- Indexes are defined per child, so we assign a default index that uses the partition columns
--  EXECUTE 'CREATE INDEX ' || quote_ident(_tablename||'_indx1') || ' ON sensorpartitions.' || quote_ident(_tablename) || ' (timestamp, sensorid)';
END IF;
 
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO oneminutesclpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
--END IF;
RETURN NULL;

END;

$_$;


SET search_path = onesecondclpartitions, pg_catalog;

--
-- Name: server_partition_function(); Type: FUNCTION; Schema: onesecondclpartitions; Owner: -
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
  _clid smallint;
 -- _enddate text;
  _result record;
BEGIN
  --Takes the current inbound "time" value and determines when midnight is for the given date
  --_new_time := ((NEW."time"/86400)::int)*86400;
  --_date :=  NEW."timestamp";
  _year_date := date_trunc('year', NEW."timestamp");
  _year := to_char( _year_date,'YYYY');
  _clid:=NEW."clid";

  _tablename := 'Classification'||_year||'_'||_clid;

 --IF _year::integer<=2013 THEN
--EXECUTE 'INSERT INTO "Rawdataold"' || ' VALUES ($1.*)' USING NEW;
 --ELSE
 
  -- Check if the partition needed for the current record exists
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'onesecondclpartitions';
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
  IF NOT FOUND THEN
    EXECUTE 'CREATE TABLE onesecondclpartitions.' || quote_ident(_tablename) || 
    ' ( check(
       "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "clid"= '|| quote_literal(_clid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", clid)
       ) INHERITS (public."Classification")';
 


  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.
  EXECUTE 'ALTER TABLE onesecondclpartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE onesecondclpartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';

  -- Indexes are defined per child, so we assign a default index that uses the partition columns
--  EXECUTE 'CREATE INDEX ' || quote_ident(_tablename||'_indx1') || ' ON sensorpartitions.' || quote_ident(_tablename) || ' (timestamp, sensorid)';
END IF;
 
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO onesecondclpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
--END IF;
RETURN NULL;

END;

$_$;


SET search_path = onesecondserrorpartitions, pg_catalog;

--
-- Name: server_partition_function(); Type: FUNCTION; Schema: onesecondserrorpartitions; Owner: -
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

  _tablename := 'Error_'||_year||'_'||_sensorid;

 --IF _year::integer<=2013 THEN
--EXECUTE 'INSERT INTO "Rawdataold"' || ' VALUES ($1.*)' USING NEW;
 --ELSE
 
  -- Check if the partition needed for the current record exists
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'onesecondserrorpartitions';
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
  IF NOT FOUND THEN
    EXECUTE 'CREATE TABLE onesecondserrorpartitions.' || quote_ident(_tablename) || 
    ' ( check(
       "timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "sensorid"= '|| quote_literal(_sensorid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", sensorid)
       ) INHERITS (public."ErrorData_1s")';
 


  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.
  EXECUTE 'ALTER TABLE onesecondserrorpartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE onesecondserrorpartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';

  -- Indexes are defined per child, so we assign a default index that uses the partition columns
--  EXECUTE 'CREATE INDEX ' || quote_ident(_tablename||'_indx1') || ' ON sensorpartitions.' || quote_ident(_tablename) || ' (timestamp, sensorid)';
END IF;
 
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO onesecondserrorpartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
--END IF;
RETURN NULL;

END;

$_$;


SET search_path = public, pg_catalog;

--
-- Name: getdays(timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION getdays(timestamp with time zone) RETURNS double precision
    LANGUAGE sql
    AS $_$
SELECT DATE_PART('days', 
        DATE_TRUNC('month',  $1) 
        + '1 MONTH'::INTERVAL 
        - DATE_TRUNC('month',  $1));
$_$;


--
-- Name: ts_round(timestamp with time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ts_round(timestamp with time zone, integer) RETURNS timestamp with time zone
    LANGUAGE sql
    AS $_$
    SELECT 'epoch'::timestamptz + '1 second'::INTERVAL * ( $2 * ( extract( epoch FROM $1 )::INT4 / $2 ) );
$_$;


--
-- Name: ts_round_month(timestamp with time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ts_round_month(timestamp with time zone, integer) RETURNS timestamp with time zone
    LANGUAGE sql
    AS $_$
    SELECT 'epoch'::timestamptz + '1 second'::INTERVAL * ( $2 * ( extract( epoch FROM $1 )::INT4 / $2 ) );
$_$;




SET search_path = rawdatapartitions, pg_catalog;

--
-- Name: server_partition_function(); Type: FUNCTION; Schema: rawdatapartitions; Owner: -
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
   
  PERFORM 1
  FROM   pg_catalog.pg_class c
  JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE  c.relkind = 'r'
  AND    c.relname = _tablename
  AND    n.nspname = 'rawdatapartitions';
 
  -- If the partition needed does not yet exist, then we create it:
  -- Note that || is string concatenation (joining two strings to make one)
  IF NOT FOUND THEN
    EXECUTE 'CREATE TABLE rawdatapartitions.' || quote_ident(_tablename) || 
    ' (
      CHECK ("timestamp" >= ' || quote_literal(_year_date) ||
        'AND "timestamp" < ' || quote_literal(_year_date::timestamp + interval '1 year') ||     
        'AND "sensorid"= '|| quote_literal(_sensorid) ||        
       ' ),
	CONSTRAINT "Pk' || _tablename || '" PRIMARY KEY ("timestamp", sensorid)
       ) INHERITS (public."Rawdata")';
 
  -- Table permissions are not inherited from the parent.
  -- If permissions change on the master be sure to change them on the child also.
  EXECUTE 'ALTER TABLE rawdatapartitions.' || quote_ident(_tablename) || '  owner TO sensetrace';
  EXECUTE 'GRANT SELECT ON TABLE rawdatapartitions.' || quote_ident(_tablename) || '  TO sensetrace_read_only';

  -- Indexes are defined per child, so we assign a default index that uses the partition columns
--  EXECUTE 'CREATE INDEX ' || quote_ident(_tablename||'_indx1') || ' ON sensorpartitions.' || quote_ident(_tablename) || ' (timestamp, sensorid)';
END IF;

--End of comment out
 
-- Insert the current record into the correct partition, which we are sure will now exist.
EXECUTE 'INSERT INTO rawdatapartitions.' || quote_ident(_tablename) || ' VALUES ($1.*)' USING NEW;
--END IF;
RETURN NULL;

END;

$_$;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Data_15m_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Data_15m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);



SET search_path = public, pg_catalog;

--
-- Name: Data_1h_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Data_1h_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


SET search_path = public, pg_catalog;

--
-- Name: Data_1m_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Data_1m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);




SET search_path = public, pg_catalog;

--
-- Name: Classification; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1m_avg_cover; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);

--
-- Name: Classification_1m_avg_cover; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1m_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);



SET search_path = public, pg_catalog;

--
-- Name: Classification_15m_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_15m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_15m_avg_cover; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_15m_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1d_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1d_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1d_avg_cover; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1d_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1h_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1h_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1h_avg_cover; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1h_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1month_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1month_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1month_avg_cover; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1month_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1y_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1y_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);


--
-- Name: Classification_1y_avg_cover; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Classification_1y_avg_cover" (
    "timestamp" timestamp without time zone NOT NULL,
    clid smallint NOT NULL
);




--
-- Name: Data_1d_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Data_1d_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);




--
-- Name: Data_1month_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Data_1month_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


--
-- Name: Data_1y_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Data_1y_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


--
-- Name: ErrorData; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ErrorData" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value real
);


--
-- Name: ErrorData_15m_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ErrorData_15m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


--
-- Name: ErrorData_1d_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ErrorData_1d_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


--
-- Name: ErrorData_1h_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ErrorData_1h_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


--
-- Name: ErrorData_1m_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ErrorData_1m_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


--
-- Name: ErrorData_1month_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ErrorData_1month_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


--
-- Name: ErrorData_1y_avg; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ErrorData_1y_avg" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value double precision
);


--
-- Name: ErrorData_User; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "ErrorData_User" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value real
);


--
-- Name: LastImportDate; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "LastImportDate" (
    "timestamp" timestamp without time zone NOT NULL
);


--
-- Name: Rawdata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Rawdata" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value real
);



--
-- Name: Registry_LastEntries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Registry_LastEntries" (
    "timestamp" timestamp without time zone NOT NULL,
    sensorid smallint NOT NULL,
    value real
);


--
-- Name: Registry_Rules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Registry_Rules" (
    rule text,
    clid smallint NOT NULL
);


--
-- Name: errorfilter15min; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW errorfilter15min AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
        CASE
            WHEN ((e1.value IS NOT NULL) AND (e1.value > ((-999))::double precision)) THEN e1.value
            WHEN (e1.value = ((-999))::double precision) THEN NULL::double precision
            ELSE r1.value
        END AS value_cor
   FROM ("Data_15m_avg" r1
   LEFT JOIN ( SELECT "ErrorData_15m_avg".sensorid,
            "ErrorData_15m_avg"."timestamp",
            COALESCE("ErrorData_15m_avg".value, ((-999))::double precision) AS value
           FROM "ErrorData_15m_avg") e1 ON (((e1.sensorid = r1.sensorid) AND (e1."timestamp" = r1."timestamp"))));


--
-- Name: avg15min; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: errorfilter1d; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW errorfilter1d AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
        CASE
            WHEN ((e1.value IS NOT NULL) AND (e1.value > ((-999))::double precision)) THEN e1.value
            WHEN (e1.value = ((-999))::double precision) THEN NULL::double precision
            ELSE r1.value
        END AS value_cor
   FROM ("Data_1d_avg" r1
   LEFT JOIN ( SELECT "ErrorData_1d_avg".sensorid,
            "ErrorData_1d_avg"."timestamp",
            COALESCE("ErrorData_1d_avg".value, ((-999))::double precision) AS value
           FROM "ErrorData_1d_avg") e1 ON (((e1.sensorid = r1.sensorid) AND (e1."timestamp" = r1."timestamp"))));


--
-- Name: avg1d; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: errorfilter1h; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW errorfilter1h AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
        CASE
            WHEN ((e1.value IS NOT NULL) AND (e1.value > ((-999))::double precision)) THEN e1.value
            WHEN (e1.value = ((-999))::double precision) THEN NULL::double precision
            ELSE r1.value
        END AS value_cor
   FROM ("Data_1h_avg" r1
   LEFT JOIN ( SELECT "ErrorData_1h_avg".sensorid,
            "ErrorData_1h_avg"."timestamp",
            COALESCE("ErrorData_1h_avg".value, ((-999))::double precision) AS value
           FROM "ErrorData_1h_avg") e1 ON (((e1.sensorid = r1.sensorid) AND (e1."timestamp" = r1."timestamp"))));


--
-- Name: avg1h; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: errorfilter1min; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW errorfilter1min AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
        CASE
            WHEN ((e1.value IS NOT NULL) AND (e1.value > ((-999))::double precision)) THEN e1.value
            WHEN (e1.value = ((-999))::double precision) THEN NULL::double precision
            ELSE r1.value
        END AS value_cor
   FROM ("Data_1m_avg" r1
   LEFT JOIN ( SELECT "ErrorData_1m_avg".sensorid,
            "ErrorData_1m_avg"."timestamp",
            COALESCE("ErrorData_1m_avg".value, ((-999))::double precision) AS value
           FROM "ErrorData_1m_avg") e1 ON (((e1.sensorid = r1.sensorid) AND (e1."timestamp" = r1."timestamp"))));


--
-- Name: avg1min; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: errorfilter1month; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW errorfilter1month AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
        CASE
            WHEN ((e1.value IS NOT NULL) AND (e1.value > ((-999))::double precision)) THEN e1.value
            WHEN (e1.value = ((-999))::double precision) THEN NULL::double precision
            ELSE r1.value
        END AS value_cor
   FROM ("Data_1month_avg" r1
   LEFT JOIN ( SELECT "ErrorData_1month_avg".sensorid,
            "ErrorData_1month_avg"."timestamp",
            COALESCE("ErrorData_1month_avg".value, ((-999))::double precision) AS value
           FROM "ErrorData_1month_avg") e1 ON (((e1.sensorid = r1.sensorid) AND (e1."timestamp" = r1."timestamp"))));


--
-- Name: avg1month; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: errorfilter1y; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW errorfilter1y AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
        CASE
            WHEN ((e1.value IS NOT NULL) AND (e1.value > ((-999))::double precision)) THEN e1.value
            WHEN (e1.value = ((-999))::double precision) THEN NULL::double precision
            ELSE r1.value
        END AS value_cor
   FROM ("Data_1y_avg" r1
   LEFT JOIN ( SELECT "ErrorData_1y_avg".sensorid,
            "ErrorData_1y_avg"."timestamp",
            COALESCE("ErrorData_1y_avg".value, ((-999))::double precision) AS value
           FROM "ErrorData_1y_avg") e1 ON (((e1.sensorid = r1.sensorid) AND (e1."timestamp" = r1."timestamp"))));


--
-- Name: avg1year; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: errorfilter; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW errorfilter AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
        CASE
            WHEN ((e1.value IS NOT NULL) AND (e1.value > ((-999))::double precision)) THEN e1.value
            WHEN (e1.value = ((-999))::double precision) THEN NULL::real
            ELSE r1.value
        END AS value_cor
   FROM ("Rawdata" r1
   LEFT JOIN ( SELECT "ErrorData".sensorid,
            "ErrorData"."timestamp",
            COALESCE("ErrorData".value, ((-999))::real) AS value
           FROM "ErrorData") e1 ON (((e1.sensorid = r1.sensorid) AND (e1."timestamp" = r1."timestamp"))));


--
-- Name: meas_in_cl; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW meas_in_cl AS
 SELECT r1.sensorid,
    r1."timestamp",
    r1.value,
    r2.clid
   FROM "Rawdata" r1,
    "Classification" r2
  WHERE (r1."timestamp" = r2."timestamp");


--
-- Name: meas_not_in_cl; Type: VIEW; Schema: public; Owner: -
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


--
-- Name: measurement; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW measurement AS
 SELECT DISTINCT r1.sensorid,
    r1."timestamp",
    r1.value,
    r1.value_cor,
    COALESCE(c1.clid, (0)::smallint) AS clid
   FROM (errorfilter r1
   LEFT JOIN "Classification" c1 ON ((r1."timestamp" = c1."timestamp")));


--
-- Name: PkClassification_15m_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_15m_avg"
    ADD CONSTRAINT "PkClassification_15m_avg" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_15m_avg_cover; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_15m_avg_cover"
    ADD CONSTRAINT "PkClassification_15m_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1d_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1d_avg"
    ADD CONSTRAINT "PkClassification_1d_avg" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1d_avg_cover; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1d_avg_cover"
    ADD CONSTRAINT "PkClassification_1d_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1h_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1h_avg"
    ADD CONSTRAINT "PkClassification_1h_avg" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1h_avg_cover; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1h_avg_cover"
    ADD CONSTRAINT "PkClassification_1h_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1m_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1m_avg"
    ADD CONSTRAINT "PkClassification_1m_avg" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1m_avg_cover; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1m_avg_cover"
    ADD CONSTRAINT "PkClassification_1m_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1month_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1month_avg"
    ADD CONSTRAINT "PkClassification_1month_avg" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1month_avg_cover; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1month_avg_cover"
    ADD CONSTRAINT "PkClassification_1month_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1s; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification"
    ADD CONSTRAINT "PkClassification_1s" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1y_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1y_avg"
    ADD CONSTRAINT "PkClassification_1y_avg" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkClassification_1y_avg_cover; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Classification_1y_avg_cover"
    ADD CONSTRAINT "PkClassification_1y_avg_cover" PRIMARY KEY ("timestamp", clid);


--
-- Name: PkRawdata; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Rawdata"
    ADD CONSTRAINT "PkRawdata" PRIMARY KEY ("timestamp", sensorid) WITH (fillfactor=30);


--
-- Name: PrimaryKeyData_15m_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Data_15m_avg"
    ADD CONSTRAINT "PrimaryKeyData_15m_avg" PRIMARY KEY (sensorid, "timestamp");



--
-- Name: PrimaryKeyData_1d_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Data_1d_avg"
    ADD CONSTRAINT "PrimaryKeyData_1d_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- Name: PrimaryKeyData_1h_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Data_1h_avg"
    ADD CONSTRAINT "PrimaryKeyData_1h_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- Name: PrimaryKeyData_1m_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Data_1m_avg"
    ADD CONSTRAINT "PrimaryKeyData_1m_avg" PRIMARY KEY (sensorid, "timestamp");



--
-- Name: PrimaryKeyData_1month_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Data_1month_avg"
    ADD CONSTRAINT "PrimaryKeyData_1month_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- Name: PrimaryKeyData_1y_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Data_1y_avg"
    ADD CONSTRAINT "PrimaryKeyData_1y_avg" PRIMARY KEY (sensorid, "timestamp");


--
-- Name: PrimaryKeyEErrorData_User; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_User"
    ADD CONSTRAINT "PrimaryKeyEErrorData_User" PRIMARY KEY ("timestamp", sensorid);


--
-- Name: PrimaryKeyErrorData_15m_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_15m_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_15m_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- Name: PrimaryKeyErrorData_1d_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1d_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1d_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- Name: PrimaryKeyErrorData_1h_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1h_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1h_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- Name: PrimaryKeyErrorData_1m_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1m_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1m_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- Name: PrimaryKeyErrorData_1month_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1month_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1month_avg" PRIMARY KEY ("timestamp", sensorid);


--
-- Name: PrimaryKeyErrorData_1s; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ErrorData"
    ADD CONSTRAINT "PrimaryKeyErrorData_1s" PRIMARY KEY ("timestamp", sensorid);


--
-- Name: PrimaryKeyErrorData_1y_avg; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "ErrorData_1y_avg"
    ADD CONSTRAINT "PrimaryKeyErrorData_1y_avg" PRIMARY KEY ("timestamp", sensorid);




SET search_path = public, pg_catalog;

--
-- Name: data_15m_avg_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER data_15m_avg_trigger BEFORE INSERT ON "Data_15m_avg" FOR EACH ROW EXECUTE PROCEDURE avg15mpartitions.partition_avgs_15m_function();


--
-- Name: data_1h_avg_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER data_1h_avg_trigger BEFORE INSERT ON "Data_1h_avg" FOR EACH ROW EXECUTE PROCEDURE avg1hpartitions.partition_avgs_1h_function();


--
-- Name: data_1m_avg_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER data_1m_avg_trigger BEFORE INSERT ON "Data_1m_avg" FOR EACH ROW EXECUTE PROCEDURE avg1mpartitions.partition_avgs_1m_function();


--
-- Name: oneminutecl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oneminutecl_trigger BEFORE INSERT ON "Classification_1m_avg" FOR EACH ROW EXECUTE PROCEDURE oneminutesclpartitions.server_partition_function();


--
-- Name: oneminuteclcover_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oneminuteclcover_trigger BEFORE INSERT ON "Classification_1m_avg_cover" FOR EACH ROW EXECUTE PROCEDURE oneminuteclcoverpartitions.server_partition_function();


--
-- Name: onesecondcl_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER onesecondcl_trigger BEFORE INSERT ON "Classification" FOR EACH ROW EXECUTE PROCEDURE onesecondclpartitions.server_partition_function();


--
-- Name: oneseconderrordata_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER oneseconderrordata_trigger BEFORE INSERT ON "ErrorData" FOR EACH ROW EXECUTE PROCEDURE onesecondserrorpartitions.server_partition_function();


--
-- Name: rawdata_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rawdata_trigger BEFORE INSERT ON "Rawdata" FOR EACH ROW EXECUTE PROCEDURE rawdatapartitions.server_partition_function();



--
-- Name: avg15mpartitions; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA avg15mpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA avg15mpartitions FROM sensetrace;
GRANT ALL ON SCHEMA avg15mpartitions TO sensetrace;
GRANT ALL ON SCHEMA avg15mpartitions TO PUBLIC;


--
-- Name: avg1hpartitions; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA avg1hpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA avg1hpartitions FROM sensetrace;
GRANT ALL ON SCHEMA avg1hpartitions TO sensetrace;
GRANT ALL ON SCHEMA avg1hpartitions TO PUBLIC;


--
-- Name: avg1mpartitions; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA avg1mpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA avg1mpartitions FROM sensetrace;
GRANT ALL ON SCHEMA avg1mpartitions TO sensetrace;
GRANT ALL ON SCHEMA avg1mpartitions TO PUBLIC;


--
-- Name: oneminuteclcoverpartitions; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA oneminuteclcoverpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA oneminuteclcoverpartitions FROM sensetrace;
GRANT ALL ON SCHEMA oneminuteclcoverpartitions TO sensetrace;
GRANT ALL ON SCHEMA oneminuteclcoverpartitions TO PUBLIC;


--
-- Name: oneminutesclpartitions; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA oneminutesclpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA oneminutesclpartitions FROM sensetrace;
GRANT ALL ON SCHEMA oneminutesclpartitions TO sensetrace;
GRANT ALL ON SCHEMA oneminutesclpartitions TO PUBLIC;


--
-- Name: onesecondclpartitions; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA onesecondclpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA onesecondclpartitions FROM sensetrace;
GRANT ALL ON SCHEMA onesecondclpartitions TO sensetrace;
GRANT ALL ON SCHEMA onesecondclpartitions TO PUBLIC;


--
-- Name: onesecondserrorpartitions; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA onesecondserrorpartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA onesecondserrorpartitions FROM sensetrace;
GRANT ALL ON SCHEMA onesecondserrorpartitions TO sensetrace;
GRANT ALL ON SCHEMA onesecondserrorpartitions TO PUBLIC;


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM sensetrace;
GRANT ALL ON SCHEMA public TO sensetrace;
GRANT ALL ON SCHEMA public TO PUBLIC;



--
-- Name: rawdatapartitions; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA rawdatapartitions FROM PUBLIC;
REVOKE ALL ON SCHEMA rawdatapartitions FROM sensetrace;
GRANT ALL ON SCHEMA rawdatapartitions TO sensetrace;
GRANT ALL ON SCHEMA rawdatapartitions TO PUBLIC;


--
-- Name: getdays(timestamp with time zone); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION getdays(timestamp with time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION getdays(timestamp with time zone) FROM sensetrace;
GRANT ALL ON FUNCTION getdays(timestamp with time zone) TO sensetrace;
GRANT ALL ON FUNCTION getdays(timestamp with time zone) TO PUBLIC;


--
-- Name: ts_round(timestamp with time zone, integer); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION ts_round(timestamp with time zone, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION ts_round(timestamp with time zone, integer) FROM sensetrace;
GRANT ALL ON FUNCTION ts_round(timestamp with time zone, integer) TO sensetrace;
GRANT ALL ON FUNCTION ts_round(timestamp with time zone, integer) TO PUBLIC;


--
-- Name: ts_round_month(timestamp with time zone, integer); Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON FUNCTION ts_round_month(timestamp with time zone, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION ts_round_month(timestamp with time zone, integer) FROM sensetrace;
GRANT ALL ON FUNCTION ts_round_month(timestamp with time zone, integer) TO sensetrace;
GRANT ALL ON FUNCTION ts_round_month(timestamp with time zone, integer) TO PUBLIC;


--
-- Name: Data_15m_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Data_15m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_15m_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_15m_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_15m_avg" TO sensetrace_read_only;



SET search_path = public, pg_catalog;

--
-- Name: Data_1h_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Data_1h_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1h_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1h_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1h_avg" TO sensetrace_read_only;





SET search_path = public, pg_catalog;

--
-- Name: Data_1m_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Data_1m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1m_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1m_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1m_avg" TO sensetrace_read_only;





SET search_path = public, pg_catalog;

--
-- Name: Classification_1m_avg_cover; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1m_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1m_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1m_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1m_avg_cover" TO sensetrace_read_only;





SET search_path = public, pg_catalog;

--
-- Name: Classification_1m_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1m_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1m_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1m_avg" TO sensetrace_read_only;


SET search_path = public, pg_catalog;

--
-- Name: Classification; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification" FROM sensetrace;
GRANT ALL ON TABLE "Classification" TO sensetrace;
GRANT SELECT ON TABLE "Classification" TO sensetrace_read_only;



SET search_path = public, pg_catalog;

--
-- Name: Classification_15m_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_15m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_15m_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_15m_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_15m_avg" TO sensetrace_read_only;


--
-- Name: Classification_15m_avg_cover; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_15m_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_15m_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_15m_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_15m_avg_cover" TO sensetrace_read_only;


--
-- Name: Classification_1d_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1d_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1d_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1d_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1d_avg" TO sensetrace_read_only;


--
-- Name: Classification_1d_avg_cover; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1d_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1d_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1d_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1d_avg_cover" TO sensetrace_read_only;


--
-- Name: Classification_1h_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1h_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1h_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1h_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1h_avg" TO sensetrace_read_only;


--
-- Name: Classification_1h_avg_cover; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1h_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1h_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1h_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1h_avg_cover" TO sensetrace_read_only;


--
-- Name: Classification_1month_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1month_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1month_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1month_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1month_avg" TO sensetrace_read_only;


--
-- Name: Classification_1month_avg_cover; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1month_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1month_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1month_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1month_avg_cover" TO sensetrace_read_only;


--
-- Name: Classification_1y_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1y_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1y_avg" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1y_avg" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1y_avg" TO sensetrace_read_only;


--
-- Name: Classification_1y_avg_cover; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Classification_1y_avg_cover" FROM PUBLIC;
REVOKE ALL ON TABLE "Classification_1y_avg_cover" FROM sensetrace;
GRANT ALL ON TABLE "Classification_1y_avg_cover" TO sensetrace;
GRANT SELECT ON TABLE "Classification_1y_avg_cover" TO sensetrace_read_only;


--
-- Name: Data_1d_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Data_1d_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1d_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1d_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1d_avg" TO sensetrace_read_only;


--
-- Name: Data_1month_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Data_1month_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1month_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1month_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1month_avg" TO sensetrace_read_only;


--
-- Name: Data_1y_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Data_1y_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "Data_1y_avg" FROM sensetrace;
GRANT ALL ON TABLE "Data_1y_avg" TO sensetrace;
GRANT SELECT ON TABLE "Data_1y_avg" TO sensetrace_read_only;


--
-- Name: ErrorData; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "ErrorData" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData" TO sensetrace_read_only;


--
-- Name: ErrorData_15m_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "ErrorData_15m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_15m_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_15m_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_15m_avg" TO sensetrace_read_only;


--
-- Name: ErrorData_1d_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "ErrorData_1d_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1d_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1d_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1d_avg" TO sensetrace_read_only;


--
-- Name: ErrorData_1h_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "ErrorData_1h_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1h_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1h_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1h_avg" TO sensetrace_read_only;


--
-- Name: ErrorData_1m_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "ErrorData_1m_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1m_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1m_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1m_avg" TO sensetrace_read_only;


--
-- Name: ErrorData_1month_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "ErrorData_1month_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1month_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1month_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1month_avg" TO sensetrace_read_only;


--
-- Name: ErrorData_1y_avg; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "ErrorData_1y_avg" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_1y_avg" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_1y_avg" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_1y_avg" TO sensetrace_read_only;


--
-- Name: ErrorData_User; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "ErrorData_User" FROM PUBLIC;
REVOKE ALL ON TABLE "ErrorData_User" FROM sensetrace;
GRANT ALL ON TABLE "ErrorData_User" TO sensetrace;
GRANT SELECT ON TABLE "ErrorData_User" TO sensetrace_read_only;



--
-- Name: LastImportDate; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "LastImportDate" FROM PUBLIC;
REVOKE ALL ON TABLE "LastImportDate" FROM sensetrace;
GRANT ALL ON TABLE "LastImportDate" TO sensetrace;
GRANT SELECT ON TABLE "LastImportDate" TO sensetrace_read_only;


--
-- Name: Rawdata; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Rawdata" FROM PUBLIC;
REVOKE ALL ON TABLE "Rawdata" FROM sensetrace;
GRANT ALL ON TABLE "Rawdata" TO sensetrace;
GRANT SELECT ON TABLE "Rawdata" TO sensetrace_read_only;


--
-- Name: Registry_LastEntries; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Registry_LastEntries" FROM PUBLIC;
REVOKE ALL ON TABLE "Registry_LastEntries" FROM sensetrace;
GRANT ALL ON TABLE "Registry_LastEntries" TO sensetrace;
GRANT SELECT ON TABLE "Registry_LastEntries" TO sensetrace_read_only;


--
-- Name: Registry_Rules; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE "Registry_Rules" FROM PUBLIC;
REVOKE ALL ON TABLE "Registry_Rules" FROM sensetrace;
GRANT ALL ON TABLE "Registry_Rules" TO sensetrace;
GRANT SELECT ON TABLE "Registry_Rules" TO sensetrace_read_only;


--
-- Name: errorfilter15min; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE errorfilter15min FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter15min FROM sensetrace;
GRANT ALL ON TABLE errorfilter15min TO sensetrace;
GRANT SELECT ON TABLE errorfilter15min TO sensetrace_read_only;


--
-- Name: avg15min; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE avg15min FROM PUBLIC;
REVOKE ALL ON TABLE avg15min FROM sensetrace;
GRANT ALL ON TABLE avg15min TO sensetrace;
GRANT SELECT ON TABLE avg15min TO sensetrace_read_only;


--
-- Name: errorfilter1d; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE errorfilter1d FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1d FROM sensetrace;
GRANT ALL ON TABLE errorfilter1d TO sensetrace;
GRANT SELECT ON TABLE errorfilter1d TO sensetrace_read_only;


--
-- Name: avg1d; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE avg1d FROM PUBLIC;
REVOKE ALL ON TABLE avg1d FROM sensetrace;
GRANT ALL ON TABLE avg1d TO sensetrace;
GRANT SELECT ON TABLE avg1d TO sensetrace_read_only;


--
-- Name: errorfilter1h; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE errorfilter1h FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1h FROM sensetrace;
GRANT ALL ON TABLE errorfilter1h TO sensetrace;
GRANT SELECT ON TABLE errorfilter1h TO sensetrace_read_only;


--
-- Name: avg1h; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE avg1h FROM PUBLIC;
REVOKE ALL ON TABLE avg1h FROM sensetrace;
GRANT ALL ON TABLE avg1h TO sensetrace;
GRANT SELECT ON TABLE avg1h TO sensetrace_read_only;


--
-- Name: errorfilter1min; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE errorfilter1min FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1min FROM sensetrace;
GRANT ALL ON TABLE errorfilter1min TO sensetrace;
GRANT SELECT ON TABLE errorfilter1min TO sensetrace_read_only;


--
-- Name: avg1min; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE avg1min FROM PUBLIC;
REVOKE ALL ON TABLE avg1min FROM sensetrace;
GRANT ALL ON TABLE avg1min TO sensetrace;
GRANT SELECT ON TABLE avg1min TO sensetrace_read_only;


--
-- Name: errorfilter1month; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE errorfilter1month FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1month FROM sensetrace;
GRANT ALL ON TABLE errorfilter1month TO sensetrace;
GRANT SELECT ON TABLE errorfilter1month TO sensetrace_read_only;


--
-- Name: avg1month; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE avg1month FROM PUBLIC;
REVOKE ALL ON TABLE avg1month FROM sensetrace;
GRANT ALL ON TABLE avg1month TO sensetrace;
GRANT SELECT ON TABLE avg1month TO sensetrace_read_only;


--
-- Name: errorfilter1y; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE errorfilter1y FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter1y FROM sensetrace;
GRANT ALL ON TABLE errorfilter1y TO sensetrace;
GRANT SELECT ON TABLE errorfilter1y TO sensetrace_read_only;


--
-- Name: avg1year; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE avg1year FROM PUBLIC;
REVOKE ALL ON TABLE avg1year FROM sensetrace;
GRANT ALL ON TABLE avg1year TO sensetrace;
GRANT SELECT ON TABLE avg1year TO sensetrace_read_only;


--
-- Name: errorfilter; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE errorfilter FROM PUBLIC;
REVOKE ALL ON TABLE errorfilter FROM sensetrace;
GRANT ALL ON TABLE errorfilter TO sensetrace;
GRANT SELECT ON TABLE errorfilter TO sensetrace_read_only;


--
-- Name: meas_in_cl; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE meas_in_cl FROM PUBLIC;
REVOKE ALL ON TABLE meas_in_cl FROM sensetrace;
GRANT ALL ON TABLE meas_in_cl TO sensetrace;
GRANT SELECT ON TABLE meas_in_cl TO sensetrace_read_only;


--
-- Name: meas_not_in_cl; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE meas_not_in_cl FROM PUBLIC;
REVOKE ALL ON TABLE meas_not_in_cl FROM sensetrace;
GRANT ALL ON TABLE meas_not_in_cl TO sensetrace;
GRANT SELECT ON TABLE meas_not_in_cl TO sensetrace_read_only;


--
-- Name: measurement; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE measurement FROM PUBLIC;
REVOKE ALL ON TABLE measurement FROM sensetrace;
GRANT ALL ON TABLE measurement TO sensetrace;
GRANT SELECT ON TABLE measurement TO sensetrace_read_only;



