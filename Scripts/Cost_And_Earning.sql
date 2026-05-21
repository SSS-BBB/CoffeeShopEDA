SHOW TABLES;

SELECT * FROM orders_staging;
SELECT * FROM staff_staging_1;

SELECT MIN(created_at) FROM orders_staging;
SELECT MAX(created_at) FROM orders_staging;
-- Orders from 2024-02-12 to 2024-02-17 (Monday - Saturday)

-- 1. Calculate total staffs payment
SELECT *, sal_per_hour * staff_work_hours AS staff_earnings
FROM staff_staging_1;

SELECT SUM(sal_per_hour * staff_work_hours) AS staff_payment
FROM staff_staging_1;
-- 960

-- 2. Calculate ingredients total cost
SELECT * FROM inventory_staging_1;

SELECT ROUND(SUM(ing_bought_price), 4) AS ing_total_cost
FROM inventory_staging_1;
-- 258.0169

-- 3. Calculate total earning
SELECT *, item_price * ordered_quantity AS item_earning
FROM items_staging_2;

SELECT ROUND(SUM(item_price * ordered_quantity), 4) AS item_total_earning
FROM items_staging_2;
-- 1857.45

-- 4. Calculate profit
SELECT 1857.45 - (960 + 258.0169) AS profit;
-- 639.4331












