# 🚀 SIMANTU - Quick Deploy Guide

## ⚡ One-Command Deployment

```bash
deploy "Your commit message here"
```

## 📋 Prerequisites
- ✅ Aplikasi sudah ter-deploy di VM
- ✅ Alias `deploy` sudah di-setup
- ✅ SSH access ke VM sudah dikonfigurasi

## 🎯 Usage Examples

### Bug Fixes
```bash
deploy "Fix: login validation issue"
deploy "Fix: dashboard loading error"
```

### New Features
```bash
deploy "Feature: add user search"
deploy "Feature: implement data export"
```

### UI Updates
```bash
deploy "Update: improve mobile design"
deploy "Update: add loading animations"
```

## 🔍 Quick Commands

### Check Status
```bash
# Cek aplikasi
curl https://simantu.bantendev.id/api/health

# Cek PM2 di VM
ssh simantu@10.255.100.140 "pm2 status"
```

### Emergency Restart
```bash
# Restart aplikasi
ssh simantu@10.255.100.140 "pm2 restart simantu-backend"
```

## 📊 What Happens Automatically

1. ✅ Git commit & push ke GitHub
2. ✅ Pull changes di VM
3. ✅ Install dependencies
4. ✅ Build frontend
5. ✅ Restart backend
6. ✅ Health check
7. ✅ Status report

## 🎉 Result

**Total waktu**: 1-2 menit  
**Downtime**: ~5-10 detik  
**Success rate**: 99%+

---

**🌐 App URL**: https://simantu.bantendev.id  
**📖 Full Docs**: [DEPLOYMENT-AUTOMATION.md](./DEPLOYMENT-AUTOMATION.md)
