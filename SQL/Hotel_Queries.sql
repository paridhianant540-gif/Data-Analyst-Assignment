-- Q1 Last booked room
SELECT user_id, room_no
FROM (
    SELECT user_id, room_no,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
    FROM bookings
) t
WHERE rn = 1;


-- Q2 Billing in November 2021
SELECT b.booking_id,
       SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE EXTRACT(MONTH FROM b.booking_date) = 11
  AND EXTRACT(YEAR FROM b.booking_date) = 2021
GROUP BY b.booking_id;


-- Q3 Bills > 1000 in Oct 2021
SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE EXTRACT(MONTH FROM bc.bill_date) = 10
  AND EXTRACT(YEAR FROM bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;


-- Q4 Most & least ordered item per month
WITH item_counts AS (
    SELECT DATE_TRUNC('month', bill_date) AS month,
           item_id,
           SUM(item_quantity) AS total_qty
    FROM booking_commercials
    GROUP BY month, item_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS max_rank,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS min_rank
    FROM item_counts
)
SELECT * FROM ranked
WHERE max_rank = 1 OR min_rank = 1;


-- Q5 Second highest bill per month
WITH bill_amounts AS (
    SELECT DATE_TRUNC('month', bill_date) AS month,
           bill_id,
           SUM(item_quantity * item_rate) AS total
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    GROUP BY month, bill_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total DESC) AS rnk
    FROM bill_amounts
)
SELECT * FROM ranked WHERE rnk = 2;