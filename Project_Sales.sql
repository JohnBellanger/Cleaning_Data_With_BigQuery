SELECT *
FROM `marketing-464513.Finance.Sales` 
;

# Duplicate table

CREATE TABLE `marketing-464513.Finance.Sales_Backup` AS
SELECT*
FROM `marketing-464513.Finance.Sales`
;

# Check table

Select *
FROM `marketing-464513.Finance.Sales_Backup`
;

# Phase 1: Looking for duplicata - Nothing

With Duplicata_CTE AS(
SELECT *, 
        ROW_NUMBER()Over(PARTITION BY Transaction_ID, 'Date', Traffic_Source, Product_Category, 'Revenue', Refund_Amount, Review_Text, Review_Sentiment ) AS Row_num
FROM `marketing-464513.Finance.Sales_Backup`)

SELECT *
FROM Duplicata_CTE 
WHERE Row_num > 1
;

# Phase 2: Checking Transaction_ID - Nothing

SELECT*
FROM `marketing-464513.Finance.Sales_Backup`
;

SELECT Transaction_ID, length(Transaction_ID) AS number
FROM `marketing-464513.Finance.Sales_Backup`
ORDER BY number DESC
;


SELECT Transaction_ID, length(Transaction_ID) AS number
FROM `marketing-464513.Finance.Sales_Backup`
ORDER BY number ASC
;

# Phase 3: Standardization of Date

SELECT DISTINCT(Date)
FROM `marketing-464513.Finance.Sales_Backup`
;


# Modify date

CREATE OR REPLACE TABLE `marketing-464513.Finance.Sales_Backup` AS

SELECT 
        Transaction_ID,
        Parse_date('%Y-%m-%d',Date) AS Date,
        Traffic_Source, 
        Product_Category,
        Revenue,
        Refund_Amount,
        Review_Text,
        Review_Sentiment
FROM `marketing-464513.Finance.Sales_Backup`
WHERE SAFE.Parse_date('%Y-%m-%d',Date) IS NOT NULL

UNION ALL

SELECT 
        Transaction_ID,
        Parse_date('%m/%d/%Y',Date) AS Date,
        Traffic_Source, 
        Product_Category,
        Revenue,
        Refund_Amount,
        Review_Text,
        Review_Sentiment
FROM `marketing-464513.Finance.Sales_Backup`
WHERE SAFE.Parse_date('%Y-%m-%d',Date) IS NOT NULL AND SAFE.Parse_date('%Y-%m-%d',Date) IS NULL
;


# Check table

Select *
FROM `marketing-464513.Finance.Sales_Backup`
;

# Phase 4: Standardization of names

SELECT DISTINCT(Traffic_Source) # ok
FROM `marketing-464513.Finance.Sales_Backup`
;

SELECT DISTINCT(Product_Category) # ok
FROM `marketing-464513.Finance.Sales_Backup`
;

SELECT DISTINCT(Review_Text) # ok
FROM `marketing-464513.Finance.Sales_Backup`
;

SELECT DISTINCT(Review_Sentiment) # ok
FROM `marketing-464513.Finance.Sales_Backup`
;

# Step 5: Standardization of numbers


Select *
FROM `marketing-464513.Finance.Sales_Backup`
;

CREATE OR REPLACE TABLE `marketing-464513.Finance.Sales_Backup` AS

SELECT 
        Transaction_ID,
        Date,
        Traffic_Source, 
        Product_Category,
        Revenue,
        Cast(Refund_Amount AS FLOAT64) AS Refund_Amount,
        Review_Text,
        Review_Sentiment
FROM `marketing-464513.Finance.Sales_Backup`
;

# Step 6: Fill the Null / Blank
# Checking Null
SELECT * # ok
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Transaction_ID IS NULL
;

SELECT * # ok
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Date IS NULL
;

SELECT * # ok
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Traffic_Source IS NULL
;

SELECT * # ok
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Product_Category IS NULL
;

SELECT * # ok
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Revenue IS NULL
;


SELECT * # ok
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Review_Text IS NULL
;


SELECT Revenue, Refund_Amount, Review_Sentiment, Review_Text
FROM `marketing-464513.Finance.Sales_Backup`
ORDER BY Revenue
;

SELECT Revenue, Refund_Amount, Review_Sentiment, Review_Text
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Review_Sentiment = 'Negative' 
ORDER BY Revenue
;

# Modification Refund

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Refund_Amount = 25.0
WHERE Revenue = 25.0 AND Review_Sentiment = 'Negative'

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Refund_Amount = 250.0
WHERE Revenue = 250.0 AND Review_Sentiment = 'Negative'

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Refund_Amount = 25.0
WHERE Revenue = 25.0 AND Review_Sentiment = 'Negative'

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Refund_Amount = 299.0
WHERE Revenue = 299.0 AND Review_Sentiment = 'Negative'


# Modification Review_Sentiment

UPDATE `marketing-464513.Finance.Sales_Backup` #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 30.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 45.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup`  #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 50.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 80.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 100.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 120.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 150.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 200.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 250.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 300.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 400.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` #ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 450.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 500.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 600.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 700.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 800.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 1000.0 AND Refund_Amount = 0.0

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Sentiment = 'Positive'
WHERE Revenue = 1100.0 AND Refund_Amount = 0.0

# Fill in Review_Text

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Must have'
WHERE Review_Sentiment = 'Positive'

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Cheap plastic'
WHERE Review_Sentiment = 'Negative'

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Delay'
WHERE Review_Sentiment = 'Negative' AND Refund_Amount = 600

SELECT Distinct(Review_Text)
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Review_Sentiment = 'Negative'

# Checking table

SELECT *
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Review_Sentiment = 'Negative' 

SELECT *
FROM `marketing-464513.Finance.Sales_Backup`
WHERE Review_Sentiment = 'Positive'

# I made a mistake with the comments I will change it into Positive and Negative per product based on the original database. 

# For Accessories
SELECT Product_Category, Review_Text
FROM `marketing-464513.Finance.Sales` 
WHERE Product_Category = 'Accessories' AND Review_Sentiment = 'Positive'


SELECT Product_Category, Review_Text
FROM `marketing-464513.Finance.Sales` 
WHERE Product_Category = 'Accessories' AND Review_Sentiment = 'Negative'

# Modification
UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Fast shipping thanks'
WHERE Review_Sentiment = 'Positive' AND Product_Category = 'Accessories'

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Cheap plastic'
WHERE Review_Sentiment = 'Negative' AND Product_Category = 'Accessories'

# For Electronics

SELECT Product_Category, Review_Text
FROM `marketing-464513.Finance.Sales` 
WHERE Product_Category = 'Electronics' AND Review_Sentiment = 'Positive'


SELECT Product_Category, Review_Text
FROM `marketing-464513.Finance.Sales` 
WHERE Product_Category = 'Electronics' AND Review_Sentiment = 'Negative'

# Modification

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Great product loved it'
WHERE Review_Sentiment = 'Positive' AND Product_Category = 'Electronics'

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Bad quality broke in 2 days'
WHERE Review_Sentiment = 'Negative' AND Product_Category = 'Electronics'

# For Clothing

SELECT Product_Category, Review_Text
FROM `marketing-464513.Finance.Sales` 
WHERE Product_Category = 'Clothing' AND Review_Sentiment = 'Positive'


SELECT Product_Category, Review_Text
FROM `marketing-464513.Finance.Sales` 
WHERE Product_Category = 'Clothing' AND Review_Sentiment = 'Negative'

# Modification

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Perfect'
WHERE Review_Sentiment = 'Positive' AND Product_Category = 'Clothing'

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Size was wrong returning it'
WHERE Review_Sentiment = 'Negative' AND Product_Category = 'Clothing'

# For Home

SELECT Product_Category, Review_Text
FROM `marketing-464513.Finance.Sales` 
WHERE Product_Category = 'Home' AND Review_Sentiment = 'Positive'

SELECT Product_Category, Review_Text
FROM `marketing-464513.Finance.Sales` 
WHERE Product_Category = 'Home' AND Review_Sentiment = 'Negative'

# Modification

UPDATE `marketing-464513.Finance.Sales_Backup` # ok
SET Review_Text = 'Good value'
WHERE Review_Sentiment = 'Positive' AND Product_Category = 'Home'

# Cheking result

SELECT *
FROM `marketing-464513.Finance.Sales_Backup`
;

SELECT Distinct(Product_Category), Review_Text, Review_Sentiment
FROM `marketing-464513.Finance.Sales_Backup`
;


# Aggregation 

# Revenue vs Refund per Reviews
SELECT Product_Category, sum(Revenue) AS Total_Revenue, sum(Refund_Amount) AS Total_Refund,Review_Text
FROM `marketing-464513.Finance.Sales_Backup`
GROUP BY Product_Category, Review_Text
ORDER BY Total_Revenue DESC

# Revenue net per product
SELECT  Product_Category, sum(Revenue) - sum(Refund_Amount) AS Revenue_net
FROM `marketing-464513.Finance.Sales_Backup`
GROUP BY Product_Category
ORDER BY Revenue_net DESC

# Total Revenue vs Total refund + Revenue net + Percentage Lost of money
SELECT sum(Revenue) AS Total_Revenue, sum(Refund_Amount) AS Total_Refund, sum(Revenue) - sum(Refund_Amount) AS Revenue_net, Round(sum(Refund_Amount) / sum(Revenue) * 100,2) AS Percent_lost
FROM `marketing-464513.Finance.Sales_Backup`

# Phase 7 Creation of flat table

CREATE TABLE `marketing-464513.Finance.Sales_Flat_table` AS

SELECT m.Ad_Spend, m.Campaign_Name, m.Clicks, m.Impressions, m.Marketing_Source,
        s.Transaction_ID, s.Date, s.Traffic_Source, s.Product_Category, s.Revenue, s.Refund_Amount, s.Review_Text, s.Review_Sentiment
FROM  `marketing-464513.Finance.Sales_Backup` s
JOIN `marketing-464513.Finance.Marketing_Duplicata` m
ON s.Date = m.Date

# Checking Flat table

SELECT *
FROM `marketing-464513.Finance.Sales_Flat_table`
;

# Phase 8: DEBUG

# Step 1: I count the row - 268 rows ok

SELECT COUNT(*) AS Total_row,
        COUNT(Ad_Spend) AS Total_Spend,
        COUNT(Campaign_Name) AS Total_Campaign_Name,
        COUNT(Clicks) AS Total_Clicks,
        COUNT(Impressions) AS Total_Impressions,
        COUNT(Marketing_Source) AS Total_Marketing_Source,
        COUNT(Transaction_ID) AS Total_Transaction_ID,
        COUNT(Date) AS Total_Date,
        COUNT(Traffic_Source) AS Total_Traffic_Source,
        COUNT(Product_Category) AS Total_Product_Category,
        COUNT(Revenue) AS Total_Revenue,
        COUNT(Refund_Amount) AS Total_Refund_Amount,
        COUNT(Review_Text) AS Total_Review_Text,
        COUNT(Review_Sentiment) AS Total_Review_Sentiment
FROM `marketing-464513.Finance.Sales_Flat_table`
;

SELECT COUNT(*) AS Total_row,
        COUNT(DISTINCT(Ad_Spend)) AS unique_Ad_Spend,
        COUNT(DISTINCT(Campaign_Name)) AS unique_Name,
        COUNT(DISTINCT(Clicks)) AS unique_Clicks,
        COUNT(DISTINCT(Impressions)) AS Tunique_Impressions,
        COUNT(DISTINCT(Marketing_Source)) AS unique_Marketing_Source,
        COUNT(DISTINCT(Transaction_ID)) AS unique_Transaction_ID,
        COUNT(DISTINCT(Date)) AS unique_Date,
        COUNT(DISTINCT(Traffic_Source)) AS unique_Traffic_Source,
        COUNT(DISTINCT(Product_Category)) AS unique_Product_Category,
        COUNT(DISTINCT(Refund_Amount)) AS unique_Refund_Amount,
        COUNT(DISTINCT(Review_Text)) AS unique_Review_Text,
        COUNT(DISTINCT(Review_Sentiment)) AS unique_Review_Sentiment
FROM `marketing-464513.Finance.Sales_Flat_table`
;

# Step 2: Date - Period ok

SELECT MIN(Date) AS Min_date, MAX(Date) AS Max_date
FROM `marketing-464513.Finance.Sales_Flat_table`
;

# Step 3: Numbers - ok

SELECT 
        MIN(Ad_Spend) AS min_Ad_Spend,
        MAX(Ad_Spend) AS max_Ad_Spend,
        AVG(Ad_Spend) AS avg_Ad_Spend,
        MIN(Clicks) AS min_Clicks,
        MAX(Clicks) AS max_Clicks,
        AVG(Clicks) AS avg_Clicks,
        MIN(Impressions) AS min_Impressions,
        MAX(Impressions) AS max_Impressions,
        AVG(Impressions) AS avg_Impressions,
        MIN(Revenue) AS min_Revenue,
        MAX(Revenue) AS max_Revenue,
        AVG(Revenue) AS avg_Revenue,
        MIN(Refund_Amount) AS min_Refund_Amount,
        MAX(Refund_Amount) AS max_Refund_Amount,
        AVG(Refund_Amount) AS avg_Refund_Amount
FROM `marketing-464513.Finance.Sales_Flat_table`
;

# Step 4: Null - ok
SELECT
        COUNTIF(Ad_Spend IS NULL) AS NULL_Ad_Spend,
        COUNTIF(Campaign_Name IS NULL) AS NULL_Campaign_Name,
        COUNTIF(Clicks IS NULL) AS NULL_Clicks,
        COUNTIF(Impressions IS NULL) AS NULL_Impressions,
        COUNTIF(Marketing_Source IS NULL) AS NULL_Marketing_Source,
        COUNTIF(Transaction_ID IS NULL) AS NULL_Transaction_ID,
        COUNTIF(Date IS NULL) AS NULL_Date,
        COUNTIF(Traffic_Source IS NULL) AS NULL_Traffic_Source,
        COUNTIF(Product_Category IS NULL) AS NULL_Product_Category,
        COUNTIF(Revenue IS NULL) AS NULL_Revenue,
        COUNTIF(Refund_Amount IS NULL) AS NULL_Refund_Amount,
        COUNTIF(Review_Text IS NULL) AS NULL_Review_Text,
        COUNTIF(Review_Sentiment IS NULL) AS NULL_Review_Sentiment
FROM `marketing-464513.Finance.Sales_Flat_table`
;

# Phase 9: Export Flat table to R_Programming 

SELECT *
FROM `marketing-464513.Finance.Sales_Flat_table`
;

