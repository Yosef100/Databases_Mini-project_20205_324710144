\o C:/sql/q5results.txt

UPDATE employee
SET active = FALSE
WHERE termination_date IS NOT NULL
  AND termination_date <= CURRENT_DATE
  AND active = TRUE;

\o