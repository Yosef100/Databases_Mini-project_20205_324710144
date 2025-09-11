-- departments
BEGIN;

INSERT INTO department (department_id, name, description, created_at) VALUES
(1, 'Personnel', 'Human Resources and personnel management', '2026-08-14 13:42'),
(2, 'Ticketing', 'Handles bookings and ticket issuance', '2023-02-06 22:06'),
(3, 'Customer Support', 'Customer support and post-booking assistance', '2022-06-28 23:17'),
(4, 'Advertising', 'Marketing and ad campaigns', '2023-01-13 13:16'),
(5, 'Payment Clearing', 'Payment processing and reconciliation', '2024-11-11 01:43'),
(6, 'Operations', 'General operations and management', '2024-12-25 00:02'),
(7, 'Business Development', 'New partnerships and deals', '2024-10-23 15:13'),
(8, 'IT', 'Infrastructure and support', '2024-11-18 12:55'),
(9, 'Legal & Compliance', 'Contracts, compliance, licensing', '2025-10-21 10:28'),
(10, 'Finance', 'Budgeting and financial reporting', '2026-02-06 12:59'),
(11, 'Training', 'Employee training and certification', '2024-05-29 12:21'),
(12, 'Logistics', 'Vendor and supplier coordination', '2028-10-13 12:44');

COMMIT;
