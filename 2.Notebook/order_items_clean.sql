USE ecommerce_sales;

-- Import table order_items
CREATE TABLE order_items(
order_id varchar(50),
product_id varchar(50),
quantity int,
unit_price decimal(10,2),
discount_percentage decimal(10,2),
discount_amount decimal(10,2),
gross_sales decimal(10,2),
tax_amount decimal(10,2),
shipping_cost decimal(10,2),
net_sales decimal(10,2),
product_cost decimal(10,2),
profit decimal(10,2)
);

LOAD DATA LOCAL INFILE 'E:/LEARN/Portfolio''s Project/E-Commerce Sales/1.Data/order_items.csv'
INTO TABLE order_items 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table order_items_clean
like order_items;
insert order_items_clean
select * from order_items;

-- CLEANING --
/* 
1. Remove duplicate
2. Check Null or Blank values
*/ 

-- 1. Remove duplicate

select *
from order_items_clean
where 
	(order_id, product_id, quantity, unit_price, discount_percentage, discount_amount,
    gross_sales, tax_amount, shipping_cost, net_sales, product_cost, profit) IN (
		select order_id, product_id, quantity, unit_price, discount_percentage, discount_amount,
			   gross_sales, tax_amount, shipping_cost, net_sales, product_cost, profit
		from order_items_clean
		group by order_id, product_id, quantity, unit_price, discount_percentage, discount_amount,
				 gross_sales, tax_amount, shipping_cost, net_sales, product_cost, profit
		having COUNT(*) > 1
)
order by order_id, product_id;

-- 2. Check Null or Blank values

select concat(
	'SUM(CASE WHEN `',COLUMN_NAME,'` IS NULL THEN 1 ELSE 0 END) AS `',COLUMN_NAME,'`,')
from information_schema.columns
where table_name = 'order_items_clean';

select 
	SUM(CASE WHEN `order_id` IS NULL OR `order_id` = '' THEN 1 ELSE 0 END) AS `order_id`,
	SUM(CASE WHEN `product_id` IS NULL OR `product_id` = '' THEN 1 ELSE 0 END) AS `product_id`,
	SUM(CASE WHEN `quantity` IS NULL THEN 1 ELSE 0 END) AS `quantity`,
	SUM(CASE WHEN `unit_price` IS NULL THEN 1 ELSE 0 END) AS `unit_price`,
	SUM(CASE WHEN `discount_percentage` IS NULL THEN 1 ELSE 0 END) AS `discount_percentage`,
	SUM(CASE WHEN `discount_amount` IS NULL THEN 1 ELSE 0 END) AS `discount_amount`,
	SUM(CASE WHEN `gross_sales` IS NULL THEN 1 ELSE 0 END) AS `gross_sales`,
	SUM(CASE WHEN `tax_amount` IS NULL THEN 1 ELSE 0 END) AS `tax_amount`,
	SUM(CASE WHEN `shipping_cost` IS NULL THEN 1 ELSE 0 END) AS `shipping_cost`,
	SUM(CASE WHEN `net_sales` IS NULL THEN 1 ELSE 0 END) AS `net_sales`,
	SUM(CASE WHEN `product_cost` IS NULL THEN 1 ELSE 0 END) AS `product_cost`,
	SUM(CASE WHEN `profit` IS NULL THEN 1 ELSE 0 END) AS `profit`
from order_items_clean;
