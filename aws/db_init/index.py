import psycopg2
import os
import json
import urllib3

http = urllib3.PoolManager()

SUCCESS = "SUCCESS"
FAILED = "FAILED"

AIDB_SCHEMA = """
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS vector;

CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE ts bigint; hex text;
BEGIN
    ts := floor(extract(epoch from clock_timestamp()) * 1000);
    hex := lpad(to_hex(ts),12,'0') || encode(gen_random_bytes(10),'hex');
    RETURN (substr(hex,1,8)||'-'||substr(hex,9,4)||'-'||'7'||substr(hex,14,3)||'-'||substr(hex,17,4)||'-'||substr(hex,21,12))::uuid;
END; $$;

CREATE TABLE IF NOT EXISTS foods (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    code int,
    name TEXT NOT NULL,
    category TEXT,
    calories_100g FLOAT,
    embedding vector(768)
);

CREATE TABLE IF NOT EXISTS exercises (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name TEXT NOT NULL,
    force TEXT,
    difficulty TEXT,
    mechanic TEXT,
    equipment TEXT,
    primary_muscles TEXT[] NOT NULL,
    secondary_muscles TEXT[],
    instructions TEXT[],
    images TEXT[],
    category TEXT,
    embedding vector(768)
);

CREATE TABLE IF NOT EXISTS chat_history (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_uuid UUID NOT NULL,
    message TEXT NOT NULL,
    ai_reply TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"""

GYMDB_SCHEMA = """
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE ts bigint; hex text;
BEGIN
    ts := floor(extract(epoch from clock_timestamp()) * 1000);
    hex := lpad(to_hex(ts),12,'0') || encode(gen_random_bytes(10),'hex');
    RETURN (substr(hex,1,8)||'-'||substr(hex,9,4)||'-'||'7'||substr(hex,14,3)||'-'||substr(hex,17,4)||'-'||substr(hex,21,12))::uuid;
END; $$;

CREATE TABLE IF NOT EXISTS facility (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(100) UNIQUE NOT NULL,
    address VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS staff_day_off (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date_off DATE NOT NULL,
    staff_uuid UUID NOT NULL
);

CREATE TABLE IF NOT EXISTS shift (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(50) NOT NULL,
    checkin TIME NOT NULL,
    checkout TIME NOT NULL,
    duration NUMERIC(4,2)
);

CREATE TABLE IF NOT EXISTS staff_schedule (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date DATE NOT NULL,
    shift_uuid UUID NOT NULL,
    staff_uuid UUID NOT NULL
);

CREATE TABLE IF NOT EXISTS salary (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date DATE NOT NULL,
    duration NUMERIC(5,2),
    day_off INTEGER,
    price NUMERIC(12,2),
    staff_uuid UUID NOT NULL
);

CREATE TABLE IF NOT EXISTS plan (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name VARCHAR(100),
    price INTEGER NOT NULL,
    duration_days INTEGER NOT NULL,
    description TEXT
);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_type') THEN
        CREATE TYPE status_type AS ENUM ('PENDING', 'SUCCESS', 'FAILED');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS pay_customer (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date DATE NOT NULL,
    plan_uuid UUID NOT NULL,
    customer_uuid UUID NOT NULL,
    txn_ref VARCHAR(50),
    bank_code VARCHAR(20),
    status status_type DEFAULT 'PENDING'
);

CREATE TABLE IF NOT EXISTS customer_schedule (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    date DATE NOT NULL,
    checkin TIME NOT NULL,
    checkout TIME NOT NULL,
    facility_uuid UUID NOT NULL,
    staff_uuid UUID NOT NULL,
    customer_uuid UUID NOT NULL
);
"""

USERDB_SCHEMA = """
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE ts bigint; hex text;
BEGIN
    ts := floor(extract(epoch from clock_timestamp()) * 1000);
    hex := lpad(to_hex(ts),12,'0') || encode(gen_random_bytes(10),'hex');
    RETURN (substr(hex,1,8)||'-'||substr(hex,9,4)||'-'||'7'||substr(hex,14,3)||'-'||substr(hex,17,4)||'-'||substr(hex,21,12))::uuid;
END; $$;

CREATE TABLE IF NOT EXISTS account (
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

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'update_account_updated_at'
    ) THEN
        CREATE TRIGGER update_account_updated_at
        BEFORE UPDATE ON account
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS admin (
    account_uuid UUID PRIMARY KEY,
    permissions TEXT,
    CONSTRAINT fk_admin_account FOREIGN KEY (account_uuid) REFERENCES account(uuid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS staff (
    account_uuid UUID PRIMARY KEY,
    type VARCHAR(10) NOT NULL DEFAULT 'INTERN',
    base_salary NUMERIC(11,2) NOT NULL,
    facility_uuid UUID NOT NULL,
    CONSTRAINT fk_staff_account FOREIGN KEY (account_uuid) REFERENCES account(uuid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer (
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
"""

# Map database name -> schema SQL
DB_SCHEMAS = {
    "gymdb": GYMDB_SCHEMA,
    "userdb": USERDB_SCHEMA,
    "aidb": AIDB_SCHEMA,
}


def send(event, context, status, data):
    response_body = {
        "Status": status,
        "Reason": f"See details in CloudWatch Log Stream: {context.log_stream_name}",
        "PhysicalResourceId": context.log_stream_name,
        "StackId": event["StackId"],
        "RequestId": event["RequestId"],
        "LogicalResourceId": event["LogicalResourceId"],
        "Data": data
    }

    encoded_body = json.dumps(response_body).encode("utf-8")

    http.request(
        "PUT",
        event["ResponseURL"],
        body=encoded_body,
        headers={"content-type": ""}
    )


def run_schema(host, port, username, password, dbname, schema_sql):
    """Connect to a specific database and execute its schema."""
    conn = psycopg2.connect(
        host=host,
        port=port,
        user=username,
        password=password,
        dbname=dbname,
        connect_timeout=10
    )
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute(schema_sql)
    cur.close()
    conn.close()
    print(f"Schema applied to '{dbname}' successfully.")


def handler(event, context):
    print(f"RequestType: {event['RequestType']}")

    if event['RequestType'] == 'Delete':
        send(event, context, SUCCESS, {})
        return

    host = os.environ['DB_HOST']
    port = int(os.environ['DB_PORT'])
    username = os.environ['DB_USERNAME']
    password = os.environ['DB_PASSWORD']

    try:
        # Step 1: Connect to postgres to create databases
        conn = psycopg2.connect(
            host=host,
            port=port,
            user=username,
            password=password,
            dbname='postgres',
            connect_timeout=10
        )
        conn.autocommit = True
        cur = conn.cursor()

        for db in DB_SCHEMAS:
            cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (db,))
            if cur.fetchone():
                print(f"Database '{db}' already exists, skipping creation.")
            else:
                cur.execute(f'CREATE DATABASE "{db}"')
                print(f"Database '{db}' created.")

        cur.close()
        conn.close()

        # Step 2: Apply schema to each database
        for db, schema in DB_SCHEMAS.items():
            run_schema(host, port, username, password, db, schema)

        send(event, context, SUCCESS, {"Message": "All databases and schemas initialized successfully"})

    except Exception as e:
        print(f"ERROR: {str(e)}")
        send(event, context, FAILED, {"Error": str(e)})