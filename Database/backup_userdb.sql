--
-- PostgreSQL database dump
--

\restrict 90edCa0IHtvIMLxDrjZ8Koop6M3ThSIlGrrVA1y4VVKrheT5gKTUSSWM2sfSLBl

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: account_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.account_role AS ENUM (
    'ADMIN',
    'STAFF',
    'CUSTOMER'
);


ALTER TYPE public.account_role OWNER TO postgres;

--
-- Name: gender_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.gender_type AS ENUM (
    'MALE',
    'FEMALE',
    'OTHER'
);


ALTER TYPE public.gender_type OWNER TO postgres;

--
-- Name: staff_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.staff_type AS ENUM (
    'FULLTIME',
    'PARTTIME',
    'INTERN'
);


ALTER TYPE public.staff_type OWNER TO postgres;

--
-- Name: stafftype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.stafftype AS ENUM (
    'FULLTIME',
    'INTERN',
    'PARTTIME'
);


ALTER TYPE public.stafftype OWNER TO postgres;

--
-- Name: CAST (public.stafftype AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.stafftype AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.stafftype); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.stafftype) WITH INOUT AS IMPLICIT;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   IF (NEW.mail,
       NEW.password_hash,
       NEW.name,
       NEW.birthday,
       NEW.gender,
       NEW.role,
       NEW.avatar,
       NEW.is_active,
       NEW.mfa_secret,
       NEW.mfa_enabled)
   IS DISTINCT FROM
      (OLD.mail,
       OLD.password_hash,
       OLD.name,
       OLD.birthday,
       OLD.gender,
       OLD.role,
       OLD.avatar,
       OLD.is_active,
       OLD.mfa_secret,
       OLD.mfa_enabled)
   THEN
      NEW.updated_at = CURRENT_TIMESTAMP;
   END IF;

   RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

--
-- Name: uuid_generate_v7(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.uuid_generate_v7() RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    ts bigint;
    hex text;
BEGIN
    ts := floor(extract(epoch from clock_timestamp()) * 1000);
    hex :=
        lpad(to_hex(ts),12,'0') ||
        encode(gen_random_bytes(10),'hex');
    RETURN (
        substr(hex,1,8) || '-' ||
        substr(hex,9,4) || '-' ||
        '7' || substr(hex,14,3) || '-' ||
        substr(hex,17,4) || '-' ||
        substr(hex,21,12)
    )::uuid;
END;
$$;


ALTER FUNCTION public.uuid_generate_v7() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    mail character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    birthday date NOT NULL,
    gender character varying(255) DEFAULT 'MALE'::public.gender_type NOT NULL,
    role character varying(255) DEFAULT 'CUSTOMER'::public.account_role NOT NULL,
    avatar character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login_at timestamp without time zone,
    is_active boolean NOT NULL,
    mfa_secret character varying(255),
    mfa_enabled boolean DEFAULT false
);


ALTER TABLE public.account OWNER TO postgres;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin (
    account_uuid uuid NOT NULL,
    permissions text
);


ALTER TABLE public.admin OWNER TO postgres;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    account_uuid uuid NOT NULL,
    weight numeric(5,2) NOT NULL,
    height numeric(4,1) NOT NULL,
    expiry_date date NOT NULL
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- Name: staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff (
    account_uuid uuid NOT NULL,
    type character varying(255) DEFAULT 'INTERN'::public.staff_type NOT NULL,
    base_salary numeric(11,2) NOT NULL,
    facility_uuid uuid NOT NULL
);


ALTER TABLE public.staff OWNER TO postgres;

--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account (uuid, mail, password_hash, name, birthday, gender, role, avatar, created_at, updated_at, last_login_at, is_active, mfa_secret, mfa_enabled) FROM stdin;
00000000-0000-0000-0000-000000000006	tuankieu@gmail.com	$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG	Kiều Minh Tuấn	1992-12-05	FEMALE	CUSTOMER	https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg	2026-04-16 22:12:14.737564	2026-04-16 22:12:14.737564	\N	t	\N	f
00000000-0000-0000-0000-000000000005	ngvanduc@gmail.com	$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG	Nguyễn Văn Đức	1992-12-05	MALE	CUSTOMER	https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg	2026-04-16 22:12:14.737564	2026-04-16 22:12:14.737564	2026-05-03 17:56:38.481601	t	\N	f
00000000-0000-0000-0000-000000000002	luduahau@gmail.com	$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG	Lư Hiếu Trung	1995-06-15	FEMALE	STAFF	https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg	2026-04-16 22:12:14.737564	2026-04-16 22:12:14.737564	2026-05-03 17:58:22.472701	t	\N	f
00000000-0000-0000-0000-000000000003	tuthanh@gmail.com	$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG	Đinh Thanh Tú	1998-03-22	MALE	STAFF	https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg	2026-04-16 22:12:14.737564	2026-04-16 22:12:14.737564	2026-05-03 18:23:01.610789	t	\N	f
00000000-0000-0000-0000-000000000001	admin@gmail.com	$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG	Admin	1990-01-01	MALE	ADMIN	https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg	2026-04-16 22:12:14.737564	2026-04-16 22:12:14.737564	2026-05-03 21:23:43.97588	t	\N	f
00000000-0000-0000-0000-000000000004	chuong1305@gmail.com	$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG	Trương Nguyên Chương	2000-08-10	MALE	STAFF	https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg	2026-04-16 22:12:14.737564	2026-04-21 13:08:40.128527	2026-04-27 01:00:22.387295	t	\N	f
\.


--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin (account_uuid, permissions) FROM stdin;
00000000-0000-0000-0000-000000000001	ALL
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (account_uuid, weight, height, expiry_date) FROM stdin;
00000000-0000-0000-0000-000000000005	72.50	175.5	2026-06-10
00000000-0000-0000-0000-000000000006	65.20	168.0	2025-08-02
\.


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff (account_uuid, type, base_salary, facility_uuid) FROM stdin;
00000000-0000-0000-0000-000000000002	FULLTIME	15000000.00	019ce53d-422b-7826-6129-038631b76b57
00000000-0000-0000-0000-000000000003	PARTTIME	30000.00	019ce53d-422b-7826-6129-038631b76b57
00000000-0000-0000-0000-000000000004	PARTTIME	19000.00	019ce53d-422c-7fff-7911-8d39aba5b0a6
\.


--
-- Name: account account_mail_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_mail_key UNIQUE (mail);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (uuid);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (account_uuid);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (account_uuid);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (account_uuid);


--
-- Name: account update_account_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_account_updated_at BEFORE UPDATE ON public.account FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: admin fk_admin_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT fk_admin_account FOREIGN KEY (account_uuid) REFERENCES public.account(uuid) ON DELETE CASCADE;


--
-- Name: customer fk_customer_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT fk_customer_account FOREIGN KEY (account_uuid) REFERENCES public.account(uuid) ON DELETE CASCADE;


--
-- Name: staff fk_staff_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_staff_account FOREIGN KEY (account_uuid) REFERENCES public.account(uuid) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 90edCa0IHtvIMLxDrjZ8Koop6M3ThSIlGrrVA1y4VVKrheT5gKTUSSWM2sfSLBl

