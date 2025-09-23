create database project1;
use project1;
desc products;
select count(*) from transactions_1997;
select count(*) from transactions_1998;
select count(*) from regions;
select count(*) from customers;
select count(*) from products;
select * from regions;
select * from stores;
select * from returns_1997_1998;
select * from transactions_1997; 
select * from transactions_1998;
select * from products;
SELECT *FROM customers;

# ---Foreign key references

alter table transactions_1997
add constraint tran_1997_fk
foreign key (customer_id) references customers(customer_id);

alter table transactions_1998 
add constraint tran_1998_fk
foreign key (customer_id) references customers (customer_id);

alter table returns_1997_1998
add constraint re_978_fk
foreign key (product_id) references products(product_id);

alter table transactions_1997
add constraint t_19_fk
foreign key (product_id) references products(product_id);

alter table transactions_1998
add constraint tra_98_fk
foreign key (product_id) references products(product_id);

alter table returns_1997_1998
add constraint re_99_fk
foreign key (store_id) references stores(store_id);

alter table transactions_1997
add constraint tion_97_fk
foreign key (store_id) references stores(store_id);

alter table transactions_1998
add constraint tan_98_fk
foreign key (store_id) references stores(store_id);

alter table stores
add constraint st_99_fk
foreign key (region_id) references regions(region_id);

alter table customers
drop column customerscol;



		 -- Question Solve

-- Q1. Top 3 products having max revenue?

SELECT p.product_brand, round(SUM(p.product_retail_price * t.quantity),2) 
AS products_max_revenue   
FROM products p 
join transactions_1997 t ON p.product_id = t.product_id
GROUP BY product_brand
ORDER BY products_max_revenue  DESC limit 3;

-- Q2. Top 3 profitable products?

SELECT product_name,round(sum(product_retail_price - product_cost),2)
AS Profittable_products 
FROM products
GROUP BY product_name
ORDER BY Profittable_products DESC
LIMIT 3;

-- Q3. Top 3 customers who had spend max amount?

SELECT c.customer_id, c.first_name, round(sum(p.product_retail_price * t.quantity),2)
AS spend_max_amount
FROM customers c
JOIN transactions_1997 t ON c.customer_id = t.customer_id
JOIN products p ON p.product_id = t.product_id
GROUP BY c.customer_id, c.first_name
ORDER BY spend_max_amount DESC
LIMIT 3;


-- Q4. Top 3 stores with max profit?

SELECT store_name, round(sum((p.product_retail_price-p.product_cost)*t.quantity),2) 
AS profit 
FROM stores s
JOIN transactions_1997 t ON t.store_id = s.store_id 
JOIN products p ON p.product_id = t.product_id
GROUP BY store_name
ORDER BY  profit DESC
LIMIT 3;

-- Q5. Customers who never purchased anything?

SELECT c.customer_id,c.first_name 
FROM customers c
LEFT JOIN transactions_1997 t ON c.customer_id = t.customer_id
WHERE t.customer_id IS NULL;

-- Q6. Customer who never purchased?
SELECT c.customer_id,c.first_name 
FROM customers c
LEFT JOIN transactions_1997 t ON c.customer_id = t.customer_id
WHERE t.customer_id IS NULL;

-- Q7. Customer who purchased 3 months ago but not purchasing now?

SELECT customer_id,transaction_date FROM transactions_1997 
WHERE customer_id NOT IN
(SELECT customer_id  
FROM transactions_1997
WHERE datediff("1997-12--31",transaction_date) <=90
GROUP BY customer_id)
GROUP BY customer_id,transaction_date
ORDER BY transaction_date DESC;

 
-- Q8. Most returned products (more than 10)?

SELECT p.product_id, SUM(r.quantity) 
AS total_returns
FROM products p
JOIN returns_1997_1998 r ON p.product_id = r.product_id
GROUP BY p.product_id
HAVING total_returns > 10
ORDER BY total_returns DESC;


-- Q9. Sales age group(18-30,31-50,>51)

SELECT 
CASE 
WHEN 1997-birthdate BETWEEN 15 AND 30 THEN '18-30'
WHEN 1997-birthdate BETWEEN 31 AND 50 THEN '31-50'
WHEN 1997-birthdate > 50 THEN '>51'
ELSE 'Unknown'
END AS age_group,COUNT(*) AS total_sales,round(SUM(product_retail_price),2) AS total_sales_amount
FROM customers s
JOIN transactions_1997 t ON t.customer_id = s.customer_id 
JOIN products p ON p.product_id = t.product_id
GROUP BY age_group
ORDER BY age_group;


-- Q10. Most popular products among age groups?

WITH product_sales AS (
SELECT p.product_id,p.product_name,
CASE 
WHEN 1998 - YEAR(c.birthdate) BETWEEN 18 AND 30 THEN '18-30'
WHEN 1998 - YEAR(c.birthdate) BETWEEN 30 AND 50 THEN '30-50'
WHEN 1998 - YEAR(c.birthdate) > 50 THEN '>50'
END AS age_group,SUM(t1.quantity) AS total_quantity,COUNT(c.customer_id) AS customer_count FROM customers c
JOIN transactions_1997 t1 ON t1.customer_id = c.customer_id
JOIN products p ON p.product_id = t1.product_id
GROUP BY age_group, p.product_id, p.product_name),ranked_sales AS (
SELECT product_id,product_name,age_group,total_quantity,customer_count,
RANK() OVER (PARTITION BY age_group 
ORDER BY total_quantity DESC) 
AS age_rank FROM product_sales)
SELECT *FROM ranked_sales
WHERE age_rank = 1;

