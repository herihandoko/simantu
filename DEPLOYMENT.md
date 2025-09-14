# 🚀 SIMANTU Production Deployment Guide

Panduan lengkap untuk deploy aplikasi SIMANTU ke VM production tanpa Docker.

## 📋 Prerequisites

### Server Requirements
- **OS**: Ubuntu 20.04 LTS atau lebih baru
- **RAM**: Minimum 2GB (Recommended: 4GB+)
- **Storage**: Minimum 20GB (Recommended: 50GB+)
- **CPU**: 2 cores minimum
- **Network**: Public IP dengan domain name

### Software Requirements
- Node.js 18.x atau lebih baru
- NPM
- MySQL 8.0
- Nginx
- PM2
- Git

## 🛠️ Deployment Steps

### 1. Persiapan Server

#### Update sistem
```bash
sudo apt update && sudo apt upgrade -y
```

#### Install dependencies dasar
```bash
sudo apt install -y curl wget git unzip
```

### 2. Clone Repository

```bash
# Clone repository ke server
git clone https://github.com/herihandoko/simantu.git
cd simantu

# Berikan permission execute pada script deployment
chmod +x deploy.sh update-deploy.sh setup-ssl.sh
```

### 3. Deploy Aplikasi

#### Jalankan script deployment
```bash
./deploy.sh
```

Script ini akan:
- ✅ Install semua dependencies yang diperlukan
- ✅ Setup direktori project di `/var/www/simantu`
- ✅ Install dan konfigurasi MySQL
- ✅ Build aplikasi frontend
- ✅ Setup PM2 untuk process management
- ✅ Konfigurasi Nginx sebagai reverse proxy
- ✅ Setup firewall
- ✅ Konfigurasi log rotation

### 4. Konfigurasi Domain

#### Update Nginx configuration
```bash
sudo nano /etc/nginx/sites-available/simantu
```

Ganti `yourdomain.com` dengan domain Anda:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

#### Reload Nginx
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Setup SSL (Opsional tapi Recommended)

```bash
# Jalankan sebagai root
sudo ./setup-ssl.sh yourdomain.com
```

Script ini akan:
- ✅ Install Certbot
- ✅ Obtain SSL certificate dari Let's Encrypt
- ✅ Update Nginx config untuk HTTPS
- ✅ Setup auto-renewal

## 🔧 Post-Deployment Configuration

### 1. Update Environment Variables

```bash
sudo nano /var/www/simantu/server/.env
```

Pastikan konfigurasi sesuai dengan environment production:
```env
NODE_ENV=production
DB_HOST=localhost
DB_USER=simantu_user
DB_PASSWORD=simantu_password_2024
DB_NAME=simantu_db
JWT_SECRET=your_secure_jwt_secret
PORT=5001
CORS_ORIGIN=https://yourdomain.com
```

### 2. Restart Aplikasi

```bash
pm2 restart simantu-backend
```

### 3. Test Aplikasi

```bash
# Test backend API
curl http://localhost:5001/api/health

# Test frontend (jika sudah setup domain)
curl https://yourdomain.com
```

## 🔄 Update Deployment

Untuk update aplikasi dengan versi terbaru:

```bash
# Dari direktori project
./update-deploy.sh
```

Script ini akan:
- ✅ Backup deployment saat ini
- ✅ Pull perubahan terbaru dari Git
- ✅ Update dependencies
- ✅ Build ulang frontend
- ✅ Update database (jika ada)
- ✅ Restart aplikasi
- ✅ Test aplikasi

## 📊 Monitoring & Maintenance

### PM2 Commands
```bash
# Lihat status aplikasi
pm2 status

# Lihat logs
pm2 logs simantu-backend

# Monitor real-time
pm2 monit

# Restart aplikasi
pm2 restart simantu-backend

# Stop aplikasi
pm2 stop simantu-backend
```

### Nginx Commands
```bash
# Test konfigurasi
sudo nginx -t

# Reload konfigurasi
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# Lihat status
sudo systemctl status nginx

# Lihat logs
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

## 🔒 Security Best Practices

### 1. Firewall Configuration
```bash
# Lihat status firewall
sudo ufw status

# Allow hanya port yang diperlukan
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

### 2. Database Security
```bash
# Update password database
mysql -u root -p
ALTER USER 'simantu_user'@'localhost' IDENTIFIED BY 'new_secure_password';
FLUSH PRIVILEGES;
```

### 3. SSL Certificate Renewal
```bash
# Test renewal
sudo certbot renew --dry-run

# Manual renewal
sudo certbot renew
```

### 4. Regular Backups
```bash
# Backup script (bisa dijadwalkan dengan cron)
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u simantu_user -psimantu_password_2024 simantu_db > /var/backups/simantu/db_backup_$DATE.sql
tar -czf /var/backups/simantu/app_backup_$DATE.tar.gz /var/www/simantu
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

3. **Cek environment variables**:
   ```bash
   cat /var/www/simantu/server/.env
   ```

### SSL Certificate Issues

1. **Cek status certificate**:
   ```bash
   sudo certbot certificates
   ```

2. **Test renewal**:
   ```bash
   sudo certbot renew --dry-run
   ```

3. **Cek logs Let's Encrypt**:
   ```bash
   sudo tail -f /var/log/letsencrypt/letsencrypt.log
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

/var/backups/simantu/      # Backup directory
├── backup-YYYYMMDD-HHMMSS/  # Automatic backups
└── db_backup_*.sql       # Database backups

/etc/nginx/sites-available/simantu  # Nginx configuration
/etc/letsencrypt/live/yourdomain.com/  # SSL certificates
```

## 🔧 Useful Commands Summary

```bash
# Deployment
./deploy.sh                    # Initial deployment
./update-deploy.sh            # Update deployment
sudo ./setup-ssl.sh domain.com # Setup SSL

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

**SIMANTU Production Deployment Guide v1.0**
