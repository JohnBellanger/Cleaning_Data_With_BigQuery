SELECT * 
FROM `marketing-464513.Training.Acquisition` 
;

-- Phase 1 : Duplicate table

-- Step 1:  Create new table

CREATE OR REPLACE TABLE `marketing-464513.Training.Acquisition_copy` 
LIKE `marketing-464513.Training.Acquisition`;

SELECT *
FROM `marketing-464513.Training.Acquisition_copy` 
;

-- Step 2: Fill the table

INSERT INTO `marketing-464513.Training.Acquisition_copy` 
SELECT * 
FROM `marketing-464513.Training.Acquisition` ;

-- Step 3: Checking

SELECT *
FROM `marketing-464513.Training.Acquisition_copy` 
;

-- PHASE 2 : Remove duplicata

-- Step 1 : Looking for dupicata

SELECT *, 
ROW_NUMBER() OVER (PARTITION BY raw_date,session_id,traffic_source,traffic_medium,campaign_name,country_geo,device_category,ad_impressions,ad_clicks,'ad_spend') AS Row_num
FROM `marketing-464513.Training.Acquisition_copy` 
;

--Step 2: Subquery

WITH Duplicate_CTE AS (
 SELECT*, 
ROW_NUMBER() OVER (PARTITION BY raw_date,session_id,traffic_source,traffic_medium,campaign_name,country_geo,device_category,ad_impressions,ad_clicks,'ad_spend') AS Row_num
FROM `marketing-464513.Training.Acquisition_copy`  
)

SELECT *
FROM Duplicate_CTE
WHERE Row_num >1
;

-- Step 3: Create table for removing duplicata

CREATE TABLE `marketing-464513.Training.Acquisition_copy_duplicata` (
  raw_date STRING,
  session_id STRING,
  traffic_source STRING,
  traffic_medium STRING,
  campaign_name STRING,
  country_geo STRING,
  device_category STRING,
  ad_impressions STRING,
  ad_clicks STRING,
  ad_spend FLOAT64,
  Row_num INT64
);

-- Step 4: Insert data in the new table

INSERT INTO `marketing-464513.Training.Acquisition_copy_duplicata`
SELECT*, 
ROW_NUMBER() OVER (PARTITION BY raw_date,session_id,traffic_source,traffic_medium,campaign_name,country_geo,device_category,ad_impressions,ad_clicks,'ad_spend') AS Row_num
FROM `marketing-464513.Training.Acquisition_copy`  
;

-- Step 5: Cheking the new table

SELECT *
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 6: Remove duplacata

DELETE
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE Row_num > 1
;

-- Step 7; Checking - OK

SELECT *
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE Row_num > 1
;

-- Step 8 :  Remove column Row_num

ALTER TABLE `marketing-464513.Training.Acquisition_copy_duplicata`
DROP COLUMN Row_num;

-- Step 9 : Checking 

SELECT *
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Phase 3 : Standardization dates

-- Step 1: Find all formate date

 SELECT raw_date
 FROM `marketing-464513.Training.Transaction`
 WHERE NOT REGEXP_CONTAINS(raw_date, r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
 ;

-- Step 2: Modify format date

CREATE OR REPLACE TABLE `marketing-464513.Training.Acquisition_copy_duplicata` AS

SELECT
    COALESCE(
        SAFE.PARSE_DATE('%Y/%m/%d', raw_date),
        SAFE.PARSE_DATE('%Y.%m.%d', raw_date),
        SAFE.PARSE_DATE('%d-%m-%Y', raw_date),
        SAFE.PARSE_DATE('%m-%d-%Y', raw_date),
        SAFE.PARSE_DATE('%Y-%m-%d', raw_date)
    ) AS date,
    session_id,
    traffic_source,
    traffic_medium,
    campaign_name,
    country_geo,
    device_category,
    ad_impressions,
    ad_clicks,
    ad_spend
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
 ;

-- Step 3: Checking missing format date

SELECT date
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE NOT REGEXP_CONTAINS(CAST(date AS STRING), r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
;

-- Phase 4: Standardization Name

-- Step 1: Checking session_id OK

SELECT Distinct(session_id)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 2: Checking traffic_source OK

SELECT*
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

SELECT Distinct(traffic_source)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 3: Checking traffic_medium OK

SELECT Distinct(traffic_medium)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 4: Checking campaign_name OK

SELECT Distinct(campaign_name)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 5: Checking country_geo OK

SELECT Distinct(country_geo)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 6: Checking device_category OK

SELECT Distinct(device_category)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 7: Checking ad_impressions OK

SELECT Distinct(ad_impressions)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 8: Checking ad_clicks OK

SELECT Distinct(ad_clicks)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 9: Checking ad_spend OK

SELECT Distinct(ad_spend)
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 10: Modify

CREATE OR REPLACE TABLE `marketing-464513.Training.Acquisition_copy_duplicata` AS 

      SELECT 
            raw_date AS date,
            session_id,
                  CASE
                        WHEN LOWER (traffic_source) = 'direct' THEN 'Direct'
                        WHEN INITCAP(traffic_source) ='Google' THEN 'Google Ads'
                        WHEN LOWER(traffic_source) = 'google' THEN 'Google Ads'
                        WHEN LOWER(traffic_source) = 'referral' THEN 'Referral'
                        WHEN LOWER(traffic_source) = 'bing' THEN 'Bing'
                        WHEN LOWER(traffic_source) = 'facebook' THEN 'Facebook'
                        WHEN LOWER(traffic_source) = 'meta' THEN ' Meta'
                        WHEN LOWER(traffic_source) = 'klaviyo' THEN 'Klaviyo'
                        WHEN LOWER(traffic_source) = 'email' THEN 'Email'
                        WHEN LOWER(traffic_source) = 'newsletter' THEN 'Email'
                        WHEN LOWER(traffic_source) = 'tiktok' THEN 'TIKTOK'
                        WHEN LOWER(traffic_source) = 'instagram' THEN 'Instagram'
                  ELSE traffic_source
            END AS traffic_source,
                  CASE
                        WHEN LOWER(traffic_medium) = 'cpc' THEN 'CPC'
                        WHEN UPPER(traffic_medium) = 'PAID_SOCIAL' THEN 'Paid_Social'
                        WHEN LOWER(traffic_medium) IN ('paid social','paid_social') THEN 'Paid_Social'
                        WHEN LOWER(traffic_medium) = 'affiliate' THEN 'Affiliate'
                        WHEN LOWER(traffic_medium) = 'email' THEN 'Email'
                        WHEN LOWER(traffic_medium) = 'klaviyo' THEN 'Klaviyo'
                        WHEN LOWER(traffic_medium) = 'organic' THEN 'Organic'
                        WHEN LOWER(traffic_medium) = 'refferal' THEN 'Refferal'
                  ELSE traffic_medium
            END AS traffic_medium,
                  CASE 
                        WHEN LOWER(campaign_name) = 'affiliate_partner_a' THEN 'AFFILIATE_PARTNER'
                        WHEN LOWER(campaign_name) = 'influencer_youtube' THEN 'INFLUENCER_YOUTUBE'
                  ELSE campaign_name
            END AS campaign_name,
                  CASE
                        WHEN UPPER(country_geo) IN ('US','USA') THEN 'United States'
                        WHEN LOWER(country_geo) = 'usa' THEN 'United States'
                        WHEN UPPER(country_geo) = 'CA' THEN 'Canada'
                        WHEN UPPER(country_geo) = 'FR' THEN 'France'
                        WHEN UPPER(country_geo) = 'UK' THEN 'United Kingdom'
                  ELSE country_geo
            END AS country_geo,
                  CASE
                        WHEN LOWER(device_category) = 'mobile' THEN 'Mobile'
                        WHEN UPPER(device_category) = 'MOBILE' THEN 'Mobile'
                        WHEN LOWER(device_category) = 'desktop' THEN 'Desktop'
                        WHEN LOWER(device_category) = 'tablet' THEN 'Tablet'
                        WHEN UPPER(device_category) = 'TABLET' THEN 'Tablet'
                  ELSE device_category
            END AS device_category,
            SAFE_CAST(ad_impressions AS INT64) AS ad_impressions,
            SAFE_CAST(ad_clicks AS INT64) AS ad_clicks,
            ad_spend
      FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;


CREATE OR REPLACE TABLE `marketing-464513.Training.Acquisition_copy_duplicata` AS  -- correction 2

      SELECT 
            date,
            session_id,
                  CASE
                        WHEN LOWER(traffic_source) = 'direct' THEN 'Direct'
                        WHEN INITCAP(traffic_source) ='Google' THEN 'Google Ads'
                        WHEN LOWER(traffic_source) = 'google' THEN 'Google Ads'
                        WHEN LOWER(traffic_source) = 'referral' THEN 'Referral'
                        WHEN LOWER(traffic_source) = 'bing' THEN 'Bing'
                        WHEN LOWER(traffic_source) = 'facebook' THEN 'Facebook'
                        WHEN LOWER(traffic_source) = 'meta' THEN ' Meta'
                        WHEN LOWER(traffic_source) = 'klaviyo' THEN 'Klaviyo'
                        WHEN LOWER(traffic_source) = 'email' THEN 'Email'
                        WHEN LOWER(traffic_source) = 'newsletter' THEN 'Email'
                        WHEN LOWER(traffic_source) = 'tiktok' THEN 'TIKTOK'
                        WHEN LOWER(traffic_source) = 'instagram' THEN 'Instagram'
                  ELSE traffic_source
            END AS traffic_source,
                  CASE
                        WHEN LOWER(traffic_source) = 'cpc' THEN 'CPC'
                        WHEN UPPER(traffic_source) = 'PAID_SOCIAL' THEN 'Paid_Social'
                        WHEN LOWER(traffic_source) IN ('paid social','paid_social') THEN 'Paid_Social'
                        WHEN LOWER(traffic_source) = 'affiliate' THEN 'Affiliate'
                        WHEN LOWER(traffic_source) = 'email' THEN 'Email'
                        WHEN LOWER(traffic_source) = 'klaviyo' THEN 'Klaviyo'
                        WHEN LOWER(traffic_source) = 'organic' THEN 'Organic'
                        WHEN LOWER(traffic_source) = 'refferal' THEN 'Refferal'
                        WHEN LOWER(traffic_source) = '(none)' THEN 'Direct'
                  ELSE traffic_medium
            END AS traffic_medium,
                  CASE 
                        WHEN LOWER(traffic_source) = 'affiliate_partner_a' THEN 'AFFILIATE_PARTNER'
                        WHEN LOWER(traffic_source) = 'influencer_youtube' THEN 'INFLUENCER_YOUTUBE'
                  ELSE campaign_name
            END AS campaign_name,
                  CASE
                        WHEN UPPER(traffic_source) IN ('US','USA') THEN 'United States'
                        WHEN LOWER(traffic_source) = 'usa' THEN 'United States'
                        WHEN UPPER(traffic_source) = 'CA' THEN 'Canada'
                        WHEN UPPER(traffic_source) = 'FR' THEN 'France'
                        WHEN UPPER(traffic_source) = 'UK' THEN 'United Kingdom'
                  ELSE country_geo
            END AS country_geo,
                  CASE
                        WHEN LOWER(traffic_source) = 'mobile' THEN 'Mobile'
                        WHEN UPPER(traffic_source) = 'MOBILE' THEN 'Mobile'
                        WHEN LOWER(traffic_source) = 'desktop' THEN 'Desktop'
                        WHEN LOWER(traffic_source) = 'tablet' THEN 'Tablet'
                        WHEN UPPER(traffic_source) = 'TABLET' THEN 'Tablet'
                  ELSE device_category
            END AS device_category,
            SAFE_CAST(ad_impressions AS INT64) AS ad_impressions,
            SAFE_CAST(ad_clicks AS INT64) AS ad_clicks,
            ad_spend
      FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

CREATE OR REPLACE TABLE `marketing-464513.Training.Acquisition_copy_duplicata` AS  -- Correction after debeug

      SELECT 
            date,
            session_id,
                  CASE
                        WHEN LOWER(TRIM(traffic_source)) = 'direct' THEN 'Direct'
                        WHEN INITCAP(TRIM(traffic_source)) ='Google' THEN 'Google Ads'
                        WHEN LOWER(TRIM(traffic_source)) = 'google' THEN 'Google Ads'
                        WHEN LOWER(TRIM(traffic_source)) = 'referral' THEN 'Referral'
                        WHEN LOWER(TRIM(traffic_source)) = 'bing' THEN 'Bing'
                        WHEN LOWER(TRIM(traffic_source)) = 'facebook' THEN 'Facebook'
                        WHEN LOWER(TRIM(traffic_source)) = 'meta' THEN ' Meta'
                        WHEN LOWER(TRIM(traffic_source)) = 'klaviyo' THEN 'Klaviyo'
                        WHEN LOWER(TRIM(traffic_source)) = 'email' THEN 'Email'
                        WHEN LOWER(TRIM(traffic_source)) = 'newsletter' THEN 'Email'
                        WHEN LOWER(TRIM(traffic_source)) = 'tiktok' THEN 'TIKTOK'
                        WHEN LOWER(TRIM(traffic_source)) = 'instagram' THEN 'Instagram'
                  ELSE traffic_source
            END AS traffic_source,
                  CASE
                        WHEN LOWER(TRIM(traffic_medium)) = 'cpc' THEN 'CPC'
                        WHEN UPPER(TRIM(traffic_medium)) = 'PAID_SOCIAL' THEN 'Paid_Social'
                        WHEN LOWER(TRIM(traffic_medium)) IN ('paid social','paid_social') THEN 'Paid_Social'
                        WHEN LOWER(TRIM(traffic_medium)) = 'affiliate' THEN 'Affiliate'
                        WHEN LOWER(TRIM(traffic_medium)) = 'email' THEN 'Email'
                        WHEN LOWER(TRIM(traffic_medium)) = 'klaviyo' THEN 'Klaviyo'
                        WHEN LOWER(TRIM(traffic_medium)) = 'organic' THEN 'Organic'
                        WHEN INITCAP(TRIM(traffic_medium)) = 'Refferal' THEN 'Referral'
                        WHEN LOWER(TRIM(traffic_medium)) = 'referral' THEN 'Referral'
                        WHEN LOWER(TRIM(traffic_medium)) = '(none)' THEN 'Direct'
                  ELSE traffic_medium
            END AS traffic_medium,
                  CASE 
                        WHEN LOWER(TRIM(campaign_name)) = 'affiliate_partner_a' THEN 'AFFILIATE_PARTNER'
                        WHEN LOWER(TRIM(campaign_name)) = 'influencer_youtube' THEN 'INFLUENCER_YOUTUBE'
                  ELSE campaign_name
            END AS campaign_name,
                  CASE
                        WHEN UPPER(TRIM(country_geo)) IN ('US','USA') THEN 'United States'
                        WHEN LOWER(TRIM(country_geo)) = 'usa' THEN 'United States'
                        WHEN UPPER(TRIM(country_geo)) = 'CA' THEN 'Canada'
                        WHEN UPPER(TRIM(country_geo)) = 'FR' THEN 'France'
                        WHEN UPPER(TRIM(country_geo)) = 'UK' THEN 'United Kingdom'
                  ELSE country_geo
            END AS country_geo,
                  CASE
                        WHEN LOWER(TRIM(device_category)) = 'mobile' THEN 'Mobile'
                        WHEN UPPER(TRIM(device_category)) = 'MOBILE' THEN 'Mobile'
                        WHEN LOWER(TRIM(device_category)) = 'desktop' THEN 'Desktop'
                        WHEN LOWER(TRIM(device_category)) = 'tablet' THEN 'Tablet'
                        WHEN UPPER(TRIM(device_category)) = 'TABLET' THEN 'Tablet'
                  ELSE device_category
            END AS device_category,
            SAFE_CAST(ad_impressions AS INT64) AS ad_impressions,
            SAFE_CAST(ad_clicks AS INT64) AS ad_clicks,
            ad_spend
      FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

CREATE OR REPLACE TABLE `marketing-464513.Training.Acquisition_copy_duplicata` AS  -- Space with Meta

      SELECT 
            date,
            session_id,
                  CASE
                        WHEN LOWER(TRIM(traffic_source)) = 'direct' THEN 'Direct'
                        WHEN INITCAP(TRIM(traffic_source)) ='Google' THEN 'Google Ads'
                        WHEN LOWER(TRIM(traffic_source)) = 'google' THEN 'Google Ads'
                        WHEN LOWER(TRIM(traffic_source)) = 'referral' THEN 'Referral'
                        WHEN LOWER(TRIM(traffic_source)) = 'bing' THEN 'Bing'
                        WHEN LOWER(TRIM(traffic_source)) = 'facebook' THEN 'Facebook'
                        WHEN INITCAP(TRIM(traffic_source)) = 'Meta' THEN 'Meta'
                        WHEN LOWER(TRIM(traffic_source)) = 'klaviyo' THEN 'Klaviyo'
                        WHEN LOWER(TRIM(traffic_source)) = 'email' THEN 'Email'
                        WHEN LOWER(TRIM(traffic_source)) = 'newsletter' THEN 'Email'
                        WHEN LOWER(TRIM(traffic_source)) = 'tiktok' THEN 'TIKTOK'
                        WHEN LOWER(TRIM(traffic_source)) = 'instagram' THEN 'Instagram'
                  ELSE TRIM(traffic_source)
            END AS traffic_source,
                  CASE
                        WHEN LOWER(TRIM(traffic_medium)) = 'cpc' THEN 'CPC'
                        WHEN UPPER(TRIM(traffic_medium)) = 'PAID_SOCIAL' THEN 'Paid_Social'
                        WHEN LOWER(TRIM(traffic_medium)) IN ('paid social','paid_social') THEN 'Paid_Social'
                        WHEN LOWER(TRIM(traffic_medium)) = 'affiliate' THEN 'Affiliate'
                        WHEN LOWER(TRIM(traffic_medium)) = 'email' THEN 'Email'
                        WHEN LOWER(TRIM(traffic_medium)) = 'klaviyo' THEN 'Klaviyo'
                        WHEN LOWER(TRIM(traffic_medium)) = 'organic' THEN 'Organic'
                        WHEN INITCAP(TRIM(traffic_medium)) = 'Refferal' THEN 'Referral'
                        WHEN LOWER(TRIM(traffic_medium)) = 'referral' THEN 'Referral'
                        WHEN LOWER(TRIM(traffic_medium)) = '(none)' THEN 'Direct'
                  ELSE TRIM(traffic_medium)
            END AS traffic_medium,
                  CASE 
                        WHEN LOWER(TRIM(campaign_name)) = 'affiliate_partner_a' THEN 'AFFILIATE_PARTNER'
                        WHEN LOWER(TRIM(campaign_name)) = 'influencer_youtube' THEN 'INFLUENCER_YOUTUBE'
                  ELSE TRIM(campaign_name)
            END AS campaign_name,
                  CASE
                        WHEN UPPER(TRIM(country_geo)) IN ('US','USA') THEN 'United States'
                        WHEN LOWER(TRIM(country_geo)) = 'usa' THEN 'United States'
                        WHEN UPPER(TRIM(country_geo)) = 'CA' THEN 'Canada'
                        WHEN UPPER(TRIM(country_geo)) = 'FR' THEN 'France'
                        WHEN UPPER(TRIM(country_geo)) = 'UK' THEN 'United Kingdom'
                  ELSE TRIM(country_geo)
            END AS country_geo,
                  CASE
                        WHEN LOWER(TRIM(device_category)) = 'mobile' THEN 'Mobile'
                        WHEN UPPER(TRIM(device_category)) = 'MOBILE' THEN 'Mobile'
                        WHEN LOWER(TRIM(device_category)) = 'desktop' THEN 'Desktop'
                        WHEN LOWER(TRIM(device_category)) = 'tablet' THEN 'Tablet'
                        WHEN UPPER(TRIM(device_category)) = 'TABLET' THEN 'Tablet'
                  ELSE TRIM(device_category)
            END AS device_category,
            SAFE_CAST(ad_impressions AS INT64) AS ad_impressions,
            SAFE_CAST(ad_clicks AS INT64) AS ad_clicks,
            ad_spend
      FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;
-- Phase 5: Blank/NA

-- Step 1: Checking 'date' OK

SELECT date, COUNT(*) AS  total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE date IS NULL 
GROUP BY date
ORDER BY total_rows DESC
;

-- Step 2: Checking session_id OK

SELECT session_id, COUNT(*) AS total_rows 
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE session_id IS NULL 
GROUP BY session_id
ORDER BY total_rows DESC
;

-- Step 3: Checking traffic_source OK

SELECT traffic_source, COUNT(*) AS total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE traffic_source IS NULL 
GROUP BY traffic_source
ORDER BY total_rows DESC
;

-- Step 4: Checking traffic_medium OK

SELECT traffic_medium, COUNT(*) AS total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE traffic_medium IS NULL 
GROUP BY traffic_medium
ORDER BY total_rows DESC
;

-- Step 5: Checking campaign_name OK

SELECT campaign_name, COUNT(*) AS total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE campaign_name IS NULL 
GROUP BY campaign_name
ORDER BY total_rows DESC
;

-- Step 6: Checking country_geo OK

SELECT country_geo, COUNT(*) AS total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE country_geo IS NULL 
GROUP BY country_geo
ORDER BY total_rows DESC
;

-- Step 7: Checking device_category OK

SELECT device_category, COUNT(*) AS total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE device_category IS NULL 
GROUP BY device_category
ORDER BY total_rows DESC
;

-- Step 8: Checking ad_impressions 32 NULL OK

SELECT ad_impressions, COUNT(*) AS total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE ad_impressions IS NULL
GROUP BY ad_impressions
ORDER BY total_rows DESC
;

-- Step 9: Checking ad_clicks 6 NULL OK

SELECT ad_clicks, COUNT(*) AS total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE ad_clicks IS NULL 
GROUP BY ad_clicks
ORDER BY total_rows DESC
;

-- Step 10: Checking ad_spend OK

SELECT ad_spend, COUNT(*) AS total_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
WHERE ad_spend IS NULL 
GROUP BY ad_spend
ORDER BY total_rows DESC
;

-- Step 11: Fill in campaign_name with No ads

CREATE OR REPLACE TABLE `marketing-464513.Training.Acquisition_copy_duplicata` AS

SELECT
          date,
          session_id,
          traffic_source,
          traffic_medium,
          COALESCE(campaign_name,'No_Ads') AS campaign_name,
          country_geo,
          device_category,
          COALESCE(ad_impressions,0) AS ad_impressions, -- My mistake because it's impossible to have 0 impression with clicks
          COALESCE(ad_clicks,0) AS ad_clicks,
          ad_spend
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

CREATE OR REPLACE TABLE `marketing-464513.Training.Acquisition_copy_duplicata` AS

SELECT
          date,
          session_id,
          traffic_source,
          traffic_medium,
          COALESCE(campaign_name,'No_Ads') AS campaign_name,
          country_geo,
          device_category,
          CASE
            WHEN ad_impressions IS NULL OR ad_impressions < ad_clicks THEN ad_clicks
            ELSE ad_impressions
            END AS ad_impressions,
          COALESCE(ad_clicks,0) AS ad_clicks,
          ad_spend
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 12: Checking table

SELECT *
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Phase 6: Remove Rows and Columns

-- Step 1: Remove Rows

-- No action needed

-- Step 2: Remove Columns

-- No action needed

-- Phase 7: Debunking (Didn't RUN yet)

-- Step 1: Checking the duplicata OK


SELECT
      COUNT(*) AS total_rows,
      COUNT(DISTINCT session_id) AS unique_session_id,
      COUNT(*) - COUNT(DISTINCT session_id) AS duplicate_rows
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 2: Checking if there is missing data (NULL/ NA) OK

SELECT
      COUNTIF(date IS NULL) AS null_date,
      COUNTIF(traffic_source IS NULL) AS null_traffic_source,
      COUNTIF(traffic_medium IS NULL) AS null_traffic_medium,
      COUNTIF(campaign_name IS NULL) AS null_campaign_name,
      COUNTIF(country_geo IS NULL) AS null_country_geo,
      COUNTIF(device_category IS NULL) AS null_device_category,
      COUNTIF(ad_impressions IS NULL) AS null_ad_impressions, -- 32 NULL (Replaced by ad_clicks) OK
      COUNTIF(ad_clicks IS NULL) AS null_ad_clicks, -- 6 NULL (Replaced by O) OK
      COUNTIF(ad_spend IS NULL) AS null_ad_spend
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 3: Checking the standardization of categorical dimensions OK

SELECT traffic_source, COUNT(*) AS count_traffic_source
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
GROUP BY traffic_source
ORDER BY count_traffic_source DESC
;

SELECT traffic_medium, COUNT(*) AS count_traffic_medium
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
GROUP BY traffic_medium
ORDER BY count_traffic_medium DESC
;

SELECT campaign_name, COUNT(*) AS count_campaign_name
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
GROUP BY campaign_name
ORDER BY count_campaign_name DESC
;

SELECT country_geo, COUNT(*) AS count_country_geo
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
GROUP BY country_geo
ORDER BY count_country_geo DESC
;

SELECT device_category, COUNT(*) AS count_device_category
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
GROUP BY device_category
ORDER BY count_device_category DESC
;

-- Step 4: Checking if numbers are negatives and inaccurate

SELECT
      COUNTIF(ad_impressions < 0) AS negative_ad_impressions,
      COUNTIF(ad_clicks < 0) AS negative_ad_clicks,
      COUNTIF(ad_spend < 0) AS negative_ad_spend,
      COUNTIF(ad_impressions < ad_clicks) AS ad_impressions_less_than_ad_clicks
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;


SELECT
      MIN(ad_impressions) AS min_ad_impressions,
      MAX(ad_impressions) AS max_ad_impressions,
      AVG(ad_impressions) AS avg_ad_impressions,
      MIN(ad_clicks) AS min_ad_clicks,
      MAX(ad_clicks) AS max_ad_clicks,
      AVG(ad_clicks) AS avg_ad_clicks,
      MIN(ad_spend) AS min_ad_spend,
      MAX(ad_spend) AS max_ad_spend,
      AVG(ad_spend) AS avg_ad_spend
FROM `marketing-464513.Training.Acquisition_copy_duplicata` 
;

-- Checking if the CTR is normal or not

SELECT CONCAT(ROUND(SUM(ad_clicks) / SUM(ad_impressions) * 100, 2),'%') AS CTR
FROM `marketing-464513.Training.Acquisition_copy_duplicata` 
;
-- Result CTR = 3,8% (normal)

-- Checking if the CPC is normal or not

SELECT CONCAT('$',ROUND((SUM(ad_spend) / SUM(ad_clicks)),2)) AS CPC
FROM `marketing-464513.Training.Acquisition_copy_duplicata` 
;
-- Result CPC = $0,71 (normal)


-- Step 5: Checking the period

SELECT min(date) AS min_date,
       max(date) AS max_date
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;

-- Step 6: Checking the number of rows

SELECT
      COUNT(*) AS total_row,
      COUNT(DISTINCT traffic_source) AS unique_traffic_source,
      COUNT(DISTINCT traffic_medium) AS unique_traffic_medium,
      COUNT(DISTINCT campaign_name) AS unique_campaign_name,
      COUNT(DISTINCT country_geo) AS unique_country_geo,
      COUNT(DISTINCT device_category) AS unique_device_category,
      COUNT(DISTINCT ad_impressions) AS unique_ad_impressions,
      COUNT(DISTINCT ad_clicks) AS unique_ad_clicks,
      COUNT(DISTINCT ad_spend) AS unique_ad_spend
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;


-- Step 7: End

SELECT *
FROM `marketing-464513.Training.Acquisition_copy_duplicata`
;
