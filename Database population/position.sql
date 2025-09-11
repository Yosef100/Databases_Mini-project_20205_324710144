-- positions
BEGIN;

INSERT INTO position (position_id, title, department_id, description, created_at) VALUES
(1, 'HR Manager', 1, 'Oversees HR and personnel policies', '2028-08-21 09:08'),
(2, 'Payroll Specialist', 1, 'Handles payroll and benefits processing', '2029-07-09 16:55'),
(3, 'Recruiter', 1, 'Finds and onboards new hires', '2028-11-28 11:11'),
(4, 'Travel Agent', 2, 'Books tickets and builds itineraries', '2021-09-21 19:19'),
(5, 'Ticketing Supervisor', 2, 'Supervises ticketing agents', '2028-10-18 12:24'),
(6, 'Support Agent', 3, 'Frontline customer support', '2023-08-31 12:54'),
(7, 'Support Supervisor', 3, 'Leads support agents', '2025-10-28 21:45'),
(8, 'Ad Campaign Manager', 4, 'Plans and runs ad campaigns', '2025-10-15 22:46'),
(9, 'Marketing Specialist', 4, 'Executes marketing tasks', '2027-12-02 04:49'),
(10, 'Payments Specialist', 5, 'Processes payments and reconciliations', '2022-04-11 13:17'),
(11, 'Clearing Analyst', 5, 'Handles clearing operations', '2025-03-24 16:11'),
(12, 'Operations Manager', 6, 'Oversees operations', '2026-01-05 03:20'),
(13, 'General Manager', 6, 'Top-level operations manager', '2024-04-08 15:57'),
(14, 'Partnerships Manager', 7, 'Handles business partnerships', '2027-01-16 08:18'),
(15, 'IT Support', 8, 'Day-to-day IT support', '2022-10-14 22:44'),
(16, 'Sysadmin', 8, 'Manages servers and deployments', '2025-01-07 21:21'),
(17, 'Legal Counsel', 9, 'Legal advice and contract drafting', '2021-02-05 13:42'),
(18, 'Compliance Officer', 9, 'Regulatory compliance', '2022-12-18 03:10'),
(19, 'Accountant', 10, 'Books and reconciles accounts', '2024-07-03 10:04'),
(20, 'Financial Analyst', 10, 'Analyzes financials', '2021-05-29 09:14'),
(21, 'Trainer', 11, 'Delivers training sessions', '2020-04-24 01:18'),
(22, 'Training Coordinator', 11, 'Schedules and manages training', '2025-11-11 00:04'),
(23, 'Logistics Coordinator', 12, 'Manages logistics tasks', '2029-12-19 19:39'),
(24, 'Vendor Manager', 12, 'Handles supplier relations', '2020-05-29 00:08'),
(25, 'Senior Travel Agent', 2, 'Experienced agent for VIPs', '2026-06-26 04:08'),
(26, 'Customer Experience Lead', 3, 'Improves CX across channels', '2029-03-03 21:51'),
(27, 'DevOps Engineer', 8, 'Automates infrastructure', '2029-07-08 10:48'),
(28, 'Data Analyst', 10, 'Insights from customer and sales data', '2025-11-07 03:37'),
(29, 'UX Designer', 4, 'Designs marketing and web UX', '2025-07-20 07:29'),
(30, 'Security Specialist', 8, 'Information security and monitoring', '2021-11-29 06:18');

COMMIT;
