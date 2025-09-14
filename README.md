# SIMANTU - System Management Application

SIMANTU adalah aplikasi manajemen sistem yang dibangun dengan Vue.js dan Express.js, dilengkapi dengan database MySQL.

## 🚀 Fitur

- ✅ **User Management** - Kelola pengguna dengan role-based access
- ✅ **Role Management** - Kelola role dan permission
- ✅ **Configuration Management** - Kelola konfigurasi sistem
- ✅ **Authentication System** - Login/logout dengan JWT
- ✅ **Beautiful UI** - Interface modern dengan Tailwind CSS
- ✅ **MySQL Database** - Database relasional yang robust

## 🛠️ Teknologi

### Frontend
- Vue.js 3
- Vue Router
- Pinia (State Management)
- Tailwind CSS
- Heroicons
- Axios

### Backend
- Node.js
- Express.js
- MySQL2
- JWT Authentication
- bcryptjs
- Express Validator

## 📦 Instalasi

### 1. Clone Repository
```bash
git clone <repository-url>
cd simantu
```

### 2. Install Dependencies
```bash
npm run install-all
```

### 3. Setup Database
```bash
# Buat database MySQL
mysql -u root -p < database/schema.sql

# (Opsional) Tambah data sample
mysql -u root -p < database/seed.sql
```

### 4. Environment Configuration
Buat file `.env` di folder `server/`:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Nd45mulh0!
DB_NAME=simantu_db
JWT_SECRET=your_jwt_secret_key_here
PORT=5001
```

**Catatan:** Port 5001 digunakan karena port 5000 biasanya digunakan oleh AirPlay di macOS.

### 5. Jalankan Aplikasi
```bash
# Development mode (menjalankan frontend dan backend bersamaan)
npm run dev

# Atau jalankan terpisah:
# Backend
npm run server

# Frontend
npm run client
```

5. **Akses aplikasi:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:5001

## 🔐 Default Login

- **Email**: admin@simantu.com
- **Password**: admin123

## 📁 Struktur Project

```
simantu/
├── client/                 # Frontend Vue.js
│   ├── src/
│   │   ├── components/     # Vue components
│   │   ├── views/          # Page views
│   │   ├── layouts/        # Layout components
│   │   ├── stores/         # Pinia stores
│   │   ├── router/         # Vue Router
│   │   └── style.css       # Global styles
│   ├── index.html
│   └── package.json
├── server/                 # Backend Express.js
│   ├── routes/             # API routes
│   ├── middleware/         # Custom middleware
│   ├── config/             # Database config
│   ├── server.js           # Main server file
│   └── package.json
├── database/               # Database files
│   ├── schema.sql          # Database schema
│   └── seed.sql            # Sample data
└── package.json            # Root package.json
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

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

## 🎨 UI Features

- **Responsive Design** - Mobile-friendly interface
- **Modern Dashboard** - Clean and intuitive layout
- **Role-based Navigation** - Dynamic menu based on user role
- **Modal Forms** - User-friendly forms for CRUD operations
- **Data Tables** - Sortable and searchable data display
- **Status Indicators** - Visual feedback for system status

## 🔒 Security Features

- JWT-based authentication
- Password hashing with bcrypt
- Input validation and sanitization
- Role-based access control
- CORS protection
- SQL injection prevention

## 📱 Responsive Design

Aplikasi ini fully responsive dan dapat diakses dari:
- Desktop computers
- Tablets
- Mobile phones

## 🚀 Deployment

### Production Build
```bash
npm run build
```

### Environment Variables untuk Production
Pastikan set environment variables yang sesuai untuk production:
- Database credentials
- JWT secret key
- CORS settings
- Port configuration

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🔧 Troubleshooting

### Database Connection Issues

Jika mengalami masalah koneksi database:

1. **Pastikan MySQL sudah running:**
```bash
# macOS dengan Homebrew
brew services start mysql

# Atau jalankan MySQL secara manual
mysql.server start
```

2. **Buat database secara manual:**
```bash
# Login ke MySQL
mysql -u root -p

# Di dalam MySQL console:
CREATE DATABASE simantu_db;
USE simantu_db;
SOURCE /path/to/simantu/database/schema.sql;
SOURCE /path/to/simantu/database/seed.sql;
```

3. **Cek konfigurasi .env:**
Pastikan file `.env` di folder `server/` memiliki konfigurasi yang benar:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Nd45mulh0!
DB_NAME=simantu_db
JWT_SECRET=your_jwt_secret_key_here
PORT=5001
```

### Port Issues

- **Port 5000 sudah digunakan:** Aplikasi menggunakan port 5001 untuk menghindari konflik dengan AirPlay
- **Port 3000 sudah digunakan:** Vite akan otomatis mencari port yang tersedia

### Frontend tidak bisa connect ke Backend

Pastikan:
1. Backend berjalan di port 5001
2. File `client/vite.config.js` memiliki proxy yang benar:
```javascript
proxy: {
  '/api': {
    target: 'http://localhost:5001',
    changeOrigin: true
  }
}
```

## 📞 Support

Jika ada pertanyaan atau masalah, silakan buat issue di repository ini.

---

**SIMANTU** - System Management Application v1.0.0
