\o C:/sql/q7results.txt

DELETE FROM payroll
WHERE pay_date < (CURRENT_DATE - INTERVAL '7 years');

\o