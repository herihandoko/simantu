# 🚀 SIMANTU VM Deployment Guide

Panduan lengkap untuk deploy aplikasi SIMANTU ke VM `simantu.bantendev.id`.

## 📋 VM Information

| Detail | Value |
|--------|-------|
| **Domain** | simantu.bantendev.id |
| **IP Address** | 103.215.154.196 |
| **Username** | simantubantendev |
| **Password** | QvyZPrWUa-FsC%Ls |
| **Port** | 2083 (cPanel) |

## 🛠️ Prerequisites

### Local Machine Requirements
- macOS/Linux dengan SSH access
- `sshpass` untuk automated SSH (install dengan `brew install hudochenkov/sshpass/sshpass`)
- Git repository sudah di-push ke GitHub

### VM Requirements
- Ubuntu 20.04+ (akan diinstall otomatis)
- Minimum 2GB RAM
- Minimum 20GB storage
- Public IP access

## 🚀 Quick Deployment

### 1. Automated Deployment (Recommended)

```bash
# Dari direktori project lokal
./deploy-vm.sh
```

Script ini akan:
- ✅ Install semua dependencies (Node.js, MySQL, Nginx, PM2)
- ✅ Clone repository dari GitHub
- ✅ Setup database dan import schema
- ✅ Build aplikasi frontend
- ✅ Configure Nginx dengan domain yang benar
- ✅ Setup PM2 untuk process management
- ✅ Configure firewall
- ✅ Test deployment

### 2. Manual Deployment

Jika automated deployment gagal, ikuti langkah manual:

#### Step 1: Connect ke VM
```bash
ssh simantubantendev@103.215.154.196
# Password: QvyZPrWUa-FsC%Ls
```

#### Step 2: Install Dependencies
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install basic tools
sudo apt install -y curl wget git unzip nginx mysql-server

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
sudo npm install -g pm2
```

#### Step 3: Clone Repository
```bash
# Clone dari GitHub
git clone https://github.com/herihandoko/simantu.git
cd simantu

# Copy ke project directory
sudo mkdir -p /var/www/simantu
sudo cp -r . /var/www/simantu/
cd /var/www/simantu
sudo chown -R simantubantendev:simantubantendev /var/www/simantu
```

#### Step 4: Setup Database
```bash
# Start MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Create database dan user
sudo mysql -e "CREATE DATABASE IF NOT EXISTS simantu_db;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'simantu_user'@'localhost' IDENTIFIED BY 'simantu_password_2024';"
sudo mysql -e "GRANT ALL PRIVILEGES ON simantu_db.* TO 'simantu_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Import schema
mysql -u simantu_user -psimantu_password_2024 simantu_db < database/schema.sql

# Import seed data (jika ada)
if [ -f "database/seed.sql" ]; then
    mysql -u simantu_user -psimantu_password_2024 simantu_db < database/seed.sql
fi
```

#### Step 5: Deploy Application
```bash
# Install dependencies
npm run install-all

# Build frontend
npm run build

# Create production environment
cat > server/.env << 'EOF'
NODE_ENV=production
DB_HOST=localhost
DB_USER=simantu_user
DB_PASSWORD=simantu_password_2024
DB_NAME=simantu_db
JWT_SECRET=simantu_jwt_secret_production_2024_$(openssl rand -hex 32)
PORT=5001
CORS_ORIGIN=https://simantu.bantendev.id
EOF

# Start dengan PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

#### Step 6: Configure Nginx
```bash
# Create Nginx config
sudo tee /etc/nginx/sites-available/simantu > /dev/null << 'EOF'
server {
    listen 80;
    server_name simantu.bantendev.id www.simantu.bantendev.id;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript;
    
    # Frontend
    location / {
        root /var/www/simantu/client/dist;
        try_files $uri $uri/ /index.html;
        
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Backend API
    location /api {
        proxy_pass http://localhost:5001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Health check
    location /health {
        proxy_pass http://localhost:5001/api/health;
        access_log off;
    }
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/simantu /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test dan reload
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl enable nginx
```

#### Step 7: Setup Firewall
```bash
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable
```

## 🔒 SSL Setup (Recommended)

Setelah deployment berhasil, setup SSL certificate:

```bash
# SSH ke VM
ssh simantubantendev@103.215.154.196

# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d simantu.bantendev.id -d www.simantu.bantendev.id

# Test auto-renewal
sudo certbot renew --dry-run
```

## 🔄 Update Deployment

Untuk update aplikasi dengan versi terbaru:

```bash
# SSH ke VM
ssh simantubantendev@103.215.154.196

# Update dari GitHub
cd /var/www/simantu
git pull origin main

# Update dependencies dan rebuild
npm run install-all
npm run build

# Restart aplikasi
pm2 restart simantu-backend
```

## 📊 Monitoring & Maintenance

### PM2 Commands
```bash
# Status aplikasi
pm2 status

# Logs aplikasi
pm2 logs simantu-backend

# Monitor real-time
pm2 monit

# Restart aplikasi
pm2 restart simantu-backend
```

### Nginx Commands
```bash
# Test konfigurasi
sudo nginx -t

# Reload konfigurasi
sudo systemctl reload nginx

# Status Nginx
sudo systemctl status nginx

# Logs Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Database Commands
```bash
# Login ke MySQL
mysql -u simantu_user -psimantu_password_2024 simantu_db

# Backup database
mysqldump -u simantu_user -psimantu_password_2024 simantu_db > backup.sql

# Restore database
mysql -u simantu_user -psimantu_password_2024 simantu_db < backup.sql
```

## 🚨 Troubleshooting

### Aplikasi Tidak Bisa Diakses

1. **Cek status PM2**:
   ```bash
   pm2 status
   ```

2. **Cek logs aplikasi**:
   ```bash
   pm2 logs simantu-backend
   ```

3. **Cek status Nginx**:
   ```bash
   sudo systemctl status nginx
   ```

4. **Cek konfigurasi Nginx**:
   ```bash
   sudo nginx -t
   ```

### Database Connection Error

1. **Cek status MySQL**:
   ```bash
   sudo systemctl status mysql
   ```

2. **Test koneksi database**:
   ```bash
   mysql -u simantu_user -psimantu_password_2024 simantu_db
   ```

### DNS Issues

Pastikan DNS record untuk `simantu.bantendev.id` mengarah ke IP `103.215.154.196`:

```bash
# Test DNS resolution
nslookup simantu.bantendev.id
dig simantu.bantendev.id
```

## 📁 File Structure Setelah Deployment

```
/var/www/simantu/           # Project directory
├── client/                 # Frontend build
│   └── dist/              # Built frontend files
├── server/                # Backend application
│   ├── .env              # Production environment
│   └── server.js         # Main server file
├── database/             # Database files
├── ecosystem.config.js   # PM2 configuration
└── package.json          # Dependencies

/etc/nginx/sites-available/simantu  # Nginx configuration
/etc/letsencrypt/live/simantu.bantendev.id/  # SSL certificates
```

## 🔧 Useful Commands Summary

```bash
# Deployment
./deploy-vm.sh                    # Automated deployment
ssh simantubantendev@103.215.154.196  # Connect to VM

# Application Management
pm2 status                     # Check app status
pm2 logs simantu-backend      # View logs
pm2 restart simantu-backend   # Restart app
pm2 monit                     # Monitor app

# Web Server
sudo nginx -t                 # Test config
sudo systemctl reload nginx   # Reload config
sudo systemctl status nginx   # Check status

# Database
mysql -u simantu_user -p simantu_db  # Connect to DB
mysqldump -u simantu_user -p simantu_db > backup.sql  # Backup

# SSL
sudo certbot certificates     # Check certificates
sudo certbot renew           # Renew certificates
```

## 📞 Support

Jika mengalami masalah deployment:

1. Cek logs aplikasi: `pm2 logs simantu-backend`
2. Cek logs Nginx: `sudo tail -f /var/log/nginx/error.log`
3. Cek status services: `sudo systemctl status nginx mysql`
4. Buat issue di repository GitHub

---

**SIMANTU VM Deployment Guide v1.0**
**Domain: simantu.bantendev.id**
**IP: 103.215.154.196**

