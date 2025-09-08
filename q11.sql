\o C:/sql/q11results.txt

\prompt 'Enter year (YYYY): ' year

WITH yearly_employee AS (
  SELECT
    e.employee_id,
    e.position_id,
    SUM(p.amount) AS total_pay
  FROM payroll p
  JOIN employee e ON p.employee_id = e.employee_id
  WHERE p.pay_date BETWEEN TO_DATE(:'year' || '-01-01','YYYY-MM-DD')
                       AND TO_DATE(:'year' || '-12-31','YYYY-MM-DD')
  GROUP BY e.employee_id, e.position_id
)
SELECT
  pos.title AS position,
  COUNT(ye.employee_id) AS employees_with_pay,
  ROUND(AVG(ye.total_pay)::numeric,2) AS avg_total_pay,
  MIN(ye.total_pay) AS min_total_pay,
  MAX(ye.total_pay) AS max_total_pay,
  SUM(ye.total_pay) AS sum_total_pay
FROM yearly_employee ye
LEFT JOIN position pos ON ye.position_id = pos.position_id
GROUP BY pos.title
ORDER BY avg_total_pay DESC NULLS LAST;

\o