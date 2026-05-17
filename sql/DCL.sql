USE Final_Project_DB_V2;


--Step 1: Create Login
-- 1 admin: (full access)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'hospital_admin')
CREATE LOGIN hospital_admin WITH PASSWORD = 'admin_hospital123';

-- 5 users 
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'staff_user1')
CREATE LOGIN staff_user1 WITH PASSWORD = 'user1_hospital123';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'staff_user2')
CREATE LOGIN staff_user2 WITH PASSWORD = 'user2_hospital123';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'staff_user3')
CREATE LOGIN staff_user3 WITH PASSWORD = 'user3_hospital123';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'staff_user4')
CREATE LOGIN staff_user4 WITH PASSWORD = 'user4_hospital123';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'staff_user5')
CREATE LOGIN staff_user5 WITH PASSWORD = 'user5_hospital123';

--Step 2: Users mapped to Logins
--admin
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'hospital_admin')
CREATE USER hospital_admin FOR LOGIN hospital_admin;

--5 users
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'staff_user1')
CREATE USER staff_user1 FOR LOGIN staff_user1;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'staff_user2')
CREATE USER staff_user2 FOR LOGIN staff_user2;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'staff_user3')
CREATE USER staff_user3 FOR LOGIN staff_user3;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'staff_user4')
CREATE USER staff_user4 FOR LOGIN staff_user4;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'staff_user5')
CREATE USER staff_user5 FOR LOGIN staff_user5;

--Step 3: Grant ADMIN full access
ALTER ROLE db_owner ADD MEMBER hospital_admin;

--Step 4: Grand USERS view/read
ALTER ROLE db_datareader ADD MEMBER staff_user1;
ALTER ROLE db_datareader ADD MEMBER staff_user2;
ALTER ROLE db_datareader ADD MEMBER staff_user3;
ALTER ROLE db_datareader ADD MEMBER staff_user4;
ALTER ROLE db_datareader ADD MEMBER staff_user5;

--Step 5: Extra safety layer for user
DENY INSERT, UPDATE, DELETE ON Department TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON Appointment TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON Billing TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON Doctor TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON MedicalRecord TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON Medicine TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON Patient TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON Prescription TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON Room TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON Staff TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;
DENY INSERT, UPDATE, DELETE ON RoomAssignment TO staff_user1,staff_user2,staff_user3,staff_user4,staff_user5;

