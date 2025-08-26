SELECT * 
FROM `marketing-464513.Google_Ads.Google_Analytics` 
;

-- Change the headers

Create Or Replace Table `marketing-464513.Google_Ads.Google_Analytics` AS (

SELECT string_field_0 AS transaction_id, 
       string_field_1 AS session_id,
       string_field_2 AS customer_id,
       string_field_3 AS product_category,
       string_field_4 AS quantity,
       string_field_5 AS revenue,
       string_field_6 AS payment_method,
       string_field_7 AS transaction_date
FROM `marketing-464513.Google_Ads.Google_Analytics`)
; 

-- Checking the dataset

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics`
Order By session_id
;

-- Duplicate database

CREATE TABLE `marketing-464513.Google_Ads.Google_Analytics_Copy` AS
SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics`
;

-- Checking the dataset

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;

-- Phase 1: Remove duplicata
-- Find duplicata (No duplicata)

WITH Duplicate_CTE AS (
SELECT *,
        ROW_NUMBER() OVER(PARTITION BY transaction_id, session_id, customer_id, product_category, quantity,revenue, payment_method, transaction_date) AS Row_num
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`)
SELECT *
FROM Duplicate_CTE
WHERE Row_num >1;

-- Phase 2: Standardization 
-- Step 1: Standardization of date

SELECT distinct(transaction_date)
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;

-- Modifying date format

CREATE OR REPLACE TABLE `marketing-464513.Google_Ads.Google_Analytics_Copy` AS ( 

SELECT transaction_id, 
       session_id,
       customer_id,
       product_category,
       quantity,revenue,
       payment_method,
              COALESCE(
                      SAFE.PARSE_DATE('%Y-%m-%d', transaction_date),
                      SAFE.PARSE_DATE('%d/%m/%Y', transaction_date)) AS transaction_date
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`)
;

-- Checking the dataset

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;

-- Step 2: Standardization of all Names

SELECT distinct(transaction_id) -- ok
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
; 

SELECT distinct(customer_id) -- ok
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;

SELECT distinct(product_category) -- ok
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;

SELECT distinct(payment_method) -- ok
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;


-- Modify names

CREATE OR REPLACE TABLE `marketing-464513.Google_Ads.Google_Analytics_Copy` AS (

SELECT transaction_id, 
       session_id,
       customer_id,
       Case 
            When Initcap(product_category) = 'Vetements' THEN 'Clothing'
            When Lower(product_category) = 'accessoires' THEN 'Accessories'
            When Lower(product_category) = 'beauté' THEN 'Beauty'
            When Lower(product_category) in ('électronique','electronique') THEN 'Electronics'
            When Lower(product_category) = 'maison' THEN 'House'
            When Lower(product_category) = 'livres' THEN 'Books'
          Else product_category
        END AS product_category,
       quantity,
       revenue,
       Case 
            When Lower(payment_method) = 'paypal' THEN 'PayPal'
            When INITCAP(payment_method) in ('Credit Card','Credit_Card', 'Carte Bleue')  THEN 'CB'
          Else payment_method
        END AS payment_method,
       transaction_date 
 FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`)
; 

-- Checking the number of charecter of names

select transaction_id, length(transaction_id) AS Number
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
Order By length(transaction_id) desc


UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- OK
SET transaction_id = 'TXN-0305'
WHERE transaction_id = 'TXN-0T305'

select session_id, length(session_id) AS Number
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- OK
ORDER BY length(session_id) desc

select customer_id, length(customer_id) AS Number
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- It needs to be modified
ORDER BY length(customer_id) desc


UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- OK
SET customer_id = 'CUST-134'
WHERE customer_id = '134'

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- OK
SET customer_id = 'CUST-112'
WHERE customer_id = '112'

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- OK
SET customer_id = 'CUST-125'
WHERE customer_id = '125'


-- Step 3: Standardization of all numbers



SELECT distinct(session_id), length(session_id) AS number -- ok
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
Where number > 6
;

SELECT distinct(quantity) -- ok
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;

SELECT distinct(revenue) -- ok
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;



-- Modify numbers

CREATE OR REPLACE TABLE `marketing-464513.Google_Ads.Google_Analytics_Copy` AS (

SELECT transaction_id, 
       session_id,
       customer_id,
       product_category,
       SAFE_CAST(quantity AS INT64) AS quantity,
       SAFE_CAST(revenue AS FLOAT64) AS revenue,
       payment_method,
       transaction_date 
 FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`);



-- Checking the dataset

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
;

-- Phase 3: Fill in the NULL/Blank


SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`

ORDER BY session_id
;

-- Modified

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET transaction_id = 'TXN-0124'
WHERE transaction_id IS NULL

DELETE FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- Duplicata deleted
WHERE product_category = 'Beauté' AND quantity = 0


UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET quantity = 0
WHERE quantity IS NULL

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET revenue = 599.0 
WHERE customer_id = 'CUST-105' AND revenue is NULL


UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET revenue = 249.95 
WHERE customer_id = 'CUST-106' AND revenue is NULL

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET revenue = 120.5
WHERE customer_id = 'CUST-103' AND revenue is NULL

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET quantity = 1
WHERE customer_id = 'CUST-113' AND quantity =-1

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET product_category = 'Appareil'
WHERE product_category = 'Apparel' 


SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- I can't Fill in because the quantity is 0 and the revenue is NULL
WHERE product_category = 'Appareil'

DELETE FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- Deleted
WHERE product_category = 'Appareil' AND revenue IS NULL


UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET revenue = 55.5
WHERE customer_id = 'CUST-118' AND revenue is NULL

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
SET revenue = 1299.0
WHERE customer_id = 'CUST-127' AND revenue is NULL

-- Checking the quantity because of 0 

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
WHERE quantity = 0 

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- I need to compare with other number
WHERE revenue = 110.0 AND product_category = 'Vêtements'

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- Replace 0 by 2
SET quantity = 2
WHERE product_category = 'Vêtements' AND revenue = 110.0

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- I need to compare with other number
WHERE revenue = 35.8 AND product_category = 'Livres'

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- I need to compare with other number
WHERE product_category = 'Livres'


UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- Replace 0 by 2
SET quantity = 2
WHERE product_category = 'Livres' AND revenue = 35.8


SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- I need to compare with other number
WHERE revenue = 120.0 AND product_category = 'Vêtements'

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- Replace 0 by 2
SET quantity = 2
WHERE product_category = 'Vêtements' AND revenue = 120.0

-- Checking NULL

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
WHERE transaction_id IS NULL

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
WHERE session_id IS NULL

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
WHERE customer_id IS NULL

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`. -- ok
WHERE product_category IS NULL

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
WHERE quantity IS NULL

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
WHERE revenue IS NULL

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- ok
WHERE payment_method IS NULL

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- I'll fill after joining the two table and compare their date
WHERE transaction_date IS NULL

-- Modified

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` -- I don't have a model, I will calculate the Average
WHERE product_category = 'Électronique' AND quantity = 1 AND payment_method = 'CB'
ORDER BY session_id 

SELECT product_category, round(avg(revenue),2) AS Avg_revenue -- 872.07
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy`
WHERE product_category = 'Électronique'
GROUP BY product_category


UPDATE `marketing-464513.Google_Ads.Google_Analytics_Copy` -- Replaced NULL by 872.07
SET revenue = 872.07
WHERE product_category = 'Électronique' AND revenue IS NULL

-- Phase 4: Join table for filling dates

SELECT t1.session_id, t2.date, t1.transaction_date
FROM `marketing-464513.Google_Ads.Google_Analytics_Copy` AS t1
JOIN `marketing-464513.Google_Ads.Google_Ads_copy` AS t2
ON t1.session_id = t2.session_id
WHERE t1.transaction_date IS NULL
;

-- I create a flat table

CREATE OR REPLACE TABLE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` AS (

  SELECT
    t1.transaction_id,
    t1.session_id,
    t1.customer_id,
    t1.product_category,
    t1.quantity,
    t1.revenue,
    t1.payment_method,
    t1.transaction_date,
    t2.date,
    t2.source_medium,
    t2.campaign_name,
    t2.ad_spend,
    t2.impressions,
    t2.clicks,
    t2.device_category,
    t2.country,
    t2.useless_column_1
  FROM`marketing-464513`.`Google_Ads`.`Google_Analytics_Copy` AS t1
  JOIN`marketing-464513`.`Google_Ads`.`Google_Ads_copy` AS t2
  ON t1.session_id = t2.session_id )
;

-- Checking my Flat table

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Flat_Table`
; 

-- Fill in the dates

SELECT session_id, date, transaction_date
FROM `marketing-464513.Google_Ads.Google_Analytics_Flat_Table`
WHERE transaction_date IS NULL
GROUP BY session_id, date, transaction_date
;

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-01-22'
WHERE session_id = 's_0160' AND date = '2025-01-22';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-03-13'
WHERE session_id = 's_0210' AND date = '2025-03-13';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-09-29'
WHERE session_id = 's_0410' AND date = '2025-09-29';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2024-10-20'
WHERE session_id = 's_0065' AND date = '2024-10-20';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-04-12'
WHERE session_id = 's_0240' AND date = '2025-04-12';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-07-21'
WHERE session_id = 's_0340' AND date = '2025-07-21';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-12-11'
WHERE session_id = 's_0481' AND date = '2025-12-11';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-06-16'
WHERE session_id = 's_0305' AND date = '2025-06-16';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-11-27'
WHERE session_id = 's_0467' AND date = '2025-11-27';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-12-28'
WHERE session_id = 's_0498' AND date = '2025-12-28';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2024-12-13'
WHERE session_id = 's_0120' AND date = '2024-12-13';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-11-03'
WHERE session_id = 's_0445' AND date = '2025-11-03';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2024-09-12'
WHERE session_id = 's_0025' AND date = '2024-09-12';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-05-17'
WHERE session_id = 's_0275' AND date = '2025-05-17';

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- OK
SET transaction_date = '2025-08-25'
WHERE session_id = 's_0375' AND date = '2025-08-25';


-- Checking my Flat table

SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Flat_Table`
;

-- Even if I just needed to delete one column in order to have just one column of date, I wanted to show how I can find solutions.
-- By now, I'm going to delete one column of date in order to have just one column of date instead of to have two

Alter Table `marketing-464513.Google_Ads.Google_Analytics_Flat_Table`
DROP column date
;

-- I'm going to drop also the column useless_column_1 because these are comments

Alter Table `marketing-464513.Google_Ads.Google_Analytics_Flat_Table`
DROP column useless_column_1
;

-- Checking my Flat table

SELECT source_medium, campaign_name, ad_spend, impressions, clicks
FROM `marketing-464513.Google_Ads.Google_Analytics_Flat_Table`
WHERE ad_spend = 0 AND source_medium LIKE '%CPC'


-- For the last checking, I have noticed that some ad_spend with bing / CPC is at 0.00. It's impossible because we have some impressions and clicks
-- I know that the average of CPC for Bing or Google is arround 0.80. I'm going to multiply this by the number of clic

UPDATE `marketing-464513.Google_Ads.Google_Analytics_Flat_Table` -- 
SET ad_spend = clicks * 0.8
WHERE ad_spend = 0.0 AND campaign_name = 'Promo_Ete_2024'
;

-- Checking column

SELECT source_medium, campaign_name, ad_spend, impressions, clicks
FROM `marketing-464513.Google_Ads.Google_Analytics_Flat_Table`
WHERE source_medium = 'Bing / CPC'
ORDER BY ad_spend desc
;

-- Final checking of my Flat Table


SELECT *
FROM `marketing-464513.Google_Ads.Google_Analytics_Flat_Table`
;



