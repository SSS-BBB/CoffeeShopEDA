SHOW TABLES;

-- Profit Per Unit for Each Items
SELECT * FROM items_staging;

SELECT * FROM recipe_staging;

SELECT * FROM ingredients_staging;

SELECT * FROM inventory_staging;

-- Price Per Unit For Each Ingredients
SELECT *, ROUND(ing_price / ing_amount, 4) AS ing_price_per_unit FROM ingredients_staging;

-- Create new ingredients_staging table to add column ing_price_per_unit
CREATE TABLE ingredients_staging_1
LIKE ingredients_staging;

ALTER TABLE ingredients_staging_1
ADD ing_price_per_unit FLOAT;

INSERT ingredients_staging_1
SELECT *, ROUND(ing_price / ing_amount, 4) AS ing_price_per_unit FROM ingredients_staging;

SELECT * FROM ingredients_staging_1;

-- Calculate each ingredients cost for each recipes
SELECT re.recipe_id, re.ing_id, re.quantity, ing.ing_name, ing.ing_price_per_unit, ROUND(re.quantity * ing.ing_price_per_unit, 4) AS ing_cost
FROM recipe_staging re
JOIN ingredients_staging_1 ing ON re.ing_id = ing.ing_id;

-- Sum ingredients price to see total cost for each recipes
WITH recipe_ing_cost AS
(
SELECT re.recipe_id, re.ing_id, re.quantity, ing.ing_name, ing.ing_price_per_unit, ROUND(re.quantity * ing.ing_price_per_unit, 4) AS ing_cost
FROM recipe_staging re
JOIN ingredients_staging_1 ing ON re.ing_id = ing.ing_id
)
SELECT recipe_id, ROUND(SUM(ing_cost), 4) AS recipe_cost FROM recipe_ing_cost
GROUP BY recipe_id;

-- Create Temporary Table to store each recipes's cost
CREATE TEMPORARY TABLE IF NOT EXISTS recipe_cost_temp (
	recipe_id VARCHAR(100),
    recipe_cost FLOAT
);

INSERT recipe_cost_temp 
WITH recipe_ing_cost AS
(
SELECT re.recipe_id, re.ing_id, re.quantity, ing.ing_name, ing.ing_price_per_unit, ROUND(re.quantity * ing.ing_price_per_unit, 4) AS ing_cost
FROM recipe_staging re
JOIN ingredients_staging_1 ing ON re.ing_id = ing.ing_id
)
SELECT recipe_id, ROUND(SUM(ing_cost), 4) AS recipe_cost FROM recipe_ing_cost
GROUP BY recipe_id;

SELECT * FROM recipe_cost_temp;

-- Add recipe_cost and profit_per_unit for each items
SELECT it.item_id, it.sku, it.item_name, it.item_cat, it.item_size, it.item_price, re.recipe_cost, 
ROUND(it.item_price - re.recipe_cost, 4) AS item_profit_per_unit
FROM items_staging it
JOIN recipe_cost_temp re ON it.sku = re.recipe_id;

-- Create new item_staging table to store recipe_cost and item_profit_per_unit for each items
CREATE TABLE items_staging_1
LIKE items_staging;

ALTER TABLE items_staging_1
ADD recipe_cost FLOAT;

ALTER TABLE items_staging_1
ADD item_profit_per_unit FLOAT;

INSERT items_staging_1
SELECT it.item_id, it.sku, it.item_name, it.item_cat, it.item_size, it.item_price, re.recipe_cost, 
ROUND(it.item_price - re.recipe_cost, 4) AS item_profit_per_unit
FROM items_staging it
JOIN recipe_cost_temp re ON it.sku = re.recipe_id;

SELECT * FROM items_staging_1;

-- Top 5 Most Profitable Items
SELECT *
FROM items_staging_1
ORDER BY item_profit_per_unit DESC
LIMIT 5;

-- Top 5 Least Profitable Items
SELECT *
FROM items_staging_1
ORDER BY item_profit_per_unit
LIMIT 5;




