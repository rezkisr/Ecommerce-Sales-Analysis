USE ecommerce_sales;

-- Import table ecommerce_sales_customer_analytics_150k
create table ecommerce_sales_customer_analytics_150k (
order_id varchar(50),
order_date DATE,
order_time time,
order_status varchar(50),
sales_channel varchar(50),
customer_id varchar(50),
customer_name varchar(100),
customer_age int,
gender varchar(50),
customer_segment varchar(50),
customer_type varchar(50),
customer_city varchar(50),
customer_state varchar(50),
customer_country varchar(50),
region varchar(50),
customer_postal_code varchar(50),
payment_method varchar(50),
payment_status varchar(50),
currency varchar(50),
shipping_method varchar(50),
warehouse varchar(50),
delivery_days int,
estimated_delivery_days int,
delivery_status varchar(50),
return_status text,
return_reason text,
customer_rating decimal(10,2),
review_sentiment varchar(50),
customer_review text,
marketing_channel varchar(50),
campaign_name varchar(50),
coupon_code varchar(50),
loyalty_points_earned int,
loyalty_points_redeemed int,
quantity int,
gross_sales decimal(10,2),
discount_amount decimal(10,2),
tax_amount decimal(10,2),
shipping_cost decimal(10,2),
net_sales decimal(10,2),
product_cost decimal(10,2),
profit decimal(10,2),
profit_margin_percentage decimal(10,2),
customer_lifetime_value decimal(10,2),
is_repeat_customer varchar(50),
customer_order_count int
);

LOAD DATA LOCAL INFILE 'E:/LEARN/Portfolio''s Project/E-Commerce Sales/1.Data/Raw Data/ecommerce_sales_customer_analytics_150k.csv'
INTO TABLE ecommerce_sales_customer_analytics_150k
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table ecommerce_sales_analytics_clean
like ecommerce_sales_customer_analytics_150k;
insert ecommerce_sales_analytics_clean
select * from ecommerce_sales_customer_analytics_150k;

-- CLEANING --
/* 
1. Remove duplicate
2. Check Null or Blank values
*/ 

-- 1. Remove duplicate

select order_id, count(*) as duplicate
from ecommerce_sales_analytics_clean
group by order_id
having count(*) > 1;

-- 2. Check Null and Blank values
	
select concat(
		'SUM(CASE WHEN `',column_name,'` IS NULL OR `',column_name,'` = '''' THEN 1 ELSE 0 END) AS `',column_name,'`,')
from information_schema.columns
where table_name = 'ecommerce_sales_analytics_clean';

select
	count(*) as total_rows,
    SUM(CASE WHEN `order_id` IS NULL OR `order_id` = '' THEN 1 ELSE 0 END) AS `order_id`,
	SUM(CASE WHEN `order_date` IS NULL THEN 1 ELSE 0 END) AS `order_date`,
	SUM(CASE WHEN `order_time` IS NULL THEN 1 ELSE 0 END) AS `order_time`,
	SUM(CASE WHEN `order_status` IS NULL OR `order_status` = '' THEN 1 ELSE 0 END) AS `order_status`,
	SUM(CASE WHEN `sales_channel` IS NULL OR `sales_channel` = '' THEN 1 ELSE 0 END) AS `sales_channel`,
	SUM(CASE WHEN `customer_id` IS NULL OR `customer_id` = '' THEN 1 ELSE 0 END) AS `customer_id`,
	SUM(CASE WHEN `customer_name` IS NULL OR `customer_name` = '' THEN 1 ELSE 0 END) AS `customer_name`,
	SUM(CASE WHEN `customer_age` IS NULL THEN 1 ELSE 0 END) AS `customer_age`,
	SUM(CASE WHEN `gender` IS NULL OR `gender` = '' THEN 1 ELSE 0 END) AS `gender`,
	SUM(CASE WHEN `customer_segment` IS NULL OR `customer_segment` = '' THEN 1 ELSE 0 END) AS `customer_segment`,
	SUM(CASE WHEN `customer_type` IS NULL OR `customer_type` = '' THEN 1 ELSE 0 END) AS `customer_type`,
	SUM(CASE WHEN `customer_city` IS NULL OR `customer_city` = '' THEN 1 ELSE 0 END) AS `customer_city`,
	SUM(CASE WHEN `customer_state` IS NULL OR `customer_state` = '' THEN 1 ELSE 0 END) AS `customer_state`,
	SUM(CASE WHEN `customer_country` IS NULL OR `customer_country` = '' THEN 1 ELSE 0 END) AS `customer_country`,
	SUM(CASE WHEN `region` IS NULL OR `region` = '' THEN 1 ELSE 0 END) AS `region`,
	SUM(CASE WHEN `customer_postal_code` IS NULL OR `customer_postal_code` = '' THEN 1 ELSE 0 END) AS `customer_postal_code`,
	SUM(CASE WHEN `payment_method` IS NULL OR `payment_method` = '' THEN 1 ELSE 0 END) AS `payment_method`,
	SUM(CASE WHEN `payment_status` IS NULL OR `payment_status` = '' THEN 1 ELSE 0 END) AS `payment_status`,
	SUM(CASE WHEN `currency` IS NULL OR `currency` = '' THEN 1 ELSE 0 END) AS `currency`,
	SUM(CASE WHEN `shipping_method` IS NULL OR `shipping_method` = '' THEN 1 ELSE 0 END) AS `shipping_method`,
	SUM(CASE WHEN `warehouse` IS NULL OR `warehouse` = '' THEN 1 ELSE 0 END) AS `warehouse`,
	SUM(CASE WHEN `delivery_days` IS NULL THEN 1 ELSE 0 END) AS `delivery_days`,
	SUM(CASE WHEN `estimated_delivery_days` IS NULL THEN 1 ELSE 0 END) AS `estimated_delivery_days`,
	SUM(CASE WHEN `delivery_status` IS NULL OR `delivery_status` = '' THEN 1 ELSE 0 END) AS `delivery_status`,
	SUM(CASE WHEN `return_status` IS NULL OR `return_status` = '' THEN 1 ELSE 0 END) AS `return_status`,
	SUM(CASE WHEN `return_reason` IS NULL OR `return_reason` = '' THEN 1 ELSE 0 END) AS `return_reason`,
	SUM(CASE WHEN `customer_rating` IS NULL THEN 1 ELSE 0 END) AS `customer_rating`,
	SUM(CASE WHEN `review_sentiment` IS NULL OR `review_sentiment` = '' THEN 1 ELSE 0 END) AS `review_sentiment`,
	SUM(CASE WHEN `customer_review` IS NULL OR `customer_review` = '' THEN 1 ELSE 0 END) AS `customer_review`,
	SUM(CASE WHEN `marketing_channel` IS NULL OR `marketing_channel` = '' THEN 1 ELSE 0 END) AS `marketing_channel`,
	SUM(CASE WHEN `campaign_name` IS NULL OR `campaign_name` = '' THEN 1 ELSE 0 END) AS `campaign_name`,
	SUM(CASE WHEN `coupon_code` IS NULL OR `coupon_code` = '' THEN 1 ELSE 0 END) AS `coupon_code`,
	SUM(CASE WHEN `loyalty_points_earned` IS NULL THEN 1 ELSE 0 END) AS `loyalty_points_earned`,
	SUM(CASE WHEN `loyalty_points_redeemed` IS NULL THEN 1 ELSE 0 END) AS `loyalty_points_redeemed`,
	SUM(CASE WHEN `quantity` IS NULL THEN 1 ELSE 0 END) AS `quantity`,
	SUM(CASE WHEN `gross_sales` IS NULL THEN 1 ELSE 0 END) AS `gross_sales`,
	SUM(CASE WHEN `discount_amount` IS NULL THEN 1 ELSE 0 END) AS `discount_amount`,
	SUM(CASE WHEN `tax_amount` IS NULL THEN 1 ELSE 0 END) AS `tax_amount`,
	SUM(CASE WHEN `shipping_cost` IS NULL THEN 1 ELSE 0 END) AS `shipping_cost`,
	SUM(CASE WHEN `net_sales` IS NULL THEN 1 ELSE 0 END) AS `net_sales`,
	SUM(CASE WHEN `product_cost` IS NULL THEN 1 ELSE 0 END) AS `product_cost`,
	SUM(CASE WHEN `profit` IS NULL THEN 1 ELSE 0 END) AS `profit`,
	SUM(CASE WHEN `profit_margin_percentage` IS NULL THEN 1 ELSE 0 END) AS `profit_margin_percentage`,
	SUM(CASE WHEN `customer_lifetime_value` IS NULL THEN 1 ELSE 0 END) AS `customer_lifetime_value`,
	SUM(CASE WHEN `is_repeat_customer` IS NULL OR `is_repeat_customer` = '' THEN 1 ELSE 0 END) AS `is_repeat_customer`,
	SUM(CASE WHEN `customer_order_count` IS NULL THEN 1 ELSE 0 END) AS `customer_order_count`
from ecommerce_sales_analytics_clean;

-- Identified blank values in return_status and return_reason column

select return_reason, return_status, count(*)
from ecommerce_sales_analytics_clean
group by return_status, return_reason;

/* 
Identified a blank value in return_reason:
The blank value represents transactions that were not returned, rather than missing data.
*/

-- Identified blank values in return_status for delivery_status 'Cancelled'

select
	delivery_status,
    return_status,
    payment_status,
    order_status,
    count(*) as total
from ecommerce_sales_analytics_clean
where delivery_status = 'Cancelled'
group by delivery_status,
		 return_status,
         payment_status,
         order_status;

/*
15,095 cancelled transactions had a blank return_status.
These values were retained because no return was recorded.
*/

-- Identified blank values in review_sentiment and customer_review column

select distinct review_sentiment, count(*)
from ecommerce_sales_analytics_clean
where customer_review is null
or customer_review = ''
group by review_sentiment;

/*
Blank review_sentiment values represent transactions where customers did not provide a review,
so the values were retained as not applicable.
*/ 

-- Identified blank values in campaign_name column

select distinct campaign_name, count(*)
from ecommerce_sales_analytics_clean
group by campaign_name;

/*
Blank values in campaign_name represent transactions that were not associated with a campaign,
so the field is not applicable.
*/

-- Identified blank values in coupon_code column

SELECT
    coupon_code,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN discount_amount > 0 THEN 1 ELSE 0 END) AS with_discount,
    SUM(CASE WHEN discount_amount = 0 THEN 1 ELSE 0 END) AS no_discount
FROM ecommerce_sales_analytics_clean
GROUP BY coupon_code
ORDER BY coupon_code;      

SELECT
    COUNT(*) AS coupon_with_no_discount
	FROM ecommerce_sales_analytics_clean
	WHERE coupon_code <> ''
	  AND discount_amount = 0;

/* 
Blank coupon_code values were investigated against discount_amount.
Of 110,502 transactions with a blank coupon code, 96,266 had a positive discount amount,
indicating that discounts can be applied without a recorded coupon code. 
Conversely, 3,628 transactions had a coupon code but no discount applied. 
Therefore, coupon_code and discount_amount cannot be used interchangeably to determine
whether a discount was applied, so the original values were retained.
*/
