-- EDA (Exploratory Data Analysis)

-- 1. Overview of Dataset
-- total rows 

SELECT COUNT(*) AS total_rows
FROM ad_click_dataset;

-- distribution of click (target variable)
-- (1 for click, 0 for no click)

SELECT 
	click, 
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*)
		FROM ad_click_dataset), 2) AS percentage
FROM ad_click_dataset
GROUP BY click;

-- demographics => distribution of (age & gender) 
-- min, max, avg

SELECT
	MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(age), 0) AS avg_age
FROM ad_click_dataset;

SELECT
	gender,
    COUNT(*) AS count
FROM ad_click_dataset
GROUP BY gender;

-- device_type & ad_position
-- device usage

SELECT 
	device_type, 
    COUNT(*) AS count
FROM ad_click_dataset
GROUP BY device_type
ORDER BY count DESC;

-- ad_position frequency

SELECT 
	ad_position,
    COUNT(*) AS count
FROM ad_click_dataset
GROUP BY ad_position
ORDER BY count DESC;

-- browsing behaviour with time of day
-- consumer behaviour

-- browsing history categories

SELECT
	browsing_history,
    COUNT(*) AS count
FROM ad_click_dataset
GROUP BY browsing_history
ORDER BY count DESC;

-- time of day

SELECT 
	time_of_day,
    COUNT(*) AS count
FROM ad_click_dataset
GROUP BY time_of_day
ORDER BY FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening', 'Night');

-- calculate CTR (Click Through Rate) per device

SELECT 
	device_type,
	COUNT(*) AS total,
    SUM(click) AS clicks,
    ROUND(SUM(click) * 100.0 / COUNT(*), 2) AS ctr_percentage
FROM ad_click_dataset
GROUP BY device_type;

-- CTR per ad position

SELECT 
	ad_position,
    COUNT(*) AS total,
    SUM(click) AS clicks,
    ROUND(SUM(click) * 100.0 / COUNT(*), 2) AS ctr_percentage
FROM ad_click_dataset
GROUP BY ad_position;

-- CTR by combination varible
-- calculate active hour user per mobile

SELECT 
	device_type,
    time_of_day,
    COUNT(*) AS total,
    SUM(click) AS clicks,
    ROUND(SUM(click) * 100.0 / COUNT(*), 2) AS ctr_percentage
FROM ad_click_dataset
GROUP BY device_type, time_of_day
ORDER BY device_type, time_of_day;

-- age per click distribution

SELECT 
	click,
    ROUND(AVG(age), 0) AS avg_age,
    MIN(age) AS min_age,
    MAX(age) AS max_age
FROM ad_click_dataset
GROUP BY click;