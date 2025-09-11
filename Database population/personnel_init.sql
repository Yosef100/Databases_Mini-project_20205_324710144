DROP TABLE IF EXISTS oncall_shift CASCADE;
DROP TABLE IF EXISTS employee_license CASCADE;
DROP TABLE IF EXISTS payroll CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS position CASCADE;
DROP TABLE IF EXISTS department CASCADE;

CREATE TABLE department (
  department_id SERIAL PRIMARY KEY,
  name VARCHAR(200),
  description TEXT,
  created_at TIMESTAMP
);

CREATE TABLE position (
  position_id SERIAL PRIMARY KEY,
  title VARCHAR(200),
  department_id INT REFERENCES department(department_id) ON DELETE SET NULL,
  description TEXT,
  created_at TIMESTAMP
);

CREATE TABLE employee (
  employee_id SERIAL PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255),
  phone VARCHAR(50),
  address VARCHAR(255),
  birth_date DATE,
  hire_date DATE,
  termination_date DATE,
  active BOOLEAN DEFAULT true,
  department_id INT REFERENCES department(department_id),
  position_id INT REFERENCES position(position_id),
  manager_id INT REFERENCES employee(employee_id),
  emergency_contacts JSONB,
  notes TEXT,
  created_at TIMESTAMP
);

CREATE TABLE payroll (
  payroll_id SERIAL PRIMARY KEY,
  employee_id INT REFERENCES employee(employee_id) ON DELETE CASCADE,
  amount NUMERIC(12,2),
  pay_date DATE,
  notes TEXT,
  created_at TIMESTAMP
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
  day_of_week INT,
  start_time TIME,
  end_time TIME,
  escalation_order INT,
  created_at TIMESTAMP
);
