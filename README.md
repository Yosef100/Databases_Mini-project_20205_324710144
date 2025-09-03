# Databases_Mini-project_20205_324710144
proposal:

# Travel Agency Personnel Schema

This document describes the **Personnel** section of a travel agency database.  
It explains the high-level goals, the chosen entities, relationships, normalization steps, and supported workflows.

---

## High-Level Goals and Intent
The personnel schema was designed to capture the core HR and staffing data needed by a travel agency.  
The goal is to provide a structured way to manage employees, their roles and reporting lines, payroll history, professional licenses, and on-call scheduling.  


# ERD:
<img width="1034" height="571" alt="image" src="https://github.com/user-attachments/assets/638bb5c2-5285-4e3d-935b-1294be0e16a5" />

# DSD:
<img width="1024" height="1024" alt="ChatGPT Image Sep 3, 2025, 03_18_53 PM" src="https://github.com/user-attachments/assets/904a9977-c757-4902-95fe-77dc8a5bdc31" />

The database should make it easy to answer practical questions such as:
- Which employees are in each department and position?  
- Who manages whom?  
- Has every employee been paid appropriately?  
- When do licenses expire?  
- Who is scheduled to be on call at a given time?  

---

## Final Chosen Entities (and Why)

### `department`
- Canonical list of departments (Personnel, Ticketing, Advertising, etc.).  
- Centralizes department names, prevents duplication, and enables consistent reporting.  

### `position`
- Job roles/titles, each linked to a department.  
- Normalizes role definitions so they can be reused across employees and analyzed consistently.  

### `employee`
- Core entity for individuals working at the agency.  
- Stores identifying info, hire/termination dates, birth date, reporting manager (self-reference), emergency contacts, and related notes.  
- Acts as the anchor for payroll, licenses, and on-call scheduling.  

### `payroll`
- Records pay events tied to employees.  
- Supports payroll history queries, compliance checks, and audit trails.  
- Enforces that pay dates cannot precede the employee’s hire date.  

### `employee_license`
- Stores professional certifications or licenses with issued and expiry dates.  
- Allows compliance officers to monitor license validity and upcoming expirations.  

### `oncall_shift`
- Weekly recurring shifts with employee, day of week, start and end time, and escalation order.  
- Supports staffing and escalation processes for customer or operational issues.  

---

## Relationships and Keys
- `position.department_id` → `department.department_id`  
- `employee.department_id` → `department.department_id`  
- `employee.position_id` → `position.position_id`  
- `employee.manager_id` → `employee.employee_id` (self-reference)  
- `payroll.employee_id`, `employee_license.employee_id`, `oncall_shift.employee_id` → `employee.employee_id`  

These relationships maintain referential integrity and make reporting straightforward.  

---

## Normalization Reasoning
- Each table holds atomic values with no repeating groups (1NF).  
- Non-key attributes depend on the whole primary key (2NF).  
- No transitive dependencies; role and department details are separated from employee records (3NF).  
- The only intentional relaxation is using JSONB for emergency contacts, chosen for flexibility where structure varies and query frequency is low.  

---

## Use Cases and Workflows Supported
- **Onboarding:** Add new employees with department, position, manager, and emergency contacts.  
- **Payroll:** Track pay history for each employee, ensuring compliance with hire dates.  
- **Compliance:** Monitor license expirations and maintain valid certification records.  
- **On-call scheduling:** Assign recurring shifts and escalation orders for employees.  
- **Management:** Build reporting structures and analyze department or position distributions.  

---

## What This Design Does Not Cover
- Detailed payroll mechanics (salaries, deductions, taxes, bank accounts).  
- Leave, vacation, or absence tracking.  
- Full audit trails of all data changes.  
- Authentication, authorization, or role-based access control.  
- Automated notifications (license expiry alerts, on-call reminders).  
- Multi-timezone support.

## Data Generation:
https://github.com/Yosef100/Databases_Mini-project_20205_324710144/blob/main/personnel_generator.py

## Dump/Restore Test:
<img width="553" height="295" alt="image" src="https://github.com/user-attachments/assets/2032c380-fb8e-4c5d-9f96-217507f65ae3" />
<img width="566" height="279" alt="image" src="https://github.com/user-attachments/assets/25449eae-aaa4-40ef-a192-2573a52302ee" />

