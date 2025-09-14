-- Fix tasks table relations
USE simantu_db;

-- Add opd_id column to tasks table
ALTER TABLE tasks 
ADD COLUMN opd_id INT,
ADD FOREIGN KEY (opd_id) REFERENCES opd(id) ON DELETE SET NULL;

-- Update existing tasks to use opd_id instead of nama_opd string
UPDATE tasks t 
JOIN opd o ON t.nama_opd = o.nama_opd 
SET t.opd_id = o.id 
WHERE t.nama_opd IS NOT NULL;

-- Add user_id column for tenaga ahli (assuming we'll use users table)
ALTER TABLE tasks 
ADD COLUMN tenaga_ahli_id INT,
ADD FOREIGN KEY (tenaga_ahli_id) REFERENCES users(id) ON DELETE SET NULL;

-- Create a role for tenaga ahli if it doesn't exist
INSERT IGNORE INTO roles (name, description, permissions) VALUES
('Tenaga Ahli', 'Tenaga Ahli role for expert users', '["tasks.read"]');

-- Add some sample tenaga ahli users
INSERT IGNORE INTO users (name, email, password, role_id) VALUES
('Dr. Ahmad Wijaya', 'ahmad.wijaya@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 5),
('Ir. Siti Nurhaliza', 'siti.nurhaliza@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 5),
('Budi Santoso, S.Kom', 'budi.santoso@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 5),
('Dr. Maria Magdalena', 'maria.magdalena@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 5),
('Ir. John Doe', 'john.doe@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 5);
