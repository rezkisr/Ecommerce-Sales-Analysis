
/*
for order-level use from ecommerce table
for item/product-level use from order table
*/

-- ================================ --
-- 		SALES & PROFITABILITY		--
-- ================================ --

-- How have sales and order volume change trended over time?

SELECT 
	YEAR(order_date) AS year,
	MONTH(order_date) AS month,
	SUM(net_sales) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY 
	YEAR(order_date),
	MONTH(order_date)
ORDER BY 
	YEAR(order_date),
	MONTH(order_date);

-- Are there seasonal purchasing patterns?

SELECT 
	YEAR(order_date) AS year,
	MONTH(order_date) AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY 
	YEAR(order_date),
	MONTH(order_date)
ORDER BY 
	YEAR(order_date),
	MONTH(order_date);

-- Which periods show unusual growth or decline?

WITH current AS(
	SELECT
		SUBSTR(order_date, 1, 7) AS year_months,
        SUM(net_sales) AS current_revenue
	FROM ecommerce_sales_analytics_clean
    WHERE order_status = 'Completed'
    GROUP BY SUBSTR(order_date, 1, 7)
),
previous AS(
	SELECT
		year_months,
        current_revenue,
		LAG(current_revenue) OVER(ORDER BY year_months) AS previous_revenue
	FROM current
)
SELECT 
	year_months,
    current_revenue,
    previous_revenue,
    ROUND(((current_revenue - previous_revenue) / NULLIF(previous_revenue, 0)) * 100.0, 2) AS growth
FROM previous
GROUP BY year_months;

-- Which regions generate the highest sales?

SELECT 
	region,
	SUM(net_sales) AS total_revenue
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY region
ORDER BY total_revenue DESC;

-- How have profit and profit margin trended over time?

SELECT
	YEAR(order_date) AS years,
    MONTH(order_date) AS months,
    SUM(profit) AS total_profit,
    ROUND((SUM(profit) / SUM(net_sales) * 100.0), 2) AS profit_margin_pct
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY
	YEAR(order_date),
    MONTH(order_date)
ORDER BY
	YEAR(order_date),
    MONTH(order_date);

-- Do higher discounts increase sales volume?

WITH order_discount AS (
    SELECT
        s.order_id,
        AVG(o.discount_percentage) AS avg_discount,
        SUM(o.quantity) AS total_units_sold,
        SUM(o.net_sales) AS total_revenue
    FROM ecommerce_sales_analytics_clean s
    JOIN order_items_clean o ON s.order_id = o.order_id
    WHERE s.order_status = 'Completed'
    GROUP BY s.order_id
)
SELECT
    CASE
        WHEN avg_discount = 0 THEN 'No Discount'
        WHEN avg_discount <= 0.25 THEN 'Low Discount'
        WHEN avg_discount <= 0.50 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_status,
    COUNT(*) AS total_orders,
    SUM(total_units_sold) AS total_units_sold,
    SUM(total_revenue) AS total_revenue
FROM order_discount
GROUP BY 1
ORDER BY total_revenue DESC;

-- At what discount level does profitability begin to decline?

WITH order_discount AS (
    SELECT
        s.order_id,
        AVG(o.discount_percentage) AS avg_discount,
        SUM(o.net_sales) AS total_revenue,
        SUM(o.profit) AS total_profit
    FROM ecommerce_sales_analytics_clean s
    JOIN order_items_clean o ON s.order_id = o.order_id
    WHERE s.order_status = 'Completed'
    GROUP BY s.order_id
)
SELECT
    CASE
        WHEN avg_discount = 0 THEN 'No Discount'
        WHEN avg_discount <= 0.25 THEN 'Low Discount'
        WHEN avg_discount <= 0.50 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_status,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_profit) * 100.0 / SUM(total_revenue), 2) AS profit_margin_pct
FROM order_discount
GROUP BY 1
ORDER BY profit_margin_pct DESC;

-- How different factors increase or decrase a value?

SELECT
	YEAR(order_date) AS years,
    ROUND(SUM(gross_sales), 2) AS gross_sales,
    ROUND(SUM(tax_amount), 2) AS tax,
    ROUND(SUM(shipping_cost), 2) AS shipping,
    ROUND(SUM(discount_amount), 2) AS discount,
    ROUND(SUM(net_sales), 2) AS total
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY 
	YEAR(order_date)
ORDER BY
	YEAR(order_date);

-- ================================ --
-- 		CUSTOMER INTELLIGENCE		--
-- ================================ --

--  Who are the highest-value customers?

WITH customers AS(
	SELECT
		c.customer_name,
		COUNT(s.order_id) AS total_orders,
        SUM(s.net_sales) AS total_revenue,
        SUM(s.profit) AS total_profit
	FROM ecommerce_sales_analytics_clean s
    JOIN customer_master_clean c ON s.customer_id = c.customer_id
    WHERE s.order_status = 'Completed'
    GROUP BY 
        c.customer_name
)
SELECT 
	customer_name,
    total_orders,
    total_revenue,
    total_profit,
    ROUND((total_profit * 100.0 / total_revenue), 2) AS profit_margin_pct
FROM customers
ORDER BY profit_margin_pct DESC;

-- Which customer segment generate the most revenue?

SELECT
	customer_segment,
    SUM(net_sales) AS total_revenue
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- Does loyalty relate to purchasing frequency or customer value?

SELECT
	customer_type,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT customer_id), 2) AS avg_orders_per_customer,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_clv
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY customer_type
ORDER BY total_orders DESC;

-- Do purchasing patterns differ between regions or demographic groups?

SELECT 
	region,
	COUNT(DISTINCT customer_id) AS total_customers,
	COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT customer_id), 2) AS avg_order_per_customer,
    ROUND(SUM(net_sales) / COUNT(DISTINCT customer_id), 2) AS avg_spending_per_customer
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY region
ORDER BY avg_order_per_customer DESC;

SELECT 
	gender,
	COUNT(DISTINCT customer_id) AS total_customers,
	COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT customer_id), 2) AS avg_order_per_customer,
    ROUND(SUM(net_sales) / COUNT(DISTINCT customer_id), 2) AS avg_spending_per_customer
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY gender
ORDER BY avg_order_per_customer DESC;

SELECT 
	customer_segment,
	COUNT(DISTINCT customer_id) AS total_customers,
	COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT customer_id), 2) AS avg_order_per_customer,
    ROUND(SUM(net_sales) / COUNT(DISTINCT customer_id), 2) AS avg_spending_per_customer
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY customer_segment
ORDER BY avg_order_per_customer DESC;

SELECT 
	CASE
		WHEN customer_age < 30 THEN 'Under Age'
        WHEN customer_age < 50 THEN '30-49'
        ELSE '50+'
	END AS age_groups,
	COUNT(DISTINCT customer_id) AS total_customers,
	COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT customer_id), 2) AS avg_order_per_customer,
    ROUND(SUM(net_sales) / COUNT(DISTINCT customer_id), 2) AS avg_spending_per_customer
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY 1
ORDER BY avg_order_per_customer DESC;

-- How does customer behavior change over time?

SELECT
	YEAR(order_date) AS year,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(COUNT(DISTINCT order_id) /  COUNT(DISTINCT customer_id), 2) AS avg_order_per_customer,
    ROUND(SUM(net_sales) /  COUNT(DISTINCT customer_id), 2)  AS avg_spending_per_customer
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY 
	YEAR(order_date)
ORDER BY
	YEAR(order_date);
    
-- How do discount levels vary across customer segments?

WITH order_discount AS (
    SELECT
        s.order_id,
        s.customer_segment,
        AVG(o.discount_percentage) AS avg_discount
    FROM ecommerce_sales_analytics_clean s
    JOIN order_items_clean o ON s.order_id = o.order_id
    WHERE s.order_status = 'Completed'
    GROUP BY s.order_id, s.customer_segment
)
SELECT
    customer_segment,
    SUM(CASE WHEN avg_discount = 0 THEN 1 ELSE 0 END) AS no_discount,
    SUM(CASE WHEN avg_discount > 0 AND avg_discount <= 0.25 THEN 1 ELSE 0 END) AS low_discount,
    SUM(CASE WHEN avg_discount > 0.25 AND avg_discount <= 0.50 THEN 1 ELSE 0 END) AS medium_discount,
    SUM(CASE WHEN avg_discount > 0.50 THEN 1 ELSE 0 END) AS high_discount,
    COUNT(*) AS total_orders
FROM order_discount
GROUP BY customer_segment;

-- Which regions have the highest-value customers?

WITH customers AS(
	SELECT
		c.customer_id,
        c.region,
		COUNT(s.order_id) AS total_orders,
        SUM(s.net_sales) AS total_spending,
        SUM(s.profit) AS total_profit
	FROM ecommerce_sales_analytics_clean s
    JOIN customer_master_clean c ON s.customer_id = c.customer_id
    WHERE s.order_status = 'Completed'
    GROUP BY
		c.customer_id,
        c.region
)
SELECT
    region,
    ROUND(AVG(total_orders), 2) AS avg_order_per_customer,
    ROUND(AVG(total_spending), 2) AS avg_spend_per_customer,
    ROUND(SUM(total_profit) * 100.0 / NULLIF(SUM(total_spending), 0), 2) AS profit_margin
FROM customers
GROUP BY region
ORDER BY avg_order_per_customer DESC;

-- ================================ --
-- 		 PRODUCT PERFORMANCE		--
-- ================================ --

-- Which products are purchased most often?

SELECT
    p.product_name,
    SUM(o.quantity) AS total_units_sold,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM order_items_clean o
JOIN product_catalog_clean p ON o.product_id = p.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_name
ORDER BY total_units_sold DESC
LIMIT 5;

-- Which products generate the highest revenue and the highest profit?

SELECT
    p.product_name,
    SUM(o.net_sales) AS total_revenue,
    SUM(o.profit) AS total_profit
FROM product_catalog_clean p
JOIN order_items_clean o ON p.product_id = o.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_name
ORDER BY 
	total_revenue DESC,
    total_profit DESC;

-- Which categories dominate revenue?

SELECT
	p.product_category,
	COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.net_sales) AS total_revenue
FROM order_items_clean o
JOIN product_catalog_clean p ON o.product_id = p.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_category
ORDER BY total_revenue DESC
LIMIT 5;

-- How do profit and margin compare across the top five revenue categories?

SELECT 
	p.product_category,
    SUM(o.profit) AS total_profit,
    ROUND((SUM(o.profit) / SUM(o.net_sales) * 100.0), 2) AS profit_margin_pct
FROM order_items_clean o
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
JOIN product_catalog_clean p ON o.product_id = p.product_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_category
ORDER BY total_profit DESC;

-- Which brands contribute the most revenue?

SELECT 
	p.brand,
    SUM(o.net_sales) AS total_revenue
FROM order_items_clean o
JOIN product_catalog_clean p ON o.product_id = p.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.brand
ORDER BY total_revenue DESC;

-- Which Sub-Category has the highest profit across the top 5 revenue categories?

SELECT
	p.product_subcategory,
    SUM(o.profit) AS total_profit,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM order_items_clean o
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
JOIN product_catalog_clean p ON o.product_id = p.product_id
WHERE s.order_status = 'Completed'
  AND p.product_category IN ('Automotive', 'Electronics', 'Home Appliances', 'Jewelry', 'Sports & Outdoors')
GROUP BY p.product_subcategory 
ORDER BY total_profit DESC;

-- Which products have strong demand but weak margins?

SELECT
	p.product_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND((SUM(o.profit) / SUM(o.net_sales) * 100.0), 2) AS profit_margin
FROM order_items_clean o 
JOIN product_catalog_clean p ON o.product_id = p.product_id 
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_name
ORDER BY
	total_orders DESC,
    profit_margin ASC;

-- Which categories combine sales growth with profitability?
	
WITH monthly_category AS (
    SELECT
        p.product_category,
        DATE_FORMAT(s.order_date, '%Y-%m') AS year_months,
        SUM(o.net_sales) AS current_revenue,
        SUM(o.profit) AS total_profit
    FROM order_items_clean o
    JOIN product_catalog_clean p ON o.product_id = p.product_id
    JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
    WHERE s.order_status = 'Completed'
    GROUP BY
        p.product_category,
        DATE_FORMAT(s.order_date, '%Y-%m')
),
previous AS (
    SELECT
        *,
        LAG(current_revenue) OVER (
            PARTITION BY product_category
            ORDER BY year_months
        ) AS previous_revenue
    FROM monthly_category
)
SELECT
    product_category,
    year_months,
    ROUND(
        (current_revenue - previous_revenue) / NULLIF(previous_revenue, 0) * 100.0, 2
    ) AS revenue_growth_pct,
    ROUND(
        total_profit / NULLIF(current_revenue, 0) * 100.0, 2
    ) AS profit_margin_pct
FROM previous
WHERE previous_revenue IS NOT NULL
ORDER BY 
	year_months, 
	revenue_growth_pct DESC;

-- How do discount levels relate to revenue and profitability across product categories?

SELECT
	p.product_category,
	CASE
		WHEN o.discount_percentage = 0 THEN 'No Discount'
		WHEN o.discount_percentage <= 0.25 AND o.discount_percentage > 0 THEN 'Low Discount'
		WHEN o.discount_percentage <= 0.50 AND o.discount_percentage > 0.25 THEN 'Medium Discount'
		ELSE 'High Discount'
	END AS discount_level,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.profit) * 100.0 / NULLIF(SUM(o.net_sales), 0), 2) AS profit_margin_pct
FROM order_items_clean o
JOIN product_catalog_clean p ON o.product_id = p.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
  AND p.product_category IN ('Automotive', 'Electronics', 'Home Appliances', 'Jewelry', 'Sports & Outdoors')
GROUP BY 
	p.product_category,
	CASE
		WHEN o.discount_percentage = 0 THEN 'No Discount'
		WHEN o.discount_percentage <= 0.25 AND o.discount_percentage > 0 THEN 'Low Discount'
		WHEN o.discount_percentage <= 0.50 AND o.discount_percentage > 0.25 THEN 'Medium Discount'
		ELSE 'High Discount' 
	END
ORDER BY
	 p.product_category,
	 FIELD(
        discount_level,
        'No Discount',
        'Low Discount',
        'Medium Discount',
        'High Discount');

-- Which products receive the largest discounts?

SELECT
	p.product_name,
    ROUND(AVG(o.discount_percentage) * 100.0, 2) AS avg_discount_pct
FROM order_items_clean o
JOIN product_catalog_clean p ON o.product_id = p.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_name
ORDER BY avg_discount_pct DESC;

-- Are highly discounted products actually profitable?

SELECT
	p.product_name,
    ROUND(AVG(o.discount_percentage) * 100.0, 2) AS avg_discount_pct,
    ROUND(SUM(o.profit) / NULLIF(SUM(o.net_sales), 0) * 100.0, 2) AS profit_margin_pct
FROM order_items_clean o
JOIN product_catalog_clean p ON o.product_id = p.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_name
ORDER BY avg_discount_pct DESC;

-- Do highly rated products perform better commercially?

SELECT
	p.product_name,
    ROUND(AVG(s.customer_rating), 2) AS avg_rating,
    SUM(o.net_sales) AS total_revenue,
    SUM(o.quantity) AS total_units_sold,
    ROUND(SUM(o.profit) / NULLIF(SUM(o.net_sales), 0) * 100.0, 2) AS profit_margin_pct
FROM order_items_clean o 
JOIN product_catalog_clean p ON o.product_id = p.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_name
ORDER BY avg_rating DESC;

-- Which categories demonstrate stronger customer satisfaction?

SELECT
	p.product_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(s.customer_rating), 2) AS avg_rating
FROM order_items_clean o 
JOIN product_catalog_clean p ON o.product_id = p.product_id
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE s.order_status = 'Completed'
GROUP BY p.product_category
ORDER BY 
	total_orders DESC,
	avg_rating DESC;

-- Does product demand differ between regions?

SELECT
	s.region,
	COUNT(DISTINCT o.order_id) AS total_orders,
	SUM(o.quantity) AS total_units_sold,
    ROUND(
		SUM(o.quantity) / NULLIF(COUNT(DISTINCT o.order_id), 0), 2) AS avg_units_per_order
FROM order_items_clean o
JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
WHERE order_status = 'Completed'
GROUP BY
	s.region
ORDER BY avg_units_per_order DESC;


-- ================================ --
-- 		MARKETING PERFORMANCE		--
-- ================================ --

-- Which acquisition channel attracts the most customers?

SELECT
	marketing_channel,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY marketing_channel
ORDER BY 
	total_orders DESC,
    total_customers DESC;
    
-- Which marketing channels generate the most revenue, and how much does each contribute to total revenue?

WITH revenue AS(
	SELECT
		marketing_channel,
		COUNT(DISTINCT order_id) AS total_orders,
		SUM(net_sales) AS total_revenue
	FROM ecommerce_sales_analytics_clean
	WHERE order_status = 'Completed'
	GROUP BY marketing_channel
)
SELECT 
	*,
    ROUND(total_revenue * 100.0 / sum(total_revenue)OVER(), 2) AS revenue_contribution_pct
FROM revenue
ORDER BY total_revenue DESC;

-- Which sales channel generates the most orders?

SELECT
	sales_channel,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY sales_channel
ORDER BY total_orders DESC;

-- Which channel attracts higher-value customers?

WITH customers AS(
	SELECT
		customer_id,
        marketing_channel,
		COUNT(DISTINCT order_id) AS total_orders,
        SUM(net_sales) AS total_revenue,
        SUM(profit) AS total_profit
	FROM ecommerce_sales_analytics_clean
    WHERE order_status = 'Completed'
    GROUP BY
		customer_id,
		marketing_channel
)
SELECT 
	marketing_channel,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,
    ROUND(AVG(total_profit), 2) AS avg_profit_per_customer,
    ROUND(SUM(total_profit) * 100.0 / NULLIF(SUM(total_revenue), 0), 2) AS profit_margin_pct
FROM customers
GROUP BY marketing_channel
ORDER BY avg_revenue_per_customer DESC;

-- Does purchasing behavior vary by acquisition source?

WITH customers AS(
	SELECT
		customer_id,
        marketing_channel,
		COUNT(DISTINCT order_id) AS total_orders,
        SUM(net_sales) AS total_spending
	FROM ecommerce_sales_analytics_clean
    WHERE order_status = 'Completed'
    GROUP BY
		customer_id,
		marketing_channel
)
SELECT 
	marketing_channel,
    COUNT(*) AS total_customers,
    ROUND(AVG(total_spending), 2) AS avg_spending_per_customer,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,
    ROUND(SUM(total_spending) / NULLIF(SUM(total_orders), 0), 2) AS avg_order_value
FROM customers
GROUP BY marketing_channel
ORDER BY avg_order_value DESC;

-- ================================ --
-- 		 LOGISTICS & RETURNS		--
-- ================================ --

-- Which payment methods are most frequently used?

WITH orders AS(
	SELECT
		payment_method,
		COUNT(DISTINCT order_id) AS total_orders
	FROM ecommerce_sales_analytics_clean
	WHERE order_status = 'Completed'
	GROUP BY payment_method
) 
SELECT
	*,
    ROUND(total_orders * 100.0 / SUM(total_orders) OVER(), 2) AS orders_contribution_pct
FROM orders
ORDER BY total_orders DESC;

-- How does average shipping cost differ across regions?

SELECT
	region,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(shipping_cost) AS total_shipping_cost,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY region
ORDER BY avg_shipping_cost DESC;

-- How does delivery time differ across transactions?

SELECT
    delivery_status,
    COUNT(DISTINCT order_id) AS total_transactions,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days
FROM ecommerce_sales_analytics_clean
GROUP BY delivery_status
ORDER BY avg_delivery_days DESC;

-- Are delayed deliveries associated with lower customer ratings?

SELECT
	delivery_status,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(customer_rating), 2) AS avg_rating
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed' 
  AND delivery_status IN ('Early', 'On Time', 'Delayed')
GROUP BY delivery_status
ORDER BY avg_rating DESC;

-- Does operational performance vary between regions?

SELECT
	region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,
    ROUND(
		COUNT(
			DISTINCT CASE 
					WHEN delivery_status = 'Delayed' THEN order_id
				END) * 100.0
		/ NULLIF(COUNT(
			DISTINCT CASE
					WHEN delivery_status IN ('On Time', 'Early', 'Delayed') THEN order_id
				END), 0),
			2) AS delay_rate_pct
FROM ecommerce_sales_analytics_clean
WHERE order_status = 'Completed'
GROUP BY region
ORDER BY delay_rate_pct DESC;

-- Which products are most frequently associated with returned orders?

WITH product_return AS(
	SELECT
		p.product_id,
		p.product_name,
        COUNT(
			DISTINCT CASE 
				WHEN s.order_status IN ('Completed', 'Returned') THEN s.order_id
		END) AS total_orders,    
		COUNT(
			DISTINCT CASE
				WHEN s.return_status = 'Returned' 
                THEN s.order_id 
			END) AS total_returned
	FROM order_items_clean o
    JOIN product_catalog_clean p ON o.product_id = p.product_id
    JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
    GROUP BY 
		p.product_id,
        p.product_name
)
SELECT
	product_name,
	ROUND(
		total_returned * 100.0 /
        NULLIF(total_orders, 0), 2) AS return_rate_pct
FROM product_return
ORDER BY return_rate_pct DESC;

-- Which product categories have the highest return rate among eligible orders?

WITH category_return AS(
	SELECT
		p.product_category,
        COUNT(
			DISTINCT CASE 
				WHEN s.order_status IN ('Completed', 'Returned') THEN s.order_id
			END) AS total_orders,
		COUNT(
			DISTINCT CASE
				WHEN s.return_status = 'Returned' THEN s.order_id
			END) AS total_returned
	FROM order_items_clean o
    JOIN product_catalog_clean p ON o.product_id = p.product_id
    JOIN ecommerce_sales_analytics_clean s ON o.order_id = s.order_id
    GROUP BY 
        p.product_category
)
SELECT
	product_category,
	ROUND(
		total_returned * 100.0 /
        NULLIF(total_orders, 0), 2) AS return_rate_pct
FROM category_return
ORDER BY return_rate_pct DESC;

-- What are the most common return reasons?

SELECT 
	return_reason,
    COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_sales_analytics_clean 
GROUP BY return_reason
ORDER BY total_orders DESC;

-- Are certain customer groups more likely to return purchases?

SELECT
	customer_segment,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(
		DISTINCT CASE
			WHEN return_status = 'Returned' THEN order_id
		END) AS total_returned,
	ROUND(COUNT(
			DISTINCT CASE
				WHEN return_status = 'Returned'THEN order_id
			END) * 100.0
		/ NULLIF(COUNT(
			DISTINCT CASE
				WHEN order_status IN ('Completed', 'Returned') THEN order_id
			END), 0),
			2) AS return_rate_pct
FROM ecommerce_sales_analytics_clean
GROUP BY customer_segment
ORDER BY return_rate_pct DESC;

-- Are return patterns consistent across markets?

SELECT
	sales_channel,
      COUNT(DISTINCT order_id) AS total_orders,
    COUNT(
		DISTINCT CASE
			WHEN return_status = 'Returned' THEN order_id
	END) AS total_returned,
	ROUND(COUNT(
			DISTINCT CASE
				WHEN return_status = 'Returned' THEN order_id
			END) * 100.0
		/ NULLIF(COUNT(
			DISTINCT CASE
				WHEN order_status IN ('Completed', 'Returned') THEN order_id
			END), 0),
			2) AS return_rate_pct
FROM ecommerce_sales_analytics_clean
GROUP BY sales_channel
ORDER BY return_rate_pct DESC;