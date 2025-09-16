-- Add supporting tables for TA functionality
-- This script creates the supporting tables for TA role features

-- Create table for sub tasks management
CREATE TABLE IF NOT EXISTS task_sub_tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Create table for evidence files
CREATE TABLE IF NOT EXISTS task_evidence (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    description TEXT,
    uploaded_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Create table for status updates history
CREATE TABLE IF NOT EXISTS task_status_updates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    update_message TEXT,
    updated_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Add foreign key constraint for status_updated_by if it doesn't exist
SET @constraint_exists = (
    SELECT COUNT(*)
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND CONSTRAINT_NAME = 'fk_tasks_status_updated_by'
);

SET @sql = IF(@constraint_exists = 0,
    'ALTER TABLE tasks ADD CONSTRAINT fk_tasks_status_updated_by FOREIGN KEY (status_updated_by) REFERENCES users(id) ON DELETE SET NULL',
    'SELECT "Foreign key constraint already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add indexes for better performance
CREATE INDEX idx_task_sub_tasks_task_id ON task_sub_tasks(task_id);
CREATE INDEX idx_task_sub_tasks_status ON task_sub_tasks(status);
CREATE INDEX idx_task_evidence_task_id ON task_evidence(task_id);
CREATE INDEX idx_task_evidence_uploaded_by ON task_evidence(uploaded_by);
CREATE INDEX idx_task_status_updates_task_id ON task_status_updates(task_id);
CREATE INDEX idx_task_status_updates_updated_by ON task_status_updates(updated_by);
