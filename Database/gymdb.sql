CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS uuid
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

CREATE TABLE facility (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(100) UNIQUE NOT NULL,
    address VARCHAR(255) NOT NULL
);

CREATE TABLE staff_day_off (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date_off DATE NOT NULL,
    staff_uuid UUID NOT NULL
);

CREATE TABLE shift (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(50) NOT NULL,
    checkin TIME NOT NULL,
    checkout TIME NOT NULL,
    duration NUMERIC(4,2)
);

CREATE TABLE staff_schedule (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date DATE NOT NULL,
    shift_uuid UUID NOT NULL,
    staff_uuid UUID NOT NULL
);

CREATE TABLE salary (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date DATE NOT NULL,
    duration NUMERIC(5,2),
    day_off INTEGER,
    price NUMERIC(12,2),
    staff_uuid UUID NOT NULL
);

CREATE TABLE plan (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(100),
    price INTEGER NOT NULL,
    duration_days INTEGER NOT NULL,
    description TEXT
);

DROP TYPE IF EXISTS status_type CASCADE;

CREATE TYPE status_type AS ENUM (
    'PENDING',
    'SUCCESS',
    'FAILED'
);

CREATE TABLE pay_customer (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date DATE NOT NULL,
    plan_uuid UUID NOT NULL,
    customer_uuid UUID NOT NULL,
    txn_ref VARCHAR(50),
    bank_code VARCHAR(20),
    status status_type DEFAULT 'PENDING'
);

CREATE TABLE customer_schedule (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date DATE NOT NULL,
    checkin TIME NOT NULL,
    checkout TIME NOT NULL,
    facility_uuid UUID NOT NULL,
    staff_uuid UUID NOT NULL,
    customer_uuid UUID NOT NULL
);




INSERT INTO facility (name, address) VALUES
('Cơ sở XH', '97 Võ Văn Tần, P. Xuân Hòa, TP. Hồ Chí Minh'),
('Cơ sở COL', '35-37 Hồ Hảo Hớn, P. Cầu Ông Lãnh, TP. Hồ Chí Minh'),
('Cơ sở HP', 'Khu dân cư Nhơn Đức, xã Hiệp Phước, TP. Hồ Chí Minh'),
('Cơ sở TD', '02 Mai Thị Lựu, P. Tân Định, TP. Hồ Chí Minh');

INSERT INTO shift (name, checkin, checkout, duration) VALUES
('Làm hành chính','05:00:00','21:00:00',16),
('Ca sáng','05:00:00','13:00:00',8),
('Ca chiều','13:00:00','21:00:00',8),
('Ca tối','21:00:00','05:00:00',8),
('Ca gãy sáng','05:00:00','09:00:00',4),
('Ca gãy trưa','09:00:00','13:00:00',4),
('Ca gãy chiều','13:00:00','17:00:00',4),
('Ca gãy tối','17:00:00','21:00:00',4);

INSERT INTO plan (name, price, duration_days, description) VALUES
('Gói sinh viên',269000,30,'Điều kiện và học sinh và sinh viên dưới 22 tuổi'),
('Gói tháng',299000,30,'Gói tập 1 tháng, không giới hạn lượt tập'),
('Gói 3 tháng',829000,91,'Gói tập 3 tháng, tặng 1 lần xông hơi'),
('Gói 6 tháng',1499000,186,'Gói tập 6 tháng, tặng 10 lần xông hơi'),
('Gói năm',2399000,365,'Gói tập 1 năm, tặng 30 lần xông hơi');

INSERT INTO staff_day_off (date_off, staff_uuid) VALUES
('2025-06-15','00000000-0000-0000-0000-000000000002'),
('2025-06-22','00000000-0000-0000-0000-000000000002'),
('2025-06-29','00000000-0000-0000-0000-000000000002');

INSERT INTO salary (date, duration, day_off, price, staff_uuid) VALUES
('2025-06-10',160,2,15500000,'00000000-0000-0000-0000-000000000002'),
('2025-07-10',80,0,4800000,'00000000-0000-0000-0000-000000000003'),
('2025-07-10',80,0,988000,'00000000-0000-0000-0000-000000000004'),
('2025-07-10',80,0,14000000,'00000000-0000-0000-0000-000000000002');

INSERT INTO staff_schedule (date, shift_uuid, staff_uuid) VALUES
('2025-08-01',(SELECT uuid FROM shift WHERE name='Ca tối'),'00000000-0000-0000-0000-000000000003'),
('2025-08-01',(SELECT uuid FROM shift WHERE name='Ca gãy chiều'),'00000000-0000-0000-0000-000000000004'),
('2025-08-02',(SELECT uuid FROM shift WHERE name='Ca chiều'),'00000000-0000-0000-0000-000000000003');

INSERT INTO pay_customer
(date, plan_uuid, customer_uuid, txn_ref, bank_code, status)
VALUES
('2025-05-10',
 (SELECT uuid FROM plan WHERE name='Gói sinh viên'),
 '00000000-0000-0000-0000-000000000005',
 '1756871250833','NCB','SUCCESS'),

('2025-06-02',
 (SELECT uuid FROM plan WHERE name='Gói tháng'),
 '00000000-0000-0000-0000-000000000006',
 '1756871010895','NCB','SUCCESS'),

('2025-06-10',
 (SELECT uuid FROM plan WHERE name='Gói năm'),
 '00000000-0000-0000-0000-000000000005',
 '1756992819560','NCB','SUCCESS'),

('2025-07-02',
 (SELECT uuid FROM plan WHERE name='Gói tháng'),
 '00000000-0000-0000-0000-000000000006',
 '-','-','PENDING');

INSERT INTO customer_schedule
(date, checkin, checkout, facility_uuid, staff_uuid, customer_uuid)
VALUES
('2025-08-13','08:00','09:30',
 (SELECT uuid FROM facility WHERE name='Cơ sở XH'),
 '00000000-0000-0000-0000-000000000002',
 '00000000-0000-0000-0000-000000000005'),

('2025-08-14','10:00','11:30',
 (SELECT uuid FROM facility WHERE name='Cơ sở COL'),
 '00000000-0000-0000-0000-000000000002',
 '00000000-0000-0000-0000-000000000006');

