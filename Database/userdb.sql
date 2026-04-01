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

DROP TYPE IF EXISTS account_role CASCADE;
DROP TYPE IF EXISTS gender_type CASCADE;
DROP TYPE IF EXISTS staff_type CASCADE;

CREATE TYPE account_role AS ENUM (
    'ADMIN',
    'STAFF',
    'CUSTOMER'
);

CREATE TYPE gender_type AS ENUM (
    'MALE',
    'FEMALE',
    'OTHER'
);

CREATE TYPE staff_type AS ENUM (
    'FULLTIME',
    'PARTTIME',
    'INTERN'
);

CREATE TABLE account (
    uuid UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v7(),
	mail VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    birthday DATE NOT NULL,
    gender gender_type NOT NULL DEFAULT 'MALE',
    role account_role NOT NULL DEFAULT 'CUSTOMER',
    avatar VARCHAR(255),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    is_active BOOLEAN NOT NULL,
	mfa_secret VARCHAR(32), -- For 2FA
    mfa_enabled BOOLEAN DEFAULT FALSE
);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_account_updated_at
BEFORE UPDATE ON account
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


CREATE TABLE admin (
    account_uuid UUID PRIMARY KEY,
    permissions JSONB, -- JSONB thay vì TEXT
    CONSTRAINT fk_admin_account FOREIGN KEY (account_uuid) REFERENCES account(uuid) ON DELETE CASCADE
);

CREATE TABLE staff (
    account_uuid UUID PRIMARY KEY,
    type staff_type NOT NULL DEFAULT 'INTERN',
	base_salary NUMERIC(11,2) NOT NULL,
    facility_uuid UUID NOT NULL,
	CONSTRAINT fk_staff_account FOREIGN KEY (account_uuid) REFERENCES account(uuid) ON DELETE CASCADE
);

CREATE TABLE customer (
    account_uuid UUID PRIMARY KEY,
	weight NUMERIC(5,2) NOT NULL,
	height NUMERIC(4,1) NOT NULL,
    expiry_date DATE NOT NULL,
	CONSTRAINT fk_customer_account FOREIGN KEY (account_uuid) REFERENCES account(uuid) ON DELETE CASCADE
);



INSERT INTO account (uuid, mail, password_hash, name, birthday, gender, role, avatar, is_active)
VALUES
('00000000-0000-0000-0000-000000000001','admin@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Admin','1990-01-01','MALE','ADMIN','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('00000000-0000-0000-0000-000000000002','luduahau@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Lư Hiếu Trung','1995-06-15','FEMALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('00000000-0000-0000-0000-000000000003','tuthanh@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Đinh Thanh Tú','1998-03-22','MALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('00000000-0000-0000-0000-000000000004','chuong1305@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Trương Nguyên Chương','2000-08-10','FEMALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('00000000-0000-0000-0000-000000000005','ngvanduc@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Nguyễn Văn Đức','1992-12-05','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('00000000-0000-0000-0000-000000000006','tuankieu@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Kiều Minh Tuấn','1992-12-05','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true);

INSERT INTO admin (account_uuid)
VALUES ('00000000-0000-0000-0000-000000000001');

INSERT INTO staff (account_uuid, type, base_salary, facility_uuid)
VALUES
('00000000-0000-0000-0000-000000000002','FULLTIME',15000000,'019ce53d-422b-7826-6129-038631b76b57'),
('00000000-0000-0000-0000-000000000003','PARTTIME',30000,'019ce53d-422b-7826-6129-038631b76b57'),
('00000000-0000-0000-0000-000000000004','INTERN',19000,'019ce53d-422b-7826-6129-038631b76b57');

INSERT INTO customer (account_uuid, weight, height, expiry_date)
VALUES
('00000000-0000-0000-0000-000000000005', 72.50, 175.5, '2026-06-10'),
('00000000-0000-0000-0000-000000000006', 65.20, 168.0, '2025-08-02');
