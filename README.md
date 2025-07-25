# CoffeeShopEDA
You can see all the datas details at [https://www.kaggle.com/datasets/viramatv/coffee-shop-data](https://www.kaggle.com/datasets/viramatv/coffee-shop-data)

## Create Staging Tables
First, I created staging tables for every tables, so that I can alter tables without affecting the original tables.

Create new table with the same columns as the original.

```sql
CREATE TABLE orders_staging LIKE orders;
```

Insert all the datas from original table to new table.

```sql
INSERT orders_staging
SELECT *
FROM orders;
```

See the results

```sql
SELECT *
FROM orders_staging;
```

## Data Cleaning
### Check Duplicates
We check duplicates by using ROW_NUMBER () with PARTITION BY [column that shouldn't have the same values]. the duplicated rows will gave row_num greater than 1

```sql
WITH check_duplicates AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY staff_id) AS row_num
FROM staff_staging
)
SELECT *
FROM check_duplicates
WHERE row_num > 1;
```

For orders_staging table some rows can have duplicated order_id(different items withing the same recipt). So we check duplicated by order_id and item_id.

```sql
WITH check_duplicates AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id, item_id) AS row_num
FROM orders_staging
)
SELECT *
FROM check_duplicates AS c1
INNER JOIN check_duplicates AS c2 ON c1.order_id = c2.order_id AND c1.item_id = c2.item_id
WHERE c1.row_num = 1 AND c2.row_num > 1;
```

Result
![Duplicated Order](/Images/duplicated_orders.png)
As you can see ORD041 has two It011 withing the recipt, and it was created at the same time. So we will delete the duplicated row, and add the quantity by 1.

```sql
-- Update orders quantity
UPDATE orders_staging
SET quantity = 2
WHERE row_id = 59 AND order_id = "ORD041";

-- Delete duplicated orders
DELETE
FROM orders_staging
WHERE row_id = 60 AND order_id = "ORD041";
```

### Standardize the Data
We want to make sure that the same data has the same values.

Find unique values for each column in every tables. Use ORDER BY to make similar values being near to each others, so we can see and standardize them.

```sql
SELECT DISTINCT ing_name
FROM ingredients_staging
ORDER BY 1;
```