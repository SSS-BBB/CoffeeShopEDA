-- DATA FROM: https://www.kaggle.com/datasets/viramatv/coffee-shop-data

-- Stage Database
CREATE TABLE orders_staging
LIKE orders;

INSERT orders_staging
SELECT *
FROM orders;

SELECT *
FROM orders_staging;

-- Check Duplicates
SELECT * FROM staff_staging;

WITH check_duplicates AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY staff_id) AS row_num
FROM staff_staging
)
SELECT *
FROM check_duplicates
WHERE row_num > 1;


SELECT * FROM orders_staging;

WITH check_duplicates AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id, item_id) AS row_num
FROM orders_staging
)
SELECT *
FROM check_duplicates AS c1
INNER JOIN check_duplicates AS c2 ON c1.order_id = c2.order_id AND c1.item_id = c2.item_id
WHERE c1.row_num = 1 AND c2.row_num > 1;

-- Duplicate order_id means diffrent items ordered within that receipt -> no need to delete some duplicated order_id
-- However at row_id 59 and 60, order_id ORD041 item_id It011 has been bought twice withing that receipt, so we can drop that duplicated row and increase quantity by 1

-- Update orders quantity
UPDATE orders_staging
SET quantity = 2
WHERE row_id = 59 AND order_id = "ORD041";

-- Delete duplicated orders
DELETE
FROM orders_staging
WHERE row_id = 60 AND order_id = "ORD041";


-- Standardize the Data
SELECT *
FROM ingredients_staging;

-- Change column name
ALTER TABLE ingredients_staging
RENAME COLUMN ing_weight to ing_amount;

ALTER TABLE ingredients_staging
RENAME COLUMN ing_meas to ing_unit;

-- Check uniques data for similar values
SELECT *
FROM staff_staging;

SELECT DISTINCT position
FROM staff_staging
ORDER BY 1;



