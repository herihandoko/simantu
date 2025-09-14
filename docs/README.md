# 📚 SIMANTU Documentation

Welcome to the SIMANTU documentation hub. Here you'll find all the information you need to understand, deploy, and maintain the SIMANTU application.

## 📖 Documentation Index

### 🚀 Deployment & Operations
- [**Automated Deployment Guide**](../DEPLOYMENT-AUTOMATION.md) - Complete guide for automated deployment
- [**Quick Deploy Guide**](../QUICK-DEPLOY.md) - One-page quick reference
- [**Troubleshooting Guide**](../TROUBLESHOOTING-DEPLOY.md) - Common issues and solutions
- [**Manual Deployment**](../DEPLOYMENT.md) - Traditional deployment methods

### 🛠️ Development
- [**Project Structure**](#project-structure) - Understanding the codebase
- [**API Documentation**](#api-documentation) - Backend API endpoints
- [**Database Schema**](#database-schema) - Database structure and relationships

### 🔧 Configuration
- [**Environment Variables**](#environment-variables) - Configuration settings
- [**Security Settings**](#security-settings) - Security configurations
- [**Performance Tuning**](#performance-tuning) - Optimization guidelines

## 🎯 Quick Start

### For Developers
1. **Clone & Setup**: See main [README](../README.md)
2. **Development**: `npm run dev`
3. **Deploy**: `deploy "Your changes"`

### For DevOps
1. **Initial Setup**: [DEPLOYMENT.md](../DEPLOYMENT.md)
2. **Automated Deploy**: [DEPLOYMENT-AUTOMATION.md](../DEPLOYMENT-AUTOMATION.md)
3. **Troubleshooting**: [TROUBLESHOOTING-DEPLOY.md](../TROUBLESHOOTING-DEPLOY.md)

## 📊 Application Status

- **🌐 Live URL**: https://simantu.bantendev.id
- **📱 API Health**: https://simantu.bantendev.id/api/health
- **🔧 Admin Panel**: https://simantu.bantendev.id/login
- **📈 Status**: ✅ Online and Running

## 🔐 Access Credentials

### Production Login
- **Super Admin**: `admin@simantu.com` / `admin123`
- **Admin**: `john@example.com` / `password123`
- **Manager**: `jane@example.com` / `password123`
- **User**: `bob@example.com` / `password123`

## 🚀 Key Commands

```bash
# Development
npm run dev                 # Start development servers
npm run build              # Build for production
npm run install-all        # Install all dependencies

# Deployment
deploy "message"           # Automated deployment
./deploy-patch.sh "msg"    # Manual deployment script

# Maintenance
pm2 status                 # Check PM2 status
pm2 logs simantu-backend   # View application logs
```

## 📁 Project Structure

```
simantu/
├── client/                 # Vue.js frontend
│   ├── src/
│   │   ├── components/     # Reusable components
│   │   ├── views/          # Page views
│   │   ├── layouts/        # Layout components
│   │   ├── stores/         # Pinia state management
│   │   └── router/         # Vue Router
│   └── dist/               # Built frontend
├── server/                 # Node.js backend
│   ├── routes/             # API routes
│   ├── middleware/         # Custom middleware
│   ├── config/             # Configuration files
│   └── server.js           # Main server file
├── database/               # Database files
│   ├── schema.sql          # Database schema
│   └── seed.sql            # Sample data
├── .github/workflows/      # GitHub Actions
├── deploy-patch.sh         # Automated deployment
└── docs/                   # Documentation
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user
- `POST /api/auth/logout` - User logout

### Users
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Roles
- `GET /api/roles` - Get all roles
- `GET /api/roles/:id` - Get role by ID
- `POST /api/roles` - Create role
- `PUT /api/roles/:id` - Update role
- `DELETE /api/roles/:id` - Delete role

### Configurations
- `GET /api/configs` - Get all configurations
- `GET /api/configs/:id` - Get config by ID
- `GET /api/configs/category/:category` - Get configs by category
- `POST /api/configs` - Create configuration
- `PUT /api/configs/:id` - Update configuration
- `DELETE /api/configs/:id` - Delete configuration

### Health Check
- `GET /api/health` - Application health status

## 🗄️ Database Schema

### Tables
- **users** - User accounts and profiles
- **roles** - User roles and permissions
- **configurations** - System configuration settings
- **tasks** - Task management (if implemented)
- **opd** - Organizational units (if implemented)

### Relationships
- Users belong to Roles (many-to-one)
- Roles have Permissions (one-to-many)
- Configurations are categorized by type

## ⚙️ Environment Variables

### Development (.env)
```env
NODE_ENV=development
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=simantu_db
JWT_SECRET=your_jwt_secret
PORT=5001
CORS_ORIGIN=http://localhost:3000
```

### Production
```env
NODE_ENV=production
DB_HOST=127.0.0.1
DB_USER=simantu_user
DB_PASSWORD=simantu_password_2024
DB_NAME=simantu_db
JWT_SECRET=simantu_jwt_secret_production_2024_*
PORT=5001
CORS_ORIGIN=https://simantu.bantendev.id
```

## 🔒 Security Features

- **JWT Authentication** - Secure token-based auth
- **Password Hashing** - bcrypt encryption
- **Input Validation** - Express-validator
- **Role-based Access** - Granular permissions
- **CORS Protection** - Cross-origin security
- **SQL Injection Prevention** - Parameterized queries

## 📱 Responsive Design

- **Mobile-first** approach
- **Tailwind CSS** for styling
- **Vue.js 3** with Composition API
- **Heroicons** for consistent icons
- **Responsive breakpoints** for all devices

## 🚀 Performance

- **PM2 Cluster Mode** - Multi-process backend
- **Vite Build** - Fast frontend builds
- **Gzip Compression** - Nginx compression
- **Static Asset Caching** - Browser caching
- **Database Connection Pooling** - MySQL2 pooling

## 📞 Support & Maintenance

### Health Monitoring
```bash
# Check application status
curl https://simantu.bantendev.id/api/health

# Check PM2 status
ssh simantu@10.255.100.140 "pm2 status"

# View logs
ssh simantu@10.255.100.140 "pm2 logs simantu-backend"
```

### Backup Procedures
```bash
# Database backup
mysqldump -u simantu_user -p simantu_db > backup_$(date +%Y%m%d).sql

# Application backup
tar -czf simantu_backup_$(date +%Y%m%d).tar.gz /var/www/simantu
```

### Update Procedures
```bash
# Automated update
deploy "Update: description of changes"

# Manual update
./deploy-patch.sh "Update: description of changes"
```

---

**📖 For more detailed information, refer to the specific documentation files linked above.**

**🌐 Live Application**: https://simantu.bantendev.id  
**📧 Support**: Contact development team  
**📅 Last Updated**: September 2025
