-- SIMANTU Database Seed Data
USE simantu_db;

-- Additional sample users
INSERT INTO users (name, email, password, role_id) VALUES
('John Doe', 'john@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 2),
('Jane Smith', 'jane@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 3),
('Bob Johnson', 'bob@example.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/8K5K5K.', 4);

-- Additional sample configurations
INSERT INTO configurations (key_name, value, category, description, data_type) VALUES
('theme', 'light', 'ui', 'Default theme', 'string'),
('language', 'en', 'ui', 'Default language', 'string'),
('timezone', 'UTC', 'ui', 'Default timezone', 'string'),
('pagination_size', '10', 'ui', 'Default pagination size', 'number'),
('auto_logout', 'true', 'security', 'Auto logout on inactivity', 'boolean'),
('password_min_length', '8', 'security', 'Minimum password length', 'number'),
('require_2fa', 'false', 'security', 'Require two-factor authentication', 'boolean'),
('log_level', 'info', 'logging', 'Application log level', 'string'),
('cache_ttl', '300', 'performance', 'Cache time to live in seconds', 'number'),
('api_rate_limit', '1000', 'performance', 'API rate limit per hour', 'number');
