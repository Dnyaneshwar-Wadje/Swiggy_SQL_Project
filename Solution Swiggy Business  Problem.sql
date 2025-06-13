-- 1. Orders & Performance

-- How many total orders have been placed?
SELECT COUNT(*) total_orders
FROM orders;

-- How many orders were successful vs. cancelled?
SELECT order_status ,COUNT(*) Total_orders 
FROM orders
GROUP BY order_status;

-- What is the average order value?
SELECT AVG(price) Average_price
FROM orders;  

-- Which dishes are ordered the most, based on total quantity (successful orders only)?
SELECT dish_ordered, sum(quantity) total_quantity
FROM orders 
WHERE order_status = "Successful"
GROUP BY dish_ordered 
ORDER BY total_quantity DESC;

-- What are the top 5 most ordered dishes in each city?
SELECT city, dish_ordered, total_orders 
FROM (SELECT r.city,o.dish_ordered, count(o.dish_ordered) total_orders,
	DENSE_RANK() OVER(PARTITION BY city ORDER BY count(o.dish_ordered) DESC )top 
	FROM orders o
	JOIN restaurants r on o.restaurant_id = r.restaurant_id 
	GROUP BY r.city,o.dish_ordered 
)top_dishes_by_city 
WHERE top<=5;


-- What is the total revenue generated from successful orders?
SELECT SUM(price)total_revenue
FROM orders
WHERE order_status="Successful";

-- What is the average delivery time in each city?
SELECT r.city,AVG(o.delivery_duration) Average_duration 
FROM orders o
JOIN restaurants r 
ON o.restaurant_id= r.restaurant_id
GROUP BY r.city; 

-- Which city has the highest number of total orders?
SELECT r.city, COUNT(o.order_id) total_orders
FROM restaurants r
JOIN orders o
ON r.restaurant_id =o.restaurant_id
GROUP BY r.city
ORDER BY total_orders DESC 
LIMIT 1;

-- What is the count of successful and cancelled orders by city?
SELECT r.city,o.order_status, COUNT(order_id) total_orders
FROM orders o
join restaurants r
ON o.restaurant_id= r.restaurant_id
GROUP BY r.city,o.order_status
ORDER BY city ;

-- Are cancelled orders more frequent in specific cities?
SELECT r.city,
COUNT(CASE WHEN o.order_status = 'Cancelled' THEN 1 END) AS cancelled_orders,
COUNT(o.order_id) AS total_orders
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY cancelled_orders DESC;


-- What is the cancellation rate per city?
SELECT r.city,
ROUND(COUNT(CASE WHEN o.order_status = 'Cancelled' THEN 1 END)*100  / COUNT(o.order_id),2) AS cancellation_rate
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY cancellation_rate DESC;



 -- 2.  Restaurant Analysis

 -- How many restaurants are available in each city?
SELECT city, COUNT(restaurant_id) total_restaurants
FROM restaurants 
GROUP BY city 
ORDER BY total_restaurants DESC;

-- Which restaurant has received the most number of orders?
SELECT r.restaurant_id,r.restaurant_name,count(o.order_id)total_order
FROM restaurants r
JOIN orders o
ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_id,r.restaurant_name
ORDER BY total_order DESC 
limit 1;

 -- Which are the top 5  revenue-generating restaurants in each city?
 SELECT * 
 FROM (SELECT o.restaurant_id,r.restaurant_name,r.city, SUM(o.price)total_revenue,
	DENSE_RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.price) DESC)top
	FROM orders o
	JOIN restaurants r
	ON o.restaurant_id=r.restaurant_id
	GROUP BY o.restaurant_id,r.restaurant_name,r.city
) top_restaurants
 WHERE top<=5;

 -- Which 5 restaurants have the highest order cancellation counts?
SELECT r.restaurant_id,r.restaurant_name,COUNT(O.order_id)total_orders
FROM orders o
JOIN restaurants r
ON o.restaurant_id=r.restaurant_id
WHERE order_status="Cancelled"
GROUP BY r.restaurant_id,r.restaurant_name
ORDER BY total_orders DESC
LIMIT 5; 
 
 
-- Which 5 restaurants have received the highest number of reviews?
SELECT *
FROM restaurants 
ORDER BY total_reviews DESC
LIMIT 5;



-- 3. Customer Behavior

-- How many customers are there in each city?
SELECT city,COUNT(customer_id)total_customers
FROM customers 
GROUP BY city 
ORDER BY total_customers DESC;

-- What is the average order value per customer?
SELECT c.customer_id, c.customer_name,SUM(o.price),COUNT(o.order_id),SUM(o.price)/ COUNT(o.order_id)as average_order_value
FROM orders o
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY average_order_value DESC;

-- Who are the top 50 most frequent customers based on number of orders?
SELECT o.customer_id, c.customer_name, COUNT(o.order_id) As total_orders
FROM orders o
JOIN customers c
ON orders.customer_id= customers.customer_id
GROUP BY o.customer_id, c.customer_name
ORDER BY total_orders DESC;

-- Who are the top 20 customers by revenue in each city?
SELECT * FROM (SELECT c.customer_id, c.customer_name,C.city, SUM(o.price)total_revenue,
	DENSE_RANK() OVER( PARTITION BY C.city ORDER BY SUM(o.price) DESC)top
	FROM orders o
	JOIN customers c
	ON O.customer_id=c.customer_id 
    GROUP BY c.customer_id, c.customer_name,c.city
)top_customers	 
WHERE TOP<=20;

-- Who are the top 20 most frequent ordering customers in each city?
SELECT * FROM (SELECT c.customer_id, c.customer_name,C.city,COUNT(o.order_id) total_orders,
	ROW_NUMBER() OVER( PARTITION BY C.city ORDER BY SUM(o.price) DESC)top
	FROM orders o
	JOIN customers c
	ON O.customer_id=c.customer_id 
    GROUP BY c.customer_id, c.customer_name,c.city
)top_customers	 
WHERE TOP<=20;



-- 4. Delivery Partner Insights

-- Which delivery partner has delivered the highest number of successful orders?
SELECT p.partner_id,p.partner_name,COUNT(o.order_id)total_order_delivered
FROM orders o
JOIN deliverypartners p
ON o.delivery_partner_id=p.partner_id
WHERE order_status="successful" 
GROUP BY p.partner_id,p.partner_name
ORDER BY total_order_delivered DESC 
LIMIT 1;

-- What is the average delivery time per delivery partner?
SELECT p.partner_id,p.partner_name,SUM(o.delivery_duration)/COUNT(o.order_id) Average_delivery_time_in_min
FROM orders o
JOIN deliverypartners p
ON o.delivery_partner_id = p.partner_id
WHERE o.order_status="Successful"
GROUP BY p.partner_id,p.partner_name 
ORDER BY  Average_delivery_time_in_min;

-- Who are the top 5 fastest delivery partners based on average delivery duration?
SELECT p.partner_id,p.partner_name,SUM(o.delivery_duration)/COUNT(o.order_id) Average_delivery_time_in_min
FROM orders o
JOIN deliverypartners p
ON o.delivery_partner_id = p.partner_id
WHERE o.order_status="Successful"
GROUP BY p.partner_id,p.partner_name 
ORDER BY  Average_delivery_time_in_min
LIMIT 5;



-- 5. Time-Based Trends

-- What are the peak order hours during the day?
SELECT HOUR(order_time) Day_hours, COUNT(order_id) AS total_orders
FROM orders
GROUP BY Day_hours
ORDER BY total_orders DESC;

-- What is the peak order hour in a day? (e.g., lunch/dinner time)
SELECT 
    CASE 
        WHEN HOUR(order_time) BETWEEN 6 AND 11 THEN 'Breakfast'
        WHEN HOUR(order_time) BETWEEN 12 AND 15 THEN 'Lunch'
        WHEN HOUR(order_time) BETWEEN 16 AND 18 THEN 'Snacks'
        WHEN HOUR(order_time) BETWEEN 19 AND 22 THEN 'Dinner'
        ELSE 'Late Night'
    END AS time_slot,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY time_slot
ORDER BY total_orders DESC;

-- What are the monthly revenue trends?
SELECT month(order_time)month, SUM(price)total_revenue
FROM orders
GROUP BY month 
ORDER BY month ASC;	

-- How does the order volume vary across cities over time
SELECT r.city, DATE_FORMAT(o.order_time, '%Y-%m') order_month, COUNT(o.order_id)  total_orders
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.city, order_month
ORDER BY order_month ,total_orders DESC;

-- On which days of the week do we receive the most orders? 
SELECT DAYNAME(order_time) day_of_week, COUNT(order_id)  total_orders
FROM orders
GROUP BY day_of_week 
ORDER BY total_orders DESC;

