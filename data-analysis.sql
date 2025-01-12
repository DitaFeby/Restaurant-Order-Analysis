--Objective 1: To understand the overall financial performance of the business.

--1. What is the total revenue?
SELECT 
	SUM(mi.price) AS total_revenue
FROM order_details od
JOIN menu_items mi
ON od.item_id = mi.menu_item_id
;
--the total revenue for three months period is $159.217,9

--2. What are the trends in monthly revenue?
SELECT 
	DATE_TRUNC('month', od.order_date), 
	SUM(mi.price) AS total_revenue
FROM order_details od
JOIN menu_items mi
ON od.item_id = mi.menu_item_id
GROUP BY
	DATE_TRUNC('month', od.order_date)
;
--The total monthly revenue from January to March 2023 shows a steady performance with slight fluctuations.
-- January 2023: Revenue was $53,816.95,
-- February 2023: Revenue slightly decreased to $50,790.35,
-- March 2023: Revenue increased to $54,610.60

--3. What are the trends in weekend and weekday revenue?
SELECT
	CASE
		WHEN EXTRACT(DOW FROM order_date) IN (1,2,3,4,5) THEN 'Weekday'
		WHEN EXTRACT(DOW FROM order_date) IN (0,6) THEN 'Weekend'
	END AS day_type,
	SUM(price) AS total_revenue
FROM
	order_details od
JOIN
	menu_items mi
ON od.item_id = mi.menu_item_id
GROUP BY
	day_type
;
--The total revenue on weekdays ($114,820.55) is significantly higher than on weekends ($44,397.35)

--4. Which menu category contributes the most to total revenue?
SELECT
	mi.category,
	SUM(price) AS total_revenue
FROM
	order_details od
JOIN
	menu_items mi
ON 
	od.item_id = mi.menu_item_id
GROUP BY
	mi.category
;
-- The Italian category generated the highest revenue ($49,462.70), followed by Asian ($46,720.65), Mexican ($34,796.80), and American ($28,237.75)
-- This indicates that Italian and Asian menus are the most popular



--Objective 2: To understand the factors driving the significant difference in sales performance between weekdays and weekends

--1. What menu items are most frequently ordered on weekdays versus weekends?
SELECT
	CASE
		WHEN EXTRACT (DOW FROM od.order_date) IN (1,2,3,4,5) THEN 'Weekday'
		WHEN EXTRACT (DOW FROM od.order_date) IN (0,6) THEN 'Weekend'
	END AS data_type,
	mi.item_name,
	COUNT(od.order_details_id) AS total_order
FROM
	order_details od
JOIN
	menu_items mi
ON
	od.item_id = mi.menu_item_id
GROUP BY
	data_type,
	mi.item_name
ORDER BY
	data_type,
	total_order	DESC
;
--Supprisingly, edamame(451 orders) is the most frequently ordered on weekdays while korean beef bowl(186 orders) is on weekends

--2. What time of day has the highest sales on weekdays versus weekends?
SELECT
	CASE
		WHEN EXTRACT (DOW FROM od.order_date) IN (1,2,3,4,5) THEN 'Weekday'
		WHEN EXTRACT (DOW FROM od.order_date) IN (0,6) THEN 'Weekend'
	END AS date_type,
	EXTRACT (HOUR FROM od.order_time) AS hour_order,
	SUM(mi.price) AS total_sales
FROM
	order_details od
JOIN
	menu_items mi
ON
	od.item_id = mi.menu_item_id
GROUP BY
	date_type,
	EXTRACT (HOUR FROM od.order_time)
ORDER BY
	date_type,
	SUM(mi.price) DESC
;
--both weekdays and weekends are getting the highest sales in lunch time (12-13 PM)
-- But total sales on weekdays are higher (avg $13.000) than on weekends (avg $7.000)
-- For the lowest sales, both are in 10 AM and 11 PM

--3. What menus are most frequently ordered in 12AM - 1PM?
SELECT
	CASE
		WHEN EXTRACT (DOW FROM od.order_date) IN (1,2,3,4,5) THEN 'Weekday'
		WHEN EXTRACT (DOW FROM od.order_date) IN (0,6) THEN 'Weekend'
	END AS date_type,
	mi.category,
	mi.item_name,
	COUNT(od.order_details_id) AS total_order
FROM
	order_details od
JOIN
	menu_items mi
ON
	od.item_id = mi.menu_item_id
WHERE
	od.order_time BETWEEN '12:00:00' AND '14:00:00'
GROUP BY
	date_type,
	mi.category,
	mi.item_name
ORDER BY 
	date_type,
	COUNT(od.order_details_id) DESC
;
--On the weekdays, the top 3 menus are Cheeseburger, Tofu Pad Thai, and Hamburger
--On the weekend are Hamburger, Korean beef bowl, French Fries
-- Even though edamame is most frequently ordered, but it seems that customer prefer to enjoy it not for lunch



-- Objective 3: to understand how each menu item contributes to the overall business success

--1. Which menu are frequently ordered with Edamame? 
SELECT
    mi_other.item_name AS combo_item,
    COUNT(*) AS combo_count
FROM
    order_details od_main
JOIN
    order_details od_other ON od_main.order_id = od_other.order_id
JOIN
    menu_items mi_main ON od_main.item_id = mi_main.menu_item_id
JOIN
    menu_items mi_other ON od_other.item_id = mi_other.menu_item_id
WHERE
    mi_main.item_name = 'Edamame' -- Filter hanya untuk Edamame
    AND mi_other.item_name != 'Edamame' -- Hindari menghitung Edamame itu sendiri
GROUP BY
    mi_other.item_name
ORDER BY
    combo_count DESC
LIMIT 5
;
--Hamburger, Cheeseburger, and Korean beef bowl are menus frequently ordered with Edamame.
--It's quite interesting that Edamame is the popular sidedish combining with Burger, compare to other


--RECOMMENDATIONS
--1. Weekday Optimization
--Lunch Promotion: Maximize weekday lunch sales by introducing lunch combos or discounts that include Edamame with popular main side dishes
-- Pre-Lunch Marketing: Since sales are lowest at 10 AM, consider targeted marketing campaigns, such as promotions for early lunch orders.

--2. Boost Weekend Performance
--Weekend-Exclusive Promotions: Encourage more weekend traffic by offering special deals, such as discounts on Korean Beef Bowl or family-sized meals.
--Brunch Options: Since sales pick up around lunch, introduce brunch specials to capture more early-day sales.

--3. Combo Strategy
--Bundle Offers with Edamame: Create bundled meal deals featuring Edamame and popular main dishes (e.g., Hamburger or Cheeseburger). 
--Highlight its versatility as a side dish in marketing materials.

--4. Operational Enhancements
--Focus on Lunch Rush: Ensure adequate staffing and quick service during lunch hours, especially on weekdays.
--Improve Weekend Service: Investigate potential bottlenecks or inefficiencies affecting weekend performance to improve customer experience
