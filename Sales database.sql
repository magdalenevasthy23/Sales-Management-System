--
-- PostgreSQL database dump
--

\restrict KAmOZxdhFViK8dRvP3DGNhNJsTcdt7NM1jT8bBm1KJ4SOS0YQtIHghm4GszbAPE

-- Dumped from database version 17.9
-- Dumped by pg_dump version 17.9

-- Started on 2026-04-27 17:52:49

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
-- TOC entry 225 (class 1255 OID 16442)
-- Name: update_received_amount(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_received_amount() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

    UPDATE customer_sales
    SET received_amount = (
        SELECT COALESCE(SUM(amount_paid),0)
        FROM payment_splits
        WHERE sale_id = NEW.sale_id
    ),
    status = CASE
        WHEN (
            SELECT COALESCE(SUM(amount_paid),0)
            FROM payment_splits
            WHERE sale_id = NEW.sale_id
        ) >= gross_sales THEN 'closed'
        ELSE 'open'
    END
    WHERE sale_id = NEW.sale_id;

    RETURN NEW;

END;
$$;


ALTER FUNCTION public.update_received_amount() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 16390)
-- Name: branches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.branches (
    branch_id integer NOT NULL,
    branch_name character varying(100) NOT NULL,
    branch_admin_name character varying(100)
);


ALTER TABLE public.branches OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16389)
-- Name: branches_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.branches_branch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.branches_branch_id_seq OWNER TO postgres;

--
-- TOC entry 4941 (class 0 OID 0)
-- Dependencies: 217
-- Name: branches_branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.branches_branch_id_seq OWNED BY public.branches.branch_id;


--
-- TOC entry 220 (class 1259 OID 16398)
-- Name: customer_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_sales (
    sale_id integer NOT NULL,
    branch_id integer,
    date date NOT NULL,
    name character varying(100),
    mobile_num character varying(15),
    product_name character varying(30),
    gross_sales numeric(12,2),
    received_amount numeric(12,2) DEFAULT 0,
    status character varying(10),
    CONSTRAINT customer_sales_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'closed'::character varying])::text[])))
);


ALTER TABLE public.customer_sales OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16397)
-- Name: customer_sales_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_sales_sale_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_sales_sale_id_seq OWNER TO postgres;

--
-- TOC entry 4942 (class 0 OID 0)
-- Dependencies: 219
-- Name: customer_sales_sale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_sales_sale_id_seq OWNED BY public.customer_sales.sale_id;


--
-- TOC entry 224 (class 1259 OID 16431)
-- Name: payment_splits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_splits (
    paymen_id integer NOT NULL,
    sale_id integer,
    payment_date date,
    amount_paid numeric(12,2),
    payment_method character varying(50)
);


ALTER TABLE public.payment_splits OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16430)
-- Name: payment_splits_paymen_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_splits_paymen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_splits_paymen_id_seq OWNER TO postgres;

--
-- TOC entry 4943 (class 0 OID 0)
-- Dependencies: 223
-- Name: payment_splits_paymen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_splits_paymen_id_seq OWNED BY public.payment_splits.paymen_id;


--
-- TOC entry 222 (class 1259 OID 16414)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(100),
    password character varying(255),
    branch_id integer,
    role character varying(20),
    email character varying(255),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['Super Admin'::character varying, 'Admin'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16413)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- TOC entry 4944 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- TOC entry 4758 (class 2604 OID 16393)
-- Name: branches branch_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches ALTER COLUMN branch_id SET DEFAULT nextval('public.branches_branch_id_seq'::regclass);


--
-- TOC entry 4759 (class 2604 OID 16401)
-- Name: customer_sales sale_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_sales ALTER COLUMN sale_id SET DEFAULT nextval('public.customer_sales_sale_id_seq'::regclass);


--
-- TOC entry 4762 (class 2604 OID 16434)
-- Name: payment_splits paymen_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_splits ALTER COLUMN paymen_id SET DEFAULT nextval('public.payment_splits_paymen_id_seq'::regclass);


--
-- TOC entry 4761 (class 2604 OID 16417)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- TOC entry 4929 (class 0 OID 16390)
-- Dependencies: 218
-- Data for Name: branches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.branches (branch_id, branch_name, branch_admin_name) FROM stdin;
1	Chennai	Magdalene
2	Bangalore	Helene
3	Coimbatore	Jayachandran
4	Hyderabad	Merlene
5	Mumbai	Stephy
\.


--
-- TOC entry 4931 (class 0 OID 16398)
-- Dependencies: 220
-- Data for Name: customer_sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_sales (sale_id, branch_id, date, name, mobile_num, product_name, gross_sales, received_amount, status) FROM stdin;
5	1	2025-04-10	Alice	9999999999	DS	60000.00	40000.00	open
6	1	2026-04-18	David	9123456780	Laptop	80000.00	0.00	open
7	1	2026-04-18	Emma	9234567890	Mobile	30000.00	0.00	open
15	2	2026-04-18	Sudha	9000000003	Tablet	30000.00	10000.00	open
16	3	2026-04-18	Meena	9100000001	Laptop	80000.00	20000.00	open
17	3	2026-04-18	Thaarini	9100003457	Mobile	20000.00	20000.00	closed
18	3	2026-04-18	Benita	9100009087	Tablet	30000.00	0.00	open
19	3	2026-04-18	Raji	9100002008	TV	50000.00	10000.00	open
20	3	2026-04-18	Vijay	9100002315	Fridge	60000.00	60000.00	closed
21	4	2026-04-18	Jyoshna	9254780121	Laptop	70000.00	20000.00	open
22	5	2026-04-18	Pranesh	9300000111	Mobile	30000.00	30000.00	closed
13	2	2026-04-18	Priya	9000000001	Laptop	75000.00	0.00	open
3	1	2025-04-01	John	9876543210	DS	50000.00	50000.00	closed
14	2	2026-04-18	Nadhiya	9000000002	Mobile	25000.00	10000.00	open
8	1	2026-04-18	Chris	9345678901	Tablet	20000.00	2000.00	open
23	3	2026-04-21	Hemanth	9156789000	Mobile	25000.00	0.00	open
\.


--
-- TOC entry 4935 (class 0 OID 16431)
-- Dependencies: 224
-- Data for Name: payment_splits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_splits (paymen_id, sale_id, payment_date, amount_paid, payment_method) FROM stdin;
3	3	2025-04-05	20000.00	UPI
5	3	2025-04-11	30000.00	UPI
13	5	2026-04-17	30000.00	Cash
14	3	2026-04-17	10000.00	Cash
15	5	2026-04-17	10000.00	Cash
16	14	2026-04-18	5000.00	UPI
17	14	2026-04-18	2.00	Cash
18	14	2026-04-18	2.00	Cash
19	14	2026-04-18	4996.00	Cash
20	8	2026-04-18	2000.00	Cash
\.


--
-- TOC entry 4933 (class 0 OID 16414)
-- Dependencies: 222
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, password, branch_id, role, email) FROM stdin;
1	Magdalene	88888	1	Admin	admin1@test.com
4	Helene	12345	2	Admin	helene@test.com
5	Jayachandran	12345	3	Admin	jaya@test.com
3	Merlene	88888	4	Admin	merl@test.com
2	Stephy	77777	5	Super Admin	super@test.com
6	admin	admin123	\N	Super Admin	\N
\.


--
-- TOC entry 4945 (class 0 OID 0)
-- Dependencies: 217
-- Name: branches_branch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.branches_branch_id_seq', 1, true);


--
-- TOC entry 4946 (class 0 OID 0)
-- Dependencies: 219
-- Name: customer_sales_sale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_sales_sale_id_seq', 23, true);


--
-- TOC entry 4947 (class 0 OID 0)
-- Dependencies: 223
-- Name: payment_splits_paymen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_splits_paymen_id_seq', 20, true);


--
-- TOC entry 4948 (class 0 OID 0)
-- Dependencies: 221
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 6, true);


--
-- TOC entry 4766 (class 2606 OID 16395)
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (branch_id);


--
-- TOC entry 4768 (class 2606 OID 16407)
-- Name: customer_sales customer_sales_mobile_num_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_sales
    ADD CONSTRAINT customer_sales_mobile_num_key UNIQUE (mobile_num);


--
-- TOC entry 4770 (class 2606 OID 16405)
-- Name: customer_sales customer_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_sales
    ADD CONSTRAINT customer_sales_pkey PRIMARY KEY (sale_id);


--
-- TOC entry 4776 (class 2606 OID 16436)
-- Name: payment_splits payment_splits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_splits
    ADD CONSTRAINT payment_splits_pkey PRIMARY KEY (paymen_id);


--
-- TOC entry 4772 (class 2606 OID 16424)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4774 (class 2606 OID 16422)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4780 (class 2620 OID 16447)
-- Name: payment_splits payment_update_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payment_update_trigger AFTER INSERT ON public.payment_splits FOR EACH ROW EXECUTE FUNCTION public.update_received_amount();


--
-- TOC entry 4781 (class 2620 OID 16443)
-- Name: payment_splits trg_update_received; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_update_received AFTER INSERT ON public.payment_splits FOR EACH ROW EXECUTE FUNCTION public.update_received_amount();


--
-- TOC entry 4782 (class 2620 OID 16445)
-- Name: payment_splits trigger_update_received; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_received AFTER INSERT ON public.payment_splits FOR EACH ROW EXECUTE FUNCTION public.update_received_amount();


--
-- TOC entry 4777 (class 2606 OID 16408)
-- Name: customer_sales customer_sales_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_sales
    ADD CONSTRAINT customer_sales_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


--
-- TOC entry 4779 (class 2606 OID 16437)
-- Name: payment_splits payment_splits_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_splits
    ADD CONSTRAINT payment_splits_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.customer_sales(sale_id) ON DELETE CASCADE;


--
-- TOC entry 4778 (class 2606 OID 16425)
-- Name: users users_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(branch_id);


-- Completed on 2026-04-27 17:52:49

--
-- PostgreSQL database dump complete
--

\unrestrict KAmOZxdhFViK8dRvP3DGNhNJsTcdt7NM1jT8bBm1KJ4SOS0YQtIHghm4GszbAPE

