\o C:/sql/q9results.txt

\prompt 'Enter department name: ' dept
\prompt 'Enter start date (YYYY-MM-DD): ' start
\prompt 'Enter end date (YYYY-MM-DD): ' end
\prompt 'Enter number of employees to show: ' n

SELECT
  e.employee_id,
  e.first_name || ' ' || e.last_name AS full_name,
  d.name AS department,
  SUM(p.amount) AS total_paid
FROM payroll p
JOIN employee e ON p.employee_id = e.employee_id
JOIN department d ON e.department_id = d.department_id
WHERE d.name = :'dept'
  AND p.pay_date BETWEEN :'start'::date AND :'end'::date
GROUP BY e.employee_id, full_name, d.name
ORDER BY total_paid DESC
LIMIT :'n';

\o