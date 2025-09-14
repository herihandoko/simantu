-- Products table
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category VARCHAR(100),
  stock_quantity INT DEFAULT 0,
  sku VARCHAR(100) UNIQUE,
  status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample products
INSERT INTO products (name, description, price, category, stock_quantity, sku, status) VALUES
('Laptop Dell XPS 13', 'High-performance laptop with Intel i7 processor', 1299.99, 'Electronics', 25, 'DELL-XPS13-001', 'active'),
('iPhone 15 Pro', 'Latest iPhone with advanced camera system', 999.99, 'Electronics', 50, 'APPLE-IP15P-001', 'active'),
('Office Chair Ergonomic', 'Comfortable office chair with lumbar support', 299.99, 'Furniture', 15, 'CHAIR-ERG-001', 'active'),
('Wireless Mouse Logitech', 'Bluetooth wireless mouse with precision tracking', 49.99, 'Accessories', 100, 'LOG-MOUSE-001', 'active'),
('Standing Desk Adjustable', 'Height-adjustable standing desk for home office', 599.99, 'Furniture', 8, 'DESK-STAND-001', 'active'),
('Mechanical Keyboard', 'RGB mechanical keyboard with blue switches', 149.99, 'Accessories', 30, 'KB-MECH-001', 'active'),
('Monitor 4K 27 inch', 'Ultra HD monitor with HDR support', 399.99, 'Electronics', 20, 'MON-4K27-001', 'active'),
('Webcam HD 1080p', 'High-definition webcam for video conferencing', 79.99, 'Accessories', 45, 'CAM-HD-001', 'active');
