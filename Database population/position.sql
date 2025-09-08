-- positions
BEGIN;

INSERT INTO position (position_id, title, department_id, description, created_at) VALUES
(1, 'HR Manager', 1, 'Oversees HR and personnel policies', '2024-10-02 18:07'),
(2, 'Payroll Specialist', 1, 'Handles payroll and benefits processing', '2022-08-26 13:55'),
(3, 'Recruiter', 1, 'Finds and onboards new hires', '2020-01-06 19:54'),
(4, 'Travel Agent', 2, 'Books tickets and builds itineraries', '2027-08-07 08:43'),
(5, 'Ticketing Supervisor', 2, 'Supervises ticketing agents', '2026-11-05 11:42'),
(6, 'Support Agent', 3, 'Frontline customer support', '2024-03-15 06:53'),
(7, 'Support Supervisor', 3, 'Leads support agents', '2021-08-24 20:30'),
(8, 'Ad Campaign Manager', 4, 'Plans and runs ad campaigns', '2024-12-15 04:45'),
(9, 'Marketing Specialist', 4, 'Executes marketing tasks', '2025-09-24 20:27'),
(10, 'Payments Specialist', 5, 'Processes payments and reconciliations', '2021-03-02 03:49'),
(11, 'Clearing Analyst', 5, 'Handles clearing operations', '2021-09-13 05:41'),
(12, 'Operations Manager', 6, 'Oversees operations', '2020-08-11 14:24'),
(13, 'General Manager', 6, 'Top-level operations manager', '2026-08-03 12:56'),
(14, 'Partnerships Manager', 7, 'Handles business partnerships', '2027-03-16 21:45'),
(15, 'IT Support', 8, 'Day-to-day IT support', '2022-06-05 04:26'),
(16, 'Sysadmin', 8, 'Manages servers and deployments', '2025-04-22 19:26'),
(17, 'Legal Counsel', 9, 'Legal advice and contract drafting', '2027-09-17 06:52'),
(18, 'Compliance Officer', 9, 'Regulatory compliance', '2024-07-25 10:43'),
(19, 'Accountant', 10, 'Books and reconciles accounts', '2028-02-02 09:18'),
(20, 'Financial Analyst', 10, 'Analyzes financials', '2024-11-19 00:11'),
(21, 'Trainer', 11, 'Delivers training sessions', '2022-03-13 05:47'),
(22, 'Training Coordinator', 11, 'Schedules and manages training', '2027-08-01 03:07'),
(23, 'Logistics Coordinator', 12, 'Manages logistics tasks', '2024-09-25 10:47'),
(24, 'Vendor Manager', 12, 'Handles supplier relations', '2028-11-18 22:26'),
(25, 'Senior Travel Agent', 2, 'Experienced agent for VIPs', '2024-10-03 10:27'),
(26, 'Customer Experience Lead', 3, 'Improves CX across channels', '2021-04-14 12:08'),
(27, 'DevOps Engineer', 8, 'Automates infrastructure', '2027-04-19 23:58'),
(28, 'Data Analyst', 10, 'Insights from customer and sales data', '2028-11-18 03:11'),
(29, 'UX Designer', 4, 'Designs marketing and web UX', '2022-12-17 15:21'),
(30, 'Security Specialist', 8, 'Information security and monitoring', '2024-12-16 09:32');

COMMIT;
