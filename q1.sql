\o C:/sql/q1results.txt
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
\o