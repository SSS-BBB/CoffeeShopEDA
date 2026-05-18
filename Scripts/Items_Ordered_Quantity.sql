SHOW TABLES;

-- Items Ordered Quantity
WITH items_ordered_quantity AS
(
SELECT item_id, SUM(quantity) AS ordered_quantity
FROM orders_staging
GROUP BY item_id
)
SELECT it.item_id, it.item_name, it.item_size, ito.ordered_quantity FROM items_staging_1 it
LEFT JOIN items_ordered_quantity ito ON it.item_id = ito.item_id;

-- Create items_staging_2 to add column ordered_quantity
CREATE TABLE items_staging_2
LIKE items_staging_1;

ALTER TABLE items_staging_2
ADD ordered_quantity INTEGER;

INSERT items_staging_2
WITH items_ordered_quantity AS
(
SELECT item_id, SUM(quantity) AS ordered_quantity
FROM orders_staging
GROUP BY item_id
)
SELECT it.item_id, it.sku, it.item_name, it.item_cat, it.item_size, it.item_price, it.recipe_cost, it.item_profit_per_unit, ito.ordered_quantity 
FROM items_staging_1 it
LEFT JOIN items_ordered_quantity ito ON it.item_id = ito.item_id;

SELECT * FROM items_staging_2;

-- Average ordered quantity of all items
SELECT AVG(ordered_quantity) FROM items_staging_2;

-- Top 5 Most Ordered Item
WITH ordered_ranking AS
(
SELECT item_id, item_name, item_size, ordered_quantity, 
dense_rank() OVER (ORDER BY ordered_quantity DESC) AS quantity_rank
FROM items_staging_2
)
SELECT * FROM ordered_ranking
WHERE quantity_rank <= 5;

-- Top 5 Least Ordered Item
WITH ordered_ranking AS
(
SELECT item_id, item_name, item_size, ordered_quantity, 
dense_rank() OVER (ORDER BY ordered_quantity) AS quantity_rank
FROM items_staging_2
)
SELECT * FROM ordered_ranking
WHERE quantity_rank <= 5;

