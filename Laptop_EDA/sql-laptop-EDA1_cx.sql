-- ************** EDA of clean laptop data *******************************
-- 1. head->tail-> sample
SELECT * FROM laptop;
-- head
SELECT * FROM laptop
ORDER BY `index` LIMIT 5;
-- tail
SELECT * FROM laptop
ORDER BY `index` DESC LIMIT 5;
-- sample -> using RAND()
SELECT * FROM laptop
ORDER BY RAND() ; -- randomly mixed the data 

SELECT * FROM laptop
ORDER BY RAND() LIMIT 5 ;-- from randomly mixed data we choose 5 data 

-- 2. for Numerical cols
-- Price 
-- 8 number summary[count,min,max,mean,std,q1,q2,q3]
-- -> Horizontal/vertical histogram
SELECT count(price) OVER(),
MIN(price) OVER(),
MAX(price) OVER(),
AVG(price) OVER(),
STD(price) OVER(),
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY price) OVER() AS "Q1",
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) OVER() AS "Median",
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY price) OVER() AS "Q3"
FROM laptop
ORDER BY `index` limit 1;

-- missing values -> no missing value in the price
SELECT count(price) 
FROM laptop
WHERE price IS NULL;

-- outliers-> Using Boxplot formula -> total 28 outliers are here 
-- here ouliers are not totally justified 
-- it could be consider as outliers if for the same specification price would be high 
SELECT * FROM (SELECT * ,
		PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY price) OVER () AS "Q1",
		PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY price) OVER () AS "Q3"
		FROM laptop ) t
WHERE t.price< t.Q1-(1.5*(t.Q3-t.Q1)) OR 
t.price> t.Q3+(1.5*(t.Q3-t.Q1));

SELECT count(*) FROM (SELECT * ,
		PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY price) OVER () AS "Q1",
		PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY price) OVER () AS "Q3"
		FROM laptop ) t
WHERE t.price< t.Q1-(1.5*(t.Q3-t.Q1)) OR 
t.price> t.Q3+(1.5*(t.Q3-t.Q1));

SELECT t.bucket,count(*) FROM (
		SELECT price,
		CASE
		   WHEN price BETWEEN 0 AND 25000 THEN "0-25k"
		   WHEN price BETWEEN 25001 AND 50000 THEN "25k-50k"
		   WHEN price BETWEEN 50001 AND 75000 THEN "50k-75k"
		   WHEN price BETWEEN 75001 AND 100000 THEN "75k-100k"
		   ELSE ">100k"
		END AS "bucket"
		FROM laptop) t
GROUP BY t.bucket 

-- horizontal histogram 
SELECT t.bucket,REPEAT('*',count(*)/5) FROM (
		SELECT price,
		CASE
		   WHEN price BETWEEN 0 AND 25000 THEN "0-25k"
		   WHEN price BETWEEN 25001 AND 50000 THEN "25k-50k"
		   WHEN price BETWEEN 50001 AND 75000 THEN "50k-75k"
		   WHEN price BETWEEN 75001 AND 100000 THEN "75k-100k"
		   ELSE ">100k"
		END AS "bucket"
		FROM laptop) t
GROUP BY t.bucket 

-- 3. for categorical cols
--  value counts-> pie charts
--  missing value
SELECT * FROM laptop

SELECT Company,COUNT(Company)
FROM laptop
GROUP BY Company
-- 4. numerical - numerical
--  - side by side 8 number analysis
--  - scatter plot
--  - correlation

SELECT * FROM laptop
-- Scatter plot for cpu_speed and price
SELECT cpu_speed, Price FROM laptop

-- 5. categorical-categorical
--   - contigency table-> stacked bar chart

SELECT * FROM laptop 

-- contengency table 
SELECT Company,
SUM(CASE WHEN touch_screen=1 THEN 1 ELSE 0 END) AS "Touch_screen_yes",
SUM(CASE WHEN touch_screen=0 THEN 1 ELSE 0 END) AS "Touch_screen_no"
FROM laptop 
GROUP BY Company

SELECT DISTINCT cpu_brand FROM laptop

SELECT Company,
SUM(CASE WHEN cpu_brand="Intel" THEN 1 ELSE 0 END) AS "intel",
SUM(CASE WHEN cpu_brand="AMD" THEN 1 ELSE 0 END) AS "amd",
SUM(CASE WHEN cpu_brand="Samsung" THEN 1 ELSE 0 END) AS "samsung"
FROM laptop 
GROUP BY Company