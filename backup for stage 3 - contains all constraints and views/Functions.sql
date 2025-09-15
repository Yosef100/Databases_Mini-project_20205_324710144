-- Functions.sql
-- Purpose: Reusable helpers for Stage 3
-- fn_full_name(emp_id): concat first/last name from employee
-- fn_license_status(expiry): expired / expires_soon / active (30d rule)
-- fn_monthly_pay(emp_id, yr, mon): SUM(amount) for month
-- fn_department_headcount(dept_id): active employees in department

CREATE OR REPLACE FUNCTION fn_full_name(emp_id INT) RETURNS TEXT LANGUAGE sql AS $$
  SELECT e.first_name || ' ' || e.last_name FROM employee e WHERE e.employee_id = emp_id;
$$;

CREATE OR REPLACE FUNCTION fn_license_status(expiry DATE) RETURNS TEXT LANGUAGE plpgsql AS $$
BEGIN
  IF expiry < CURRENT_DATE THEN RETURN 'expired';
  ELSIF expiry <= CURRENT_DATE + INTERVAL '30 days' THEN RETURN 'expires_soon';
  ELSE RETURN 'active';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION fn_monthly_pay(emp_id INT, yr INT, mon INT) RETURNS NUMERIC LANGUAGE sql AS $$
  SELECT COALESCE(SUM(amount),0) FROM payroll
  WHERE employee_id = emp_id
    AND EXTRACT(YEAR FROM pay_date)=yr
    AND EXTRACT(MONTH FROM pay_date)=mon;
$$;

CREATE OR REPLACE FUNCTION fn_department_headcount(dept_id INT) RETURNS INT LANGUAGE sql AS $$
  SELECT COUNT(*) FROM employee WHERE department_id = dept_id AND active=TRUE;
$$;
