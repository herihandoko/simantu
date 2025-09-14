-- Update tasks table to match the form structure
ALTER TABLE tasks 
ADD COLUMN task_id VARCHAR(50) UNIQUE,
ADD COLUMN nama_opd VARCHAR(255),
ADD COLUMN nama_pekerjaan VARCHAR(255),
ADD COLUMN tugas VARCHAR(255),
ADD COLUMN uraian_tugas TEXT,
ADD COLUMN tenaga_ahli VARCHAR(255),
ADD COLUMN tanggal_selesai DATE;

-- Update existing tasks with new structure
UPDATE tasks SET 
  task_id = CONCAT('TASK-', LPAD(id, 4, '0')),
  nama_pekerjaan = title,
  tugas = title,
  uraian_tugas = description,
  tanggal_selesai = due_date
WHERE task_id IS NULL;

-- Create OPD table for dropdown
CREATE TABLE IF NOT EXISTS opd (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama_opd VARCHAR(255) NOT NULL,
  kode_opd VARCHAR(50) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample OPD data
INSERT INTO opd (nama_opd, kode_opd) VALUES
('Dinas Pendidikan', 'DINDIK'),
('Dinas Kesehatan', 'DINKES'),
('Dinas Pekerjaan Umum', 'DINPU'),
('Dinas Perhubungan', 'DINHUB'),
('Dinas Sosial', 'DINSOS'),
('Badan Perencanaan Pembangunan Daerah', 'BAPPEDA'),
('Sekretariat Daerah', 'SEKDA'),
('Inspektorat', 'INSPEKTORAT');

-- Create Tenaga Ahli table
CREATE TABLE IF NOT EXISTS tenaga_ahli (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(255) NOT NULL,
  spesialisasi VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample Tenaga Ahli data
INSERT INTO tenaga_ahli (nama, spesialisasi, email, phone) VALUES
('Dr. Ahmad Wijaya', 'IT Specialist', 'ahmad.wijaya@example.com', '081234567890'),
('Ir. Siti Nurhaliza', 'Project Manager', 'siti.nurhaliza@example.com', '081234567891'),
('Budi Santoso, S.Kom', 'Software Developer', 'budi.santoso@example.com', '081234567892'),
('Dr. Maria Magdalena', 'System Analyst', 'maria.magdalena@example.com', '081234567893'),
('Ir. John Doe', 'Database Administrator', 'john.doe@example.com', '081234567894');
