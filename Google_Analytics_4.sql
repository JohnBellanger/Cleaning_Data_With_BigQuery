SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4`
;


-- Phase 1: Duplicate database Facebook_Ads as Backup --

CREATE TABLE `marketing-464513.ECommerce.Google_Analytics_4_copy`
Like `marketing-464513.ECommerce.Google_Analytics_4`;


-- Checking result

SELECT  *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy`;

-- Fill in with data

INSERT `marketing-464513.ECommerce.Google_Analytics_4_copy` 
SELECT *
 FROM `marketing-464513.ECommerce.Google_Analytics_4`;

-- Checking result

SELECT  *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy`;

-- Phase 2: Cleaning Data --
-- Step 1: Identify duplicata

SELECT *,
ROW_NUMBER() OVER(PARTITION BY 'date',session_source_medium, sessions, conversions_ga4, total_revenue, country, city) AS Row_num
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy`;


-- Step 2: Subquery in order to filter Row_num

WITH Duplicata_CTE AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 'date',session_source_medium, sessions, conversions_ga4, total_revenue, country, city) AS Row_num
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy`
)
SELECT *
FROM Duplicata_CTE
WHERE Row_num > 1;

-- Step 3: Example of checking of all duplicata data discovered

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy`
WHERE session_source_medium = 'facebook / cpc' AND city = 'new york'
; 

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy`
WHERE session_source_medium = 'facebook / cpc' AND city = 'New York'
;

-- Step 4 : Create new table in order to delete duplacate data

CREATE TABLE `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`(
`date` STRING,
session_source_medium STRING, 
sessions INT64, 
conversions_ga4 STRING, 
`total_revenue` STRING, 
country STRING, 
city STRING,
Row_num INT64
);


-- Step 5: Fill in the new table and at the same time convert the type of data

INSERT INTO `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 'date',session_source_medium, sessions, conversions_ga4, total_revenue, country, city) AS Row_num
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy`;


-- Step 6: Checking result

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
WHERE Row_num >1
;

-- Step 7: Delete duplicata

DELETE
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
WHERE Row_num >1


-- Step 8: Checking result

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
WHERE session_source_medium = 'facebook / cpc' AND city = 'New York'
;

-- Step 9: Standardization of dates

CREATE OR REPLACE TABLE `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` AS
SELECT
      PARSE_DATE('%Y-%m-%d',date) AS date,
      session_source_medium, 
      sessions, 
      conversions_ga4, 
      total_revenue, 
      country, 
      city
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
WHERE SAFE.PARSE_DATE('%Y-%m-%d',date) IS NOT NULL

UNION ALL

SELECT
      PARSE_DATE('%d/%m-%Y',date) AS date,
      session_source_medium, 
      sessions, 
      conversions_ga4, 
      total_revenue, 
      country, 
      city
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
WHERE SAFE.PARSE_DATE('%d/%m-%Y',date) IS NOT NULL AND SAFE.PARSE_DATE('%Y-%m-%d',date) IS NULL
;


-- Step 10: Checking result

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
;

-- Step 11: Standardization of names with one query

-- I'm looking for distinct name  and data type before changing

SELECT distinct(session_source_medium) -- Ok
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` 
;
SELECT sessions -- Int64 OK
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` 
;
SELECT conversions_ga4 -- Int64 OK
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` 
;
SELECT total_revenue -- Float64 OK
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` 
;

SELECT distinct(country) -- Ok
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` 
;

SELECT distinct(city) -- Ok
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` 
;

-- I convert what I found

CREATE OR REPLACE TABLE `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup` AS
SELECT
  date,

  CASE
    WHEN LOWER(session_source_medium) IN ('(direct) / (none)', 'direct') THEN 'Direct'
    WHEN LOWER(session_source_medium) = 'email / newsletter' THEN 'Email / Newsletter'
    WHEN LOWER(session_source_medium) = 'facebook / cpc' THEN 'Facebook / CPC'
    WHEN LOWER(session_source_medium) IN ('google / cpc','google / organic') THEN 'Google / Organic'
    ELSE session_source_medium
END AS session_source_medium,

  CAST(sessions AS Int64) AS sessions,

  SAFE_CAST(conversions_ga4 AS Int64) AS conversions_ga4,

  SAFE_CAST(total_revenue AS FLOAT64) AS total_revenue,

  CASE
    WHEN UPPER(country) IN ('FRANCE', 'FR') THEN 'France'
    WHEN UPPER(country) IN ('US','USA','usa') THEN 'United States'
    WHEN UPPER(country) = 'CANADA' THEN 'Canada'
    ELSE country
END AS country,

  INITCAP(TRIM(city)) AS city
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`;

-- Step 12: Checking result

SELECT *
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`;

-- Step 13: Fill In the NULL/Blank

-- Found where are the NULL / Blank
SELECT * -- Nothing
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`
WHERE 'date' IS NULL OR 'date' = '';

SELECT * -- Nothing
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`
WHERE session_source_medium IS NULL OR session_source_medium = '';

SELECT * -- Nothing
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`
WHERE sessions IS NULL;

SELECT * -- NULL
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`
WHERE conversions_ga4 IS NULL ;

SELECT * -- NULL
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`
WHERE total_revenue IS NULL ;

SELECT * -- Nothing
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`
WHERE country IS NULL OR country = '';

SELECT * -- NULL
FROM `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup`
WHERE city IS NULL OR city = '';

-- Fill in the NULL / Blank

CREATE OR REPLACE TABLE `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` AS
SELECT
      date,
      session_source_medium, 
      sessions, 
      Coalesce(conversions_ga4,0) AS conversions_ga4, 
      Coalesce(total_revenue, 0.0) AS total_revenue,
      country, 
      Coalesce(city,'Unknown') AS city
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
;

-- Step 14: Checking result

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
;

-- Step 15: No need to delete rows or colulmn because evrything is usefull

CREATE OR REPLACE TABLE `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup` AS
SELECT
  date,
  session_source_medium,
  sessions,
  conversions_ga4,
  total_revenue,
  country,
  city
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
;

-- Step 16: Checking result

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
;

-- Phase 3: Validation of data in order to remove any mistakes --
-- Step 1: Validation (Dimension) : session_source_medium

SELECT session_source_medium, COUNT(*) AS count_session_source_medium
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
GROUP BY session_source_medium
ORDER BY count_session_source_medium DESC;

-- Step 2:Validation (Dimension) : country

SELECT country, COUNT(*) AS count_country
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
GROUP BY country
ORDER BY count_country DESC;

-- Step 3: Validation (Dimension) : city

SELECT city, COUNT(*) AS count_city
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
GROUP BY city
ORDER BY count_city DESC;

-- Step 4: Validation of metric

SELECT
  COUNTIF(sessions < 0) AS negative_sessions_count,
  COUNTIF(conversions_ga4 < 0) AS negative_conversions_ga4_count,
  COUNTIF(total_revenue < 0) AS negative_total_revenue_count,
  COUNTIF(sessions < conversions_ga4) AS sessions_less_than_conversions_count
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`;

-- Phase 4: Agregation of data in order to have insight --
-- Step 1: Agregation by month and 'Facebook / CPC'
SELECT
  FORMAT_DATE('%Y-%m', date) AS month,
  SUM(sessions) AS total_sessions_facebook_ga4,
  SUM(conversions_ga4) AS total_conversions_ga4_facebook,
  SUM(total_revenue) AS total_revenue_ga4_facebook
FROM`marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
WHERE session_source_medium = 'Facebook / CPC'
GROUP BY month
ORDER BY month;

-- Step 2: Agregation by channels

SELECT
  FORMAT_DATE('%Y-%m', date) AS month,
  SUM(sessions) AS total_sessions_ga4_all_channels,
  SUM(conversions_ga4) AS total_conversions_ga4_all_channels,
  SUM(total_revenue) AS total_revenue_ga4_all_channels
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
GROUP BY month
ORDER BY month;

-- Phase 5 Debugging agregations in order to make sure there's no mistakes --
-- All The checks are compared with the cleaned data.
-- Step 1: The debugging for the number of row after cleaning

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT date) AS unique_dates,
  COUNT(DISTINCT session_source_medium) AS unique_session_sources,
  COUNT(DISTINCT country) AS unique_countries,
  COUNT(DISTINCT city) AS unique_cities
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`


-- Step 2: The debugging date (Period)

SELECT
  MIN(date) AS min_date,
  MAX(date) AS max_date
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`;

-- Step 3:The debugging Amount

SELECT
  MIN(sessions) AS min_sessions,
  MAX(sessions) AS max_sessions,
  AVG(sessions) AS avg_sessions,
  MIN(conversions_ga4) AS min_conversions_ga4,
  MAX(conversions_ga4) AS max_conversions_ga4,
  AVG(conversions_ga4) AS avg_conversions_ga4,
  MIN(total_revenue) AS min_total_revenue,
  MAX(total_revenue) AS max_total_revenue,
  AVG(total_revenue) AS avg_total_revenue
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`;

-- Problem with negative spending (min_conversions_ga4 = 0 + min_total_revenue = -5390.0)

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
WHERE conversions_ga4 < 1;

-- Problem with impressions (Too high: Campaign April-Fools-Joke, country United States, City Miami )

SELECT *
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`
WHERE total_revenue = -5390.0;


-- Step 4: The debugging NULL/Blank

SELECT
  COUNTIF(session_source_medium IS NULL) AS null_session_source_medium_count,
  COUNTIF(sessions IS NULL) AS null_sessions_count,
  COUNTIF(conversions_ga4 IS NULL) AS null_conversions_ga4_count,
  COUNTIF(total_revenue IS NULL) AS null_total_revenue_count,
  COUNTIF(country IS NULL) AS null_country_count,
  COUNTIF(city IS NULL) AS null_city_count
FROM `marketing-464513.ECommerce.Google_Analytics_4_copy_Backup`;


-- Phase 6: Creation of flat table that we'll export next to Google Sheet for analysis --
-- Step 1: Join table


CREATE OR REPLACE TABLE
  `marketing-464513.ECommerce.marketing_flat_table` AS
SELECT
  f.date,
  f.campaign_name,
  f.spend AS facebook_spend,
  f.impressions AS facebook_impressions,
  f.clicks AS facebook_clicks,
  f.conversions_facebook,
  f.country,
  f.city,
  g.session_source_medium,
  g.sessions AS ga4_facebook_sessions,
  g.conversions_ga4 AS ga4_facebook_conversions,
  g.total_revenue AS ga4_facebook_revenue
FROM
  `marketing-464513`.`ECommerce`.`Facebook_Ads_cleaned_backup` AS f
 JOIN
  `marketing-464513`.`ECommerce`.`Google_Analytics_4_copy_Backup` AS g
ON
  f.date = g.date
  AND f.country = g.country
  AND f.city = g.city
  AND g.session_source_medium = 'Facebook / CPC';

-- Step 2: Checking result

SELECT *
FROM `marketing-464513.ECommerce.marketing_flat_table`
;

-- Phase 7: Final Agregation --
-- Agregation 1: Monthly metrics and derivatives from the flat table

SELECT
  FORMAT_DATE('%Y-%m', date) AS month,
  SUM(facebook_spend) AS total_facebook_spend,
  SUM(facebook_impressions) AS total_facebook_impressions,
  SUM(facebook_clicks) AS total_facebook_clicks,
  SUM(conversions_facebook) AS total_conversions_facebook_reported, -- Conversions reported by Facebook
  SUM(ga4_facebook_sessions) AS total_ga4_facebook_sessions,
  SUM(ga4_facebook_conversions) AS total_ga4_facebook_conversions, -- Conversions attributed to Facebook by GA4
  SUM(ga4_facebook_revenue) AS total_ga4_facebook_revenue,
  -- Derived metrics
  SAFE_DIVIDE(SUM(facebook_spend), SUM(facebook_clicks)) AS cost_per_click_facebook,
  SAFE_DIVIDE(SUM(facebook_spend), SUM(conversions_facebook)) AS cost_per_conversion_facebook_reported,
  SAFE_DIVIDE(SUM(facebook_spend), SUM(ga4_facebook_conversions)) AS cost_per_conversion_ga4_facebook,
  SAFE_DIVIDE(SUM(ga4_facebook_revenue), SUM(facebook_spend)) AS roas_ga4_facebook
FROM `marketing-464513.ECommerce.marketing_flat_table`
GROUP BY month
ORDER BY month;

-- Aggregation 2: Quarterly metrics and derivatives from the flat table

SELECT
  FORMAT_DATE('%Y-Q%Q', date) AS quarter,
  SUM(facebook_spend) AS total_facebook_spend,
  SUM(facebook_impressions) AS total_facebook_impressions,
  SUM(facebook_clicks) AS total_facebook_clicks,
  SUM(conversions_facebook) AS total_conversions_facebook_reported,
  SUM(ga4_facebook_sessions) AS total_ga4_facebook_sessions,
  SUM(ga4_facebook_conversions) AS total_ga4_facebook_conversions,
  SUM(ga4_facebook_revenue) AS total_ga4_facebook_revenue,
  SAFE_DIVIDE(SUM(facebook_spend), SUM(facebook_clicks)) AS cost_per_click_facebook,
  SAFE_DIVIDE(SUM(facebook_spend), SUM(conversions_facebook)) AS cost_per_conversion_facebook_reported,
  SAFE_DIVIDE(SUM(facebook_spend), SUM(ga4_facebook_conversions)) AS cost_per_conversion_ga4_facebook,
  SAFE_DIVIDE(SUM(ga4_facebook_revenue), SUM(facebook_spend)) AS roas_ga4_facebook
FROM `marketing-464513.ECommerce.marketing_flat_table`
GROUP BY quarter
ORDER BY quarter;

-- Phase 8: Final Debugging --
-- All The checks are compared with the cleaned data.
-- Debugging 1: Total number of rows and date range of the flat table

SELECT
  COUNT(*) AS total_rows_flat_table,
  MIN(date) AS min_date_flat_table,
  MAX(date) AS max_date_flat_table
FROM `marketing-464513.ECommerce.marketing_flat_table`;

-- Debugging 2: Checking for NULL values in critical columns of the flat table

SELECT
  COUNTIF(facebook_spend IS NULL) AS null_facebook_spend,
  COUNTIF(facebook_impressions IS NULL) AS null_facebook_impressions,
  COUNTIF(facebook_clicks IS NULL) AS null_facebook_clicks,
  COUNTIF(conversions_facebook IS NULL) AS null_conversions_facebook,

  COUNTIF(ga4_facebook_sessions IS NULL) AS null_ga4_facebook_sessions,
  COUNTIF(ga4_facebook_conversions IS NULL) AS null_ga4_facebook_conversions,
  COUNTIF(ga4_facebook_revenue IS NULL) AS null_ga4_facebook_revenue,
  COUNTIF(campaign_name IS NULL) AS null_campaign_name,
  COUNTIF(country IS NULL) AS null_country,
  COUNTIF(city IS NULL) AS null_city
FROM `marketing-464513.ECommerce.marketing_flat_table`;

-- Debugging 3: Checking for extreme or inconsistent values for key metrics

SELECT
  MIN(facebook_spend) AS min_facebook_spend,
  MAX(facebook_spend) AS max_facebook_spend,
  MIN(facebook_impressions) AS min_facebook_impressions,
  MAX(facebook_impressions) AS max_facebook_impressions,
  MIN(facebook_clicks) AS min_facebook_clicks,
  MAX(facebook_clicks) AS max_facebook_clicks,
  MIN(conversions_facebook) AS min_conversions_facebook,
  MAX(conversions_facebook) AS max_conversions_facebook,
  
  MIN(ga4_facebook_sessions) AS min_ga4_facebook_sessions,
  MAX(ga4_facebook_sessions) AS max_ga4_facebook_sessions,
  MIN(ga4_facebook_conversions) AS min_ga4_facebook_conversions,
  MAX(ga4_facebook_conversions) AS max_ga4_facebook_conversions,
  MIN(ga4_facebook_revenue) AS min_ga4_facebook_revenue,
  MAX(ga4_facebook_revenue) AS max_ga4_facebook_revenue
FROM `marketing-464513.ECommerce.marketing_flat_table`;

-- Phase 9: Export flat table to Google Sheet for Analysis and Visualization--

SELECT *
FROM `marketing-464513.ECommerce.marketing_flat_table`;























