-- Update database untuk fitur Tenaga Ahli (TA)
-- Menambahkan field-field khusus untuk role TA

-- 1. Tambah field baru ke tabel tasks untuk TA
ALTER TABLE tasks 
ADD COLUMN narasi_pekerjaan TEXT DEFAULT NULL COMMENT 'Narasi pekerjaan yang dilakukan oleh TA',
ADD COLUMN evidence_url VARCHAR(500) DEFAULT NULL COMMENT 'URL atau path file evidence',
ADD COLUMN link_url VARCHAR(500) DEFAULT NULL COMMENT 'Link URL terkait pekerjaan';

-- 2. Buat tabel subtasks untuk breakdown pekerjaan
CREATE TABLE IF NOT EXISTS subtasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    title VARCHAR(255) NOT NULL COMMENT 'Judul sub task',
    description TEXT DEFAULT NULL COMMENT 'Deskripsi sub task',
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    created_by INT NOT NULL COMMENT 'User yang membuat sub task (biasanya TA)',
    assigned_to INT DEFAULT NULL COMMENT 'User yang ditugaskan (biasanya TA yang sama)',
    start_date DATE DEFAULT NULL,
    due_date DATE DEFAULT NULL,
    completed_at TIMESTAMP NULL,
    progress_percentage INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
);

-- 3. Buat tabel untuk menyimpan file evidence
CREATE TABLE IF NOT EXISTS task_evidence (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    subtask_id INT DEFAULT NULL COMMENT 'Jika evidence terkait sub task tertentu',
    user_id INT NOT NULL COMMENT 'User yang upload evidence',
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    description TEXT DEFAULT NULL COMMENT 'Deskripsi evidence',
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (subtask_id) REFERENCES subtasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Buat tabel untuk status update log (untuk tracking perubahan status)
CREATE TABLE IF NOT EXISTS task_status_updates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task_id INT NOT NULL,
    subtask_id INT DEFAULT NULL COMMENT 'Jika update status sub task',
    user_id INT NOT NULL COMMENT 'User yang melakukan update',
    old_status VARCHAR(50) DEFAULT NULL,
    new_status VARCHAR(50) NOT NULL,
    update_reason TEXT DEFAULT NULL COMMENT 'Alasan perubahan status',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (subtask_id) REFERENCES subtasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. Tambah index untuk performa
CREATE INDEX idx_subtasks_task_id ON subtasks(task_id);
CREATE INDEX idx_subtasks_status ON subtasks(status);
CREATE INDEX idx_subtasks_created_by ON subtasks(created_by);
CREATE INDEX idx_subtasks_assigned_to ON subtasks(assigned_to);
CREATE INDEX idx_task_evidence_task_id ON task_evidence(task_id);
CREATE INDEX idx_task_evidence_subtask_id ON task_evidence(subtask_id);
CREATE INDEX idx_task_status_updates_task_id ON task_status_updates(task_id);
CREATE INDEX idx_task_status_updates_subtask_id ON task_status_updates(subtask_id);

-- 6. Insert role Tenaga Ahli jika belum ada
INSERT IGNORE INTO roles (name, description, permissions) VALUES
('Tenaga Ahli', 'Tenaga Ahli dengan akses khusus untuk breakdown task dan upload evidence', 
'["tasks.read", "tasks.update", "tasks.create", "subtasks.read", "subtasks.create", "subtasks.update", "evidence.upload", "evidence.read"]');
