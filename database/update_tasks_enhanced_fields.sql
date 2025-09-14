-- Update tasks table with enhanced fields
-- Add new columns to support additional useful fields

-- Add new columns to tasks table
ALTER TABLE tasks 
ADD COLUMN estimasi_durasi INT DEFAULT NULL COMMENT 'Estimasi durasi dalam hari',
ADD COLUMN progress_percentage INT DEFAULT 0 COMMENT 'Progress percentage (0-100)',
ADD COLUMN tags JSON DEFAULT NULL COMMENT 'Tags untuk kategorisasi',
ADD COLUMN attachments JSON DEFAULT NULL COMMENT 'File attachments',
ADD COLUMN comments JSON DEFAULT NULL COMMENT 'Comments/notes',
ADD COLUMN dependencies JSON DEFAULT NULL COMMENT 'Task dependencies',
ADD COLUMN estimated_hours DECIMAL(5,2) DEFAULT NULL COMMENT 'Estimasi jam kerja',
ADD COLUMN actual_hours DECIMAL(5,2) DEFAULT NULL COMMENT 'Jam kerja aktual',
ADD COLUMN start_date DATE DEFAULT NULL COMMENT 'Tanggal mulai tugas',
ADD COLUMN milestone VARCHAR(255) DEFAULT NULL COMMENT 'Milestone atau fase proyek',
ADD COLUMN budget DECIMAL(12,2) DEFAULT NULL COMMENT 'Budget untuk tugas',
ADD COLUMN actual_cost DECIMAL(12,2) DEFAULT NULL COMMENT 'Biaya aktual',
ADD COLUMN risk_level ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low' COMMENT 'Tingkat risiko',
ADD COLUMN complexity ENUM('simple', 'moderate', 'complex', 'very_complex') DEFAULT 'moderate' COMMENT 'Tingkat kompleksitas';

-- Create task_comments table for better comment management
CREATE TABLE IF NOT EXISTS task_comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create task_attachments table for file management
CREATE TABLE IF NOT EXISTS task_attachments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create task_dependencies table for task relationships
CREATE TABLE IF NOT EXISTS task_dependencies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    depends_on_task_id INT NOT NULL,
    dependency_type ENUM('finish_to_start', 'start_to_start', 'finish_to_finish', 'start_to_finish') DEFAULT 'finish_to_start',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (depends_on_task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    UNIQUE KEY unique_dependency (task_id, depends_on_task_id)
);

-- Create task_time_logs table for time tracking
CREATE TABLE IF NOT EXISTS task_time_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NULL,
    duration_minutes INT DEFAULT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create task_history table for audit trail
CREATE TABLE IF NOT EXISTS task_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    old_value JSON DEFAULT NULL,
    new_value JSON DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Add indexes for better performance
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_tenaga_ahli ON tasks(tenaga_ahli_id);
CREATE INDEX idx_tasks_opd ON tasks(opd_id);
CREATE INDEX idx_tasks_created_by ON tasks(created_by);
CREATE INDEX idx_tasks_due_date ON tasks(tanggal_selesai);
CREATE INDEX idx_tasks_progress ON tasks(progress_percentage);
CREATE INDEX idx_task_comments_task_id ON task_comments(task_id);
CREATE INDEX idx_task_attachments_task_id ON task_attachments(task_id);
CREATE INDEX idx_task_dependencies_task_id ON task_dependencies(task_id);
CREATE INDEX idx_task_time_logs_task_id ON task_time_logs(task_id);
CREATE INDEX idx_task_history_task_id ON task_history(task_id);
