-- Update SIMANTU Role Permissions
-- This script adds permissions for Tasks, OPD, Analytics, and Dashboard

-- Update Super Admin permissions (Full access to everything)
UPDATE roles SET permissions = '["users.read", "users.create", "users.update", "users.delete", "roles.read", "roles.create", "roles.update", "roles.delete", "configs.read", "configs.create", "configs.update", "configs.delete", "tasks.read", "tasks.create", "tasks.update", "tasks.delete", "opd.read", "opd.create", "opd.update", "opd.delete", "analytics.read", "dashboard.read"]' WHERE id = 1;

-- Update Admin permissions (Administrative access)
UPDATE roles SET permissions = '["users.read", "users.create", "users.update", "roles.read", "configs.read", "configs.update", "tasks.read", "tasks.create", "tasks.update", "opd.read", "opd.create", "opd.update", "analytics.read", "dashboard.read"]' WHERE id = 2;

-- Update Manager permissions (Management access)
UPDATE roles SET permissions = '["users.read", "configs.read", "tasks.read", "tasks.create", "tasks.update", "opd.read", "analytics.read", "dashboard.read"]' WHERE id = 3;

-- Update User permissions (Basic user access)
UPDATE roles SET permissions = '["configs.read", "tasks.read", "dashboard.read"]' WHERE id = 4;

-- Verify the updates
SELECT id, name, permissions FROM roles ORDER BY id;
