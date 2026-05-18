SHOW TABLES;

SELECT * FROM rota_staging;

SELECT * FROM shift_staging;
-- odd number shift_id is morning shift
-- even number shift_id is evening shif

SELECT * FROM staff_staging;

-- 1. How many staffs on each shift
SELECT shift_id, COUNT(*) AS staffs_count 
FROM rota_staging
GROUP BY shift_id;
-- odd number shif_id has 2 staffs while even number shif_id has 1 staff could be because there are more customers in the morning than the evening

-- 2. How many shifts each staff has
WITH staff_shift_count AS
(
SELECT staff_id, COUNT(*) AS shift_count 
FROM rota_staging
GROUP BY staff_id
)
SELECT * FROM staff_staging st1
LEFT JOIN staff_shift_count st2 ON st1.staff_id = st2.staff_id;

-- 3. staff work hours
SELECT s.shift_id, r.staff_id, s.end_time - s.start_time AS work_hours FROM shift_staging s
JOIN rota_staging r ON s.shift_id = r.shift_id;

WITH shift_work_hours AS
(
SELECT s.shift_id, r.staff_id, s.end_time - s.start_time AS work_hours FROM shift_staging s
JOIN rota_staging r ON s.shift_id = r.shift_id
)
SELECT staff_id, SUM(work_hours) AS staff_work_hours FROM shift_work_hours
GROUP BY staff_id;

WITH staff_work_hours AS
(
WITH shift_work_hours AS
(
SELECT s.shift_id, r.staff_id, s.end_time - s.start_time AS work_hours FROM shift_staging s
JOIN rota_staging r ON s.shift_id = r.shift_id
)
SELECT staff_id, SUM(work_hours) AS staff_work_hours FROM shift_work_hours
GROUP BY staff_id
)
SELECT s1.staff_id, s1.first_name, s1.last_name, s1.position, s1.sal_per_hour, s2.staff_work_hours
FROM staff_staging s1
LEFT JOIN staff_work_hours s2 ON s1.staff_id = s2.staff_id;

-- create staff_staging_1 table to add column staff_work_hours
CREATE TABLE staff_staging_1
LIKE staff_staging;

ALTER TABLE staff_staging_1
ADD staff_work_hours INTEGER;

INSERT staff_staging_1
WITH staff_work_hours AS
(
WITH shift_work_hours AS
(
SELECT s.shift_id, r.staff_id, s.end_time - s.start_time AS work_hours FROM shift_staging s
JOIN rota_staging r ON s.shift_id = r.shift_id
)
SELECT staff_id, SUM(work_hours) AS staff_work_hours FROM shift_work_hours
GROUP BY staff_id
)
SELECT s1.staff_id, s1.first_name, s1.last_name, s1.position, s1.sal_per_hour, s2.staff_work_hours
FROM staff_staging s1
LEFT JOIN staff_work_hours s2 ON s1.staff_id = s2.staff_id;

SELECT * FROM staff_staging_1;

-- staff earnings
SELECT *, sal_per_hour * staff_work_hours AS staff_earnings
FROM staff_staging_1;







