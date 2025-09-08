
ALTER TABLE position
  ADD CONSTRAINT uq_position_title UNIQUE (title);
-- 3.2.1: add the termination/hire check
ALTER TABLE employee
  ADD CONSTRAINT chk_hire_before_termination
  CHECK (termination_date IS NULL OR hire_date < termination_date);

-- 3.2.2: add birth/age constraint
ALTER TABLE employee
  ADD CONSTRAINT chk_birth_age
  CHECK (birth_date IS NULL OR (date_part('year', age(hire_date, birth_date)) BETWEEN 18 AND 65));

-- 3.2.3: ensure email not empty
ALTER TABLE employee
  ADD CONSTRAINT chk_email_nonempty CHECK (email IS NOT NULL AND btrim(email) <> '');

-- 3.2.4: set hire_date to NOT NULL
ALTER TABLE employee
  ALTER COLUMN hire_date SET NOT NULL;

ALTER TABLE payroll
  ALTER COLUMN employee_id SET NOT NULL,
  ALTER COLUMN amount SET NOT NULL,
  ALTER COLUMN pay_date SET NOT NULL;

ALTER TABLE payroll
  ADD CONSTRAINT chk_payroll_amount_nonneg CHECK (amount >= 0);
ALTER TABLE payroll
  ALTER COLUMN employee_id SET NOT NULL,
  ALTER COLUMN amount SET NOT NULL,
  ALTER COLUMN pay_date SET NOT NULL;

ALTER TABLE payroll
  ADD CONSTRAINT chk_payroll_amount_nonneg CHECK (amount >= 0);

ALTER TABLE oncall_shift
  ALTER COLUMN day_of_week SET NOT NULL,
  ALTER COLUMN start_time SET NOT NULL,
  ALTER COLUMN end_time SET NOT NULL,
  ALTER COLUMN escalation_order SET NOT NULL;

-- ensure day_of_week range & escalation order positivity & start < end
ALTER TABLE oncall_shift
  ADD CONSTRAINT chk_shift_day_range CHECK (day_of_week BETWEEN 1 AND 7),
  ADD CONSTRAINT chk_shift_order CHECK (start_time < end_time),
  ADD CONSTRAINT chk_escalation_positive CHECK (escalation_order > 0);

CREATE OR REPLACE FUNCTION payroll_pay_date_after_hire()
RETURNS TRIGGER AS $$
DECLARE
  emp_hire DATE;
BEGIN
  -- grab the hire_date for the referenced employee
  SELECT hire_date INTO emp_hire FROM employee WHERE employee_id = NEW.employee_id;

  IF emp_hire IS NULL THEN
    RAISE EXCEPTION 'Referenced employee % does not exist or has no hire_date', NEW.employee_id;
  END IF;

  IF NEW.pay_date < emp_hire THEN
    RAISE EXCEPTION 'Payroll pay_date (%) is before employee (%) hire_date (%)',
      NEW.pay_date, NEW.employee_id, emp_hire;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payroll_pay_date_before_ins_upd
BEFORE INSERT OR UPDATE ON payroll
FOR EACH ROW EXECUTE FUNCTION payroll_pay_date_after_hire();


