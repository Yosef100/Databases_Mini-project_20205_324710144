\o C:/sql/q8results.txt

DELETE FROM department d
WHERE NOT EXISTS (SELECT 1 FROM position p WHERE p.department_id = d.department_id)
  AND NOT EXISTS (SELECT 1 FROM employee  e WHERE e.department_id = d.department_id);

\o