# 🚀 SIMANTU Quick Start Guide

## Prerequisites
- Node.js (v16 atau lebih baru)
- MySQL (v8.0 atau lebih baru)
- Git

## Quick Setup (5 menit)

### 1. Clone & Install
```bash
git clone <repository-url>
cd simantu
chmod +x setup.sh
./setup.sh
```

### 2. Start Application
```bash
npm run dev
```

### 3. Access Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5001
- **Login**: admin@simantu.com / admin123

## Manual Setup (jika script gagal)

### 1. Install Dependencies
```bash
npm run install-all
```

### 2. Setup Database
```bash
# Start MySQL
brew services start mysql  # macOS
# atau
sudo systemctl start mysql  # Linux

# Create database
mysql -u root -p -e "CREATE DATABASE simantu_db;"
mysql -u root -p simantu_db < database/schema.sql
mysql -u root -p simantu_db < database/seed.sql
```

### 3. Configure Environment
Buat file `server/.env`:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Nd45mulh0!
DB_NAME=simantu_db
JWT_SECRET=simantu_jwt_secret_key_2024
PORT=5001
```

### 4. Run Application
```bash
npm run dev
```

## Features Overview

### 🔐 Authentication
- Login/Logout dengan JWT
- Protected routes
- Session management

### 👥 User Management
- Create, Read, Update, Delete users
- Role assignment
- Password hashing

### 🛡️ Role Management
- Create custom roles
- Permission-based access
- User count per role

### ⚙️ Configuration Management
- System settings
- Category-based organization
- Multiple data types

### 🎨 Modern UI
- Responsive design
- Beautiful dashboard
- Intuitive navigation

## Default Data

### Users
- **Super Admin**: admin@simantu.com / admin123
- **Admin**: john@example.com / admin123
- **Manager**: jane@example.com / admin123
- **User**: bob@example.com / admin123

### Roles
- Super Admin (full access)
- Admin (user management)
- Manager (read access)
- User (basic access)

### Sample Configurations
- App settings (name, version, maintenance mode)
- Security settings (login attempts, session timeout)
- Notification settings
- Backup settings

## Troubleshooting

### Database Connection Failed
```bash
# Check MySQL status
brew services list | grep mysql

# Start MySQL
brew services start mysql

# Test connection
mysql -u root -p -e "SHOW DATABASES;"
```

### Port Already in Use
```bash
# Check what's using port 5001
lsof -i :5001

# Kill process if needed
kill -9 <PID>
```

### Frontend Can't Connect to Backend
1. Check if backend is running: `curl http://localhost:5001/api/health`
2. Verify proxy config in `client/vite.config.js`
3. Check browser console for errors

## Development Commands

```bash
# Install all dependencies
npm run install-all

# Run both frontend and backend
npm run dev

# Run only backend
npm run server

# Run only frontend
npm run client

# Build for production
npm run build
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Get current user

### Users
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Roles
- `GET /api/roles` - List roles
- `POST /api/roles` - Create role
- `PUT /api/roles/:id` - Update role
- `DELETE /api/roles/:id` - Delete role

### Configurations
- `GET /api/configs` - List configurations
- `POST /api/configs` - Create configuration
- `PUT /api/configs/:id` - Update configuration
- `DELETE /api/configs/:id` - Delete configuration

## Need Help?

1. Check the full [README.md](README.md) for detailed documentation
2. Look at the troubleshooting section
3. Check browser console and server logs
4. Create an issue in the repository

---

**Happy coding! 🎉**
