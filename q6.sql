\o C:/sql/q6results.txt

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

\o