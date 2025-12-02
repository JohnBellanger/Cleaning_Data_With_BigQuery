SELECT *
 FROM `marketing-464513.Finance.Marketing` 
 ;

# Duplicate table

Create Table `marketing-464513.Finance.Marketing_Copy` AS
SELECT *
FROM `marketing-464513.Finance.Marketing`
;

# Check table
SELECT *
From `marketing-464513.Finance.Marketing_Copy`
;

# Phase 1: Looking for duplicata

WITH duplicata_CTE AS (

Select *,
        ROW_NUMBER()OVER(PARTITION BY 'Date', Marketing_Source, Campaign_Name, Ad_Spend, Impressions,  Clicks)  AS Row_num
FROM `marketing-464513.Finance.Marketing_Copy`)

SELECT *
FROM duplicata_CTE 
WHERE Row_num >1
;

# Create table in order to remove data

Create or Replace Table  `marketing-464513.Finance.Marketing_Duplicata` (
       Date STRING,
       Marketing_Source STRING, 
       Campaign_Name STRING,
       Ad_Spend INT64,
       Impressions INT64,
       Clicks INT64,
       Row_num INT64)
       ;

INSERT INTO `marketing-464513.Finance.Marketing_Duplicata`

Select *,
        ROW_NUMBER()OVER(PARTITION BY 'Date', Marketing_Source, Campaign_Name, Ad_Spend, Impressions,  Clicks)  AS Row_num
FROM `marketing-464513.Finance.Marketing_Copy`;


# Check table

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Select deplucate

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE Row_num >1
;

# Delete Duplicate

DELETE
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE Row_num >1
;

# Checking Table

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Remove Row_num

CREATE OR REPLACE TABLE`marketing-464513.Finance.Marketing_Duplicata` AS
SELECT Date, Marketing_Source,Campaign_Name,Ad_Spend,Impressions,Clicks
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Check Table

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Phase 2: Standardization of date

SELECT distinct(Date)
FROM `marketing-464513.Finance.Marketing_Duplicata`
;


Create OR REPLACE TABLE `marketing-464513.Finance.Marketing_Duplicata` AS 

Select 
        Parse_date('%Y-%m-%d', date) AS Date,
        Marketing_Source,
        Campaign_Name,
        Ad_Spend,
        Impressions,
        Clicks
FROM  `marketing-464513.Finance.Marketing_Duplicata`
WHERE Safe.Parse_date('%Y-%m-%d', date) IS NOT NULL

UNION ALL

SELECT 
        PARSE_DATE('%d/%m/%Y', date) AS Date,
        Marketing_Source,
        Campaign_Name,
        Ad_Spend,
        Impressions,
        Clicks
FROM  `marketing-464513.Finance.Marketing_Duplicata`
WHERE Safe.Parse_date('%d/%m/%Y', date) IS NOT NULL AND Safe.Parse_date('%Y-%m-%d', date) IS NULL

UNION ALL

SELECT 
        PARSE_DATE('%b %d %Y', date) AS Date,
        Marketing_Source,
        Campaign_Name,
        Ad_Spend,
        Impressions,
        Clicks
FROM  `marketing-464513.Finance.Marketing_Duplicata`
WHERE safe.parse_date('%b %d %Y', date)IS NOT NULL AND safe.parse_date('%d/%m/%Y', date) IS NULL
;

# Check Table

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Phase 3: Standardization of name 
# Step 1: Checking names for Marketing_Source
SELECT DISTINCT(Marketing_Source)
FROM `marketing-464513.Finance.Marketing_Duplicata`


# Step 2: Changing names for Marketing_Source

CREATE OR REPLACE TABLE `marketing-464513.Finance.Marketing_Duplicata` AS
SELECT 
        Date,
        Case 
                WHEN LOWER(Marketing_Source) ='FaceBook Ads' Then 'Facebook Ads'
                WHEN LOWER(Marketing_Source) = 'facebok' Then 'Facebook Ads'
                WHEN LOWER(Marketing_Source) = 'google ads' Then 'Google Ads'
                ELSE Marketing_Source
        END AS Marketing_Source,
        Campaign_Name,
        Ad_Spend,
        Impressions,
        Clicks
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Change FaceBook Ads because LOWER, UPPER or INITCAP don't work

UPDATE `marketing-464513.Finance.Marketing_Duplicata`
SET Marketing_Source = 'Facebook Ads'
WHERE Marketing_Source = 'FaceBook Ads'

# Check Table

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Step 3:  Checking names for Campaign_Name

SELECT DISTINCT(Campaign_Name) #ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE  Campaign_Name LIKE '%Jan%'

SELECT DISTINCT(Campaign_Name) #ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE  Campaign_Name LIKE '%BackToSchool%'

SELECT DISTINCT(Campaign_Name) #ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE  Campaign_Name LIKE '%Gift%'

SELECT DISTINCT(Campaign_Name) # I don't touch ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE  Campaign_Name LIKE '%Last%'

SELECT DISTINCT(Campaign_Name) # Change date and names ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE  Campaign_Name LIKE '%Retargeting%'

SELECT DISTINCT(Campaign_Name) # ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE  Campaign_Name LIKE '%Awareness%'


# Step 4: Changing names for Campaign_Name
CREATE OR REPLACE TABLE `marketing-464513.Finance.Marketing_Duplicata` AS
SELECT 
        Date,
        Marketing_Source,
         Case 
                WHEN INITCAP(Campaign_Name) ='Jan_Newsletter' Then 'Newsletter_Jan'
                WHEN INITCAP(Campaign_Name) = 'BackToSchool' Then 'BackToSchool_Teaser'
                WHEN INITCAP(Campaign_Name) = 'Retargeting_Jan' Then 'Retargeting_Jan_2024'
                WHEN INITCAP(Campaign_Name) = 'Retargeting' Then 'Retargeting_Jan_2023'
                WHEN INITCAP(Campaign_Name) = 'Gift_Cards' Then 'Gift_Cards_Promo'
                ELSE Campaign_Name
        END AS Campaign_Name,
        Cast(Ad_Spend AS Float64) AS Ad_Spend,
        Cast(Impressions AS Int64) AS Impressions,
        Cast(Clicks AS Int64) AS Clicks
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Other changes

UPDATE `marketing-464513.Finance.Marketing_Duplicata` #ok
SET Campaign_Name = 'Retargeting_Jan'
WHERE Date = '2024-01-05'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` #ok
SET Date = '2023-01-10'
WHERE Date = '2023-10-10'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'Q2_Awareness'
WHERE Date = '2023-05-01'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'Q1_Awareness'
WHERE Date = '2023-01-01'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'Post_BlackFriday_Deals'
WHERE Campaign_Name = 'Post_BF_Deals'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'BlackFriday_Countdown'
WHERE Campaign_Name = 'BF_Countdown'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'BlackFriday_Week'
WHERE Campaign_Name = 'BF_Week'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'BlackFriday_Week_Start'
WHERE Campaign_Name = 'BF_Week_Start'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'BlackFriday_Week_Peak'
WHERE Campaign_Name = 'BF_Week_Peak'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'BlackFriday_Weekend'
WHERE Campaign_Name = 'BF_Weekend'

UPDATE `marketing-464513.Finance.Marketing_Duplicata` # ok
SET Campaign_Name = 'BlackFriday_Hype'
WHERE Campaign_Name = 'BF_Hype'

# Check Table

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Phase 4: Standardization of numbers 
SELECT Marketing_Source, Ad_Spend
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE Ad_Spend = 0
;

# Phase 5: Removing Null and Blank

SELECT * # ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE Date IS Null 
;

SELECT * # ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE Marketing_Source IS Null 
;

SELECT * # ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE Campaign_Name IS Null 
;

SELECT * #ok
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE Ad_Spend IS Null 
;

# I'm going to replace Null by 0.00
UPDATE `marketing-464513.Finance.Marketing_Duplicata`
SET Ad_Spend = 0.00
WHERE Ad_Spend IS NULL

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE 'Impressions' IS Null
;

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
WHERE 'Clicks' IS Null 
;

# Check Table

SELECT *
FROM `marketing-464513.Finance.Marketing_Duplicata`
;

# Done

       















 