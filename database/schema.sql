-- SIMANTU Database Schema
-- Create database
CREATE DATABASE IF NOT EXISTS simantu_db;
USE simantu_db;

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    permissions JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE SET NULL
);

-- Configurations table
CREATE TABLE IF NOT EXISTS configurations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(255) NOT NULL,
    value TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    data_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_key_category (key_name, category)
);

-- Insert default roles
INSERT INTO roles (name, description, permissions) VALUES
('Super Admin', 'Full system access', '["users.read", "users.create", "users.update", "users.delete", "roles.read", "roles.create", "roles.update", "roles.delete", "configs.read", "configs.create", "configs.update", "configs.delete"]'),
('Admin', 'Administrative access', '["users.read", "users.create", "users.update", "roles.read", "configs.read", "configs.update"]'),
('Manager', 'Management access', '["users.read", "configs.read"]'),
('User', 'Basic user access', '["configs.read"]');

-- Insert default admin user (password: admin123)
INSERT INTO users (name, email, password, role_id) VALUES
('Super Admin', 'admin@simantu.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 1);

-- Insert default configurations
INSERT INTO configurations (key_name, value, category, description, data_type) VALUES
('app_name', 'SIMANTU', 'general', 'Application name', 'string'),
('app_version', '1.0.0', 'general', 'Application version', 'string'),
('maintenance_mode', 'false', 'general', 'Maintenance mode status', 'boolean'),
('max_login_attempts', '5', 'security', 'Maximum login attempts before lockout', 'number'),
('session_timeout', '3600', 'security', 'Session timeout in seconds', 'number'),
('email_notifications', 'true', 'notifications', 'Enable email notifications', 'boolean'),
('backup_frequency', 'daily', 'backup', 'Backup frequency', 'string'),
('max_file_size', '10485760', 'upload', 'Maximum file upload size in bytes', 'number');
