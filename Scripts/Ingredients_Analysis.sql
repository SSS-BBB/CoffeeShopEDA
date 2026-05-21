SHOW TABLES;

SELECT * FROM ingredients_staging_1;
SELECT * FROM inventory_staging;
SELECT * FROM items_staging_2;
SELECT * FROM recipe_staging;

-- 1. How much each ingredients has been used in total?
SELECT re.ing_id, SUM(re.quantity * it.ordered_quantity) AS ing_used
FROM recipe_staging re
LEFT JOIN items_staging_2 it ON re.recipe_id = it.sku
GROUP BY re.ing_id;

-- 2. How much have we bought each ingredients?
WITH ing_data AS
(
SELECT re.ing_id, SUM(re.quantity * it.ordered_quantity) AS ing_used
FROM recipe_staging re
LEFT JOIN items_staging_2 it ON re.recipe_id = it.sku
GROUP BY re.ing_id
)
SELECT inven.inv_id, inven.ing_id, inven.quantity, ing.ing_used, ing1.ing_price_per_unit, 
ROUND((inven.quantity + ing.ing_used) * ing1.ing_price_per_unit, 4) AS ing_bought_price
FROM inventory_staging inven
LEFT JOIN ing_data ing ON inven.ing_id = ing.ing_id
LEFT JOIN ingredients_staging_1 ing1 ON inven.ing_id = ing1.ing_id;

-- Create inventory_staging_1 to store additional columns
CREATE TABLE IF NOT EXISTS inventory_staging_1
LIKE inventory_staging;

ALTER TABLE inventory_staging_1
ADD ing_used INTEGER,
ADD ing_price_per_unit FLOAT,
ADD ing_bought_price FLOAT;

INSERT inventory_staging_1
WITH ing_data AS
(
SELECT re.ing_id, SUM(re.quantity * it.ordered_quantity) AS ing_used
FROM recipe_staging re
LEFT JOIN items_staging_2 it ON re.recipe_id = it.sku
GROUP BY re.ing_id
)
SELECT inven.inv_id, inven.ing_id, inven.quantity, ing.ing_used, ing1.ing_price_per_unit, 
ROUND((inven.quantity + ing.ing_used) * ing1.ing_price_per_unit, 4) AS ing_bought_price
FROM inventory_staging inven
LEFT JOIN ing_data ing ON inven.ing_id = ing.ing_id
LEFT JOIN ingredients_staging_1 ing1 ON inven.ing_id = ing1.ing_id;

SELECT * FROM inventory_staging_1;

-- Set Null ing_used to 0
UPDATE inventory_staging_1
SET ing_used = 0, ing_bought_price = quantity * ing_price_per_unit
WHERE ing_used IS NULL;

SELECT * FROM inventory_staging_1;




