-- Fix tasks table to add missing foreign key columns
-- This script adds the missing opd_id and tenaga_ahli_id columns to the tasks table

-- Add missing columns to tasks table
ALTER TABLE tasks 
ADD COLUMN IF NOT EXISTS opd_id INT NULL,
ADD COLUMN IF NOT EXISTS tenaga_ahli_id INT NULL;

-- Add foreign key constraints (optional, for data integrity)
-- ALTER TABLE tasks 
-- ADD CONSTRAINT fk_tasks_opd FOREIGN KEY (opd_id) REFERENCES opd(id) ON DELETE SET NULL,
-- ADD CONSTRAINT fk_tasks_tenaga_ahli FOREIGN KEY (tenaga_ahli_id) REFERENCES users(id) ON DELETE SET NULL;

-- Update existing tasks to have proper relationships if needed
-- This is optional and can be customized based on your data

-- Verify the changes
SELECT 'Tasks table structure updated successfully' as status;