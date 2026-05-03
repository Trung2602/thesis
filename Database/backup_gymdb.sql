--
-- PostgreSQL database dump
--

\restrict 3W8sVgCgW82GYDmxZi5bg8VCch7bDckfPWoPH24lJ5JuInb1GVvgBeOSQd2GAPC

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
-- Name: status_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.status_type AS ENUM (
    'PENDING',
    'SUCCESS',
    'FAILED'
);


ALTER TYPE public.status_type OWNER TO postgres;

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
-- Name: customer_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_schedule (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    date date NOT NULL,
    checkin time without time zone NOT NULL,
    checkout time without time zone NOT NULL,
    facility_uuid uuid NOT NULL,
    staff_uuid uuid NOT NULL,
    customer_uuid uuid NOT NULL
);


ALTER TABLE public.customer_schedule OWNER TO postgres;

--
-- Name: facility; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.facility (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(255) NOT NULL
);


ALTER TABLE public.facility OWNER TO postgres;

--
-- Name: pay_customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pay_customer (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    date date NOT NULL,
    plan_uuid uuid NOT NULL,
    customer_uuid uuid NOT NULL,
    txn_ref character varying(50),
    bank_code character varying(20),
    status character varying(255) DEFAULT 'PENDING'::public.status_type
);


ALTER TABLE public.pay_customer OWNER TO postgres;

--
-- Name: plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plan (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    name character varying(100),
    price integer NOT NULL,
    duration_days integer NOT NULL,
    description text
);


ALTER TABLE public.plan OWNER TO postgres;

--
-- Name: salary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    date date NOT NULL,
    duration numeric(5,2),
    day_off integer,
    price numeric(12,2),
    staff_uuid uuid NOT NULL
);


ALTER TABLE public.salary OWNER TO postgres;

--
-- Name: shift; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shift (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    name character varying(50) NOT NULL,
    checkin time without time zone NOT NULL,
    checkout time without time zone NOT NULL,
    duration numeric(4,2)
);


ALTER TABLE public.shift OWNER TO postgres;

--
-- Name: staff_day_off; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff_day_off (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    date_off date NOT NULL,
    staff_uuid uuid NOT NULL
);


ALTER TABLE public.staff_day_off OWNER TO postgres;

--
-- Name: staff_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff_schedule (
    uuid uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    date date NOT NULL,
    shift_uuid uuid NOT NULL,
    staff_uuid uuid NOT NULL
);


ALTER TABLE public.staff_schedule OWNER TO postgres;

--
-- Data for Name: customer_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_schedule (uuid, date, checkin, checkout, facility_uuid, staff_uuid, customer_uuid) FROM stdin;
019ce53d-4230-7aed-ae6f-47b26a931656	2025-08-13	08:00:00	09:30:00	019ce53d-422b-7826-6129-038631b76b57	00000000-0000-0000-0000-000000000002	00000000-0000-0000-0000-000000000005
019ce53d-4230-736b-8799-bab18e9e2c3c	2025-08-14	10:00:00	11:30:00	019ce53d-422c-7b55-a5d6-d8b4ac6111ac	00000000-0000-0000-0000-000000000002	00000000-0000-0000-0000-000000000006
019d3ac2-4549-736e-2260-92fa4c8eb3c8	2026-03-30	09:00:00	10:00:00	019ce53d-422b-7826-6129-038631b76b57	00000000-0000-0000-0000-000000000002	00000000-0000-0000-0000-000000000005
\.


--
-- Data for Name: facility; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.facility (uuid, name, address) FROM stdin;
019ce53d-422b-7826-6129-038631b76b57	Cơ sở XH	97 Võ Văn Tần, P. Xuân Hòa, TP. Hồ Chí Minh
019ce53d-422c-7b55-a5d6-d8b4ac6111ac	Cơ sở COL	35-37 Hồ Hảo Hớn, P. Cầu Ông Lãnh, TP. Hồ Chí Minh
019ce53d-422c-7fff-7911-8d39aba5b0a6	Cơ sở HP	Khu dân cư Nhơn Đức, xã Hiệp Phước, TP. Hồ Chí Minh
019ce53d-422c-7444-ba57-9b527dfdb39d	Cơ sở TD	02 Mai Thị Lựu, P. Tân Định, TP. Hồ Chí Minh
\.


--
-- Data for Name: pay_customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pay_customer (uuid, date, plan_uuid, customer_uuid, txn_ref, bank_code, status) FROM stdin;
019ce53d-422f-7abd-2152-1b989c73029c	2025-05-10	019ce53d-422d-7acf-81db-d6083831e2a2	00000000-0000-0000-0000-000000000005	1756871250833	NCB	SUCCESS
019ce53d-422f-70b1-2baa-152245708df4	2025-06-02	019ce53d-422d-717f-bded-e60594f6e835	00000000-0000-0000-0000-000000000006	1756871010895	NCB	SUCCESS
019ce53d-422f-7943-a7b4-de33a0793bcc	2025-06-10	019ce53d-422d-7adf-0950-1283ce462631	00000000-0000-0000-0000-000000000005	1756992819560	NCB	SUCCESS
019ce53d-422f-76d4-b71a-05b42096c757	2025-07-02	019ce53d-422d-717f-bded-e60594f6e835	00000000-0000-0000-0000-000000000006	-	-	PENDING
019de857-3ad6-7d0a-7326-4c86555d06d7	2026-05-02	019ce53d-422d-717f-bded-e60594f6e835	00000000-0000-0000-0000-000000000005	\N	\N	FAILED
\.


--
-- Data for Name: plan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plan (uuid, name, price, duration_days, description) FROM stdin;
019ce53d-422d-717f-bded-e60594f6e835	Gói tháng	299000	30	Gói tập 1 tháng, không giới hạn lượt tập
019ce53d-422d-7adf-0950-1283ce462631	Gói năm	2399000	365	Gói tập 1 năm
019ce53d-422d-7bee-a144-06fa79462201	Gói 3 tháng	829000	91	Gói tập 3 tháng
019ce53d-422d-734a-bd66-f637aff0f778	Gói 6 tháng	1499000	186	Gói tập 6 tháng
019ce53d-422d-7acf-81db-d6083831e2a2	Gói sinh viên	269000	30	Điều kiện và học sinh và sinh viên
\.


--
-- Data for Name: salary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salary (uuid, date, duration, day_off, price, staff_uuid) FROM stdin;
019ce53d-422e-7ece-94ea-9c884f042027	2025-06-10	160.00	2	15500000.00	00000000-0000-0000-0000-000000000002
019ce53d-422e-7014-8662-4ef0c76cfd4b	2025-07-10	80.00	0	4800000.00	00000000-0000-0000-0000-000000000003
019ce53d-422e-7105-7055-64b1aae81ffd	2025-07-10	80.00	0	988000.00	00000000-0000-0000-0000-000000000004
019ce53d-422e-7f21-05ec-6b7cf492ebf7	2025-07-10	80.00	0	14000000.00	00000000-0000-0000-0000-000000000002
019d92b3-8bfb-780f-4c99-cad1ea5d2c63	2026-04-10	240.00	2	15000000.00	00000000-0000-0000-0000-000000000002
019d92b3-8bfe-7c72-7c67-8d5ec36e31cd	2026-04-10	0.00	0	0.00	00000000-0000-0000-0000-000000000004
019d92b3-8c03-7db4-ee89-2c06cdc609f8	2026-04-10	16.00	0	480000.00	00000000-0000-0000-0000-000000000003
\.


--
-- Data for Name: shift; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shift (uuid, name, checkin, checkout, duration) FROM stdin;
019ce53d-422c-7568-7a0e-a1889976b575	Làm hành chính	05:00:00	21:00:00	16.00
019ce53d-422d-73b9-310a-d016c3001f32	Ca sáng	05:00:00	13:00:00	8.00
019ce53d-422d-7336-56af-1f02d9734d7a	Ca chiều	13:00:00	21:00:00	8.00
019ce53d-422d-76ab-ffa4-8cc9c5a65232	Ca tối	21:00:00	05:00:00	8.00
019ce53d-422d-7c7b-619d-3b5faa5c5f18	Ca gãy sáng	05:00:00	09:00:00	4.00
019ce53d-422d-70a3-22f4-1716f2ea5077	Ca gãy trưa	09:00:00	13:00:00	4.00
019ce53d-422d-7e38-e81d-29053bde2aa6	Ca gãy chiều	13:00:00	17:00:00	4.00
019ce53d-422d-7050-abca-ed0000b52e9d	Ca gãy tối	17:00:00	21:00:00	4.00
\.


--
-- Data for Name: staff_day_off; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff_day_off (uuid, date_off, staff_uuid) FROM stdin;
019ce53d-422d-7b17-f420-59696f974821	2025-06-15	00000000-0000-0000-0000-000000000002
019ce53d-422d-7dcf-bdca-edff11044d02	2025-06-22	00000000-0000-0000-0000-000000000002
019ce53d-422d-7b39-2cd0-dbaaff640826	2025-06-29	00000000-0000-0000-0000-000000000002
019d4888-7de4-7dd9-9f3a-acf4852d0d1c	2026-04-01	00000000-0000-0000-0000-000000000002
019d48a2-425f-75f7-f875-13a15344cb1c	2026-04-02	00000000-0000-0000-0000-000000000002
\.


--
-- Data for Name: staff_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff_schedule (uuid, date, shift_uuid, staff_uuid) FROM stdin;
019ce53d-422e-73b5-0794-7b25247f5600	2025-08-01	019ce53d-422d-76ab-ffa4-8cc9c5a65232	00000000-0000-0000-0000-000000000003
019ce53d-422f-76bf-9860-c11b39acb343	2025-08-01	019ce53d-422d-7e38-e81d-29053bde2aa6	00000000-0000-0000-0000-000000000004
019ce53d-422f-7535-b52d-b0014e780066	2025-08-02	019ce53d-422d-7336-56af-1f02d9734d7a	00000000-0000-0000-0000-000000000003
019d3cbc-6cfc-7761-3935-589108fedaf3	2026-04-02	019ce53d-422c-7568-7a0e-a1889976b575	00000000-0000-0000-0000-000000000003
019d9af3-d4fa-722e-13d9-c8f7b6cf97e1	2026-04-30	019ce53d-422c-7568-7a0e-a1889976b575	00000000-0000-0000-0000-000000000004
\.


--
-- Name: customer_schedule customer_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_schedule
    ADD CONSTRAINT customer_schedule_pkey PRIMARY KEY (uuid);


--
-- Name: facility facility_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility
    ADD CONSTRAINT facility_name_key UNIQUE (name);


--
-- Name: facility facility_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.facility
    ADD CONSTRAINT facility_pkey PRIMARY KEY (uuid);


--
-- Name: pay_customer pay_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pay_customer
    ADD CONSTRAINT pay_customer_pkey PRIMARY KEY (uuid);


--
-- Name: plan plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plan
    ADD CONSTRAINT plan_pkey PRIMARY KEY (uuid);


--
-- Name: salary salary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary
    ADD CONSTRAINT salary_pkey PRIMARY KEY (uuid);


--
-- Name: shift shift_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT shift_pkey PRIMARY KEY (uuid);


--
-- Name: staff_day_off staff_day_off_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_day_off
    ADD CONSTRAINT staff_day_off_pkey PRIMARY KEY (uuid);


--
-- Name: staff_schedule staff_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_schedule
    ADD CONSTRAINT staff_schedule_pkey PRIMARY KEY (uuid);


--
-- PostgreSQL database dump complete
--

\unrestrict 3W8sVgCgW82GYDmxZi5bg8VCch7bDckfPWoPH24lJ5JuInb1GVvgBeOSQd2GAPC

