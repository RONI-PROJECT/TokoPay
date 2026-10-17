--
-- PostgreSQL database dump
--

\restrict phVWvU5Q3RDK3dLQdWl6MCSxsF2xFPu8ZGNiVOeLKdBoXyhxhJWljShXeQjrutp

-- Dumped from database version 18.6 (c021049)
-- Dumped by pg_dump version 18.6

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: neondb_owner
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO neondb_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: neondb_owner
--

COMMENT ON SCHEMA public IS '';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_sessions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.admin_sessions (
    token text NOT NULL,
    username text NOT NULL,
    "expiresAt" text NOT NULL,
    "createdAt" text DEFAULT (now())::text NOT NULL,
    "lastSeenAt" text
);


ALTER TABLE public.admin_sessions OWNER TO neondb_owner;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.api_keys (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    "userId" text NOT NULL,
    name text,
    key text NOT NULL,
    secret text,
    status text DEFAULT 'active'::text NOT NULL,
    environment text DEFAULT 'production'::text NOT NULL,
    "lastUsedAt" text,
    "createdAt" text NOT NULL,
    ip_whitelist text[]
);


ALTER TABLE public.api_keys OWNER TO neondb_owner;

--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.app_settings (
    key text NOT NULL,
    value text,
    "updatedAt" text
);


ALTER TABLE public.app_settings OWNER TO neondb_owner;

--
-- Name: gobiz_history; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.gobiz_history (
    "gobizId" text NOT NULL,
    amount bigint NOT NULL,
    "time" text,
    "matchedTrxId" text,
    raw jsonb,
    "seenAt" text NOT NULL
);


ALTER TABLE public.gobiz_history OWNER TO neondb_owner;

--
-- Name: meta; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.meta (
    key text NOT NULL,
    value jsonb NOT NULL
);


ALTER TABLE public.meta OWNER TO neondb_owner;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.notifications (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    "userId" text NOT NULL,
    type text,
    title text,
    message text,
    meta jsonb,
    "isRead" boolean DEFAULT false CONSTRAINT notifications_read_not_null NOT NULL,
    "createdAt" text NOT NULL
);


ALTER TABLE public.notifications OWNER TO neondb_owner;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.sessions (
    token text NOT NULL,
    "userId" text NOT NULL,
    "createdAt" text NOT NULL,
    "expiresAt" text NOT NULL,
    "ipAddress" text,
    "userAgent" text
);


ALTER TABLE public.sessions OWNER TO neondb_owner;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.transactions (
    "trxId" text NOT NULL,
    "userId" text,
    status text NOT NULL,
    amount bigint NOT NULL,
    fee bigint DEFAULT 0 NOT NULL,
    net bigint DEFAULT 0 NOT NULL,
    "merchantAmount" bigint DEFAULT 0 NOT NULL,
    "feePercent" numeric DEFAULT 0 NOT NULL,
    total bigint NOT NULL,
    "payAmount" bigint NOT NULL,
    "qrString" text NOT NULL,
    "qrImageUrl" text,
    "callbackUrl" text,
    "callbackSecret" text,
    "idempotencyKey" text,
    metadata jsonb,
    "createdAt" text NOT NULL,
    "expiresAt" text NOT NULL,
    "paidAt" text,
    entry jsonb,
    "webhookState" text,
    "webhookAttempts" integer DEFAULT 0 NOT NULL,
    "webhookNextAt" text,
    "webhookLastError" text
);


ALTER TABLE public.transactions OWNER TO neondb_owner;

--
-- Name: users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.users (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    name text,
    phone text,
    role text DEFAULT 'user'::text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    balance bigint DEFAULT 0 NOT NULL,
    "webhookUrl" text,
    "webhookSecret" text,
    "createdAt" text NOT NULL,
    "lastLoginAt" text,
    totp_enabled boolean DEFAULT false,
    totp_secret text,
    totp_backup_codes text,
    totp_verified_at text,
    "isAdmin" boolean DEFAULT false,
    "adminBalance" bigint DEFAULT 0 NOT NULL,
    merchant_code text
);


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Name: webhook_logs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.webhook_logs (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    user_id text,
    trx_id text,
    event text,
    url text,
    http_status integer,
    latency_ms integer,
    status text,
    error text,
    sent_at text
);


ALTER TABLE public.webhook_logs OWNER TO neondb_owner;

--
-- Name: withdrawals; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.withdrawals (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    "wdrId" text NOT NULL,
    "userId" text NOT NULL,
    amount bigint NOT NULL,
    fee bigint DEFAULT 0 NOT NULL,
    received bigint NOT NULL,
    bank text,
    account text,
    status text DEFAULT 'PENDING'::text NOT NULL,
    note text,
    "createdAt" text NOT NULL,
    "processedAt" text
);


ALTER TABLE public.withdrawals OWNER TO neondb_owner;

--
-- Data for Name: admin_sessions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.admin_sessions (token, username, "expiresAt", "createdAt", "lastSeenAt") FROM stdin;
d799e047b073ce9653532716d3855312fdeeb152505cccdca99a674ed30044d0	admin	2026-10-16T08:01:47.487Z	2026-10-09 08:01:47.579452+00	\N
4f5081637d184e0b092bd27fd2fa181fd9bac3fcb8e5264232272dbc699fbc62	admin	2026-10-16T08:05:29.736Z	2026-10-09 08:05:29.74223+00	\N
7bf7b8152ef8ecb74352cf983abae4190e8219cdbf233d4c88f1761b68e3f1b9	admin	2026-10-16T08:08:11.634Z	2026-10-09 08:08:11.639955+00	\N
a7d98c742734dd0f97327562edf49e1a9084e43bc2f1ae058f703fd06293b4a1	admin	2026-10-16T08:09:49.493Z	2026-10-09 08:09:49.589751+00	\N
0c530aa0cf73af8304217862cc4248d1436388e10afb6665187c26da0b267522	admin	2026-10-16T08:11:35.881Z	2026-10-09 08:11:35.976173+00	\N
7455f378fb604177141f65c76e7b8771fc65a8ab1fadd59885b225e3ce1e5352	admin	2026-10-16T08:12:27.084Z	2026-10-09 08:12:27.09051+00	\N
04a348c0fe8d5c14f217e3933ca311cf7972c799c3725967cfc42ba90b6235d8	admin	2026-10-16T08:13:57.613Z	2026-10-09 08:13:57.697227+00	\N
4bf25404b753a172b2e221106149f80b2309f20506a3979c4645dcff5d67c6bb	admin	2026-10-16T08:18:13.841Z	2026-10-09 08:18:13.8474+00	2026-10-09 08:18:15.388896+00
ac9d25c59d790a99d404adf2eedf064800f368b19abc1931b1b9b1d4607e03d9	admin	2026-10-16T09:00:21.402Z	2026-10-09 09:00:21.408424+00	2026-10-09 09:00:23.56166+00
23c2727370c67066046b5394df6881c0dd4f7b9bf9e052f417bd0e56996cc737	admin	2026-10-16T14:15:14.425Z	2026-10-09 14:15:14.432204+00	2026-10-10 10:25:58.170179+00
3a08acdb1df0d4e7d92bebb44fc3155fa77b640e30e720099798004bee622dd1	admin	2026-10-16T09:13:07.717Z	2026-10-09 09:13:07.725453+00	\N
e155f9239fedf6a26bf39715293c960bce540d5979723355e9ce256114623726	admin	2026-10-16T09:13:24.922Z	2026-10-09 09:13:24.930402+00	2026-10-09 09:13:25.746169+00
290e806abd0fbd3deb1f89491567365679376eb47aa0f3282a1f4dc87e77a267	admin	2026-10-21T15:07:29.214Z	2026-10-14 15:07:29.912287+00	2026-10-14 15:08:01.128088+00
1460d34bdd6e0fc6dc6ff30931a1feb1af48316549341cdd4e636d24bd331e22	admin	2026-10-16T08:25:48.219Z	2026-10-09 08:25:48.321691+00	2026-10-09 08:25:49.025435+00
0cc0cf8e66139aa51bdbb068b36605f9d6b811b6cf83976e2a858280d8b66986	admin	2026-10-17T18:02:28.754Z	2026-10-10 18:02:28.760317+00	2026-10-10 21:37:50.454629+00
132db6cd5b4fc21b86a8a367bad0b14da25891c584b0c7d9699413311e8acdf6	admin	2026-10-22T09:15:21.991Z	2026-10-15 09:15:22.082795+00	2026-10-15 09:20:57.465914+00
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.api_keys (id, "userId", name, key, secret, status, environment, "lastUsedAt", "createdAt", ip_whitelist) FROM stdin;
9b01f815-fe9c-4db2-84fb-2a511303f08f	8bc1cd08-2178-414e-8639-5ae9252c53a2	i	rp_live_95fc4f0b06074f15a18c9a801734bb11	f2fb8edf-1b0f-4b54-aa89-db4374f465b2	active	production	\N	2026-10-14T17:14:15.418Z	\N
\.


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.app_settings (key, value, "updatedAt") FROM stdin;
site_name	UnoPay	2026-10-15 09:20:35.126939+00
site_title	UnoPay — Payment Gateway QRIS untuk Merchant Indonesia	2026-10-15 09:20:35.143+00
site_description	UnoPay adalah payment gateway QRIS untuk merchant Indonesia. Terima pembayaran QRIS, kelola transaksi, dan tarik dana dari satu dashboard.	2026-10-15 09:20:35.158981+00
site_keywords	UnoPay, payment gateway, qris, terima qris, merchant indonesia	2026-10-15 09:20:35.174912+00
logo_url	https://cdn.phototourl.com/member/2026-10-15-fa6b7e0b-291c-49f5-8ace-0514a9edd5de.png	2026-10-15 09:20:35.190848+00
marquee_text	Didukung berbagai bank & e-wallet	2026-10-15 09:20:35.206661+00
marquee_items	BCA,Mandiri,BNI,BRI,GoPay,OVO,DANA,ShopeePay,LinkAja,Jenius,Permata,CIMB Niaga	2026-10-15 09:20:35.222814+00
footer_text	UnoPay — payment gateway QRIS untuk merchant Indonesia.	2026-10-15 09:20:35.239122+00
hero_title	UnoPay Terima pembayaran QRIS tanpa ribet urus teknisnya	2026-10-15 09:20:35.255498+00
hero_lead	Satu dashboard untuk merchant: buat QRIS dinamis, pantau transaksi masuk, settlement otomatis, dan API yang siap dipasang ke sistem Anda.	2026-10-15 09:20:35.271724+00
footer_copyright	© 2026 UnoPay. All rights reserved.	2026-10-15 09:20:35.288224+00
favicon_url	https://cdn.phototourl.com/member/2026-10-15-a7c1ba44-a7bf-4b93-ad72-b672aa886579.png	2026-10-15 09:20:35.304186+00
maintenance_mode	false	2026-10-09 14:16:25.257508+00
wd_min	85000	2026-10-09 14:20:04.46091+00
wd_fee_percent	2.5	2026-10-09 14:20:04.476222+00
wd_fee_flat	4500	2026-10-09 14:20:04.490912+00
fee_transaction_percent	2.9	2026-10-09 14:20:04.505684+00
\.


--
-- Data for Name: gobiz_history; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.gobiz_history ("gobizId", amount, "time", "matchedTrxId", raw, "seenAt") FROM stdin;
01a1262d-cff8-7000-8676-0871fe4fa345	1111	10 Oct 2026 - 21:18:19	\N	{"raw": {"id": "01a1262d-cff8-7000-8676-0871fe4fa345", "shares": [{"id": "01a1262d-d438-7000-8676-0871fe4fa345", "vat": 0, "wht": 0, "gojek_share": 0, "merchant_id": "G490563346", "gross_amount": 111100, "payment_type": "qris", "refund_amount": 0, "merchant_share": 111100, "provider_share": 0, "voucher_amount": 0, "settlement_time": "2026-10-10T21:18:20.088+07:00", "is_refund_action": false, "transaction_time": "2026-10-10T21:18:19+07:00", "merchant_fixed_fee": 0, "platform_total_fee": 0, "voucher_commission": 0, "gross_amount_regular": 111100, "merchant_percentage_fee": 0.003, "wallstreet_transaction_id": "0120261010141819YcYMIiAwXbID", "sku_commission_offset_amount_after_tax": null}], "version": 1791641900088, "currency": "IDR", "order_id": "QRIS-0120261010141819YcYMIiAwXbID", "qris_on_us": false, "merchant_id": "G490563346", "channel_type": "STATIC_QR", "gross_amount": 111100, "payment_type": "QRIS", "service_type": "QRIS", "promo_details": {"promo_code": "", "promo_original_amount": 0}, "settlement_time": "2026-10-10T21:18:20.119023+07:00", "transaction_time": "2026-10-10T21:18:19+07:00", "real_gross_amount": 111100, "transaction_source": "GOPAY_INSTORE", "transaction_status": "SETTLEMENT", "transaction_history": [{"id": "01a1262d-d457-7059-8676-0871fe4fa345", "amount": 111100, "action_name": "Settlement Transaction", "action_time": "2026-10-10T21:18:20.119023+07:00", "action_user": "", "action_status": "SETTLEMENT"}], "qris_provider_aspi_issuer": "DANA", "wallstreet_transaction_id": "0120261010141819YcYMIiAwXbID", "merchant_cross_reference_id": "70087b5d-4647-4a0f-9b86-e74e51c15804", "qris_provider_aspi_acquirer": "gopay", "qris_provider_retrieval_reference_number": "020879854374"}, "time": "10 Oct 2026 - 21:18:19", "amount": 1111, "paidAt": "2026-10-10T14:18:19.000Z", "gobizId": "01a1262d-cff8-7000-8676-0871fe4fa345"}	2026-10-10T14:30:14.667Z
01a11da1-61b0-7000-ad1c-dd6e223139f2	1000	09 Oct 2026 - 05:27:58	TRX-9Q9WR3R4CZYY	{"raw": {"id": "01a11da1-61b0-7000-ad1c-dd6e223139f2", "shares": [{"id": "01a11da1-650a-7000-ad1c-dd6e223139f2", "vat": 0, "wht": 0, "gojek_share": 0, "merchant_id": "G490563346", "gross_amount": 100000, "payment_type": "qris", "refund_amount": 0, "merchant_share": 100000, "provider_share": 0, "voucher_amount": 0, "settlement_time": "2026-10-09T05:27:58.858+07:00", "is_refund_action": false, "transaction_time": "2026-10-09T05:27:58+07:00", "merchant_fixed_fee": 0, "platform_total_fee": 0, "voucher_commission": 0, "gross_amount_regular": 100000, "merchant_percentage_fee": 0.003, "wallstreet_transaction_id": "05202610082227589jgWPIBWQcID", "sku_commission_offset_amount_after_tax": null}], "version": 1791498478858, "currency": "IDR", "order_id": "QRIS-05202610082227589jgWPIBWQcID", "qris_on_us": false, "merchant_id": "G490563346", "channel_type": "STATIC_QR", "gross_amount": 100000, "payment_type": "QRIS", "service_type": "QRIS", "promo_details": {"promo_code": "", "promo_original_amount": 0}, "settlement_time": "2026-10-09T05:27:58.882555+07:00", "transaction_time": "2026-10-09T05:27:58+07:00", "real_gross_amount": 100000, "transaction_source": "GOPAY_INSTORE", "transaction_status": "SETTLEMENT", "transaction_history": [{"id": "01a11da1-6522-7877-ad1c-dd6e223139f2", "amount": 100000, "action_name": "Settlement Transaction", "action_time": "2026-10-09T05:27:58.882555+07:00", "action_user": "", "action_status": "SETTLEMENT"}], "qris_provider_aspi_issuer": "DANA", "wallstreet_transaction_id": "05202610082227589jgWPIBWQcID", "merchant_cross_reference_id": "70087b5d-4647-4a0f-9b86-e74e51c15804", "qris_provider_aspi_acquirer": "gopay", "qris_provider_retrieval_reference_number": "1t11f6r24511"}, "time": "09 Oct 2026 - 05:27:58", "amount": 1000, "paidAt": "2026-10-08T22:27:58.000Z", "gobizId": "01a11da1-61b0-7000-ad1c-dd6e223139f2"}	2026-10-09T05:13:03.623Z
01a11f8a-5978-7000-a038-5001ecf5479e	50000	09 Oct 2026 - 14:22:03	TEST-001	{"raw": {"id": "01a11f8a-5978-7000-a038-5001ecf5479e", "shares": [{"id": "01a11f8a-5cda-7000-a038-5001ecf5479e", "vat": 0, "wht": 0, "gojek_share": 0, "merchant_id": "G490563346", "gross_amount": 5000000, "payment_type": "qris", "refund_amount": 0, "merchant_share": 5000000, "provider_share": 0, "voucher_amount": 0, "settlement_time": "2026-10-09T14:22:03.866+07:00", "is_refund_action": false, "transaction_time": "2026-10-09T14:22:03+07:00", "merchant_fixed_fee": 0, "platform_total_fee": 0, "voucher_commission": 0, "gross_amount_regular": 5000000, "merchant_percentage_fee": 0.003, "wallstreet_transaction_id": "0220261009072203yYkGtoab8sID", "sku_commission_offset_amount_after_tax": null}], "version": 1791530523866, "currency": "IDR", "order_id": "QRIS-0220261009072203yYkGtoab8sID", "qris_on_us": false, "merchant_id": "G490563346", "channel_type": "STATIC_QR", "gross_amount": 5000000, "payment_type": "QRIS", "service_type": "QRIS", "promo_details": {"promo_code": "", "promo_original_amount": 0}, "settlement_time": "2026-10-09T14:22:03.889244+07:00", "transaction_time": "2026-10-09T14:22:03+07:00", "real_gross_amount": 5000000, "transaction_source": "GOPAY_INSTORE", "transaction_status": "SETTLEMENT", "transaction_history": [{"id": "01a11f8a-5cf1-73b9-a038-5001ecf5479e", "amount": 5000000, "action_name": "Settlement Transaction", "action_time": "2026-10-09T14:22:03.889244+07:00", "action_user": "", "action_status": "SETTLEMENT"}], "qris_provider_aspi_issuer": "DANA", "wallstreet_transaction_id": "0220261009072203yYkGtoab8sID", "merchant_cross_reference_id": "70087b5d-4647-4a0f-9b86-e74e51c15804", "qris_provider_aspi_acquirer": "gopay", "qris_provider_retrieval_reference_number": "021285749177"}, "time": "09 Oct 2026 - 14:22:03", "amount": 50000, "paidAt": "2026-10-09T07:22:03.000Z", "gobizId": "01a11f8a-5978-7000-a038-5001ecf5479e"}	2026-10-09T07:23:04.050Z
01a11d9b-27f0-7000-b37a-6b76da3583e4	50000	09 Oct 2026 - 05:21:10	TRX-GKWMTEZ5HCEA	{"raw": {"id": "01a11d9b-27f0-7000-b37a-6b76da3583e4", "shares": [{"id": "01a11d9b-28dd-7000-b37a-6b76da3583e4", "vat": 0, "wht": 0, "gojek_share": 0, "merchant_id": "G490563346", "gross_amount": 5000000, "payment_type": "qris", "refund_amount": 0, "merchant_share": 5000000, "provider_share": 0, "voucher_amount": 0, "settlement_time": "2026-10-09T05:21:10.237+07:00", "is_refund_action": false, "transaction_time": "2026-10-09T05:21:10+07:00", "merchant_fixed_fee": 0, "platform_total_fee": 0, "voucher_commission": 0, "gross_amount_regular": 5000000, "merchant_percentage_fee": 0.003, "wallstreet_transaction_id": "05202610082221105EH4d1wdKIID", "sku_commission_offset_amount_after_tax": null}], "version": 1791498070237, "currency": "IDR", "order_id": "QRIS-05202610082221105EH4d1wdKIID", "qris_on_us": false, "merchant_id": "G490563346", "channel_type": "STATIC_QR", "gross_amount": 5000000, "payment_type": "QRIS", "service_type": "QRIS", "promo_details": {"promo_code": "", "promo_original_amount": 0}, "settlement_time": "2026-10-09T05:21:10.258666+07:00", "transaction_time": "2026-10-09T05:21:10+07:00", "real_gross_amount": 5000000, "transaction_source": "GOPAY_INSTORE", "transaction_status": "SETTLEMENT", "transaction_history": [{"id": "01a11d9b-28f2-7a29-b37a-6b76da3583e4", "amount": 5000000, "action_name": "Settlement Transaction", "action_time": "2026-10-09T05:21:10.258666+07:00", "action_user": "", "action_status": "SETTLEMENT"}], "qris_provider_aspi_issuer": "DANA", "wallstreet_transaction_id": "05202610082221105EH4d1wdKIID", "merchant_cross_reference_id": "70087b5d-4647-4a0f-9b86-e74e51c15804", "qris_provider_aspi_acquirer": "gopay", "qris_provider_retrieval_reference_number": "020851020074"}, "time": "09 Oct 2026 - 05:21:10", "amount": 50000, "paidAt": "2026-10-08T22:21:10.000Z", "gobizId": "01a11d9b-27f0-7000-b37a-6b76da3583e4"}	2026-10-09T07:12:04.110Z
01a12f70-3060-7000-9ac0-5b7a168d8a7e	1000	12 Oct 2026 - 16:27:24	\N	{"raw": {"id": "01a12f70-3060-7000-9ac0-5b7a168d8a7e", "shares": [{"id": "01a12f70-3363-7000-9ac0-5b7a168d8a7e", "vat": 0, "wht": 0, "gojek_share": 0, "merchant_id": "G490563346", "gross_amount": 100000, "payment_type": "qris", "refund_amount": 0, "merchant_share": 100000, "provider_share": 0, "voucher_amount": 0, "settlement_time": "2026-10-12T16:27:24.771+07:00", "is_refund_action": false, "transaction_time": "2026-10-12T16:27:24+07:00", "merchant_fixed_fee": 0, "platform_total_fee": 0, "voucher_commission": 0, "gross_amount_regular": 100000, "merchant_percentage_fee": 0.003, "wallstreet_transaction_id": "0120261012092724HyjeKNvUR7ID", "sku_commission_offset_amount_after_tax": null}], "version": 1791797244771, "currency": "IDR", "order_id": "QRIS-0120261012092724HyjeKNvUR7ID", "qris_on_us": false, "merchant_id": "G490563346", "channel_type": "STATIC_QR", "gross_amount": 100000, "payment_type": "QRIS", "service_type": "QRIS", "promo_details": {"promo_code": "", "promo_original_amount": 0}, "settlement_time": "2026-10-12T16:27:24.806028+07:00", "transaction_time": "2026-10-12T16:27:24+07:00", "real_gross_amount": 100000, "transaction_source": "GOPAY_INSTORE", "transaction_status": "SETTLEMENT", "transaction_history": [{"id": "01a12f70-3386-706d-9ac0-5b7a168d8a7e", "amount": 100000, "action_name": "Settlement Transaction", "action_time": "2026-10-12T16:27:24.806028+07:00", "action_user": "", "action_status": "SETTLEMENT"}], "qris_provider_aspi_issuer": "DANA", "wallstreet_transaction_id": "0120261012092724HyjeKNvUR7ID", "merchant_cross_reference_id": "70087b5d-4647-4a0f-9b86-e74e51c15804", "qris_provider_aspi_acquirer": "gopay", "qris_provider_retrieval_reference_number": "1t4vqkn86651"}, "time": "12 Oct 2026 - 16:27:24", "amount": 1000, "paidAt": "2026-10-12T09:27:24.000Z", "gobizId": "01a12f70-3060-7000-9ac0-5b7a168d8a7e"}	2026-10-12T09:28:03.846Z
01a13092-e258-7000-8d19-7f8535d4c70a	1000	12 Oct 2026 - 21:44:55	TRX-WAU74HXG833N	{"raw": {"id": "01a13092-e258-7000-8d19-7f8535d4c70a", "shares": [{"id": "01a13092-e485-7000-8d19-7f8535d4c70a", "vat": 0, "wht": 0, "gojek_share": 0, "merchant_id": "G490563346", "gross_amount": 100000, "payment_type": "qris", "refund_amount": 0, "merchant_share": 100000, "provider_share": 0, "voucher_amount": 0, "settlement_time": "2026-10-12T21:44:55.557+07:00", "is_refund_action": false, "transaction_time": "2026-10-12T21:44:55+07:00", "merchant_fixed_fee": 0, "platform_total_fee": 0, "voucher_commission": 0, "gross_amount_regular": 100000, "merchant_percentage_fee": 0.003, "wallstreet_transaction_id": "0520261012144455yB5RXo1cLcID", "sku_commission_offset_amount_after_tax": null}], "version": 1791816295557, "currency": "IDR", "order_id": "QRIS-0520261012144455yB5RXo1cLcID", "qris_on_us": false, "merchant_id": "G490563346", "channel_type": "STATIC_QR", "gross_amount": 100000, "payment_type": "QRIS", "service_type": "QRIS", "promo_details": {"promo_code": "", "promo_original_amount": 0}, "settlement_time": "2026-10-12T21:44:55.580059+07:00", "transaction_time": "2026-10-12T21:44:55+07:00", "real_gross_amount": 100000, "transaction_source": "GOPAY_INSTORE", "transaction_status": "SETTLEMENT", "transaction_history": [{"id": "01a13092-e49c-70e6-8d19-7f8535d4c70a", "amount": 100000, "action_name": "Settlement Transaction", "action_time": "2026-10-12T21:44:55.580059+07:00", "action_user": "", "action_status": "SETTLEMENT"}], "qris_provider_aspi_issuer": "DANA", "wallstreet_transaction_id": "0520261012144455yB5RXo1cLcID", "merchant_cross_reference_id": "70087b5d-4647-4a0f-9b86-e74e51c15804", "qris_provider_aspi_acquirer": "gopay", "qris_provider_retrieval_reference_number": "021333022977"}, "time": "12 Oct 2026 - 21:44:55", "amount": 1000, "paidAt": "2026-10-12T14:44:55.000Z", "gobizId": "01a13092-e258-7000-8d19-7f8535d4c70a"}	2026-10-12T14:45:08.681Z
01a13094-41e8-7000-a7ef-220b35df9d87	3755	12 Oct 2026 - 21:46:25	TRX-UPJ69JY4QDXK	{"raw": {"id": "01a13094-41e8-7000-a7ef-220b35df9d87", "shares": [{"id": "01a13094-4573-7000-a7ef-220b35df9d87", "vat": 0, "wht": 0, "gojek_share": 0, "merchant_id": "G490563346", "gross_amount": 375500, "payment_type": "qris", "refund_amount": 0, "merchant_share": 375500, "provider_share": 0, "voucher_amount": 0, "settlement_time": "2026-10-12T21:46:25.907+07:00", "is_refund_action": false, "transaction_time": "2026-10-12T21:46:25+07:00", "merchant_fixed_fee": 0, "platform_total_fee": 0, "voucher_commission": 0, "gross_amount_regular": 375500, "merchant_percentage_fee": 0.003, "wallstreet_transaction_id": "0520261012144625z9qAEvKWKyID", "sku_commission_offset_amount_after_tax": null}], "version": 1791816385907, "currency": "IDR", "order_id": "QRIS-0520261012144625z9qAEvKWKyID", "qris_on_us": false, "merchant_id": "G490563346", "channel_type": "STATIC_QR", "gross_amount": 375500, "payment_type": "QRIS", "service_type": "QRIS", "promo_details": {"promo_code": "", "promo_original_amount": 0}, "settlement_time": "2026-10-12T21:46:25.941297+07:00", "transaction_time": "2026-10-12T21:46:25+07:00", "real_gross_amount": 375500, "transaction_source": "GOPAY_INSTORE", "transaction_status": "SETTLEMENT", "transaction_history": [{"id": "01a13094-4595-7488-a7ef-220b35df9d87", "amount": 375500, "action_name": "Settlement Transaction", "action_time": "2026-10-12T21:46:25.941297+07:00", "action_user": "", "action_status": "SETTLEMENT"}], "qris_provider_aspi_issuer": "DANA", "wallstreet_transaction_id": "0520261012144625z9qAEvKWKyID", "merchant_cross_reference_id": "70087b5d-4647-4a0f-9b86-e74e51c15804", "qris_provider_aspi_acquirer": "gopay", "qris_provider_retrieval_reference_number": "1t54lmr14634"}, "time": "12 Oct 2026 - 21:46:25", "amount": 3755, "paidAt": "2026-10-12T14:46:25.000Z", "gobizId": "01a13094-41e8-7000-a7ef-220b35df9d87"}	2026-10-12T14:47:04.128Z
01a1352d-0fa0-7000-8fe5-d6fc733bc5fd	12500	13 Oct 2026 - 19:11:48	\N	{"raw": {"id": "01a1352d-0fa0-7000-8fe5-d6fc733bc5fd", "shares": [{"id": "01a1352d-10fd-7000-8fe5-d6fc733bc5fd", "vat": 0, "wht": 0, "gojek_share": 0, "merchant_id": "G490563346", "gross_amount": 1250000, "payment_type": "qris", "refund_amount": 0, "merchant_share": 1250000, "provider_share": 0, "voucher_amount": 0, "settlement_time": "2026-10-13T19:11:48.349+07:00", "is_refund_action": false, "transaction_time": "2026-10-13T19:11:48+07:00", "merchant_fixed_fee": 0, "platform_total_fee": 0, "voucher_commission": 0, "gross_amount_regular": 1250000, "merchant_percentage_fee": 0.003, "wallstreet_transaction_id": "0320261013121148ltmxZnT24OID", "sku_commission_offset_amount_after_tax": null}], "version": 1791893508349, "currency": "IDR", "order_id": "QRIS-0320261013121148ltmxZnT24OID", "qris_on_us": false, "merchant_id": "G490563346", "channel_type": "STATIC_QR", "gross_amount": 1250000, "payment_type": "QRIS", "service_type": "QRIS", "promo_details": {"promo_code": "", "promo_original_amount": 0}, "settlement_time": "2026-10-13T19:11:48.372365+07:00", "transaction_time": "2026-10-13T19:11:48+07:00", "real_gross_amount": 1250000, "transaction_source": "GOPAY_INSTORE", "transaction_status": "SETTLEMENT", "transaction_history": [{"id": "01a1352d-1114-7591-8fe5-d6fc733bc5fd", "amount": 1250000, "action_name": "Settlement Transaction", "action_time": "2026-10-13T19:11:48.372365+07:00", "action_user": "", "action_status": "SETTLEMENT"}], "qris_provider_aspi_issuer": "DANA", "wallstreet_transaction_id": "0320261013121148ltmxZnT24OID", "merchant_cross_reference_id": "70087b5d-4647-4a0f-9b86-e74e51c15804", "qris_provider_aspi_acquirer": "gopay", "qris_provider_retrieval_reference_number": "021340212877"}, "time": "13 Oct 2026 - 19:11:48", "amount": 12500, "paidAt": "2026-10-13T12:11:48.000Z", "gobizId": "01a1352d-0fa0-7000-8fe5-d6fc733bc5fd"}	2026-10-13T12:30:16.686Z
\.


--
-- Data for Name: meta; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.meta (key, value) FROM stdin;
gobiz.cache	{"token": "eyJhbGciOiJkaXIiLCJjdHkiOiJKV1QiLCJlbmMiOiJBMTI4R0NNIiwidHlwIjoiSldUIiwiemlwIjoiREVGIn0..JrzPmGxXw5YD_Dly.LWKNhMXGPGR1mRdyI65W5MBxB4_vcUR--laNUFMGFRV8mfBpdMI6HktrTFardvinrQA5klx4yYvFTsJxndvyNRz5TTszNBWygfbkqxd6yPG5x7-fN-fRLVY8DwilQt4JPE_L_UVDZb00YyqKuzZU9VTJOmz21YRStWwI4IxjOmz2mREzsd6l7WsD15NyIe9cpHFU3EWuemlDYQjizijWeoXuvIY-a5rB6j1fKy-SDE_kxieeQc10Nvh1qezX2-1xFYzDVGndE3Zq6N0cVajby0WMJdceAAo8GtxbK8l0JiZof_5BXg93uhnA3wWpmt3EQNtwAJLWnUtnd7m40tcM6-kSzrXl2IGDQAvVK2Zh6UcTM93F17Q3jZguTD89GOKkswZVupUPi7P6vZxxJUliZ2pI5g8-hWl66yGowm465p9N3lZCKd-9fcMbKAmBFFdCcGUVCPzJT_Os-Pb-TTWq_8vryqDyOJpweXTL8he8iZMxz81YpIpkI8z1mA-9vJ6Ufz1fnxCF5-0FUFkjGBeZNNm35DSj9onnO2XS6D3IxYcv7YDj26Y5uHtWL2TTlP5J5KN2SinQAxPGtVenyKKncXybKf-zgJg58AS-lrmGU6K0klnhlUKF8wVhj-hNOb2fafWgtJpI01faeH0uTfh_Gyq9A-xUt0QcZoidI1OrKh3fxD3RQWQmDNWb-3pDNMLmcSF_Hm2-O9pnEffddh7GQc4Q75SdiOEn0ZeicWMsH1fGzJTePH5GxtaKSI8B_G7lNu4A3QTy9jVPauDqaLI0uoiVoUK79Cr3lc7UiSscPPMQEJPXIbccdTrItpgg_jxCiXxgWtxyWEzN85At7XgjunlAL2DtWgtP24nSSB2kY7ktbSwqvKtMji3Lg6ltvhya_y_WD837RZnKMAXPhhkk5y32wze-zHpXdts6m7YhBY2Hq3pnSH7huInCoB1D7CZA-cHycFnKMUt_Lnjfb1YIPy3qi-W8UQ603Y2ayz-iCkddcPk66IiE6oSE8hQZfPDCnqBnJk3YPhU6hrOPLuS-dUIOHMYXInbNvD8LBNSEvO_qaKSF5jNziaZUKJrnw7fUih-whtCJ16LMwANz6iA01hK6Cm91afatuZkVeHcVEoNArLGgnBeDK6f0EzRc2zABzPENxkNL8k4Cu9VaiqgWzBVt5uV0Dq4Clnocs5b6nIrSMoqkuMvqFqD-QZ2vDC2d_SKaKktHzqeh2TFeNYjgjcVNKkdrjtPQ9IpHy_uaWFhc76Z2C5tebRkP6ayi3NGELrEYcn2rToSo251XumWri0ubnzZsXNu_G59mgyi2p3hoDopDRlrWzEJ-_mrs4mwG-waLdkJNl7b_lVZQXhegtulqj_0YjRwhiMUxGR1oJp62NNuQ0F-QBljPf_jfvTMgHJxXVgvJcIoi2KZeUn5cgO9sRqvbtHiQKW_cRND3WmqRXxOjn8Gdm0dl8lbRHFxnWOzmfh5KS_vxz8DKYY5NRObfXeNOxScbtR-7rSZaYIKtgiCf-Tr6mOK6bHKze8FtjofX9xtQKyI6ppYe1NiHTSloMM9IgbHEJagSLCNhn792M8HGKAV9eRQOuiKSZMklIxLodjUe2PId7ZSR1H2TjavJ5x6Gfy6YLMclJMMaMKORWoe_ASpTRkjSQe2IEpfvKxeB4h8LuvmOWhcRZ2uoAYByf7M3gElHyEutPALiJVPO8QKCfagg1XsrER2Ye7jKp3ato15cvYu2LzRA8XSfUBxZ79WeZK5JSQYEGeXj0kB6n1XzZoDLecpdOdWqi45mymNzqnj6yQlinIofP3JWURdNQzkVJS_-tr-kyz862cXICJ4O8BZRz2Eg9eRZDwVmM4Qrer2LRtvjUFEUgl1tnfCwxwHEALwHqYOLd4B8GQYNBQyuwUY-SE2_6HtdNCLSgGaIeTW4LAjpL4USMMyxsjtYry6J7Bb-E0vwIEZBymoxhnob4yLhiheVUFADlc--cxCOBeJS9HrG6RBbvU5XMbtXsqP8wfQITWwIhk-mOftpPa2c1FHPfuuqZpMkHbROyu1udsAEkEtPdMiPzSTDrs-viv6LPHBMLYgy_3zi0rSoCdbBWp3VBDqiOEx6w-ojWqdGe9bZVYtJp-rB_j0D_V3y0PPLLuB35dlDFpOGvY3v956lGqlOp7bhpXGLPg.4Kwewd4YyPC1UCiKwSfV2Q", "merchantId": "G490563346", "loginCooldownUntil": null}
session.health	{"ok": true, "reauths": 3, "lastOkAt": "2026-10-15T10:00:32.493Z", "lastError": null, "lastCheckAt": "2026-10-15T10:00:32.493Z", "consecutiveFailures": 0}
poller.lastRunAt	1792058433719
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.notifications (id, "userId", type, title, message, meta, "isRead", "createdAt") FROM stdin;
8adadd51-ceb9-40e7-a516-ebfcd4d8bced	8bc1cd08-2178-414e-8639-5ae9252c53a2	info	Selamat datang di UnoPay	Akun Anda sudah aktif. Mulai terima pembayaran QRIS sekarang.	{"welcome": true}	f	2026-10-14T16:28:42.565Z
89bf4e3b-db5b-4290-bc9b-35b56ce00fbb	8bc1cd08-2178-414e-8639-5ae9252c53a2	payment	Saldo tersedia bertambah	Pembayaran TEST-001 berhasil. Saldo Tersedia +Rp 48.550.	{"fee": 1450, "net": 48550, "gross": 50000, "trxId": "TEST-001"}	f	2026-10-14T17:40:39.316Z
f0314947-606b-473a-adf4-226972e15cc6	8bc1cd08-2178-414e-8639-5ae9252c53a2	payment	Saldo tersedia bertambah	Pembayaran TEST-001 berhasil. Saldo +Rp 48.550.	{"fee": 1450, "net": 48550, "gross": 50000, "trxId": "TEST-001"}	f	2026-10-14T17:40:42.274Z
0bd29ffa-6426-445f-b64e-f3c0510038e5	5fe61dc3-05ca-45e1-994a-eda0d20f87ba	info	Selamat datang di UnoPay	Akun Anda sudah aktif. Mulai terima pembayaran QRIS sekarang.	{"welcome": true}	f	2026-10-15T09:30:39.819Z
28a22f4a-a8db-447c-a375-89884347d987	5fe61dc3-05ca-45e1-994a-eda0d20f87ba	payment	Saldo tersedia bertambah	Pembayaran TRX-GKWMTEZ5HCEA berhasil. Saldo Tersedia +Rp 48.550.	{"fee": 1450, "net": 48550, "gross": 50000, "trxId": "TRX-GKWMTEZ5HCEA"}	f	2026-10-15T10:00:35.032Z
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.sessions (token, "userId", "createdAt", "expiresAt", "ipAddress", "userAgent") FROM stdin;
30118950818992945d8f1d120f99a936d8b4c8b066c220351c77af080cb8e846	8bc1cd08-2178-414e-8639-5ae9252c53a2	2026-10-14T16:28:43.050Z	2026-10-21T16:28:43.050Z	127.0.0.1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36
89b751ff9887f27a844934997846830ceaa04907ba24cdb8c1f5952dde40bd89	8bc1cd08-2178-414e-8639-5ae9252c53a2	2026-10-14T16:28:55.319Z	2026-10-21T16:28:55.319Z	127.0.0.1	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36
209901b8cb36c9335c1ea64b9195d4599529cc26144b03ba03954fd7026358ca	5fe61dc3-05ca-45e1-994a-eda0d20f87ba	2026-10-15T09:30:39.841Z	2026-10-22T09:30:39.841Z	104.28.245.128	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36
9cb120015a025e55fabdbda877a15418d73d33308de6d4a2ac664f3c7ef8882f	5fe61dc3-05ca-45e1-994a-eda0d20f87ba	2026-10-15T09:30:47.815Z	2026-10-22T09:30:47.815Z	104.28.245.128	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.transactions ("trxId", "userId", status, amount, fee, net, "merchantAmount", "feePercent", total, "payAmount", "qrString", "qrImageUrl", "callbackUrl", "callbackSecret", "idempotencyKey", metadata, "createdAt", "expiresAt", "paidAt", entry, "webhookState", "webhookAttempts", "webhookNextAt", "webhookLastError") FROM stdin;
TEST-001	8bc1cd08-2178-414e-8639-5ae9252c53a2	PAID	50000	1450	48550	48550	2.9000000000000004	50000	50000	00020101021226610014COM.GO-JEK.WWW01189360091434905633460210G4905633460303UMI51440014ID.CO.QRIS.WWW0215ID10254274264040303UMI5204899953033605405500005802ID5924MITRABL072827, Digital &6011BANJARMASIN61057012262070703A016304DE6C	\N	\N	\N	\N	{"merchant_reference": "TEST-001"}	2026-10-14T17:40:33.353Z	2026-10-14T18:10:33.353Z	2026-10-14 17:40:38.940113+00	\N	SENT	1	\N	\N
TRX-GKWMTEZ5HCEA	5fe61dc3-05ca-45e1-994a-eda0d20f87ba	PAID	50000	1450	48550	48550	2.9000000000000004	50000	50000	00020101021226610014COM.GO-JEK.WWW01189360091434905633460210G4905633460303UMI51440014ID.CO.QRIS.WWW0215ID10254274264040303UMI5204899953033605405500005802ID5924MITRABL072827, Digital &6011BANJARMASIN61057012262070703A016304DE6C	data:image/png;base64,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	\N	\N	\N	\N	2026-10-15T09:30:56.078Z	2026-10-15T10:00:56.078Z	2026-10-15 10:00:34.94826+00	\N	SENT	1	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.users (id, email, password, name, phone, role, status, balance, "webhookUrl", "webhookSecret", "createdAt", "lastLoginAt", totp_enabled, totp_secret, totp_backup_codes, totp_verified_at, "isAdmin", "adminBalance", merchant_code) FROM stdin;
8bc1cd08-2178-414e-8639-5ae9252c53a2	admin@ronipay.com	$2b$10$6yImuCZVA3l060gqb9XJuepa6GNBqPMneqZkhdQUezhj74J4wmzlO	adm	08385080976	user	active	48550	https://mayor303.icu/ronipay_callback.php	whsec_10ca4e2dea5604329632304ad14266e9543d1d2003e67754	2026-10-14T16:28:41.270Z	2026-10-14T16:28:54.954Z	f	JGRKBHMWGBXB3QBRUH7Q	\N	\N	f	0	MRC-SZ8W77
5fe61dc3-05ca-45e1-994a-eda0d20f87ba	admin@unupay.com	$2b$10$iTGT2scoIsfpvmz/VFyWYuIUnvH.GoI4CQJ53ubUubiZ72zwWl/XC	adminuno	08166166131	user	active	48550	\N	whsec_3f6b0f529e07b094dad465a2c31c390337c0559eba08efd1	2026-10-15T09:30:39.710Z	2026-10-15T09:30:47.663Z	f	\N	\N	\N	f	0	MRC-MFPU7C
\.


--
-- Data for Name: webhook_logs; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.webhook_logs (id, user_id, trx_id, event, url, http_status, latency_ms, status, error, sent_at) FROM stdin;
4e05ae4d-20b6-496f-8583-70253127f812	8bc1cd08-2178-414e-8639-5ae9252c53a2	TRX-TEST-1791997230944	webhook.test	https://mayor303.icu/ronipay_callback.php	200	582	delivered	\N	2026-10-14T17:00:31.538Z
641d19f3-c5cb-46c8-ab77-d1d707795149	8bc1cd08-2178-414e-8639-5ae9252c53a2	TEST-001	payment.paid	https://mayor303.icu/ronipay_callback.php	200	1012	delivered	\N	2026-10-14T17:40:41.659Z
\.


--
-- Data for Name: withdrawals; Type: TABLE DATA; Schema: public; Owner: neondb_owner
--

COPY public.withdrawals (id, "wdrId", "userId", amount, fee, received, bank, account, status, note, "createdAt", "processedAt") FROM stdin;
\.


--
-- Name: admin_sessions admin_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.admin_sessions
    ADD CONSTRAINT admin_sessions_pkey PRIMARY KEY (token);


--
-- Name: api_keys api_keys_key_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_key_key UNIQUE (key);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (key);


--
-- Name: gobiz_history gobiz_history_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gobiz_history
    ADD CONSTRAINT gobiz_history_pkey PRIMARY KEY ("gobizId");


--
-- Name: meta meta_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.meta
    ADD CONSTRAINT meta_pkey PRIMARY KEY (key);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (token);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY ("trxId");


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhook_logs webhook_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.webhook_logs
    ADD CONSTRAINT webhook_logs_pkey PRIMARY KEY (id);


--
-- Name: withdrawals withdrawals_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.withdrawals
    ADD CONSTRAINT withdrawals_pkey PRIMARY KEY (id);


--
-- Name: withdrawals withdrawals_wdrId_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.withdrawals
    ADD CONSTRAINT "withdrawals_wdrId_key" UNIQUE ("wdrId");


--
-- Name: idx_admin_sessions_expires; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_admin_sessions_expires ON public.admin_sessions USING btree ("expiresAt");


--
-- Name: idx_api_keys_user; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_api_keys_user ON public.api_keys USING btree ("userId");


--
-- Name: idx_created; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_created ON public.transactions USING btree ("createdAt" DESC);


--
-- Name: idx_hist_matched; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_hist_matched ON public.gobiz_history USING btree ("matchedTrxId");


--
-- Name: idx_hist_seen; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_hist_seen ON public.gobiz_history USING btree ("seenAt" DESC);


--
-- Name: idx_idempotency; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX idx_idempotency ON public.transactions USING btree ("idempotencyKey") WHERE ("idempotencyKey" IS NOT NULL);


--
-- Name: idx_notif_user; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_notif_user ON public.notifications USING btree ("userId", "createdAt" DESC);


--
-- Name: idx_pay_amount; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_pay_amount ON public.transactions USING btree ("payAmount");


--
-- Name: idx_pending_expiry; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_pending_expiry ON public.transactions USING btree ("expiresAt") WHERE (status = 'PENDING'::text);


--
-- Name: idx_sessions_expires; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_sessions_expires ON public.sessions USING btree ("expiresAt");


--
-- Name: idx_sessions_user; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_sessions_user ON public.sessions USING btree ("userId");


--
-- Name: idx_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_status ON public.transactions USING btree (status);


--
-- Name: idx_users_merchant_code; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX idx_users_merchant_code ON public.users USING btree (merchant_code) WHERE (merchant_code IS NOT NULL);


--
-- Name: idx_webhook_due; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_webhook_due ON public.transactions USING btree ("webhookNextAt") WHERE ("webhookState" = 'PENDING'::text);


--
-- Name: idx_wh_logs_trx; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_wh_logs_trx ON public.webhook_logs USING btree (trx_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: neondb_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict phVWvU5Q3RDK3dLQdWl6MCSxsF2xFPu8ZGNiVOeLKdBoXyhxhJWljShXeQjrutp

