CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS vector;

-- UUID v7 generator
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

CREATE TYPE meal_type_enum AS ENUM (
    'breakfast',
    'lunch',
    'dinner'
);

CREATE TYPE fitness_goal_enum AS ENUM (
    'lose_weight',
    'gain_muscle',
    'maintain'
);

CREATE TYPE muscle_group_enum AS ENUM (
    'chest',
    'back',
    'legs',
    'shoulders',
    'arms',
    'core',
    'full_body'
);

CREATE TYPE activity_level_enum AS ENUM (
    'low',
    'medium',
    'high'
);

CREATE TABLE foods (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name TEXT NOT NULL,
    category TEXT,
    calories_100g FLOAT,
    protein_100g FLOAT,
    carbs_100g FLOAT,
    fat_100g FLOAT,
    embedding vector(768)
);

CREATE TABLE usda_food (
    fdc_id INT,
    data_type TEXT,
    description TEXT,
    food_category_id TEXT,
    publication_date DATE
);

CREATE TABLE usda_nutrient (
    id INT,
    name TEXT
);

CREATE TABLE usda_food_nutrient (
	id TEXT,
    fdc_id INT,
    nutrient_id INT,
    amount FLOAT,
    data_points TEXT,
    derivation_id TEXT,
    min TEXT,
    max TEXT,
    median TEXT,
    loq TEXT,
    footnote TEXT,
    min_year_acquired TEXT,
    percent_daily_value TEXT
);

CREATE TABLE usda_food_category (
    id TEXT,
    code TEXT,
    description TEXT
);

-- EXERCISES
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

-- CHAT HISTORY
CREATE TABLE chat_history (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_uuid UUID NOT NULL,
    message TEXT NOT NULL,
    ai_reply TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE meal_days (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_uuid UUID NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_uuid, date)
);

CREATE TABLE meal_items (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    meal_day_uuid UUID NOT NULL,
    meal_type meal_type_enum NOT NULL,
    food_uuid UUID NOT NULL,
    grams FLOAT CHECK (grams > 0),
    CONSTRAINT fk_meal_day FOREIGN KEY (meal_day_uuid) REFERENCES meal_days(uuid) ON DELETE CASCADE,
    CONSTRAINT fk_food FOREIGN KEY (food_uuid) REFERENCES foods(uuid)
);

CREATE TABLE workout_days (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_uuid UUID NOT NULL,
    date DATE NOT NULL,
    focus_muscle muscle_group_enum NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE(user_uuid, date)
);

CREATE TABLE workout_items (
    uuid UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    workout_day_uuid UUID NOT NULL,
    exercise_uuid UUID NOT NULL,
    number_sets INT CHECK (number_sets > 0),
    number_reps INT, 
    duration_minutes INT,
    CONSTRAINT fk_workout_day FOREIGN KEY (workout_day_uuid) REFERENCES workout_days(uuid) ON DELETE CASCADE,
    CONSTRAINT fk_exercise FOREIGN KEY (exercise_uuid)  REFERENCES exercises(uuid)
);

ALTER TABLE workout_items ADD CONSTRAINT chk_workout_type
CHECK (
    number_reps IS NOT NULL OR duration_minutes IS NOT NULL
);



-- IMPORT EXERCISE JSON
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

-- USDA NUTRIENT MAPPING
INSERT INTO usda_nutrient(id, name)
VALUES
(1008, 'calories'),
(1003, 'protein'),
(1004, 'fat'),
(1005, 'carbs');

-- IMPORT USDA DATA
COPY usda_food
FROM 'C:/Users/ADMIN/Desktop/KhoaLuan/Database/FoodData_Central_csv_2025-12-18/food.csv'
DELIMITER ','
CSV HEADER;

COPY usda_food_nutrient
FROM 'C:/Users/ADMIN/Desktop/KhoaLuan/Database/FoodData_Central_csv_2025-12-18/food_nutrient.csv'
DELIMITER ','
CSV HEADER
NULL '\N';

COPY usda_food_category
FROM 'C:/Users/ADMIN/Desktop/KhoaLuan/Database/FoodData_Central_csv_2025-12-18/food_category.csv'
DELIMITER ','
CSV HEADER;

-- BUILD FINAL FOOD TABLE
INSERT INTO foods(name, category, calories_100g, protein_100g, carbs_100g, fat_100g)
SELECT
    f.description,
    fc.description,
    MAX(CASE WHEN fn.nutrient_id = 1008 THEN fn.amount END),
    MAX(CASE WHEN fn.nutrient_id = 1003 THEN fn.amount END),
    MAX(CASE WHEN fn.nutrient_id = 1005 THEN fn.amount END),
    MAX(CASE WHEN fn.nutrient_id = 1004 THEN fn.amount END)
FROM usda_food f
JOIN usda_food_nutrient fn
ON f.fdc_id = fn.fdc_id
LEFT JOIN usda_food_category fc
ON f.food_category_id = fc.id
WHERE f.data_type IN ('foundation_food','sr_legacy')
GROUP BY f.fdc_id, f.description, fc.description
HAVING
    MAX(CASE WHEN fn.nutrient_id = 1008 THEN fn.amount END) IS NOT NULL
LIMIT 10000;


CREATE INDEX idx_food_name ON foods(name);
CREATE INDEX idx_food_embedding ON foods USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_exercise_muscle ON exercises USING GIN(primary_muscles);
CREATE INDEX idx_exercise_embedding ON exercises USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- SELECT
-- SUM(f.calories_100g * mpi.grams / 100) AS calories,
-- SUM(f.protein_100g * mpi.grams / 100) AS protein,
-- SUM(f.carbs_100g * mpi.grams / 100) AS carbs,
-- SUM(f.fat_100g * mpi.grams / 100) AS fat
-- FROM meal_plan_items mpi
-- JOIN foods f
-- ON mpi.food_uuid = f.uuid
-- WHERE mpi.meal_uuid = :mealId;