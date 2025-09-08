\o C:/sql/q4results.txt
SELECT
  e.employee_id,
  e.first_name || ' ' || e.last_name AS employee,
  COUNT(s.shift_id) AS shifts_per_week,
  SUM(s.end_time - s.start_time) AS total_oncall_duration -- returns an interval
FROM oncall_shift s
JOIN employee e ON s.employee_id = e.employee_id
GROUP BY e.employee_id, employee
ORDER BY total_oncall_duration DESC NULLS LAST;

\o