CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE ts bigint; hex text;
BEGIN
    ts := floor(extract(epoch from clock_timestamp()) * 1000);
    hex := lpad(to_hex(ts),12,'0') || encode(gen_random_bytes(10),'hex');
    RETURN (substr(hex,1,8)||'-'||substr(hex,9,4)||'-'||'7'||substr(hex,14,3)||'-'||substr(hex,17,4)||'-'||substr(hex,21,12))::uuid;
END; $$;

CREATE TABLE account (
    uuid UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v7(),
    mail VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    birthday DATE NOT NULL,
    gender VARCHAR(10) NOT NULL DEFAULT 'MALE',
    role VARCHAR(10) NOT NULL DEFAULT 'CUSTOMER',
    avatar VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    is_active BOOLEAN NOT NULL,
    mfa_secret VARCHAR(32),
    mfa_enabled BOOLEAN DEFAULT FALSE
);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   IF (NEW.mail, NEW.password_hash, NEW.name, NEW.birthday, NEW.gender, NEW.role, NEW.avatar, NEW.is_active, NEW.mfa_secret, NEW.mfa_enabled)
   IS DISTINCT FROM
      (OLD.mail, OLD.password_hash, OLD.name, OLD.birthday, OLD.gender, OLD.role, OLD.avatar, OLD.is_active, OLD.mfa_secret, OLD.mfa_enabled)
   THEN
      NEW.updated_at = CURRENT_TIMESTAMP;
   END IF;
   RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER update_account_updated_at
BEFORE UPDATE ON account
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE admin (
    account_uuid UUID PRIMARY KEY,
    permissions TEXT,
    CONSTRAINT fk_admin_account FOREIGN KEY (account_uuid) REFERENCES account(uuid) ON DELETE CASCADE
);

CREATE TABLE staff (
    account_uuid UUID PRIMARY KEY,
    type VARCHAR(10) NOT NULL DEFAULT 'INTERN',
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

CREATE TABLE body_log (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    customer_uuid UUID NOT NULL,
    staff_uuid UUID NOT NULL,
    weight NUMERIC(5,2) NOT NULL,
    height NUMERIC(4,1) NOT NULL,
    body_fat_percent NUMERIC(4,1),
    muscle_mass NUMERIC(5,2),
    note TEXT,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_body_log_customer FOREIGN KEY (customer_uuid) REFERENCES customer(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_body_log_staff FOREIGN KEY (staff_uuid) REFERENCES staff(account_uuid) ON DELETE CASCADE
);

CREATE TABLE goal (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    customer_uuid UUID NOT NULL,
    goal_type VARCHAR(20) NOT NULL,
    target_weight NUMERIC(5,2),
    target_body_fat NUMERIC(4,1),
    deadline DATE,
    is_achieved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_goal_customer FOREIGN KEY (customer_uuid) REFERENCES customer(account_uuid) ON DELETE CASCADE
);


INSERT INTO account (uuid, mail, password_hash, name, birthday, gender, role, avatar, is_active) VALUES
('00000000-0000-0000-0000-000000000001','admin@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Admin','1990-01-01','MALE','ADMIN','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('00000000-0000-0000-0000-000000000002','luduahau@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Lư Hiếu Trung','1995-06-15','FEMALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f935-77c2-c2f7-5fa56e43235e','tranthilan10@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Tran Thi Lan','1986-12-28','FEMALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f937-7c02-bd05-60a548b63ac2','phamcongdanh11@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Pham Cong Danh','1984-12-04','MALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f939-7701-12ab-ed8874a3adf8','voquocthang12@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Vo Quoc Thang','1997-08-12','MALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f93b-76f2-3e1a-6445b6a4dc52','trinhvanlong13@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Trinh Van Long','1984-07-05','MALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f93d-721e-c9b4-f1d592b3f1ca','hoangvanphuc14@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Hoang Van Phuc','1991-08-12','MALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f93f-7655-02ab-7761529b62da','nguyenthithanhhuyen15@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Nguyen Thi Thanh Huyen','1984-12-20','FEMALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f942-783b-2e30-9486946b480e','lethihoa16@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Le Thi Hoa','1985-12-02','FEMALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f944-767c-a631-8f42691871ee','ngothanhbinh17@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Ngo Thanh Binh','1993-11-10','MALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f946-74cf-a6f3-d04f4fcd724c','dangthilinh18@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Dang Thi Linh','1997-10-03','FEMALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f948-751a-c1f0-19649e7db26c','maidinhtuan19@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Mai Dinh Tuan','1997-12-30','MALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f94a-7b8a-35f1-835ca671056e','vuthihuong20@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Vu Thi Huong','1990-10-15','FEMALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f94c-7a34-a5d2-0cff5befb3ae','nguyenhuunghia21@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Nguyen Huu Nghia','1993-05-14','MALE','STAFF','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f94e-7121-0f95-c95da2810a8e','lyminhtoan20@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Ly Minh Toan','2007-01-21','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f950-7d7b-eb2e-0236d4d6aadd','phamduchuy21@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Pham Duc Huy','2000-05-09','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f952-75d3-e554-9f8f97b5e213','caothidiem22@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Cao Thi Diem','1988-07-02','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f955-7c8f-1602-112a23acfb2e','tothingan23@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','To Thi Ngan','1986-03-31','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f957-7ee7-0b14-c576712dbfca','duongquockhanh24@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Duong Quoc Khanh','1986-09-01','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f959-71fc-eb4d-9aa20356e13e','nguyenthimai25@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Nguyen Thi Mai','1988-05-27','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f95b-7103-5fbf-632d7525196d','trinhthiphuong26@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Trinh Thi Phuong','1990-07-05','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f95d-7f65-5b1c-c1d4c2c4e862','nguyenminhkhoa27@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Nguyen Minh Khoa','1996-12-22','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f95f-74d0-8c47-6c2559ca2486','vothitrang28@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Vo Thi Trang','2000-07-27','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f961-78c6-5d4c-7cd04b78615d','huynhthanhlam29@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Huynh Thanh Lam','1994-04-23','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f963-7266-914e-9be8a79898ed','ngothikimanh30@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Ngo Thi Kim Anh','1999-04-02','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f965-782c-3504-f609e4a32aa5','hoangthimyduyen31@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Hoang Thi My Duyen','1983-04-02','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f967-75a1-440f-b4534a13976e','dinhthimylinh32@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Dinh Thi My Linh','2003-02-23','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f96a-7240-18d6-60e55269b7cf','buithiyen33@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Bui Thi Yen','2000-02-17','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f96c-741a-5a49-319aca49c6c9','hoangthithu34@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Hoang Thi Thu','2006-11-28','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f96e-744a-ee31-07eb80bddbf6','lengocbao35@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Le Ngoc Bao','1988-05-12','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f970-7a40-87b0-1ee7d00d49bc','tranbaloc36@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Tran Ba Loc','1995-11-24','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f972-730c-0f4f-9215eb94d066','huynhthihong37@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Huynh Thi Hong','1998-11-06','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f974-7a4d-5492-45b04207bf5c','tranthibaonhi38@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Tran Thi Bao Nhi','2004-06-10','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f976-7b17-e691-3aa04186e43f','lythihanh39@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Ly Thi Hanh','1985-04-25','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f978-7b43-27ed-c085e2ac1cb9','dothithao40@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Do Thi Thao','2000-03-08','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f97a-7f37-546a-132750ac3bb6','lethibaochau41@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Le Thi Bao Chau','1977-04-08','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f97d-7a50-a15d-d5c0fb811f02','phanchikien42@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Phan Chi Kien','1987-02-19','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f97f-7fa5-5d34-1b564004f2f3','dangthikieuoanh43@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Dang Thi Kieu Oanh','1980-03-27','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f981-7c59-87af-c4febbe53520','phamthikhanhly44@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Pham Thi Khanh Ly','1982-01-13','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f983-7e1d-bbe1-ead71009292f','lehoangnam45@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Le Hoang Nam','1983-10-20','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f985-7dfd-08d2-9a220fa93157','phamthingoc46@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Pham Thi Ngoc','1985-11-23','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f987-7fab-9ba7-2017fac26ca2','phanthicamtu47@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Phan Thi Cam Tu','2008-05-16','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f989-7cc3-6cf6-3d4aa18866a7','dangquanghung48@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Dang Quang Hung','1993-02-22','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f98b-784c-fc27-9888c718ed78','duongthibich49@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Duong Thi Bich','1987-07-07','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f98d-7a1a-9478-857a44e00591','buitiendat50@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Bui Tien Dat','2001-03-29','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f98f-760d-8924-55a4e1ace8ba','domanhcuong51@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Do Manh Cuong','2008-02-23','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f992-758f-1c88-208a8205787d','tovanhai52@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','To Van Hai','1991-03-20','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f994-71b7-5028-3c7a82275469','caoxuanhung53@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Cao Xuan Hung','1998-03-03','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f996-7ad0-f96f-0e4772251493','dinhgiaphat54@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Dinh Gia Phat','2002-03-29','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f998-78d3-549a-185b6d726eee','tranquocbao55@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Tran Quoc Bao','1984-12-07','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f99a-70ab-4082-ecc09f98bdd4','vuanhtu56@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Vu Anh Tu','1995-05-24','MALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true),
('019e1816-f99c-718f-3d08-13154ecc3d6d','maithiquynh57@gmail.com','$2a$10$Okh2cGnAQ1jAGnUnxhEqluSm.FhhJn6JMMe7hOdGZjz2iaUjcdOMG','Mai Thi Quynh','2006-08-07','FEMALE','CUSTOMER','https://res.cloudinary.com/dxgc9wwrd/image/upload/v1754928114/nzoi1xjxasxfvsut1azv.jpg',true);

INSERT INTO admin (account_uuid, permissions)
VALUES ('00000000-0000-0000-0000-000000000001','ALL');

INSERT INTO staff (account_uuid, type, base_salary, facility_uuid) VALUES
('00000000-0000-0000-0000-000000000002','FULLTIME',15000000,'019e06fa-4953-762d-800c-a5334b0bbae2'),
('019e1816-f935-77c2-c2f7-5fa56e43235e','FULLTIME',20000000,'019e06fa-4953-762d-800c-a5334b0bbae2'),
('019e1816-f937-7c02-bd05-60a548b63ac2','FULLTIME',18000000,'019e06fa-4953-762d-800c-a5334b0bbae2'),
('019e1816-f939-7701-12ab-ed8874a3adf8','FULLTIME',15000000,'019e06fa-4953-762d-800c-a5334b0bbae2'),
('019e1816-f93b-76f2-3e1a-6445b6a4dc52','FULLTIME',12000000,'019e06fa-4c01-7152-2393-46fca5c0ef46'),
('019e1816-f93d-721e-c9b4-f1d592b3f1ca','PARTTIME',70000,'019e06fa-4c01-7152-2393-46fca5c0ef46'),
('019e1816-f93f-7655-02ab-7761529b62da','PARTTIME',60000,'019e06fa-4c01-7152-2393-46fca5c0ef46'),
('019e1816-f942-783b-2e30-9486946b480e','PARTTIME',80000,'019e06fa-4c01-726e-ee92-aec7a393bca2'),
('019e1816-f944-767c-a631-8f42691871ee','PARTTIME',80000,'019e06fa-4c01-726e-ee92-aec7a393bca2'),
('019e1816-f946-74cf-a6f3-d04f4fcd724c','INTERN',30000,'019e06fa-4c01-726e-ee92-aec7a393bca2'),
('019e1816-f948-751a-c1f0-19649e7db26c','INTERN',28000,'019e06fa-4c01-7b15-4242-d7a88a842325'),
('019e1816-f94a-7b8a-35f1-835ca671056e','INTERN',30000,'019e06fa-4c01-7b15-4242-d7a88a842325'),
('019e1816-f94c-7a34-a5d2-0cff5befb3ae','INTERN',25000,'019e06fa-4c01-7b15-4242-d7a88a842325');

INSERT INTO customer (account_uuid, weight, height, expiry_date) VALUES
('019e1816-f94e-7121-0f95-c95da2810a8e',79.16,173.3,'2026-12-03'),
('019e1816-f950-7d7b-eb2e-0236d4d6aadd',82.81,159.9,'2027-07-04'),
('019e1816-f952-75d3-e554-9f8f97b5e213',94.53,174.2,'2028-01-02'),
('019e1816-f955-7c8f-1602-112a23acfb2e',80.81,180.3,'2026-08-07'),
('019e1816-f957-7ee7-0b14-c576712dbfca',86.98,179.2,'2027-07-26'),
('019e1816-f959-71fc-eb4d-9aa20356e13e',52.98,182.4,'2028-01-12'),
('019e1816-f95b-7103-5fbf-632d7525196d',59.57,170.0,'2028-03-30'),
('019e1816-f95d-7f65-5b1c-c1d4c2c4e862',56.43,159.2,'2028-01-06'),
('019e1816-f95f-74d0-8c47-6c2559ca2486',61.82,172.5,'2028-01-29'),
('019e1816-f961-78c6-5d4c-7cd04b78615d',66.29,184.9,'2026-10-30'),
('019e1816-f963-7266-914e-9be8a79898ed',72.21,177.7,'2026-10-01'),
('019e1816-f965-782c-3504-f609e4a32aa5',78.24,178.8,'2027-08-17'),
('019e1816-f967-75a1-440f-b4534a13976e',52.86,166.4,'2027-10-03'),
('019e1816-f96a-7240-18d6-60e55269b7cf',61.31,171.6,'2026-06-22'),
('019e1816-f96c-741a-5a49-319aca49c6c9',82.43,175.5,'2027-12-12'),
('019e1816-f96e-744a-ee31-07eb80bddbf6',84.59,165.2,'2027-04-07'),
('019e1816-f970-7a40-87b0-1ee7d00d49bc',57.12,155.1,'2027-03-07'),
('019e1816-f972-730c-0f4f-9215eb94d066',84.29,170.2,'2026-09-27'),
('019e1816-f974-7a4d-5492-45b04207bf5c',63.43,174.2,'2028-02-24'),
('019e1816-f976-7b17-e691-3aa04186e43f',56.88,177.9,'2027-12-15'),
('019e1816-f978-7b43-27ed-c085e2ac1cb9',91.33,173.0,'2027-10-24'),
('019e1816-f97a-7f37-546a-132750ac3bb6',55.03,165.9,'2027-04-21'),
('019e1816-f97d-7a50-a15d-d5c0fb811f02',52.61,181.3,'2026-08-30'),
('019e1816-f97f-7fa5-5d34-1b564004f2f3',82.94,179.5,'2027-12-08'),
('019e1816-f981-7c59-87af-c4febbe53520',55.78,169.3,'2027-12-25'),
('019e1816-f983-7e1d-bbe1-ead71009292f',61.93,181.2,'2027-08-18'),
('019e1816-f985-7dfd-08d2-9a220fa93157',91.8,177.7,'2027-01-02'),
('019e1816-f987-7fab-9ba7-2017fac26ca2',64.03,184.9,'2028-04-06'),
('019e1816-f989-7cc3-6cf6-3d4aa18866a7',69.71,170.5,'2026-10-12'),
('019e1816-f98b-784c-fc27-9888c718ed78',60.11,165.1,'2028-02-03'),
('019e1816-f98d-7a1a-9478-857a44e00591',60.36,161.6,'2026-08-22'),
('019e1816-f98f-760d-8924-55a4e1ace8ba',78.4,161.9,'2026-07-13'),
('019e1816-f992-758f-1c88-208a8205787d',53.19,162.1,'2028-04-26'),
('019e1816-f994-71b7-5028-3c7a82275469',59.64,159.0,'2028-01-16'),
('019e1816-f996-7ad0-f96f-0e4772251493',71.27,178.5,'2027-08-01'),
('019e1816-f998-78d3-549a-185b6d726eee',54.24,174.8,'2027-06-08'),
('019e1816-f99a-70ab-4082-ecc09f98bdd4',68.5,180.9,'2026-08-05'),
('019e1816-f99c-718f-3d08-13154ecc3d6d',79.41,174.4,'2026-08-12');

INSERT INTO body_log (customer_uuid, staff_uuid, weight, height, body_fat_percent, muscle_mass, note, logged_at) VALUES
('019e1816-f94e-7121-0f95-c95da2810a8e','019e1816-f935-77c2-c2f7-5fa56e43235e',79.16,173.3,24.5,31.20,'Khách mới bắt đầu tập','2026-01-05 08:30:00'),
('019e1816-f950-7d7b-eb2e-0236d4d6aadd','019e1816-f937-7c02-bd05-60a548b63ac2',82.81,159.9,28.1,29.50,'Cần giảm mỡ bụng','2026-01-07 09:00:00'),
('019e1816-f952-75d3-e554-9f8f97b5e213','019e1816-f939-7701-12ab-ed8874a3adf8',94.53,174.2,32.7,36.10,'Theo giáo án cardio','2026-01-10 17:45:00'),
('019e1816-f955-7c8f-1602-112a23acfb2e','019e1816-f93b-76f2-3e1a-6445b6a4dc52',80.81,180.3,21.0,35.80,'Thể trạng ổn định','2026-01-11 18:15:00'),
('019e1816-f957-7ee7-0b14-c576712dbfca','019e1816-f93d-721e-c9b4-f1d592b3f1ca',86.98,179.2,26.2,34.60,'Mục tiêu siết cân','2026-01-13 06:45:00'),
('019e1816-f959-71fc-eb4d-9aa20356e13e','019e1816-f93f-7655-02ab-7761529b62da',52.98,182.4,14.8,25.20,'Khá gầy cần tăng cơ','2026-01-14 10:10:00'),
('019e1816-f95b-7103-5fbf-632d7525196d','019e1816-f942-783b-2e30-9486946b480e',59.57,170.0,18.9,27.40,'Tập strength cơ bản','2026-01-16 15:20:00'),
('019e1816-f95d-7f65-5b1c-c1d4c2c4e862','019e1816-f944-767c-a631-8f42691871ee',56.43,159.2,20.4,24.70,'Theo dõi tiến độ tăng cân','2026-01-18 16:00:00'),
('019e1816-f95f-74d0-8c47-6c2559ca2486','019e1816-f946-74cf-a6f3-d04f4fcd724c',61.82,172.5,19.1,28.00,'Tăng sức bền','2026-01-19 11:00:00'),
('019e1816-f961-78c6-5d4c-7cd04b78615d','019e1816-f948-751a-c1f0-19649e7db26c',66.29,184.9,17.3,31.10,'Form cơ thể tốt','2026-01-20 08:20:00'),
('019e1816-f963-7266-914e-9be8a79898ed','019e1816-f94a-7b8a-35f1-835ca671056e',72.21,177.7,18.2,32.90,'Duy trì thể lực','2026-01-21 14:40:00'),
('019e1816-f965-782c-3504-f609e4a32aa5','019e1816-f94c-7a34-a5d2-0cff5befb3ae',78.24,178.8,25.6,33.50,'Giảm mỡ nhẹ','2026-01-22 19:00:00'),
('019e1816-f967-75a1-440f-b4534a13976e','019e1816-f935-77c2-c2f7-5fa56e43235e',52.86,166.4,21.8,22.90,'Tập yoga kết hợp gym','2026-01-24 07:30:00'),
('019e1816-f96a-7240-18d6-60e55269b7cf','019e1816-f937-7c02-bd05-60a548b63ac2',61.31,171.6,19.5,27.80,'Tiến triển tốt','2026-01-25 13:10:00'),
('019e1816-f96c-741a-5a49-319aca49c6c9','019e1816-f939-7701-12ab-ed8874a3adf8',82.43,175.5,27.0,34.20,'Ưu tiên giảm cân','2026-01-27 18:40:00');

INSERT INTO goal(customer_uuid, goal_type, target_weight, target_body_fat, deadline, is_achieved) VALUES
('019e1816-f94e-7121-0f95-c95da2810a8e','LOSE_WEIGHT',72.00,18.0,'2026-08-01',false),
('019e1816-f950-7d7b-eb2e-0236d4d6aadd','LOSE_WEIGHT',75.00,20.0,'2026-10-15',false),
('019e1816-f952-75d3-e554-9f8f97b5e213','LOSE_WEIGHT',82.00,24.0,'2026-12-20',false),
('019e1816-f955-7c8f-1602-112a23acfb2e','MAINTAIN',80.00,20.0,'2026-09-01',false),
('019e1816-f957-7ee7-0b14-c576712dbfca','GAIN_MUSCLE',90.00,18.0,'2026-11-11',false),
('019e1816-f959-71fc-eb4d-9aa20356e13e','GAIN_MUSCLE',60.00,12.0,'2026-07-01',false),
('019e1816-f95b-7103-5fbf-632d7525196d','GAIN_MUSCLE',66.00,15.0,'2026-08-20',false),
('019e1816-f95d-7f65-5b1c-c1d4c2c4e862','GAIN_MUSCLE',62.00,18.0,'2026-10-01',false),
('019e1816-f95f-74d0-8c47-6c2559ca2486','MAINTAIN',61.00,17.0,'2026-09-10',true),
('019e1816-f961-78c6-5d4c-7cd04b78615d','GAIN_MUSCLE',74.00,14.0,'2026-12-12',false),
('019e1816-f963-7266-914e-9be8a79898ed','MAINTAIN',72.00,16.0,'2026-08-08',true),
('019e1816-f965-782c-3504-f609e4a32aa5','LOSE_WEIGHT',70.00,19.0,'2026-11-30',false),
('019e1816-f967-75a1-440f-b4534a13976e','GAIN_MUSCLE',58.00,17.0,'2026-09-18',false),
('019e1816-f96a-7240-18d6-60e55269b7cf','MAINTAIN',61.00,18.0,'2026-07-25',true),
('019e1816-f96c-741a-5a49-319aca49c6c9','LOSE_WEIGHT',74.00,21.0,'2026-12-01',false);
