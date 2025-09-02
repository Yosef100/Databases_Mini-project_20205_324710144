-- departments
BEGIN;

INSERT INTO department (department_id, name, description, created_at) VALUES
(1, 'Personnel', 'Human Resources and personnel management', '2020-02-17 11:01'),
(2, 'Ticketing', 'Handles bookings and ticket issuance', '2029-11-06 14:59'),
(3, 'Customer Support', 'Customer support and post-booking assistance', '2027-12-19 17:38'),
(4, 'Advertising', 'Marketing and ad campaigns', '2028-10-14 08:20'),
(5, 'Payment Clearing', 'Payment processing and reconciliation', '2020-04-21 21:40'),
(6, 'Operations', 'General operations and management', '2025-03-10 05:52'),
(7, 'Business Development', 'New partnerships and deals', '2024-03-26 11:45'),
(8, 'IT', 'Infrastructure and support', '2029-10-19 13:07'),
(9, 'Legal & Compliance', 'Contracts, compliance, licensing', '2029-10-22 00:06'),
(10, 'Finance', 'Budgeting and financial reporting', '2029-03-16 23:10'),
(11, 'Training', 'Employee training and certification', '2021-10-19 12:52'),
(12, 'Logistics', 'Vendor and supplier coordination', '2022-04-16 20:52');

COMMIT;
