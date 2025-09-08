\o C:/sql/q2results.txt
SELECT
  date_trunc('month', pay_date)                AS month,
  COUNT(*)                                     AS payments_count,
  SUM(amount)::numeric(18,2)                   AS total_paid,
  ROUND(AVG(amount)::numeric,2)                AS avg_payment,
  MIN(amount)                                  AS smallest_payment,
  MAX(amount)                                  AS largest_payment
FROM payroll
GROUP BY date_trunc('month', pay_date)
ORDER BY month DESC;

\o