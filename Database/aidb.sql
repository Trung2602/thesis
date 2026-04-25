CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS vector;

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

CREATE TABLE foods (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
	code int,
    name TEXT NOT NULL,
    category TEXT,
    calories_100g FLOAT,
    embedding vector(768)
);

CREATE TABLE exercises (
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

CREATE TABLE chat_history (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_uuid UUID NOT NULL,
    message TEXT NOT NULL,
    ai_reply TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1. Tạo bảng tạm
CREATE TEMP TABLE IF NOT EXISTS foods_tmp (
    code int,
    category text,
    name text,
    calories_100g float
);

TRUNCATE foods_tmp;
--Import dữ liệu từ file
COPY foods_tmp
FROM 'C:\Users\ADMIN\Desktop\KhoaLuan\Database\foods-db\database_food_csv.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

INSERT INTO foods(code, category, name, calories_100g)
SELECT code, category, name, calories_100g
FROM foods_tmp;

--Xóa bảng tạm
DROP TABLE foods_tmp;

INSERT INTO exercises(
    name,
    force,
    difficulty,
    mechanic,
    equipment,
    primary_muscles,
    secondary_muscles,
    instructions,
    images,
    category
)
SELECT
    value->>'name',
    value->>'force',
    value->>'level',
    value->>'mechanic',
    value->>'equipment',
    ARRAY(SELECT jsonb_array_elements_text(value->'primaryMuscles')),
    ARRAY(SELECT jsonb_array_elements_text(value->'secondaryMuscles')),
    ARRAY(SELECT jsonb_array_elements_text(value->'instructions')),
    ARRAY(SELECT jsonb_array_elements_text(value->'images')),
    value->>'category'
FROM jsonb_array_elements(
    pg_read_file('C:/Users/ADMIN/Desktop/KhoaLuan/Database/exercise-db/dist/exercises.json')::jsonb
);

CREATE INDEX idx_food_name ON foods(name);
CREATE INDEX idx_food_embedding ON foods USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_exercise_muscle ON exercises USING GIN(primary_muscles);
CREATE INDEX idx_exercise_embedding ON exercises USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);