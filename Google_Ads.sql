SELECT * 
FROM `marketing-464513.Google_Ads.Google_Ads` ;


-- Duplicate dataset for safety

CREATE TABLE `marketing-464513.Google_Ads.Google_Ads_copy` AS
Select *
FROM `marketing-464513.Google_Ads.Google_Ads` ;

-- Checking data

Select *
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;

-- Phase 1: Remove duplicata
-- Cheching duplicata (No duplicata found)

WITH duplicate_CTE AS (
select *,
        ROW_NUMBER() OVER(PARTITION BY session_id, 'date', source_medium, campaign_name, ad_spend, impressions, clicks,  device_category, country, useless_column_1) AS Row_num
FROM `marketing-464513.Google_Ads.Google_Ads_copy` )
SELECT *
FROM duplicate_CTE
WHERE Row_num >1;

-- Phase 2 Standardization
-- column session_id ok

Select count(session_id)
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;


Select distinct(session_id)
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;



Select *
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;

-- column date: I'm going to check all the different format there are in order to format that way YYYY-MM_DD

Select distinct(date)
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;

-- Now I modify the format

CREATE Or Replace table `marketing-464513.Google_Ads.Google_Ads_copy` AS (
SELECT
  session_id,
  COALESCE( SAFE.PARSE_DATE('%Y-%m-%d', date), 
            SAFE.PARSE_DATE('%d/%m/%Y', date), 
            SAFE.PARSE_DATE('%Y %m, %d', date)) AS date,
            source_medium, 
        campaign_name, 
        ad_spend, 
        impressions, 
        clicks,  
        device_category, 
        country,      
        useless_column_1
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`);

-- Checking data

Select *
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;


-- Check all names

Select distinct(source_medium) -- ok
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;

Select distinct(campaign_name) -- ok
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;

Select distinct(device_category) -- ok
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;

Select distinct(country) -- ok
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;

Select distinct(useless_column_1) -- ok
FROM `marketing-464513.Google_Ads.Google_Ads_copy` ;

-- I need to check the number of charcters

SELECT *
FROM `marketing-464513.Google_Ads.Google_Ads_copy`
;

SELECT session_id, length(session_id) AS Number
FROM `marketing-464513.Google_Ads.Google_Ads_copy` -- OK
ORDER BY length(session_id) desc
;

-- Standardization of all names

CREATE OR REPLACE TABLE `marketing-464513.Google_Ads.Google_Ads_copy` AS (

SELECT
  session_id,
  date,
  CASE
    WHEN LOWER(source_medium) = 'bing / cpc' THEN 'Bing / CPC'
    WHEN LOWER(source_medium) = 'direct / (none)' THEN 'Direct / (None)'
    WHEN LOWER(source_medium) = 'google / cpc' THEN 'Google / CPC'
    WHEN LOWER(source_medium) = 'google / organic' THEN 'Google / Organic'
    WHEN LOWER(source_medium) = 'newsletter / email' THEN 'Newsletter / Email'
    WHEN LOWER(source_medium) = 'instagram / social' THEN 'Instagram / Social'
    WHEN LOWER(source_medium) = 'tiktok / social' THEN 'TikTok / Social'
    WHEN LOWER(source_medium) = 'facebook / cpc' THEN 'Facebook / CPC'
    ELSE source_medium
END
  AS source_medium,
  CASE
    WHEN INITCAP(campaign_name) = 'Promo_Automne' THEN 'Promo_Automne_2025'
    WHEN INITCAP(campaign_name) = 'Promo_Hiver' THEN 'Promo_Hiver_2025'
    WHEN INITCAP(campaign_name) = 'Promo_Printemps' THEN 'Promo_Printemps_2025'
    WHEN INITCAP(campaign_name) = 'Nouveautes_Printemps' THEN 'Nouveautes_Printemps_2025'
    WHEN INITCAP(campaign_name) = 'Fete_des_Meres_2025' THEN 'Fete_Des_Meres_2025'
    WHEN INITCAP(campaign_name) = 'Promo_Octobre' THEN 'Promo_Oct_2025'
    WHEN INITCAP(campaign_name) = 'Promo_Juillet' THEN 'Promo_Juil_2025'
    WHEN INITCAP(campaign_name) = 'Newsletter_Mai' THEN 'Newsletter_Mai_2025'
    WHEN INITCAP(campaign_name) = 'Newsletter_Mars' THEN 'Newsletter_Mars_2025'
    WHEN INITCAP(campaign_name) = 'Newsletter_Sept' THEN 'Newsletter_Sept_2024'
    WHEN INITCAP(campaign_name) = 'Newsletter_Avr' THEN 'Newsletter_Avr_2025'
    WHEN INITCAP(campaign_name) = 'Newsletter_Oct' THEN 'Newsletter_Oct_2024'
    WHEN INITCAP(campaign_name) = 'Newsletter_Dec' THEN 'Newsletter_Dec_2024'
    WHEN INITCAP(campaign_name) = 'Newsletter_Nov' THEN 'Newsletter_Nov_2024'
    WHEN INITCAP(campaign_name) = 'Newsletter_Juil' THEN 'Newsletter_Juil_2025'
    WHEN INITCAP(campaign_name) = 'Newsletter_Juin' THEN 'Newsletter_Juin_2025'
    WHEN INITCAP(campaign_name) = 'Newsletter_Aout' THEN 'Newsletter_Aout_2025'
    WHEN INITCAP(campaign_name) = 'Newsletter_Jan' THEN 'Newsletter_Jan_2025'
    WHEN INITCAP(campaign_name) = 'Newsletter_Fev' THEN 'Newsletter_Fev_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Notoriete' THEN 'Campagne_Notoriete_2024'
    WHEN INITCAP(campaign_name) = 'Campagne_Octobre' THEN 'Campagne_Oct_2024'
    WHEN INITCAP(campaign_name) = 'Campagne_Mars' THEN 'Campagne_Mars_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Novembre' THEN 'Campagne_Nov_2024'
    WHEN INITCAP(campaign_name) = 'Campagne_Aout' THEN 'Campagne_Aout_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Avril' THEN 'Campagne_Avr_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Fevrier' THEN 'Campagne_Fev_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Janvier' THEN 'Campagne_Jan_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Decembre' THEN 'Campagne_Dec_2024'
    WHEN INITCAP(campaign_name) = 'Campagne_Septembre' THEN 'Campagne_Sept_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Juillet' THEN 'Campagne_Juil_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Juin' THEN 'Campagne_Juin_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Mai' THEN 'Campagne_Mai_2025'
    WHEN INITCAP(campaign_name) = 'Campagne_Mai' THEN 'Campagne_Mai_2025'
    WHEN LOWER(campaign_name) = 'direct / (none)' THEN 'Direct / (None)'
    WHEN LOWER(campaign_name) = 'google / organic' THEN 'Google / Organic' -- Wrong Column
    WHEN Initcap(campaign_name) = 'Lancement_Produit_X' THEN 'Lancement_Produit_X_2024' -- Missing Transformation
    WHEN Initcap(campaign_name) = 'Black_Friday_Prep' THEN 'Black_Friday_Prep_2025' -- Missing Transformation
    WHEN Initcap(campaign_name) = 'Challenge_Septembre' THEN 'Challenge_Sept_2024' -- Missing Transformation
    WHEN Initcap(campaign_name) = 'Newsletter_Juil' THEN 'Newsletter_Juil_2025' -- Missing Transformation
    WHEN Initcap(campaign_name) = 'Newsletter_Aout' THEN 'Newsletter_Aout_2025' -- Missing Transformation + Wrong year
    WHEN Initcap(campaign_name) = 'Newsletter_Juin' THEN 'Newsletter_Juin_2025' -- Missing Transformation
    ELSE campaign_name
END
  AS campaign_name,
  ad_spend,
  impressions,
  clicks,
  CASE
    WHEN UPPER(device_category) = 'TABLET' THEN 'Tablet'
    WHEN LOWER(device_category) = 'desktop' THEN 'Desktop'
    WHEN LOWER(device_category) = 'mobile' THEN 'Mobile'
    ELSE device_category
END
  AS device_category,
  CASE
    WHEN UPPER(country) = 'USA' THEN 'United States'
    WHEN UPPER(country) = 'DE' THEN 'Germany'
    WHEN UPPER(country) = 'FR' THEN 'France'
    ELSE country
END
  AS country,
  useless_column_1
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`);

-- Missing transformation

SELECT date, campaign_name -- ok
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`
WHERE campaign_name = 'Lancement_Produit_X';

SELECT date, campaign_name -- ok
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`
WHERE campaign_name = 'Black_Friday_Prep';

SELECT date, campaign_name -- ok
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`
WHERE campaign_name = 'Challenge_Septembre_';

SELECT date, campaign_name -- ok
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`
WHERE campaign_name = 'Newsletter_Juil';

SELECT date, campaign_name -- ok
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`
WHERE campaign_name = 'Newsletter_Aout';

SELECT date, campaign_name -- ok
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`
WHERE campaign_name = 'Newsletter_Juin';

-- Modify 2024-08-26 to 2025-08-26


UPDATE `marketing-464513`.`Google_Ads`.`Google_Ads_copy`
SET date = '2025-08-26'
WHERE date = '2024-08-26';

-- Check standardization of all Names

SELECT *
FROM`marketing-464513.Google_Ads.Google_Ads_copy`;


-- Standardization of all numbers

CREATE Or Replace table `marketing-464513.Google_Ads.Google_Ads_copy` AS (

SELECT  session_id,
        date,
        source_medium,
        campaign_name, 
        SAFE_CAST(ad_spend AS FLOAT64) AS ad_spend, 
        SAFE_CAST(impressions AS INT64) AS impressions, 
        SAFE_CAST(clicks AS INT64) AS clicks,  
        device_category, 
        country,      
        useless_column_1
FROM`marketing-464513`.`Google_Ads`.`Google_Ads_copy`);

-- Phase 3: Fill the NULL/Blank


SELECT *
FROM`marketing-464513.Google_Ads.Google_Ads_copy`
WHERE source_medium IS NULL
 ;

UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- They were in the wrong column
SET source_medium = 'Direct / (None)'
WHERE date = '2024-08-19'

UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- They were in the wrong column
SET source_medium = 'Google / Organic'
WHERE date = '2024-08-30'

SELECT *
FROM`marketing-464513.Google_Ads.Google_Ads_copy`
WHERE campaign_name IS NULL
 ;

 UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- They don't need campaign because it's free
 SET campaign_name = 'Organic'
 WHERE campaign_name IS NULL
 ;

SELECT distinct(campaign_name)
FROM`marketing-464513.Google_Ads.Google_Ads_copy`;

UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- They don't need campaign because it's free
 SET campaign_name = 'Organic'
 WHERE campaign_name = 'Google / Organic';

 UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- They don't need campaign because it's free
 SET campaign_name = 'Organic'
 WHERE campaign_name = 'Direct / (None)';

SELECT *
FROM`marketing-464513.Google_Ads.Google_Ads_copy`
WHERE ad_spend IS NULL;

UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- They don't need campaign because it's free
 SET ad_spend = 0.00
 WHERE campaign_name = 'Organic';

 UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- They is a mistake with the type of Source_medium
 SET source_medium = 'Bing / CPC'
 WHERE campaign_name = 'Promo_Ete_2024';

 UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- They is a mistake with the type of Source_medium
 SET source_medium = 'Google / CPC'
 WHERE campaign_name = 'BlackFriday_2023';

 UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- AS they fictive data, I put random data
 SET ad_spend = 0.00
 WHERE campaign_name = 'Promo_Ete_2024';

 UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- AS they fictive data, I put random data
 SET ad_spend = 500.00
 WHERE campaign_name = 'Lancement_Produit_X_2024';

 UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- AS they fictive data, I put random data
 SET ad_spend = 1200.5
 WHERE campaign_name = 'BlackFriday_2023';

 UPDATE `marketing-464513.Google_Ads.Google_Ads_copy` -- AS they fictive data, I put random data
 SET ad_spend = 750.00
 WHERE campaign_name = 'BlackFriday_2023';

 SELECT *
FROM`marketing-464513.Google_Ads.Google_Ads_copy` -- Columns from impressions to useless_column_1 ( No Null)
WHERE country IS NULL;

-- Checking the result

SELECT date 
FROM`marketing-464513.Google_Ads.Google_Ads_copy`
WHERE session_id = 's_0065'
;


-- Done Cleaning that dataset
