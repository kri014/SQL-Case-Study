-- Zomato case study 
-- 1. Create database 
CREATE DATABASE zomato
-- 2. Import data set of zomato
-- 3. Select a particular database 
USE zomato

-- 4. Count number of rows
SELECT count(*) FROM order_details

-- 5. Return n random records
-- replicate function from pandas 
SELECT * FROM users ORDER BY rand() LIMIT 5

-- 6. Find null values

SELECT * FROM orders WHERE restaurant_rating = ""

UPDATE orders SET restaurant_rating= Null 
WHERE restaurant_rating=""

SELECT * FROM orders WHERE restaurant_rating IS NULL
-------------------------------------------------------------
-- Questions to solve 
-- 5. Find number of order placed by each customer
SELECT  t2.name,count(*) AS "total_order" 
FROM orders t1
JOIN users t2
ON t1.user_id=t2.user_id
GROUP BY t2.user_id 

# SELECT * FROM orders 

-- 6. find restaurant with most number of menu items
# SELECT * FROM restaurants
# SELECT * FROM menu

SELECT t1.r_name,count(*) AS "total_menu" 
FROM restaurants t1
JOIN menu t2
ON t1.r_id=t2.r_id
GROUP BY t1.r_id

-- 7. find number of votes and avg rating for all the resturant

SELECT * FROM orders 
SELECT * FROM restaurants

SELECT r_name,count(*) AS "total_votes", ROUND(avg(restaurant_rating),1) AS "Rating"
FROM orders t1
JOIN restaurants t2
ON t1.r_id=t2.r_id
WHERE restaurant_rating IS NOT NULL
GROUP BY t2.r_id

-- 8. find the food that is being sold at most number of resturant

SELECT f_name, count(*) AS "sold_food" FROM menu t1
JOIN food t2
ON t1.f_id=t2.f_id
GROUP BY t1.f_id
ORDER BY sold_food DESC LIMIT 1

-- 9. find resturant with max revenue in a given months 
-- For may month 
SELECT * FROM orders
SELECT MONTHNAME(DATE(date)), DATE (date) FROM orders

SELECT r_name,sum(amount) AS "revenue" FROM orders t1
JOIN restaurants t2
ON t1.r_id=t2.r_id
WHERE MONTHNAME(DATE(date))="may"
GROUP BY t1.r_id
ORDER BY revenue DESC LIMIT 1

-- month by month revenue for kfc
SELECT  MONTHNAME(DATE(date)) , sum(amount) AS "revenue"
FROM orders t1
JOIN restaurants t2
ON t1.r_id=t2.r_id
WHERE r_name = "kfc"
GROUP BY MONTHNAME(DATE(date))
ORDER BY revenue DESC

-- 10. Find resturant with sales >x 
SELECT r_name, sum(amount) AS "revenue" FROM orders t1
JOIN restaurants t2
ON t1.r_id=t2.r_id
GROUP BY t1.r_id
HAVING revenue>1500

-- 11. find customers who have never ordered
SELECT user_id,name  FROM users
EXCEPT 
SELECT t1.user_id, name  FROM orders t1
JOIN users t2
ON t1.user_id=t2.user_id

-- 12. show order details of a particular 
--     customer in a given data range 
SELECT t1.order_id,date,f_name FROM orders t1
JOIN order_details t2
ON t1.order_id=t2.order_id
JOIN food t3
ON t2.f_id=t3.f_id
WHERE user_id= 2 and date BETWEEN "2022-05-15" and "2022-06-15" 

SELECT t1.order_id,date,f_name FROM orders t1
JOIN order_details t2
ON t1.order_id=t2.order_id
JOIN food t3
ON t2.f_id=t3.f_id
WHERE user_id= 1 and date BETWEEN "2022-05-15" and "2022-06-15" 

-- 13. customer favoirate food 

SELECT name,f_name,count(*) FROM orders t1
JOIN users t2
ON t1.user_id=t2.user_id
JOIN order_details t3
ON t1.order_id=t3.order_id
JOIN food t4
ON t3.f_id=t4.f_id
GROUP BY t1.user_id,t3.order_id 
ORDER BY count(*) DESC

-- 14. find most costly restrant (avg price/ dish)
SELECT r_name,sum(price)/count(*) AS "avg_price"
FROM menu t1
JOIN restaurants t2
ON t1.r_id=t2.r_id
GROUP BY t1.r_id
ORDER BY avg_price DESC limit 1
-- 15. find delivery partner compensation using the formula 
--     (# deliveriies *100+ 1000*avg_rating)
SELECT partner_name,
count(*)*100+1000*AVG(delivery_rating) AS "salary" 
FROM orders t1
JOIN delivery_partner t2
ON t1.partner_id= t2.partner_id
GROUP BY partner_name
ORDER BY salary DESC

-- 16. find revenue per month for a resturant 

-- 17. find correlation between delivery_time and total rating
-- 18. find corr between # order and avg price for all restaurant
-- 19. find all the veg restaurant
SELECT r_name FROM menu t1
JOIN food t2
ON t1.f_id=t2.f_id
JOIN restaurants t3
ON t1.r_id=t3.r_id
GROUP BY t1.r_id
HAVING MIN(type)="veg" AND MAX(type)="veg"

-- 20. find min and max order value for all the customers  
SELECT name,min(amount),max(amount), avg(amount) FROM orders  t1
JOIN users t2
ON t1.user_id = t2.user_id
GROUP BY t1.user_id

