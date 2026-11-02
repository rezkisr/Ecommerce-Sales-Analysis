use ecommerce_sales;

-- CLEANING --
/* 
1. Remove duplicate
2. Check Null values
3. Standardize inconsistent & invalid values
4. Check data type
*/ 

-- Cleaning Table customer_master

create table customer_master_clean
like customer_master;
insert customer_master_clean
select * from customer_master;

-- 1. Check Duplicate
select customer_id, count(*) as duplicates
from customer_master_clean
group by customer_id
having count(*) > 1;

-- 2. Check Null values
select concat(
	 'SUM(CASE WHEN `',column_name,'` IS NULL THEN 1 ELSE 0 END) AS `',column_name,'`,')
from information_schema.columns
where table_name = 'customer_master_clean';

select 
	count(*) as total_rows,
    SUM(CASE WHEN `customer_acquisition_cost` IS NULL THEN 1 ELSE 0 END) AS `customer_acquisition_cost`,
	SUM(CASE WHEN `customer_age` IS NULL THEN 1 ELSE 0 END) AS `customer_age`,
	SUM(CASE WHEN `customer_city` IS NULL THEN 1 ELSE 0 END) AS `customer_city`,
	SUM(CASE WHEN `customer_country` IS NULL THEN 1 ELSE 0 END) AS `customer_country`,
	SUM(CASE WHEN `customer_id` IS NULL THEN 1 ELSE 0 END) AS `customer_id`,
	SUM(CASE WHEN `customer_name` IS NULL THEN 1 ELSE 0 END) AS `customer_name`,
	SUM(CASE WHEN `customer_postal_code` IS NULL THEN 1 ELSE 0 END) AS `customer_postal_code`,
	SUM(CASE WHEN `customer_segment` IS NULL THEN 1 ELSE 0 END) AS `customer_segment`,
	SUM(CASE WHEN `customer_state` IS NULL THEN 1 ELSE 0 END) AS `customer_state`,
	SUM(CASE WHEN `gender` IS NULL THEN 1 ELSE 0 END) AS `gender`,
	SUM(CASE WHEN `region` IS NULL THEN 1 ELSE 0 END) AS `region`
from customer_master_clean;

-- 3. Standardize inconsistent & invalid values

select distinct customer_state
from customer_master_clean
group by customer_state;

/*
Identified an encoding issue:
"Baden-WÃ¼rttemberg" should be "Baden-Württemberg"
*/

update customer_master
set `customer_state` = 'Baden-Württemberg'
where `customer_state` = 'Baden-WÃ¼rttemberg';

-- 4. Modify Data Type
alter table customer_master_clean
modify column customer_acquisition_cost decimal(10,2);
