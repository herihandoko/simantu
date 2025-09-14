-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
  priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  assigned_to INT,
  created_by INT,
  due_date DATE,
  completed_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert sample tasks
INSERT INTO tasks (title, description, status, priority, assigned_to, created_by, due_date) VALUES
('Setup Development Environment', 'Configure local development environment for new project', 'completed', 'high', 1, 1, '2025-09-15'),
('Design User Interface', 'Create wireframes and mockups for the main dashboard', 'in_progress', 'high', 2, 1, '2025-09-20'),
('Implement Authentication', 'Setup JWT authentication and user management', 'completed', 'high', 1, 1, '2025-09-12'),
('Database Schema Design', 'Design and implement database schema for all modules', 'completed', 'medium', 1, 1, '2025-09-10'),
('API Documentation', 'Create comprehensive API documentation', 'pending', 'medium', 3, 1, '2025-09-25'),
('Frontend Testing', 'Write unit tests for Vue components', 'pending', 'medium', 2, 1, '2025-09-22'),
('Performance Optimization', 'Optimize database queries and frontend performance', 'pending', 'low', 1, 1, '2025-09-30'),
('Security Audit', 'Review and enhance application security', 'pending', 'high', 1, 1, '2025-09-28');
