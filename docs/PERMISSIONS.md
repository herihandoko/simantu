# 🔐 SIMANTU Permission System

## 📋 Overview

SIMANTU menggunakan role-based access control (RBAC) untuk mengatur akses pengguna ke berbagai fitur aplikasi. Setiap role memiliki permission yang berbeda sesuai dengan level aksesnya.

## 🎯 Available Permissions

### User Management
- `users.read` - Melihat daftar user
- `users.create` - Membuat user baru
- `users.update` - Mengupdate data user
- `users.delete` - Menghapus user

### Role Management
- `roles.read` - Melihat daftar role
- `roles.create` - Membuat role baru
- `roles.update` - Mengupdate role
- `roles.delete` - Menghapus role

### Configuration Management
- `configs.read` - Melihat konfigurasi
- `configs.create` - Membuat konfigurasi baru
- `configs.update` - Mengupdate konfigurasi
- `configs.delete` - Menghapus konfigurasi

### Task Management
- `tasks.read` - Melihat daftar task
- `tasks.create` - Membuat task baru
- `tasks.update` - Mengupdate task
- `tasks.delete` - Menghapus task

### OPD Management
- `opd.read` - Melihat daftar OPD
- `opd.create` - Membuat OPD baru
- `opd.update` - Mengupdate OPD
- `opd.delete` - Menghapus OPD

### Analytics
- `analytics.read` - Mengakses halaman analytics

### Dashboard
- `dashboard.read` - Mengakses dashboard

## 👥 Role Definitions

### 1. Super Admin
**Full system access** - Akses penuh ke semua fitur

**Permissions:**
- ✅ All user permissions (read, create, update, delete)
- ✅ All role permissions (read, create, update, delete)
- ✅ All config permissions (read, create, update, delete)
- ✅ All task permissions (read, create, update, delete)
- ✅ All OPD permissions (read, create, update, delete)
- ✅ Analytics access
- ✅ Dashboard access

**Default User:** `admin@simantu.com`

### 2. Admin
**Administrative access** - Akses administratif tanpa delete

**Permissions:**
- ✅ User management (read, create, update)
- ✅ Role viewing (read only)
- ✅ Config management (read, update)
- ✅ Task management (read, create, update)
- ✅ OPD management (read, create, update)
- ✅ Analytics access
- ✅ Dashboard access

**Default User:** `john@example.com`

### 3. Manager
**Management access** - Akses manajemen terbatas

**Permissions:**
- ✅ User viewing (read only)
- ✅ Config viewing (read only)
- ✅ Task management (read, create, update)
- ✅ OPD viewing (read only)
- ✅ Analytics access
- ✅ Dashboard access

**Default User:** `jane@example.com`

### 4. User
**Basic user access** - Akses dasar untuk user biasa

**Permissions:**
- ✅ Config viewing (read only)
- ✅ Task viewing (read only)
- ✅ Dashboard access

**Default User:** `bob@example.com`

## 🔧 Permission Management

### Adding New Permissions

1. **Update Database:**
```sql
-- Add new permission to role
UPDATE roles SET permissions = JSON_ARRAY_APPEND(permissions, '$', 'new.permission') WHERE id = 1;
```

2. **Update Frontend:**
```javascript
// Add permission check in component
if (hasPermission('new.permission')) {
  // Show feature
}
```

### Updating Role Permissions

```sql
-- Update specific role permissions
UPDATE roles SET permissions = '["permission1", "permission2", "permission3"]' WHERE id = 1;
```

### Bulk Permission Update

Gunakan script `database/update_permissions.sql` untuk update semua permission:

```bash
mysql -u simantu_user -p simantu_db < database/update_permissions.sql
```

## 🛡️ Security Features

### Frontend Protection
- Menu items hidden based on permissions
- Action buttons disabled for unauthorized users
- Route guards for protected pages

### Backend Protection
- Middleware authentication on all API routes
- Permission validation in route handlers
- Role-based data filtering

### Database Security
- Password hashing with bcrypt
- JWT token authentication
- SQL injection prevention

## 📊 Permission Matrix

| Feature | Super Admin | Admin | Manager | User |
|---------|-------------|-------|---------|------|
| **Users** | Full Access | CRU | Read | - |
| **Roles** | Full Access | Read | - | - |
| **Configs** | Full Access | RU | Read | Read |
| **Tasks** | Full Access | CRU | CRU | Read |
| **OPD** | Full Access | CRU | Read | - |
| **Analytics** | ✅ | ✅ | ✅ | - |
| **Dashboard** | ✅ | ✅ | ✅ | ✅ |

**Legend:**
- **Full Access**: Create, Read, Update, Delete
- **CRU**: Create, Read, Update
- **RU**: Read, Update
- **Read**: Read only
- **-**: No access

## 🔄 Permission Updates

### Recent Updates (September 2025)
- ✅ Added `tasks.read`, `tasks.create`, `tasks.update`, `tasks.delete`
- ✅ Added `opd.read`, `opd.create`, `opd.update`, `opd.delete`
- ✅ Added `analytics.read`
- ✅ Added `dashboard.read`

### How to Apply Updates
```bash
# Deploy permission updates
deploy "Update: Add permissions for Tasks, OPD, Analytics, and Dashboard"
```

## 🧪 Testing Permissions

### Test Different Roles
```bash
# Test Super Admin
curl -X POST http://localhost/api/auth/login -d '{"email":"admin@simantu.com","password":"admin123"}'

# Test Admin
curl -X POST http://localhost/api/auth/login -d '{"email":"john@example.com","password":"password123"}'

# Test Manager
curl -X POST http://localhost/api/auth/login -d '{"email":"jane@example.com","password":"password123"}'

# Test User
curl -X POST http://localhost/api/auth/login -d '{"email":"bob@example.com","password":"password123"}'
```

### Verify Menu Access
1. Login with different roles
2. Check which menu items are visible
3. Verify action buttons are enabled/disabled correctly

## 📝 Best Practices

### Permission Naming
- Use dot notation: `module.action`
- Be descriptive: `users.delete` not `users.del`
- Keep consistent: `tasks.read` not `task.view`

### Role Design
- Follow principle of least privilege
- Create roles based on job functions
- Avoid too many granular permissions

### Security
- Always validate permissions on backend
- Don't rely only on frontend checks
- Log permission violations
- Regular permission audits

---

**📖 Related Documentation:**
- [User Management Guide](./USER-MANAGEMENT.md)
- [API Documentation](./API.md)
- [Security Guide](./SECURITY.md)

**🌐 Application**: https://simantu.bantendev.id  
**📧 Support**: Contact development team  
**📅 Last Updated**: September 2025
