SELECT
  e.employee_id,
  e.first_name || ' ' || e.last_name AS full_name,
  d.name          AS department,
  p.title         AS position,
  COALESCE(m.first_name || ' ' || m.last_name, '—') AS manager,
  e.email,
  e.hire_date
FROM employee e
LEFT JOIN department d ON e.department_id = d.department_id
LEFT JOIN position p   ON e.position_id = p.position_id
LEFT JOIN employee m   ON e.manager_id = m.employee_id
WHERE e.active = TRUE
ORDER BY e.last_name, e.first_name;

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


SELECT
  el.license_id,
  el.employee_id,
  e.first_name || ' ' || e.last_name AS employee,
  el.license_name,
  el.expiry_date,
  (el.expiry_date - CURRENT_DATE) AS days_until_expiry
FROM employee_license el
JOIN employee e ON el.employee_id = e.employee_id
WHERE el.expiry_date IS NOT NULL
  AND el.expiry_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + INTERVAL '60 days')
ORDER BY el.expiry_date ASC;

SELECT
  e.employee_id,
  e.first_name || ' ' || e.last_name AS employee,
  COUNT(s.shift_id) AS shifts_per_week,
  SUM(s.end_time - s.start_time) AS total_oncall_duration -- returns an interval
FROM oncall_shift s
JOIN employee e ON s.employee_id = e.employee_id
GROUP BY e.employee_id, employee
ORDER BY total_oncall_duration DESC NULLS LAST;

--Q5
UPDATE employee
SET active = FALSE
WHERE termination_date IS NOT NULL
  AND termination_date <= CURRENT_DATE
  AND active = TRUE;

UPDATE employee
SET position_id = (
  SELECT position_id FROM position WHERE title = 'Senior Developer' LIMIT 1
)
WHERE position_id = (
  SELECT position_id FROM position WHERE title = 'Junior Developer' LIMIT 1
)
AND (
  SELECT position_id FROM position WHERE title = 'Senior Developer' LIMIT 1
) IS NOT NULL;

DELETE FROM payroll
WHERE pay_date < (CURRENT_DATE - INTERVAL '7 years');

DELETE FROM department d
WHERE NOT EXISTS (SELECT 1 FROM position p WHERE p.department_id = d.department_id)
  AND NOT EXISTS (SELECT 1 FROM employee  e WHERE e.department_id = d.department_id);

--Q9
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

\prompt 'Enter number of days ahead to check: ' days_ahead

SELECT
  el.employee_id,
  e.first_name || ' ' || e.last_name AS employee,
  COUNT(*) AS expiring_licenses,
  MIN(el.expiry_date) AS nearest_expiry
FROM employee_license el
JOIN employee e ON el.employee_id = e.employee_id
WHERE el.expiry_date IS NOT NULL
  AND el.expiry_date BETWEEN CURRENT_DATE AND (CURRENT_DATE + (:'days_ahead'::int * INTERVAL '1 day'))
GROUP BY el.employee_id, employee
ORDER BY nearest_expiry ASC;

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

\prompt 'Enter day of week (1=Sunday .. 7=Saturday): ' dow
\prompt 'Enter max employee ID: ' max

SELECT
  e1.employee_id AS emp1_id,
  e1.first_name || ' ' || e1.last_name AS emp1_name,
  e2.employee_id AS emp2_id,
  e2.first_name || ' ' || e2.last_name AS emp2_name,
  COUNT(*) AS overlapping_shifts_count,
  MIN(GREATEST(s1.start_time, s2.start_time)) AS first_overlap_start,
  MAX(LEAST(s1.end_time, s2.end_time)) AS last_overlap_end
FROM oncall_shift s1
JOIN oncall_shift s2
  ON s1.day_of_week = s2.day_of_week
  AND s1.shift_id < s2.shift_id
  AND s1.start_time < s2.end_time
  AND s2.start_time < s1.end_time
  AND s1.day_of_week = :'dow'::int
  AND s1.employee_id < :'max'::int
JOIN employee e1 ON s1.employee_id = e1.employee_id
JOIN employee e2 ON s2.employee_id = e2.employee_id
GROUP BY e1.employee_id, emp1_name, e2.employee_id, emp2_name
ORDER BY overlapping_shifts_count DESC, emp1_name, emp2_name;
