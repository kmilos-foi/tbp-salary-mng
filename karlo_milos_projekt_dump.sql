--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4 (Ubuntu 16.4-0ubuntu0.24.04.2)
-- Dumped by pg_dump version 16.4 (Ubuntu 16.4-0ubuntu0.24.04.2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: check_admin_login(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_admin_login(_username character varying, _password character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    valid BOOLEAN;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM administrators
        WHERE username = _username AND password = _password
    ) THEN
        valid := TRUE;
    ELSE
        valid := FALSE;
    END IF;

    RETURN valid;
END;
$$;


ALTER FUNCTION public.check_admin_login(_username character varying, _password character varying) OWNER TO postgres;

--
-- Name: check_duplicate_workday(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_duplicate_workday() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM work_times
        WHERE employee_id = NEW.employee_id AND day = NEW.day
    ) THEN
        RAISE EXCEPTION 'Već ste unijeli sate za taj dan';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_duplicate_workday() OWNER TO postgres;

--
-- Name: check_employee_login(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_employee_login(_username character varying, _password character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    valid BOOLEAN;
BEGIN
    IF EXISTS (
        SELECT 1
        FROM employees
        WHERE username = _username 
          AND password = _password
          AND CURRENT_DATE >= lower(employment_period) 
          AND CURRENT_DATE < upper(employment_period)
    ) THEN
        valid := TRUE;
    ELSE
        valid := FALSE;
    END IF;

    RETURN valid;
END;
$$;


ALTER FUNCTION public.check_employee_login(_username character varying, _password character varying) OWNER TO postgres;

--
-- Name: set_log_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_log_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.timestamp IS NULL THEN
        NEW.timestamp := NOW();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_log_timestamp() OWNER TO postgres;

--
-- Name: validate_day(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_day() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.day > CURRENT_DATE THEN
        RAISE EXCEPTION 'Dan ne smije biti u budućnosti';
    END IF;

    IF NEW.day < CURRENT_DATE - INTERVAL '7 days' THEN
        RAISE EXCEPTION 'Dan ne smije biti stariji od tjedan dana';
    END IF;

    IF EXTRACT(MONTH FROM NEW.day) < EXTRACT(MONTH FROM CURRENT_DATE) AND
       EXTRACT(YEAR FROM NEW.day) <= EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'Dan ne smije biti iz prošlog mjeseca';
    END IF;
    
    IF EXTRACT(YEAR FROM NEW.day) < EXTRACT(YEAR FROM CURRENT_DATE) AND
       EXTRACT(MONTH FROM NEW.day) = 12 AND EXTRACT(MONTH FROM CURRENT_DATE) = 1 THEN
        RAISE EXCEPTION 'Dan ne smije biti iz prošlog mjeseca';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_day() OWNER TO postgres;

--
-- Name: validate_employee_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_employee_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.first_name = '' THEN
        RAISE EXCEPTION 'Ime ne smije biti prazno';
    END IF;

    IF NEW.last_name = '' THEN
        RAISE EXCEPTION 'Prezime ne smije biti prazno';
    END IF;

    IF NEW.username = '' THEN
        RAISE EXCEPTION 'Korisničko ime ne smije biti prazno';
    END IF;

    IF NEW.password = '' THEN
        RAISE EXCEPTION 'Lozinka ne smije biti prazna';
    END IF;

    IF NEW.title_id IS NULL THEN
        RAISE EXCEPTION 'Titula mora biti postavljena';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_employee_update() OWNER TO postgres;

--
-- Name: validate_payroll_month(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_payroll_month() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Obračun ne smije biti u budućnosti';
    END IF;

    IF NEW.date < CURRENT_DATE - INTERVAL '3 months' THEN
        RAISE EXCEPTION 'Obračin ne smije biti stariji od 3 mjeseca';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_payroll_month() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: administrators; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.administrators (
    id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(50) NOT NULL
);


ALTER TABLE public.administrators OWNER TO postgres;

--
-- Name: administrators_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.administrators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.administrators_id_seq OWNER TO postgres;

--
-- Name: administrators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.administrators_id_seq OWNED BY public.administrators.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    title_id integer,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    employment_period daterange
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_id_seq OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: hours; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hours (
    id integer NOT NULL,
    hour integer NOT NULL
);


ALTER TABLE public.hours OWNER TO postgres;

--
-- Name: hours_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hours_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hours_id_seq OWNER TO postgres;

--
-- Name: hours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hours_id_seq OWNED BY public.hours.id;


--
-- Name: log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log (
    id integer NOT NULL,
    message character varying(255) NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


ALTER TABLE public.log OWNER TO postgres;

--
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_id_seq OWNER TO postgres;

--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- Name: payroll_processes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll_processes (
    id integer NOT NULL,
    administrator_id integer,
    date date
);


ALTER TABLE public.payroll_processes OWNER TO postgres;

--
-- Name: payroll_processes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payroll_processes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_processes_id_seq OWNER TO postgres;

--
-- Name: payroll_processes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payroll_processes_id_seq OWNED BY public.payroll_processes.id;


--
-- Name: payrolls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payrolls (
    id integer NOT NULL,
    payroll_processes_id integer,
    employee_id integer,
    month_salary integer NOT NULL,
    total_hours integer NOT NULL
);


ALTER TABLE public.payrolls OWNER TO postgres;

--
-- Name: payrolls_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payrolls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payrolls_id_seq OWNER TO postgres;

--
-- Name: payrolls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payrolls_id_seq OWNED BY public.payrolls.id;


--
-- Name: titles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.titles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    salary_bonus integer NOT NULL
);


ALTER TABLE public.titles OWNER TO postgres;

--
-- Name: titles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.titles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.titles_id_seq OWNER TO postgres;

--
-- Name: titles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.titles_id_seq OWNED BY public.titles.id;


--
-- Name: work_times; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_times (
    hour_id integer NOT NULL,
    employee_id integer NOT NULL,
    day date NOT NULL
);


ALTER TABLE public.work_times OWNER TO postgres;

--
-- Name: administrators id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administrators ALTER COLUMN id SET DEFAULT nextval('public.administrators_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: hours id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hours ALTER COLUMN id SET DEFAULT nextval('public.hours_id_seq'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- Name: payroll_processes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_processes ALTER COLUMN id SET DEFAULT nextval('public.payroll_processes_id_seq'::regclass);


--
-- Name: payrolls id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payrolls ALTER COLUMN id SET DEFAULT nextval('public.payrolls_id_seq'::regclass);


--
-- Name: titles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.titles ALTER COLUMN id SET DEFAULT nextval('public.titles_id_seq'::regclass);


--
-- Data for Name: administrators; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.administrators (id, first_name, last_name, username, password) FROM stdin;
1	Luka	Lukić	admin	admin
2	Tina Tinić	Emić	eemic	admin456
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, title_id, first_name, last_name, username, password, employment_period) FROM stdin;
3	2	Marko	Marić	user	user	[2022-09-10,2026-09-10)
4	1	Boris	Borić	direktor	user	[2023-09-10,2026-09-10)
1	2	Ivan	Maticevic	user3	user	[0001-01-01,2024-12-31)
2	1	Ana	Anić	user2	user	[2021-05-15,2025-05-15)
\.


--
-- Data for Name: hours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hours (id, hour) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log (id, message, "timestamp") FROM stdin;
\.


--
-- Data for Name: payroll_processes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payroll_processes (id, administrator_id, date) FROM stdin;
\.


--
-- Data for Name: payrolls; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payrolls (id, payroll_processes_id, employee_id, month_salary, total_hours) FROM stdin;
\.


--
-- Data for Name: titles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.titles (id, name, salary_bonus) FROM stdin;
1	menadzer	1000
2	radnik	50
\.


--
-- Data for Name: work_times; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_times (hour_id, employee_id, day) FROM stdin;
\.


--
-- Name: administrators_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.administrators_id_seq', 2, true);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 4, true);


--
-- Name: hours_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hours_id_seq', 8, true);


--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_id_seq', 76, true);


--
-- Name: payroll_processes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payroll_processes_id_seq', 14, true);


--
-- Name: payrolls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payrolls_id_seq', 16, true);


--
-- Name: titles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.titles_id_seq', 2, true);


--
-- Name: administrators administrators_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administrators
    ADD CONSTRAINT administrators_pkey PRIMARY KEY (id);


--
-- Name: administrators administrators_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.administrators
    ADD CONSTRAINT administrators_username_key UNIQUE (username);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: employees employees_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_username_key UNIQUE (username);


--
-- Name: hours hours_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hours
    ADD CONSTRAINT hours_pkey PRIMARY KEY (id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: payroll_processes payroll_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_processes
    ADD CONSTRAINT payroll_processes_pkey PRIMARY KEY (id);


--
-- Name: payrolls payrolls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payrolls
    ADD CONSTRAINT payrolls_pkey PRIMARY KEY (id);


--
-- Name: titles titles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.titles
    ADD CONSTRAINT titles_pkey PRIMARY KEY (id);


--
-- Name: work_times work_times_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_times
    ADD CONSTRAINT work_times_pkey PRIMARY KEY (hour_id, employee_id, day);


--
-- Name: work_times check_duplicate_workday; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_duplicate_workday BEFORE INSERT ON public.work_times FOR EACH ROW EXECUTE FUNCTION public.check_duplicate_workday();


--
-- Name: log set_log_timestamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_log_timestamp BEFORE INSERT ON public.log FOR EACH ROW EXECUTE FUNCTION public.set_log_timestamp();


--
-- Name: employees validate_before_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validate_before_update BEFORE UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION public.validate_employee_update();


--
-- Name: work_times validate_day; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validate_day BEFORE INSERT OR UPDATE ON public.work_times FOR EACH ROW EXECUTE FUNCTION public.validate_day();


--
-- Name: payroll_processes validate_payroll_month; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validate_payroll_month BEFORE INSERT ON public.payroll_processes FOR EACH ROW EXECUTE FUNCTION public.validate_payroll_month();


--
-- Name: employees employees_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_title_id_fkey FOREIGN KEY (title_id) REFERENCES public.titles(id);


--
-- Name: payroll_processes payroll_processes_administrator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll_processes
    ADD CONSTRAINT payroll_processes_administrator_id_fkey FOREIGN KEY (administrator_id) REFERENCES public.administrators(id);


--
-- Name: payrolls payrolls_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payrolls
    ADD CONSTRAINT payrolls_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: payrolls payrolls_payroll_processes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payrolls
    ADD CONSTRAINT payrolls_payroll_processes_id_fkey FOREIGN KEY (payroll_processes_id) REFERENCES public.payroll_processes(id);


--
-- Name: work_times work_times_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_times
    ADD CONSTRAINT work_times_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: work_times work_times_hour_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_times
    ADD CONSTRAINT work_times_hour_id_fkey FOREIGN KEY (hour_id) REFERENCES public.hours(id);


--
-- PostgreSQL database dump complete
--

