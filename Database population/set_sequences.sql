-- Set sequences to the current max values (use if your DDL used SERIAL for ids)

SELECT setval('department_department_id_seq', (SELECT COALESCE(MAX(department_id),0) FROM department), true);
SELECT setval('position_position_id_seq', (SELECT COALESCE(MAX(position_id),0) FROM position), true);
SELECT setval('employee_employee_id_seq', (SELECT COALESCE(MAX(employee_id),0) FROM employee), true);
SELECT setval('payroll_payroll_id_seq', (SELECT COALESCE(MAX(payroll_id),0) FROM payroll), true);
SELECT setval('employee_license_license_id_seq', (SELECT COALESCE(MAX(license_id),0) FROM employee_license), true);
SELECT setval('oncall_shift_shift_id_seq', (SELECT COALESCE(MAX(shift_id),0) FROM oncall_shift), true);
