SELECT  *
FROM `marketing-464513.Training.Transaction` 
;

-- Phase 1 - Duplicate table

-- Step 1: Create table

  CREATE OR REPLACE TABLE `marketing-464513.Training.Transaction_duplicata` 
  LIKE `marketing-464513.Training.Transaction` 
;

-- Step 2: import data in table

  INSERT INTO `marketing-464513.Training.Transaction_duplicata` 
  SELECT  *
  FROM `marketing-464513.Training.Transaction` 
  ;

-- Step 3: Checking table

  SELECT *
  FROM `marketing-464513.Training.Transaction_duplicata` 
  ;

-- Phase 2 - Remove duplicata data

-- Step 1: Checking duplicata

  SELECT *,
  ROW_NUMBER()OVER(PARTITION BY raw_order_date, order_id, session_id, customer_id, payment_status, product_sku, sku_category, quantity, 'gross_revenue', discount_applied, 'refund_amount') AS row_num
   FROM `marketing-464513.Training.Transaction_duplicata` 
  ;

  WITH Duplicate_CTE AS (
  SELECT *,
  ROW_NUMBER()OVER(PARTITION BY raw_order_date, order_id, session_id, customer_id, payment_status, product_sku, sku_category, quantity, 'gross_revenue', discount_applied, 'refund_amount')  AS row_num
   FROM `marketing-464513.Training.Transaction_duplicata`  
  )
  SELECT *
  FROM Duplicate_CTE
  WHERE row_num > 1
  ;

-- Step 2: Create table for removing duplicata

  CREATE OR REPLACE TABLE `marketing-464513.Training.Transaction_duplicata_copy`(
   
        raw_order_date STRING, 
        order_id STRING, 
        session_id STRING, 
        customer_id STRING, 
        payment_status STRING, 
        product_sku STRING, 
        sku_category STRING, 
        quantity INT64, 
        gross_revenue FLOAT64, 
        discount_applied INT64, 
        refund_amount FLOAT64,
        row_num INT64
      );

-- Step 3: Import data in the new table

  INSERT INTO `marketing-464513.Training.Transaction_duplicata_copy`
  SELECT *,
  ROW_NUMBER()OVER(PARTITION BY raw_order_date, order_id, session_id, customer_id, payment_status, product_sku, sku_category, quantity, 'gross_revenue', discount_applied, 'refund_amount') AS row_num
   FROM `marketing-464513.Training.Transaction_duplicata` 
  ;

-- Step 4: Delete duplicata

  DELETE
  FROM `marketing-464513.Training.Transaction_duplicata_copy`
  WHERE row_num > 1
  ;

-- Step 5: Remove Column

  ALTER TABLE `marketing-464513.Training.Transaction_duplicata_copy`
  DROP COLUMN  row_num 
  ;

-- Step 6: Checking table

  SELECT *
  FROM `marketing-464513.Training.Transaction_duplicata_copy`
  ;

-- Phase 3 - Standardization 

-- Step 1: Checking date  

  SELECT raw_order_date
  FROM `marketing-464513.Training.Transaction`
  WHERE NOT REGEXP_CONTAINS(raw_order_date, r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
  ;

-- Step 2: Modify date

  CREATE OR REPLACE TABLE `marketing-464513.Training.Transaction_duplicata_copy` AS

  SELECT
      COALESCE(
          SAFE.PARSE_DATE('%Y-%m-%d', raw_order_date),
          SAFE.PARSE_DATE('%Y/%m/%d', raw_order_date),
          SAFE.PARSE_DATE('%Y.%m.%d', raw_order_date),
          SAFE.PARSE_DATE('%d-%m-%Y', raw_order_date),
          SAFE.PARSE_DATE('%d/%m/%Y', raw_order_date),
          SAFE.PARSE_DATE('%m-%d-%Y', raw_order_date)
      ) AS date,
      order_id, 
      session_id, 
      customer_id, 
      payment_status, 
      product_sku, 
      sku_category, 
      quantity, 
      gross_revenue, 
      discount_applied, 
      refund_amount
  FROM `marketing-464513.Training.Transaction_duplicata_copy`
  ;

-- Step 3: Checking date

  SELECT date
  FROM `marketing-464513.Training.Transaction_duplicata_copy`
  WHERE NOT REGEXP_CONTAINS(CAST(date AS STRING), r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$')
  ;

-- Step 4: Checking id and SKU

-- Step 4 BIS: Checking the lengh -- OK

  SELECT *
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;  

  SELECT order_id, length(order_id) AS char_num
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ORDER BY char_num DESC
  ;    

  SELECT session_id, length(session_id) AS char_num
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ORDER BY char_num DESC
  ;     

  SELECT customer_id, length(customer_id) AS char_num
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ORDER BY char_num DESC
  ;     

  SELECT product_sku, length(product_sku) AS char_num
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ORDER BY char_num DESC
  ;     

-- Step 4 BIS BIS: Checking the character string -- OK

  SELECT
        COUNTIF(NOT REGEXP_CONTAINS(order_id, r'^ORD_[0-9]+$')) AS invalid_order_ids,
        COUNTIF(NOT REGEXP_CONTAINS(session_id, r'^SES_[0-9]+$')) AS invalid_session_id,
        COUNTIF(NOT REGEXP_CONTAINS(customer_id, r'^CUST_[0-9]+$')) AS invalid_customer_id,
        COUNTIF(NOT REGEXP_CONTAINS(product_sku, r'^SKU_[A-Z]+_[0-9]{2}$')) AS invalid_product_sku
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;      

-- Step 5: Checking categories

  SELECT DISTINCT(payment_status)
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;  

  SELECT DISTINCT(sku_category)
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;  


-- Step 7: Modify data

  SELECT *
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;

  CREATE OR REPLACE TABLE `marketing-464513.Training.Transaction_duplicata_copy` AS 

  SELECT 
        date,
        TRIM(order_id) AS order_id,
        TRIM(session_id) AS session_id,
        TRIM(customer_id) AS customer_id,
        CASE
            WHEN UPPER(TRIM(payment_status)) = 'PAID' THEN 'Paid'
            WHEN LOWER(TRIM(payment_status)) = 'paid' THEN 'Paid'
            WHEN LOWER(TRIM(payment_status)) = 'completed' THEN 'Completed'
            WHEN LOWER(TRIM(payment_status)) = 'failed' THEN 'Failed'
            WHEN LOWER(TRIM(payment_status)) = 'refunded' THEN 'Refunded'
            ELSE payment_status
        END AS payment_status,
        TRIM(product_sku) AS product_sku,
        CASE
            WHEN LOWER(TRIM(sku_category)) = 'accessories' THEN 'Accessories'
            WHEN UPPER(TRIM(sku_category)) = 'APPAREL' THEN 'Apparel'
            WHEN UPPER(TRIM(sku_category)) = 'FOOTWEAR' THEN 'Footwear'
            WHEN LOWER(TRIM(sku_category)) = 'footwear' THEN 'Footwear'
            ELSE sku_category
        END AS sku_category,
        quantity,
        gross_revenue,
        SAFE_CAST(discount_applied AS FLOAT64) AS discount_applied,
        refund_amount
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;


-- Step 8: Checking table

  SELECT *
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;

-- Phase 4 - Remove Null / Blank

-- Step 1: Checking Null / Blank by colomn

  SELECT DISTINCT(date), COUNT(*) AS total_missing_date -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE date IS NULL 
     OR CAST(date AS STRING) = ''
  GROUP BY date
  ORDER BY total_missing_date DESC
  ;

  SELECT DISTINCT(order_id), COUNT(*) AS total_missing_order_id -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE order_id IS NULL
     OR order_id = ''
  GROUP BY order_id
  ORDER BY total_missing_order_id
  ;

  SELECT DISTINCT(session_id), COUNT(*) AS total_missing_session_id -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE session_id IS NULL
     OR session_id = ''
  GROUP BY session_id
  ORDER BY total_missing_session_id
  ;

  SELECT DISTINCT(customer_id), COUNT(*) AS total_missing_customer_id -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE customer_id IS NULL
     OR customer_id = ''
  GROUP BY customer_id
  ORDER BY total_missing_customer_id
  ;

  SELECT DISTINCT(payment_status), COUNT(*) AS total_missing_payment_status -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE payment_status IS NULL
     OR payment_status = ''
  GROUP BY payment_status
  ORDER BY total_missing_payment_status
  ;

  SELECT DISTINCT(product_sku), COUNT(*) AS total_missing_product_sku -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE product_sku IS NULL
     OR product_sku = ''
  GROUP BY product_sku
  ORDER BY total_missing_product_sku
  ;

  SELECT DISTINCT(sku_category), COUNT(*) AS total_missing_sku_category -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE sku_category IS NULL
     OR sku_category = ''
  GROUP BY sku_category
  ORDER BY total_missing_sku_category
  ;

  SELECT DISTINCT(quantity), COUNT(*) AS total_missing_quantity -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE quantity IS NULL
     OR CAST(quantity AS STRING) = ''
  GROUP BY quantity
  ORDER BY total_missing_quantity
  ;

  SELECT DISTINCT(gross_revenue), COUNT(*) AS total_missing_gross_revenue -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE gross_revenue IS NULL
     OR CAST(gross_revenue AS STRING) = ''
  GROUP BY gross_revenue
  ORDER BY total_missing_gross_revenue
  ;

  SELECT DISTINCT(discount_applied), COUNT(*) AS total_missing_discount_applied -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE discount_applied IS NULL
     OR CAST(discount_applied AS STRING) = ''
  GROUP BY discount_applied
  ORDER BY total_missing_discount_applied
  ;

  SELECT DISTINCT(refund_amount), COUNT(*) AS total_missing_refund_amount -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  WHERE refund_amount IS NULL
     OR CAST(refund_amount AS STRING) = ''
  GROUP BY refund_amount
  ORDER BY total_missing_refund_amount
  ;

-- Step 2: Checking table

  SELECT *
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;

-- Phase 5 - If necessery, remove rows and column

-- Step 1: Remove rows if needed OK

-- Step 2: Remove column if needed OK


-- Phase 6 - Debugging

-- Step 1: Checking missing duplicate amoung ID -- OK

  SELECT 
        COUNT(*) AS total_row,
        COUNT(DISTINCT(order_id)) AS unique_order_id,
        COUNT(*) - COUNT(DISTINCT(order_id)) AS unique_order_id_duplicated, 
        COUNT(*) AS total_row,
        COUNT(DISTINCT(session_id)) AS unique_session_id,
        COUNT(*) - COUNT(DISTINCT(session_id)) AS unique_session_id_duplicated,
        COUNT(*) AS total_row,
        COUNT(DISTINCT(customer_id)) AS unique_customer_id,
        COUNT(*) - COUNT(DISTINCT(customer_id)) AS unique_customer_id_duplicated
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;  

-- Step 2: Checking missing NULL / BLANK -- OK

  SELECT
        COUNTIF(date IS NULL) AS missing_date,
        COUNTIF(order_id IS NULL) AS missing_order_id,
        COUNTIF(session_id IS NULL) AS missing_session_id,
        COUNTIF(customer_id IS NULL) AS missing_customer_id,
        COUNTIF(payment_status IS NULL) AS missing_payment_status,
        COUNTIF(product_sku IS NULL) AS missing_product_sku,
        COUNTIF(sku_category IS NULL) AS missing_sku_category,
        COUNTIF(quantity IS NULL) AS missing_quantity,
        COUNTIF(CAST(gross_revenue AS STRING) IS NULL) AS missing_gross_revenue,
        COUNTIF(CAST(discount_applied AS STRING) IS NULL) AS missing_discount_applied,
        COUNTIF(CAST(refund_amount AS STRING) IS NULL) AS missing_refund_amount
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;  

-- Step 3: Checking missing standardization categories -- OK

  SELECT payment_status, COUNT(*) AS total_row
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  GROUP BY payment_status
  ORDER BY total_row DESC
  ;  

  SELECT sku_category, COUNT(*) AS total_row
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  GROUP BY sku_category
  ORDER BY total_row DESC
  ;  

-- Step 4: Checking if numbers are negative 

  SELECT quantity, gross_revenue, discount_applied, refund_amount
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;

    SELECT 
        COUNTIF(quantity < 0) AS negative_quantity,
        COUNTIF(gross_revenue < 0) AS negative_gross_revenue,
        COUNTIF(discount_applied < 0) AS negative_discount_applied,
        COUNTIF(refund_amount < 0) AS negative_refund_amount,
        COUNTIF((gross_revenue * (1 - discount_applied / 100)) - refund_amount < 0) AS negative_net_revenue -- 16 anomalies
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;

-- Step 5: Where the 16 anomalies are coming from

  SELECT 
    order_id, 
    gross_revenue, 
    discount_applied, 
    refund_amount,
    (gross_revenue * (1 - discount_applied / 100)) - refund_amount AS revenue_net
  FROM `marketing-464513.Training.Transaction_duplicata_copy`
  WHERE (gross_revenue * (1 - discount_applied / 100)) - refund_amount < 0
  ;

-- The anlomaly is coming from the fact that the client have been refunded more than he has paid for the product

-- Step 6: Fixing the 16 anomalies

  UPDATE `marketing-464513.Training.Transaction_duplicata_copy`
  SET refund_amount = gross_revenue * (1 - discount_applied / 100)
  WHERE (gross_revenue * (1 - discount_applied / 100)) - refund_amount < 0
  ;

-- Step 6 Bis: Checking the update OK

 SELECT 
        CONCAT('$',ROUND(SUM ((gross_revenue * (1 - discount_applied / 100)) - refund_amount),2)) AS total_net_revenue
  FROM `marketing-464513.Training.Transaction_duplicata_copy`
  ;

  -- Net revenue $18,794.95

-- Step 7: Checking if numbers are wrong OK

  SELECT
        min(quantity) AS min_quantity,
        max(quantity) AS max_quantity,
        AVG(quantity) AS avg_quantity,
        min(gross_revenue) AS min_gross_revenue,
        max(gross_revenue) AS max_gross_revenue,
        AVG(gross_revenue) AS avg_gross_revenue,
        min(discount_applied) AS min_discount_applied,
        max(discount_applied) AS max_discount_applied,
        AVG(discount_applied) AS avg_discount_applied,
        min(refund_amount) AS min_refund_amount,
        max(refund_amount) AS max_refund_amount,
        AVG(refund_amount) AS avg_refund_amount
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;     

-- Step 6: Checking if metric are wrong

-- Step 6 bis: Calcul of the net revenue

  SELECT
        CONCAT('$',ROUND(SUM(gross_revenue) - (SUM((gross_revenue * (1 - discount_applied / 100)) - refund_amount) - SUM(refund_amount)),2)) AS net_revenue
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;   

-- Net revenue: $9,257

-- Step 7: Checking if the period of analysis is good OK

  SELECT  
        min(date) AS start_period,
        max(date) AS end_period
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;   

-- Step 8: Checking number of rows

  SELECT 
        COUNT(*) AS total_row,
        COUNT(date) AS unique_date,
        COUNT(DISTINCT(order_id)) AS unique_order_id,
        COUNT(DISTINCT(session_id)) AS unique_session_id,
        COUNT(DISTINCT(customer_id)) AS unique_customer_id,
        COUNT(payment_status) AS unique_payment_status,
        COUNT(product_sku) AS unique_product_sku, 
        COUNT(sku_category) AS unique_sku_category,
        COUNT(quantity) AS unique_quantity,
        COUNT(gross_revenue) AS unique_gross_revenue,
        COUNT(discount_applied) AS unique_discount_applied,
        COUNT(refund_amount) AS unique_refund_amount
  FROM `marketing-464513.Training.Transaction_duplicata_copy` 
  ;  

-- Phase 7 - Create Flat Table

-- Step 1: Join table

CREATE OR REPLACE TABLE `marketing-464513.Training.Transaction_duplicata_copy_flat_table` AS (

  SELECT
    t.date,
    t.order_id,
    t.session_id,
    t.customer_id,
    t.payment_status,
    t.product_sku,
    t.sku_category,
    t.quantity,
    t.gross_revenue,
    t.discount_applied,
    t.refund_amount,
    a.traffic_source,
    a.traffic_medium,
    a.campaign_name,
    a.country_geo,
    a.device_category,
    a.ad_impressions,
    a.ad_clicks,
    a.ad_spend
  FROM `marketing-464513`.`Training`.`Transaction_duplicata_copy` AS t
  LEFT JOIN `marketing-464513`.`Training`.`Acquisition_copy_duplicata` AS a
    ON t.session_id = a.session_id AND t.date = a.date
  ORDER BY t.date)
  ;



  WITH agg_transactions AS (
  -- On résume les ventes par date
  SELECT
    date,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM((gross_revenue * (1 - discount_applied / 100)) - refund_amount) AS net_revenue
  FROM `marketing-464513.Training.Transaction_duplicata_copy`
  GROUP BY date
),

agg_acquisition AS (
  -- On résume le marketing par date
  SELECT
    date,
    SUM(ad_impressions) AS total_impressions,
    SUM(ad_clicks) AS total_clicks,
    SUM(ad_spend) AS total_spend
  FROM `marketing-464513.Training.Acquisition_copy_duplicata` -- Remplacez par le vrai nom de votre table acquisition si nécessaire
  GROUP BY date
)

-- On fusionne les deux par Date : le nombre de lignes sera strictement égal au nombre de jours analysés
SELECT
  COALESCE(a.date, t.date) AS date,
  COALESCE(a.total_impressions, 0) AS impressions,
  COALESCE(a.total_clicks, 0) AS clics,
  COALESCE(a.total_spend, 0) AS budget_depense,
  COALESCE(t.total_orders, 0) AS commandes,
  COALESCE(t.net_revenue, 0) AS chiffre_affaires_net
FROM agg_acquisition AS a
FULL OUTER JOIN agg_transactions AS t
  ON a.date = t.date
ORDER BY date;


-- Step 2: Checking table

  SELECT *
  FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table`
  ;

-- Phase 8 - Debugging the Flat Table

-- Step 1: Checking missing duplicate amoung ID OK

  SELECT 
        COUNT(*) AS total_row,
        COUNT(DISTINCT (order_id)) AS unique_order_id,
        COUNT(*) - COUNT(DISTINCT (order_id)) AS duplicated_order_id,
        COUNT(*) AS total_row,
        COUNT(DISTINCT (session_id)) AS unique_session_id,
        COUNT(*) - COUNT(DISTINCT (session_id)) AS duplicated_session_id,
        COUNT(*) AS total_row,
        COUNT(DISTINCT (customer_id)) AS unique_customer_id,
        COUNT(*) - COUNT(DISTINCT (customer_id)) AS duplicated_customer_id
  FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table`
;

-- Step 2: Checking missing NULL / BLANK

  SELECT
        COUNTIF(CAST(date AS STRING) IS NULL) AS missing_date,
        COUNTIF(payment_status IS NULL) AS missing_payment_status,
        COUNTIF(product_sku IS NULL) AS missing_product_sku,
        COUNTIF(sku_category IS NULL) AS missing_sku_category,
        COUNTIF(quantity IS NULL) AS missing_quantity,
        COUNTIF(CAST(gross_revenue AS STRING) IS NULL) AS missing_gross_revenue,
        COUNTIF(CAST(discount_applied AS STRING) IS NULL) AS missing_discount_applied,
        COUNTIF(CAST(refund_amount AS STRING) IS NULL) AS missing_refund_amount,
        COUNTIF(traffic_source IS NULL) AS missing_traffic_source, -- 26 missing
        COUNTIF(traffic_medium IS NULL) AS missing_traffic_medium, -- 26 missing
        COUNTIF(campaign_name IS NULL) AS missing_campaign_name, -- 26 missing
        COUNTIF(country_geo IS NULL) AS missing_country_geo, -- 26 missing
        COUNTIF(device_category IS NULL) AS missing_device_category, -- 26 missing
        COUNTIF(ad_impressions IS NULL) AS missing_ad_impressions, -- 26 missing
        COUNTIF(ad_clicks IS NULL) AS missing_ad_clicks, -- 26 missing
        COUNTIF(CAST(ad_spend AS STRING) IS NULL) AS missing_ad_spend -- 26 missing
  FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table`
;

-- It's normal because of the LEFT JOIN TABLE (200 rows - 174 rows = 26 rows missing) That mean, it could be an organic sell, or tacking issue

-- Step 2 bis : Fill in the NULL / BLANK

CREATE OR REPLACE TABLE `marketing-464513.Training.Transaction_duplicata_copy_flat_table_2` AS

  SELECT
        date,
        order_id,
        session_id,
        customer_id,
        payment_status,
        product_sku,
        sku_category,
        quantity,
        gross_revenue,
        discount_applied,
        refund_amount,
        COALESCE(traffic_source, 'Direct') AS traffic_source,
        COALESCE(traffic_medium, 'Direct') AS traffic_medium, 
        COALESCE(campaign_name, 'None') AS campaign_name, 
        COALESCE(country_geo, 'Unknown') AS country_geo, 
        COALESCE(device_category, 'Unknown') AS device_category, 
        COALESCE(ad_impressions, 0) AS ad_impressions, 
        COALESCE(ad_clicks, 0) AS ad_clicks, 
        COALESCE(ad_spend, 0) AS ad_spend 
  FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table`
;

-- Step 3: Checking Flat Table

  SELECT
        COUNTIF(CAST(date AS STRING) IS NULL) AS missing_date,
        COUNTIF(payment_status IS NULL) AS missing_payment_status,
        COUNTIF(product_sku IS NULL) AS missing_product_sku,
        COUNTIF(sku_category IS NULL) AS missing_sku_category,
        COUNTIF(quantity IS NULL) AS missing_quantity,
        COUNTIF(CAST(gross_revenue AS STRING) IS NULL) AS missing_gross_revenue,
        COUNTIF(CAST(discount_applied AS STRING) IS NULL) AS missing_discount_applied,
        COUNTIF(CAST(refund_amount AS STRING) IS NULL) AS missing_refund_amount,
        COUNTIF(traffic_source IS NULL) AS missing_traffic_source, -- OK
        COUNTIF(traffic_medium IS NULL) AS missing_traffic_medium, -- OK
        COUNTIF(campaign_name IS NULL) AS missing_campaign_name, -- OK
        COUNTIF(country_geo IS NULL) AS missing_country_geo, -- OK
        COUNTIF(device_category IS NULL) AS missing_device_category, -- OK
        COUNTIF(ad_impressions IS NULL) AS missing_ad_impressions, -- OK
        COUNTIF(ad_clicks IS NULL) AS missing_ad_clicks, -- OK
        COUNTIF(CAST(ad_spend AS STRING) IS NULL) AS missing_ad_spend -- OK
  FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table_2`
;

-- Step 4: Checking if the sum of ad_spend is the same for the Flat table and for the transactional table with common sessions OK

SELECT
  (
    SELECT ROUND(SUM(ad_spend), 2) 
    FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table_2`
    WHERE campaign_name != 'None'
  ) AS budget_flat_table,
  (
    SELECT ROUND(SUM(a.ad_spend), 2)
    FROM `marketing-464513.Training.Acquisition_copy_duplicata` a
    WHERE EXISTS (
      SELECT 1 
      FROM `marketing-464513.Training.Transaction_duplicata_copy` t 
      WHERE t.session_id = a.session_id AND t.date = a.date
    )
  ) AS budget_acquisition
;
-- The total budget for both is $14,208.3 OK

-- Step 5: Checking if the period of analysis is good OK

  SELECT
        min(date) AS starting_date,
        max(date) AS ending_date
  FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table_2`
;

-- Step 5: Checking if the transactional table row's number is the same for the Flat table row's number OK

  SELECT ( 
        SELECT
        COUNT(*)
        FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table_2`) AS total_row_flat_table,
        (SELECT
        COUNT(*) 
        FROM `marketing-464513.Training.Transaction_duplicata_copy` ) AS total_row_transaction
;        

-- Phase 9 - Export Flat Table

-- Step 1: Checking Flat Table before exporting

  SELECT *
  FROM `marketing-464513.Training.Transaction_duplicata_copy_flat_table_2`
;
-- Step 2: Export Flat Table for analysis with R Programming library




