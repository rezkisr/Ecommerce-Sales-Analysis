USE ecommerce_sales;

create table dataset_statistics_clean
like dataset_statistics;
insert dataset_statistics_clean
select * from dataset_statistics;

select * from dataset_statistics_clean;

-- Validate the results for all columns --

-- Total Transactions

select `Total Transactions`, 
	(select count(*) from ecommerce_sales_analytics_clean) as validate
from dataset_statistics_clean;

-- Total Columns

select `Total Columns`,
	(select count(*) from information_schema.columns
	where table_schema = database()
	  and table_name = 'ecommerce_sales_analytics_clean') as validate
from dataset_statistics_clean;

-- Total Customers

select `Total Customers`,
	(select count(distinct customer_id) from ecommerce_sales_analytics_clean) as validate
from dataset_statistics_clean;

-- Total Products Used

/*
Total Products Used should be removed because ecommerce_sales_analytics_clean 
does not contain a product identifier (such as product_id or product name),
so there is no reliable column or metric available to validate it.
*/

alter table dataset_statistics_clean
drop column `Total Products Used`;

-- Date Range

select `Date Range`,
	(select	min(order_date) from ecommerce_sales_analytics_clean) as date_min,
	(select	max(order_date) from ecommerce_sales_analytics_clean) as date_max
from dataset_statistics_clean;

-- Total Revenue

select `Total Revenue`,
	(select sum(net_sales) from ecommerce_sales_analytics_clean) as validate
from dataset_statistics_clean;

-- Average Order Value

select `Average Order Value`,
	(select round(avg(net_sales), 2) from ecommerce_sales_analytics_clean) as validate
from dataset_statistics_clean;

-- Average Rating

select `Average Rating`,
	(select round(avg(customer_rating), 2) from ecommerce_sales_analytics_clean) as validate
from dataset_statistics_clean;

update dataset_statistics_clean
set `Average Rating` = 3.02
where `Average Rating` = 3.68;

/*
Updated Average Rating from 3.68 to 3.02 after validation against ecommerce_sales_analytics_clean.
The original value did not match the calculated average of customer_rating.
*/

-- Return Rate

select `Return Rate`,
	round((select sum(case when return_status = 'Returned' then 1 else 0 end) * 100.0 / count(*)
	from ecommerce_sales_analytics_clean
    ), 2) as validate
from dataset_statistics_clean;

-- Cancellation Rate

select `Cancellation Rate`,
	round((select sum(case when order_status = 'Cancelled' then 1 else 0 end) * 100.0 / count(*)
    from ecommerce_sales_analytics_clean
    ), 2) as validate
from dataset_statistics_clean;
