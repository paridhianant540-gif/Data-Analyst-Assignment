-- Q1: Revenue per channel
SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

-- Q2: Top 10 customers
SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

-- Q3: Monthly profit/loss
WITH revenue AS (
    SELECT MONTH(datetime) AS month,
           SUM(amount) AS revenue
    FROM clinic_sales
    GROUP BY MONTH(datetime)
),
expense AS (
    SELECT MONTH(datetime) AS month,
           SUM(amount) AS expense
    FROM expenses
    GROUP BY MONTH(datetime)
)
SELECT r.month,
       r.revenue,
       e.expense,
       (r.revenue - e.expense) AS profit,
       CASE 
           WHEN (r.revenue - e.expense) > 0 THEN 'Profit'
           ELSE 'Loss'
       END AS status
FROM revenue r
JOIN expense e ON r.month = e.month;

-- Q4: Most profitable clinic per city
WITH profit_calc AS (
    SELECT c.city, cs.cid,
           SUM(cs.amount) AS revenue
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    GROUP BY c.city, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY revenue DESC) AS rnk
    FROM profit_calc
)
SELECT *
FROM ranked
WHERE rnk = 1;

-- Q5: 2nd least profitable clinic per state
WITH profit_calc AS (
    SELECT c.state, cs.cid,
           SUM(cs.amount) AS revenue
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY state ORDER BY revenue ASC) AS rnk
    FROM profit_calc
)
SELECT *
FROM ranked
WHERE rnk = 2;