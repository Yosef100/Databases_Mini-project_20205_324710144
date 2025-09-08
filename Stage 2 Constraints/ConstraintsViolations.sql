-- =========================
-- 1) Delete test rows
-- =========================

-- Employee test rows (by known emails used in your script)
DELETE FROM employee
WHERE email IN (
    'nohire_insert@example.com',
    'nohire_update@example.com',
    'term_insert@example.com',
    'term_update@example.com',
    'birth_insert_young@example.com',
    'birth_update@example.com',
    'blank_email_update@example.com',
    'payroll_emp@example.com'
);

-- Payroll test rows
DELETE FROM payroll
WHERE employee_id NOT IN (SELECT employee_id FROM employee);

-- Oncall_shift test rows
DELETE FROM oncall_shift
WHERE employee_id NOT IN (SELECT employee_id FROM employee);

-- =========================
-- 2) Reset sequences
-- =========================

-- Employee
SELECT setval(pg_get_serial_sequence('employee','employee_id'),
              COALESCE((SELECT MAX(employee_id) FROM employee),0) + 1, false);

-- Payroll
SELECT setval(pg_get_serial_sequence('payroll','payroll_id'),
              COALESCE((SELECT MAX(payroll_id) FROM payroll),0) + 1, false);

-- Oncall_shift
SELECT setval(pg_get_serial_sequence('oncall_shift','shift_id'),
              COALESCE((SELECT MAX(shift_id) FROM oncall_shift),0) + 1, false);




-- 1) employee.hire_date NOT NULL
-- illegal INSERT (will fail)
INSERT INTO employee (first_name, last_name, email) VALUES ('NoHire', 'Test', 'nohire_insert@example.com');

-- ensure a legal row exists for the UPDATE/DELETE tests
INSERT INTO employee (first_name, last_name, email, hire_date)
VALUES ('HasHire', 'Test', 'nohire_update@example.com', '2024-01-01');

-- UPDATE that should fail due to NOT NULL (target the row we just created by email)
UPDATE employee
SET hire_date = NULL
WHERE employee_id = (
  SELECT employee_id FROM employee WHERE email = 'nohire_update@example.com'
);

-- DELETE (cleanup of the legal row)
DELETE FROM employee WHERE email = 'nohire_update@example.com';


-- 2) employee.chk_hire_before_termination (termination_date must be after hire_date)
-- illegal INSERT (will fail)
INSERT INTO employee (first_name, last_name, email, hire_date, termination_date)
VALUES ('Term', 'Insert', 'term_insert@example.com', '2024-01-10', '2024-01-01');

-- legal row for UPDATE/DELETE tests
INSERT INTO employee (first_name, last_name, email, hire_date, termination_date)
VALUES ('TermLegal', 'Test', 'term_update@example.com', '2024-01-01', '2024-12-31');

-- UPDATE that should fail (set termination_date before hire_date) targeting that specific employee
UPDATE employee
SET termination_date = (hire_date - INTERVAL '1 day')
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'term_update@example.com');

-- DELETE of the legal row (cleanup)
DELETE FROM employee WHERE email = 'term_update@example.com';


-- 3) employee.chk_birth_age (age at hire between 18 and 65)
-- illegal INSERT (too young -> will fail)
INSERT INTO employee (first_name, last_name, email, hire_date, birth_date)
VALUES ('Young', 'Insert', 'birth_insert_young@example.com', '2024-01-01', '2010-01-02');

-- legal row for UPDATE/DELETE tests (age in range)
INSERT INTO employee (first_name, last_name, email, hire_date, birth_date)
VALUES ('AgeLegal', 'Test', 'birth_update@example.com', '2024-01-01', '1990-01-01');

-- UPDATE that should fail (make birth_date too recent -> under 18)
UPDATE employee
SET birth_date = '2010-01-02'
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'birth_update@example.com');

-- DELETE of the legal row (cleanup)
DELETE FROM employee WHERE email = 'birth_update@example.com';


-- 4) employee.chk_email_nonempty (email not NULL/blank)
-- illegal INSERT (blank email -> will fail)
INSERT INTO employee (first_name, last_name, email, hire_date)
VALUES ('BlankEmail', 'Insert', '   ', '2024-01-01');

-- legal row for UPDATE/DELETE tests
INSERT INTO employee (first_name, last_name, email, hire_date)
VALUES ('EmailLegal', 'Test', 'blank_email_update@example.com', '2024-01-01');

-- UPDATE that should fail (set email to empty string) targeting the known employee
UPDATE employee
SET email = ''
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'blank_email_update@example.com');

-- DELETE of the legal row (cleanup)
DELETE FROM employee WHERE email = 'blank_email_update@example.com';


-- 5) payroll.employee_id NOT NULL
-- illegal INSERT (missing employee_id -> will fail)
INSERT INTO payroll (amount, pay_date) VALUES (100.00, '2024-01-15');

-- prepare a legal employee and payroll row for UPDATE/DELETE tests
INSERT INTO employee (first_name, last_name, email, hire_date)
VALUES ('PayrollEmp', 'Test', 'payroll_emp@example.com', '2024-01-01');

-- insert a legal payroll row for that employee (unique pay_date for easy targeting)
INSERT INTO payroll (employee_id, amount, pay_date)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  100.00, '2024-01-15'
);

-- UPDATE that should fail (set employee_id to NULL) targeting the payroll we inserted
UPDATE payroll
SET employee_id = NULL
WHERE payroll_id = (
  SELECT payroll_id FROM payroll
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND pay_date = '2024-01-15'
  LIMIT 1
);

-- DELETE of the legal payroll row (cleanup)
DELETE FROM payroll
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND pay_date = '2024-01-15';


-- 6) payroll.amount NOT NULL
-- illegal INSERT (missing amount -> will fail)
INSERT INTO payroll (employee_id, pay_date)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  '2024-01-15'
);

-- ensure a legal payroll exists for UPDATE/DELETE tests (unique pay_date)
INSERT INTO payroll (employee_id, amount, pay_date)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  200.00, '2024-02-15'
);

-- UPDATE that should fail (set amount = NULL) targeting that payroll row
UPDATE payroll
SET amount = NULL
WHERE payroll_id = (
  SELECT payroll_id FROM payroll
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND pay_date = '2024-02-15'
  LIMIT 1
);

-- DELETE of the legal payroll row (cleanup)
DELETE FROM payroll
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND pay_date = '2024-02-15';


-- 7) payroll.pay_date NOT NULL
-- illegal INSERT (missing pay_date -> will fail)
INSERT INTO payroll (employee_id, amount)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  50.00
);

-- ensure a legal payroll exists for UPDATE/DELETE tests
INSERT INTO payroll (employee_id, amount, pay_date)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  50.00, '2024-03-01'
);

-- UPDATE that should fail (set pay_date = NULL) targeting that payroll row
UPDATE payroll
SET pay_date = NULL
WHERE payroll_id = (
  SELECT payroll_id FROM payroll
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND pay_date = '2024-03-01'
  LIMIT 1
);

-- DELETE of the legal payroll row (cleanup)
DELETE FROM payroll
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND pay_date = '2024-03-01';


-- 8) payroll.chk_payroll_amount_nonneg (amount >= 0)
-- illegal INSERT (negative amount -> will fail)
INSERT INTO payroll (employee_id, amount, pay_date)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  -100.00, '2024-01-15'
);

-- ensure a legal payroll exists for UPDATE/DELETE tests
INSERT INTO payroll (employee_id, amount, pay_date)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  300.00, '2024-04-01'
);

-- UPDATE that should fail (set negative amount) targeting that payroll row
UPDATE payroll
SET amount = -1.00
WHERE payroll_id = (
  SELECT payroll_id FROM payroll
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND pay_date = '2024-04-01'
  LIMIT 1
);

-- DELETE of the legal payroll row (cleanup)
DELETE FROM payroll
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND pay_date = '2024-04-01';


-- 9) payroll_pay_date_after_hire trigger (pay_date >= employee.hire_date)
-- illegal INSERT (pay_date before hire_date -> trigger raises)
INSERT INTO payroll (employee_id, amount, pay_date)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  100.00, '1900-01-01'
);

-- ensure a legal payroll exists for UPDATE/DELETE tests
INSERT INTO payroll (employee_id, amount, pay_date)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  400.00, '2024-05-01'
);

-- UPDATE that should fail (set pay_date earlier than hire_date) targeting that payroll row
UPDATE payroll
SET pay_date = '1900-01-01'
WHERE payroll_id = (
  SELECT payroll_id FROM payroll
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND pay_date = '2024-05-01'
  LIMIT 1
);

-- DELETE of the legal payroll row (cleanup)
DELETE FROM payroll
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND pay_date = '2024-05-01';


-- 10) oncall_shift.day_of_week NOT NULL
-- illegal INSERT (missing day_of_week -> will fail)
INSERT INTO oncall_shift (employee_id, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  '09:00', '17:00', 1
);

-- insert legal oncall_shift for UPDATE/DELETE tests (unique start_time/end_time)
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  1, '09:00', '17:00', 1
);

-- UPDATE that should fail (set day_of_week = NULL) targeting that shift by shift_id
UPDATE oncall_shift
SET day_of_week = NULL
WHERE shift_id = (
  SELECT shift_id FROM oncall_shift
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND start_time = '09:00' AND end_time = '17:00'
  LIMIT 1
);

-- DELETE of the legal shift row (cleanup)
DELETE FROM oncall_shift
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND start_time = '09:00' AND end_time = '17:00';


-- 11) oncall_shift.day_of_week range (1..7)
-- illegal INSERT (day_of_week = 8 -> will fail)
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  8, '09:00', '10:00', 1
);

-- insert legal shift for UPDATE/DELETE tests
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  2, '09:00', '10:00', 1
);

-- UPDATE that should fail (set day_of_week = 0) targeting that shift by shift_id
UPDATE oncall_shift
SET day_of_week = 0
WHERE shift_id = (
  SELECT shift_id FROM oncall_shift
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND day_of_week = 2 AND start_time = '09:00' AND end_time = '10:00'
  LIMIT 1
);

-- DELETE of the legal shift row (cleanup)
DELETE FROM oncall_shift
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND day_of_week = 2 AND start_time = '09:00' AND end_time = '10:00';


-- 12) oncall_shift.start_time NOT NULL
-- illegal INSERT (missing start_time -> will fail)
INSERT INTO oncall_shift (employee_id, day_of_week, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  1, '17:00', 1
);

-- insert legal shift for UPDATE/DELETE tests
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  3, '08:00', '16:00', 1
);

-- UPDATE that should fail (set start_time = NULL) targeting that shift by shift_id
UPDATE oncall_shift
SET start_time = NULL
WHERE shift_id = (
  SELECT shift_id FROM oncall_shift
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND day_of_week = 3 AND start_time = '08:00' AND end_time = '16:00'
  LIMIT 1
);

-- DELETE of the legal shift row (cleanup)
DELETE FROM oncall_shift
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND day_of_week = 3 AND start_time = '08:00' AND end_time = '16:00';


-- 13) oncall_shift.end_time NOT NULL
-- illegal INSERT (missing end_time -> will fail)
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  1, '09:00', 1
);

-- insert legal shift for UPDATE/DELETE tests
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  4, '09:00', '17:00', 1
);

-- UPDATE that should fail (set end_time = NULL) targeting that shift by shift_id
UPDATE oncall_shift
SET end_time = NULL
WHERE shift_id = (
  SELECT shift_id FROM oncall_shift
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND day_of_week = 4 AND start_time = '09:00' AND end_time = '17:00'
  LIMIT 1
);

-- DELETE of the legal shift row (cleanup)
DELETE FROM oncall_shift
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND day_of_week = 4 AND start_time = '09:00' AND end_time = '17:00';


-- 14) oncall_shift.escalation_order NOT NULL
-- illegal INSERT (missing escalation_order -> will fail)
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  1, '09:00', '10:00'
);

-- insert legal shift for UPDATE/DELETE tests
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  5, '09:00', '10:00', 1
);

-- UPDATE that should fail (set escalation_order = NULL) targeting that shift
UPDATE oncall_shift
SET escalation_order = NULL
WHERE shift_id = (
  SELECT shift_id FROM oncall_shift
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND day_of_week = 5 AND start_time = '09:00' AND end_time = '10:00'
  LIMIT 1
);

-- DELETE of the legal shift row (cleanup)
DELETE FROM oncall_shift
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND day_of_week = 5 AND start_time = '09:00' AND end_time = '10:00';


-- 15) oncall_shift.chk_escalation_positive (escalation_order > 0)
-- illegal INSERT (escalation_order = 0 -> will fail)
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  1, '09:00', '10:00', 0
);

-- insert legal shift for UPDATE/DELETE tests
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  6, '09:00', '10:00', 2
);

-- UPDATE that should fail (set escalation_order = 0) targeting that shift
UPDATE oncall_shift
SET escalation_order = 0
WHERE shift_id = (
  SELECT shift_id FROM oncall_shift
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND day_of_week = 6 AND start_time = '09:00' AND end_time = '10:00'
  LIMIT 1
);

-- DELETE of the legal shift row (cleanup)
DELETE FROM oncall_shift
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND day_of_week = 6 AND start_time = '09:00' AND end_time = '10:00';


-- 16) oncall_shift.chk_shift_order (start_time < end_time)
-- illegal INSERT (start_time >= end_time -> will fail)
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  1, '17:00', '09:00', 1
);

-- insert legal shift for UPDATE/DELETE tests
INSERT INTO oncall_shift (employee_id, day_of_week, start_time, end_time, escalation_order)
VALUES (
  (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com'),
  7, '09:00', '17:00', 1
);

-- UPDATE that should fail (make start_time >= end_time) targeting that shift
UPDATE oncall_shift
SET start_time = '18:00', end_time = '17:00'
WHERE shift_id = (
  SELECT shift_id FROM oncall_shift
  WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
    AND day_of_week = 7 AND start_time = '09:00' AND end_time = '17:00'
  LIMIT 1
);

-- DELETE of the legal shift row (cleanup)
DELETE FROM oncall_shift
WHERE employee_id = (SELECT employee_id FROM employee WHERE email = 'payroll_emp@example.com')
  AND day_of_week = 7 AND start_time = '09:00' AND end_time = '17:00';
