-- 1. How many unique users exist in the logs dataset?
SELECT
  COUNT (DISTINCT id)
FROM health.user_logs;
-- Answer 544

-- for questions 2-8 we created a temporary table
DROP TABLE IF EXISTS user_measure_count;
CREATE TEMP TABLE user_measure_count AS
SELECT
    id,
    COUNT(*) AS measure_count,
    COUNT(DISTINCT measure) as unique_measures
  FROM health.user_logs
  GROUP BY 1; 

-- 2. How many total measurements do we have per user on average?
SELECT
  ROUND(AVG(measure_count),0) average_total_measurement
FROM user_measure_count;
-- Answer 79


-- 3. What about the median number of measurements per user?
SELECT --id,
  CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY id)  AS NUMERIC) AS median_value
FROM user_measure_count
-- Answer 2  ;

-- 4. How many users have 3 or more measurements?
SELECT 
  COUNT(distinct id)
FROM user_measure_count
where measure_count >= 3;
-- Answer 209

-- 5. How many users have 1,000 or more measurements?
SELECT
  count(*) as frequency 
FROM user_measure_count
WHERE measure_count >= 1000;
-- Answer 5

-- 6. Have logged blood glucose measurements?
SELECT
   COUNT (DISTINCT id)
FROM health.user_logs
WHERE measure = 'blood_glucose';
-- Answer 325

-- 7. Have at least 2 types of measurements?
SELECT
  COUNT(*) 
FROM user_measure_count
WHERE  unique_measures >= 2;
-- Answer 204


-- 8. Have all 3 measures - blood glucose, weight and blood pressure?
SELECT
  COUNT(*)
FROM user_measure_count
WHERE unique_measures = 3;
-- Anwer 50

-- 9.  What is the median systolic/diastolic blood pressure values?
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY systolic) AS median_systolic
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diastolic) AS median_diastolic
FROM health.user_logs
WHERE measure = "blood_pressure";
-- Answer 126/79