# 🔧 SIMANTU Troubleshooting Guide

## Halaman Blank Putih

Jika Anda melihat halaman blank putih saat mengakses http://localhost:3000, ikuti langkah-langkah berikut:

### 1. Cek Browser Console
1. Buka Developer Tools (F12 atau Cmd+Option+I)
2. Klik tab **Console**
3. Lihat apakah ada error berwarna merah
4. Screenshot error dan laporkan

### 2. Hard Refresh Browser
- **Windows/Linux**: Ctrl + F5
- **macOS**: Cmd + Shift + R

### 3. Cek JavaScript
Pastikan JavaScript enabled di browser:
- Chrome: Settings > Privacy and security > Site settings > JavaScript
- Firefox: about:config > javascript.enabled = true

### 4. Cek Network Tab
1. Buka Developer Tools (F12)
2. Klik tab **Network**
3. Refresh halaman
4. Lihat apakah ada file yang gagal load (status merah)

### 5. Test Endpoint
Buka terminal dan jalankan:
```bash
curl http://localhost:3000
```
Seharusnya menampilkan HTML.

### 6. Cek Log Server
Lihat terminal dimana `npm run dev` berjalan, cari error berwarna merah.

## Masalah Umum

### Port 5000 Sudah Digunakan
**Error**: `EADDRINUSE: address already in use :::5000`
**Solusi**: Aplikasi sudah dikonfigurasi menggunakan port 5001

### Database Connection Failed
**Error**: `Access denied for user 'root'@'localhost'`
**Solusi**: 
1. Pastikan MySQL running: `brew services start mysql`
2. Cek password di `server/.env`
3. Test koneksi: `mysql -u root -p'Nd45mulh0!' -e "SHOW DATABASES;"`

### Frontend Tidak Bisa Connect ke Backend
**Error**: Network error di browser console
**Solusi**:
1. Pastikan backend running di port 5001
2. Test: `curl http://localhost:5001/api/health`
3. Cek proxy config di `client/vite.config.js`

### Vite CJS Warning
**Warning**: `The CJS build of Vite's Node API is deprecated`
**Solusi**: Warning ini tidak mempengaruhi fungsi, bisa diabaikan.

## Test Manual

### 1. Test Backend
```bash
curl http://localhost:5001/api/health
```
Expected: `{"status":"OK","timestamp":"...","message":"SIMANTU API is running"}`

### 2. Test Frontend
```bash
curl http://localhost:3000
```
Expected: HTML dengan title "SIMANTU - System Management"

### 3. Test Login API
```bash
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@simantu.com","password":"admin123"}'
```
Expected: JSON dengan token dan user data

## Reset Aplikasi

Jika semua gagal, reset aplikasi:

```bash
# Stop aplikasi
pkill -f "npm run dev"

# Clear cache
rm -rf client/node_modules/.vite
rm -rf client/dist

# Restart
npm run dev
```

## Log Locations

- **Frontend logs**: Terminal dimana `npm run dev` berjalan
- **Backend logs**: Terminal dimana `npm run dev` berjalan
- **Browser logs**: Developer Tools > Console
- **Network logs**: Developer Tools > Network

## Contact Support

Jika masalah masih berlanjut:
1. Screenshot error di console
2. Copy log dari terminal
3. Jelaskan langkah yang sudah dicoba
4. Buat issue di repository
