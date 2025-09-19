-- Add missing indexes for TA fields
-- This script adds indexes that might be missing

-- Check and add indexes for better performance
SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND INDEX_NAME = 'idx_tasks_link_url'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_tasks_link_url ON tasks(link_url)',
    'SELECT "Index idx_tasks_link_url already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add status_updated_at index
SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND INDEX_NAME = 'idx_tasks_status_updated_at'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_tasks_status_updated_at ON tasks(status_updated_at)',
    'SELECT "Index idx_tasks_status_updated_at already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add status_updated_by index
SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'tasks'
    AND INDEX_NAME = 'idx_tasks_status_updated_by'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_tasks_status_updated_by ON tasks(status_updated_by)',
    'SELECT "Index idx_tasks_status_updated_by already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add task_sub_tasks indexes
SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'task_sub_tasks'
    AND INDEX_NAME = 'idx_task_sub_tasks_task_id'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_task_sub_tasks_task_id ON task_sub_tasks(task_id)',
    'SELECT "Index idx_task_sub_tasks_task_id already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'task_sub_tasks'
    AND INDEX_NAME = 'idx_task_sub_tasks_status'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_task_sub_tasks_status ON task_sub_tasks(status)',
    'SELECT "Index idx_task_sub_tasks_status already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add task_evidence indexes
SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'task_evidence'
    AND INDEX_NAME = 'idx_task_evidence_task_id'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_task_evidence_task_id ON task_evidence(task_id)',
    'SELECT "Index idx_task_evidence_task_id already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'task_evidence'
    AND INDEX_NAME = 'idx_task_evidence_uploaded_by'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_task_evidence_uploaded_by ON task_evidence(uploaded_by)',
    'SELECT "Index idx_task_evidence_uploaded_by already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add task_status_updates indexes
SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'task_status_updates'
    AND INDEX_NAME = 'idx_task_status_updates_task_id'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_task_status_updates_task_id ON task_status_updates(task_id)',
    'SELECT "Index idx_task_status_updates_task_id already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'simantu_db'
    AND TABLE_NAME = 'task_status_updates'
    AND INDEX_NAME = 'idx_task_status_updates_updated_by'
);

SET @sql = IF(@index_exists = 0,
    'CREATE INDEX idx_task_status_updates_updated_by ON task_status_updates(updated_by)',
    'SELECT "Index idx_task_status_updates_updated_by already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
