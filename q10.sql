\o C:/sql/q10results.txt

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

\o