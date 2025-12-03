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



