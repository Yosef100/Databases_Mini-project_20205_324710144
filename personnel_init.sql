-- personnel_init_constrained.sql
-- DDL for personnel schema with additional constraints and trigger-based checks.
-- Notes:
--  * Date-range constraints (2020-2030) are intentionally NOT enforced here per request.
--  * The "every employee must have at least one payroll row" constraint is implemented
--    as a DEFERRABLE constraint trigger; during bulk loads make sure payroll rows are
--    inserted in the same transaction before COMMIT (or temporarily disable the trigger).
--  * The "pay_date >= hire_date" constraint is enforced with a BEFORE INSERT/UPDATE trigger
--    on the payroll table so that it can compare cross-table values.
--  * Age check uses PostgreSQL date_part(age()) to measure years between hire_date and birth_date.
--
-- Usage for bulk import that inserts employees and payroll in separate files:
--   BEGIN;
--   \i employee.sql
--   \i payroll.sql
--   COMMIT;
-- This works because the employee-check trigger below is DEFERRABLE and INITIALLY DEFERRED.

DROP TABLE IF EXISTS oncall_shift CASCADE;
DROP TABLE IF EXISTS employee_license CASCADE;
DROP TABLE IF EXISTS payroll CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS position CASCADE;
DROP TABLE IF EXISTS department CASCADE;

CREATE TABLE department (
  department_id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP
);

CREATE TABLE position (
  position_id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL UNIQUE,
  department_id INT REFERENCES department(department_id) ON DELETE SET NULL,
  description TEXT,
  created_at TIMESTAMP
);

CREATE TABLE employee (
  employee_id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(50),
  birth_date DATE,
  hire_date DATE NOT NULL,
  termination_date DATE,
  active BOOLEAN DEFAULT true,
  department_id INT REFERENCES department(department_id),
  position_id INT REFERENCES position(position_id),
  manager_id INT REFERENCES employee(employee_id),
  emergency_contacts JSONB,
  notes TEXT,
  created_at TIMESTAMP,
  -- Constraints:
  -- 1) termination_date, if present, must be after hire_date
  CONSTRAINT chk_hire_before_termination CHECK (termination_date IS NULL OR hire_date < termination_date),
  -- 2) birth_date, if present, must be 18..65 years before hire_date
  CONSTRAINT chk_birth_age CHECK (birth_date IS NULL OR (date_part('year', age(hire_date, birth_date)) BETWEEN 18 AND 65))
);

CREATE TABLE payroll (
  payroll_id SERIAL PRIMARY KEY,
  employee_id INT NOT NULL REFERENCES employee(employee_id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL,
  pay_date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP
  -- Note: cross-table constraint "pay_date >= employee.hire_date" is enforced with a trigger below.
);

CREATE TABLE employee_license (
  license_id SERIAL PRIMARY KEY,
  employee_id INT REFERENCES employee(employee_id) ON DELETE CASCADE,
  license_name VARCHAR(200),
  issued_date DATE,
  expiry_date DATE,
  notes TEXT,
  created_at TIMESTAMP
);

CREATE TABLE oncall_shift (
  shift_id SERIAL PRIMARY KEY,
  employee_id INT REFERENCES employee(employee_id) ON DELETE CASCADE,
  day_of_week INT NOT NULL CHECK (day_of_week >= 1 AND day_of_week <= 7),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  escalation_order INT NOT NULL CHECK (escalation_order > 0),
  created_at TIMESTAMP,
  CONSTRAINT chk_shift_order CHECK (start_time < end_time)
);

-- Indexes
CREATE INDEX idx_employee_email ON employee(email);
CREATE INDEX idx_employee_department ON employee(department_id);
CREATE INDEX idx_payroll_employee ON payroll(employee_id);
CREATE INDEX idx_license_employee ON employee_license(employee_id);
CREATE INDEX idx_shift_employee ON oncall_shift(employee_id);

-- ======================================================================
-- Trigger: enforce payroll.pay_date >= employee.hire_date
-- ======================================================================
CREATE OR REPLACE FUNCTION payroll_pay_date_after_hire()
RETURNS TRIGGER AS $$
DECLARE
  emp_hire DATE;
BEGIN
  -- retrieve hire date for the referenced employee
  SELECT hire_date INTO emp_hire FROM employee WHERE employee_id = NEW.employee_id;
  IF emp_hire IS NULL THEN
    RAISE EXCEPTION 'Referenced employee % does not exist or has no hire_date', NEW.employee_id;
  END IF;
  IF NEW.pay_date < emp_hire THEN
    RAISE EXCEPTION 'Payroll pay_date (%) is before employee (%) hire_date (%)', NEW.pay_date, NEW.employee_id, emp_hire;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payroll_pay_date_before_ins_upd
BEFORE INSERT OR UPDATE ON payroll
FOR EACH ROW EXECUTE FUNCTION payroll_pay_date_after_hire();

-- ======================================================================
-- Deferred constraint trigger: ensure every employee has at least one payroll row
-- This trigger is DEFERRABLE and INITIALLY DEFERRED so that imports which insert employees
-- and payroll in the same transaction will succeed. If you insert employees without payroll,
-- the trigger will raise an exception at COMMIT time.
-- ======================================================================
CREATE OR REPLACE FUNCTION ensure_employees_have_payroll()
RETURNS TRIGGER AS $$
DECLARE
  missing_count INT;
BEGIN
  -- Count any employees who do not have a payroll row
  SELECT COUNT(*) INTO missing_count
  FROM employee e
  WHERE NOT EXISTS (SELECT 1 FROM payroll p WHERE p.employee_id = e.employee_id);

  IF missing_count > 0 THEN
    RAISE EXCEPTION 'Constraint violation: % employee(s) have no payroll rows', missing_count;
  END IF;

  RETURN NULL; -- for constraint triggers, return value is ignored
END;
$$ LANGUAGE plpgsql;

-- Create a constraint trigger that is deferrable (checked at transaction end)
CREATE CONSTRAINT TRIGGER trg_employees_have_payroll
AFTER INSERT OR UPDATE ON employee
DEFERRABLE INITIALLY DEFERRED
FOR EACH STATEMENT
EXECUTE FUNCTION ensure_employees_have_payroll();

-- ======================================================================
-- Additional helpful constraints/checks (optional)
-- - Prevent email from being empty string
-- - Ensure amount in payroll is non-negative
-- ======================================================================
ALTER TABLE employee
  ADD CONSTRAINT chk_email_nonempty CHECK (email IS NOT NULL AND btrim(email) <> '');

ALTER TABLE payroll
  ADD CONSTRAINT chk_payroll_amount_nonneg CHECK (amount >= 0);

-- End of DDL
