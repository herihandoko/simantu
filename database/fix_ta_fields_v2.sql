-- Fix TA fields migration - MySQL compatible version
-- Add new columns to tasks table for TA-specific fields

-- Check and add sub_tasks column
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'sub_tasks'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE tasks ADD COLUMN sub_tasks JSON DEFAULT NULL COMMENT "Sub tasks breakdown untuk TA"',
    'SELECT "Column sub_tasks already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add narasi_pekerjaan column
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'narasi_pekerjaan'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE tasks ADD COLUMN narasi_pekerjaan TEXT DEFAULT NULL COMMENT "Narasi pekerjaan yang dilakukan oleh TA"',
    'SELECT "Column narasi_pekerjaan already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add evidence_files column
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'evidence_files'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE tasks ADD COLUMN evidence_files JSON DEFAULT NULL COMMENT "Evidence files yang diupload TA"',
    'SELECT "Column evidence_files already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add link_url column
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'link_url'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE tasks ADD COLUMN link_url VARCHAR(500) DEFAULT NULL COMMENT "Link URL terkait pekerjaan"',
    'SELECT "Column link_url already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add status_update column
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'status_update'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE tasks ADD COLUMN status_update TEXT DEFAULT NULL COMMENT "Update status dari TA"',
    'SELECT "Column status_update already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add status_updated_at column
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'status_updated_at'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE tasks ADD COLUMN status_updated_at TIMESTAMP NULL COMMENT "Waktu terakhir status diupdate oleh TA"',
    'SELECT "Column status_updated_at already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add status_updated_by column
SET @col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND COLUMN_NAME = 'status_updated_by'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE tasks ADD COLUMN status_updated_by INT DEFAULT NULL COMMENT "User yang mengupdate status terakhir"',
    'SELECT "Column status_updated_by already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add foreign key for status_updated_by (if not exists)
SET @constraint_exists = (
    SELECT COUNT(*)
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND CONSTRAINT_NAME = 'fk_tasks_status_updated_by'
);

SET @sql = IF(@constraint_exists = 0,
    'ALTER TABLE tasks ADD CONSTRAINT fk_tasks_status_updated_by FOREIGN KEY (status_updated_by) REFERENCES users(id) ON DELETE SET NULL',
    'SELECT "Foreign key already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

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

-- Add indexes for better performance (excluding TEXT columns)
CREATE INDEX IF NOT EXISTS idx_tasks_link_url ON tasks(link_url);
CREATE INDEX IF NOT EXISTS idx_tasks_status_updated_at ON tasks(status_updated_at);
CREATE INDEX IF NOT EXISTS idx_tasks_status_updated_by ON tasks(status_updated_by);
CREATE INDEX IF NOT EXISTS idx_task_sub_tasks_task_id ON task_sub_tasks(task_id);
CREATE INDEX IF NOT EXISTS idx_task_sub_tasks_status ON task_sub_tasks(status);
CREATE INDEX IF NOT EXISTS idx_task_evidence_task_id ON task_evidence(task_id);
CREATE INDEX IF NOT EXISTS idx_task_evidence_uploaded_by ON task_evidence(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_task_status_updates_task_id ON task_status_updates(task_id);
CREATE INDEX IF NOT EXISTS idx_task_status_updates_updated_by ON task_status_updates(updated_by);
