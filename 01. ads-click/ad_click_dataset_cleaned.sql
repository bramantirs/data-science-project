-- create database

CREATE DATABASE IF NOT EXISTS ads_dataset;
USE ads_dataset;

SELECT *
FROM ad_click_dataset
;

-- check total missing value in rows

SELECT 
	COUNT(*) AS total_rows,
    SUM(id IS NULL OR id = '') AS missing_id,
    SUM(full_name IS NULL OR full_name = '') AS missing_name,
    SUM(age IS NULL OR age = '') AS missing_age,
    SUM(gender IS NULL OR gender = '') AS missing_gender,
    SUM(device_type IS NULL OR device_type = '') AS missing_device,
    SUM(ad_position IS NULL OR ad_position = '') AS missing_ad,
    SUM(browsing_history IS NULL OR browsing_history = '') AS missing_history,
	SUM(time_of_day IS NULL OR time_of_day = '') AS missing_time
FROM ad_click_dataset;

-- 1. Standardize data format with lower and trim

UPDATE ad_click_dataset
SET 
	full_name = LOWER(TRIM(full_name)),
	gender = LOWER(TRIM(gender)),
	device_type = LOWER(TRIM(device_type)),
	ad_position = LOWER(TRIM(ad_position)),
    browsing_history = LOWER(TRIM(browsing_history)),
    time_of_day = LOWER(TRIM(time_of_day));
    
-- 2. Fill the blank values 

-- age per id (imputation by group id)
-- a. create lookup table & index for batch execution

CREATE TEMPORARY TABLE id_age_lookup AS
SELECT 
	id,
	MAX(age) AS filled_age
FROM ad_click_dataset
WHERE NULLIF(age, '') IS NOT NULL
GROUP BY id;

ALTER TABLE id_age_lookup ADD INDEX idx_id (id);
ALTER TABLE ad_click_dataset ADD INDEX idx_id(id);

-- b. Run update per batch with subquery id

UPDATE ad_click_dataset AS a
JOIN id_age_lookup AS B ON a.id = b.id
JOIN (
	SELECT id
    FROM ad_click_dataset
    WHERE NULLIF(age, '') IS NULL
    LIMIT 5000
) AS c ON a.id = c.id
SET a.age = b.filled_age
WHERE NULLIF(a.age, '') IS NULL;

-- fill blank age with global age average
-- calculate global age average

SELECT AVG(CAST(NULLIF(age, '') AS DECIMAL(6,2)))
INTO @avg_age
FROM ad_click_dataset
WHERE NULLIF(age, '') IS NOT NULL;

-- update blank rows with the calculated average

UPDATE ad_click_dataset
SET age = @avg_age
WHERE NULLIF(age, '') IS NULL;

UPDATE ad_click_dataset
SET age = ROUND(age, 0);

-- change data type from text to int for age column

ALTER TABLE ad_click_dataset
MODIFY COLUMN age INT;

-- gender, device_type, ad_position, browsing_history, time_of_day per id
-- a. create lookup table per column

CREATE TEMPORARY TABLE id_lookup AS
SELECT
	id,
    MAX(NULLIF(gender, '')) AS gender_hint,
    MAX(NULLIF(device_type, '')) AS device_hint,
    MAX(NULLIF(ad_position, '')) AS adpos_hint,
    MAX(NULLIF(browsing_history, '')) AS history_hint,
    MAX(NULLIF(time_of_day, '')) AS time_hint
FROM ad_click_dataset
GROUP BY id;

ALTER TABLE id_lookup ADD INDEX idx_id (id);

-- b. update column based on id (per batch)

UPDATE ad_click_dataset AS a
JOIN id_lookup AS b ON a.id = b.id
SET
	a.gender = COALESCE(NULLIF(a.gender, ''), b.gender_hint),
    a.device_type = COALESCE(NULLIF(a.device_type, ''), b.device_hint),
    a.ad_position = COALESCE(NULLIF(a.ad_position, ''), b.adpos_hint),
    a.browsing_history = COALESCE(NULLIF(a.browsing_history, ''), b.history_hint),
    a.time_of_day = COALESCE(NULLIF(a.time_of_day, ''), b.time_hint)
WHERE
	NULLIF(a.gender, '') IS NULL
    OR NULLIF(a.device_type, '') IS NULL
    OR NULLIF(a.ad_position, '') IS NULL
	OR NULLIF(a.browsing_history, '') IS NULL
    OR NULLIF(a.time_of_day, '') IS NULL;
    
-- c. fill the rest of NULL or blank values with global mode per column
-- calculate the mode value per columns

(
	SELECT 'gender' AS col, gender AS val, COUNT(*) AS total
    FROM ad_click_dataset
    WHERE NULLIF(gender, '') IS NOT NULL
    GROUP BY gender
    ORDER BY total DESC
    LIMIT 1
)
UNION ALL
(
	SELECT 'device_type', device_type, COUNT(*)
    FROM ad_click_dataset
    WHERE NULLIF(device_type, '') IS NOT NULL
    GROUP BY device_type
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
UNION ALL
(
	SELECT 'ad_position', ad_position, COUNT(*)
    FROM ad_click_dataset
    WHERE NULLIF(ad_position, '') IS NOT NULL
    GROUP BY ad_position
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
UNION ALL
(
	SELECT 'browsing_history', browsing_history, COUNT(*)
    FROM ad_click_dataset
    WHERE NULLIF(browsing_history, '') IS NOT NULL
    GROUP BY browsing_history
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
UNION ALL
(
	SELECT 'time_of_day', time_of_day, COUNT(*)
    FROM ad_click_dataset
    WHERE NULLIF(time_of_day, '') IS NOT NULL
    GROUP BY time_of_day
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- fill the columns with calculated mode

UPDATE ad_click_dataset
SET
	gender = IF(NULLIF(gender, '') IS NULL, 'female', gender),
    device_type = IF(NULLIF(device_type, '') IS NULL, 'desktop', device_type),
    ad_position = IF(NULLIF(ad_position, '') IS NULL, 'bottom', ad_position),
    browsing_history = IF(NULLIF(browsing_history, '') IS NULL, 'entertaiment', browsing_history),
    time_of_day = IF(NULLIF(time_of_day, '') IS NULL, 'morning', time_of_day);

SELECT * FROM ad_click_dataset ORDER BY id;

-- 3. Check for duplicates 
-- check duplicates 
SELECT id, 
	age, 
    gender, 
    device_type, 
    ad_position, 
    browsing_history, 
    time_of_day,
    click, 
    COUNT(*) AS total
FROM ad_click_dataset
GROUP BY 
	id,
	age,
    gender,
    device_type,
    ad_position,
    browsing_history,
    time_of_day,
    click
HAVING COUNT(*) > 1;

-- create unique column

ALTER TABLE ad_click_dataset 
ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;

-- delete duplicates data

DELETE a FROM ad_click_dataset AS a
JOIN ad_click_dataset AS b
	ON a.id = b.id
    AND a.age = b.age
    AND a.gender = b.gender
    AND a.device_type = a.device_type
    AND a.ad_position = b.ad_position
    AND a.browsing_history = b.browsing_history
    AND a.time_of_day = b.time_of_day
    AND a.click = b.click
    AND a.row_id > b.row_id; -- 6k rows deleted