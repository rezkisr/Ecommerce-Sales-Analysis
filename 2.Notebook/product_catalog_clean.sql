USE ecommerce_sales;

create table product_catalog_clean
like product_catalog;
insert product_catalog_clean
select * from product_catalog;

-- CLEANING --
/* 
1. Remove duplicate
2. Check Null and Blank values
3. Standardize inconsistent & invalid values
4. Check data type
*/ 

-- 1. Remove duplicate

select product_id
from product_catalog_clean
group by product_id
having count(*) > 1;

-- 2. Check Null and Blank values

select concat(
	'SUM(CASE WHEN `',COLUMN_NAME,'` IS NULL OR `',COLUMN_NAME,'` = '''' THEN 1 ELSE 0 END) AS `',COLUMN_NAME,'`,')
from information_schema.columns
where table_name = 'product_catalog_clean';

select
	SUM(CASE WHEN `product_id` IS NULL OR `product_id` = '' THEN 1 ELSE 0 END) AS `product_id`,
	SUM(CASE WHEN `product_name` IS NULL OR `product_name` = '' THEN 1 ELSE 0 END) AS `product_name`,
	SUM(CASE WHEN `product_category` IS NULL OR `product_category` = '' THEN 1 ELSE 0 END) AS `product_category`,
	SUM(CASE WHEN `product_subcategory` IS NULL OR `product_subcategory` = '' THEN 1 ELSE 0 END) AS `product_subcategory`,
	SUM(CASE WHEN `brand` IS NULL OR `brand` = '' THEN 1 ELSE 0 END) AS `brand`,
	SUM(CASE WHEN `supplier` IS NULL OR `supplier` = '' THEN 1 ELSE 0 END) AS `supplier`,
	SUM(CASE WHEN `unit_price` IS NULL THEN 1 ELSE 0 END) AS `unit_price`,
	SUM(CASE WHEN `product_cost` IS NULL THEN 1 ELSE 0 END) AS `product_cost`,
	SUM(CASE WHEN `product_rating` IS NULL THEN 1 ELSE 0 END) AS `product_rating`
from product_catalog_clean;
