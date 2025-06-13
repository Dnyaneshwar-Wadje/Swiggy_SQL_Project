create database swiggy;
use swiggy;
CREATE TABLE orders (
    order_id INT,                          
    customer_id INT,                       
    restaurant_id INT,                      
    dish_ordered VARCHAR(100),             
    order_time DATETIME,                   
    delivery_time DATETIME,                
    order_status VARCHAR(20),              
    price int,                   
    quantity INT,                          
    delivery_address VARCHAR(200),         
    delivery_partner_id INT,               
    delivery_duration INT,                
    expected_delivery_duration INT        
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv"
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;



CREATE TABLE deliverypartners(
	partner_id INT, 
    partner_name VARCHAR(100),
    city VARCHAR(50)
);
    
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/swiggy/deliverypartners.csv"
INTO TABLE deliverypartners
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;    
    
 
CREATE TABLE customers(
	customer_id int,
	customer_name VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    email VARCHAR(50),
    phone_number varchar(20)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/swiggy/customers.CSV"
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS; 
   
CREATE TABLE restaurants(
	restaurant_id INT,
    restaurant_name VARCHAR(50),
    city VARCHAR(50),
    ratings DECIMAL (3,1),
    total_reviews INT
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/swiggy/restaurants.csv"
INTO TABLE restaurants
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS; 
