-- 010_add_role_id_to_users.down.sql
ALTER TABLE users DROP COLUMN IF EXISTS role_id;
