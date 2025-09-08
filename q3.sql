\o C:/sql/q3results.txt

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

\o