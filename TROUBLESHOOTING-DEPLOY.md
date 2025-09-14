# 🔧 SIMANTU - Deployment Troubleshooting

## 🚨 Common Issues & Solutions

### 1. Deployment Script Not Found
```bash
# Error: ./deploy-patch.sh: No such file or directory
# Solution:
ls -la deploy-patch.sh
chmod +x deploy-patch.sh
```

### 2. SSH Connection Failed
```bash
# Error: ssh: connect to host 10.255.100.140 port 22: Connection refused
# Solution:
ping 10.255.100.140
ssh simantu@10.255.100.140
```

### 3. Git Push Failed
```bash
# Error: Permission denied (publickey)
# Solution:
git remote -v
git push origin main
```

### 4. Build Failed
```bash
# Error: npm run build failed
# Solution:
cd client
npm install
npm run build
```

### 5. PM2 Not Running
```bash
# Error: PM2 process not found
# Solution:
ssh simantu@10.255.100.140
cd /var/www/simantu
pm2 start ecosystem.config.js --env production
pm2 status
```

### 6. Database Connection Failed
```bash
# Error: Database connection failed
# Solution:
ssh simantu@10.255.100.140
mysql -u simantu_user -psimantu_password_2024 simantu_db -e "SELECT 1;"
```

## 🔍 Debug Commands

### Check VM Status
```bash
# SSH ke VM
ssh simantu@10.255.100.140

# Cek disk space
df -h

# Cek memory
free -h

# Cek processes
ps aux | grep node
```

### Check Application Logs
```bash
# PM2 logs
pm2 logs simantu-backend --lines 50

# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Check Network
```bash
# Test API
curl http://localhost:5001/api/health

# Test frontend
curl -I http://localhost

# Test external
curl -I https://simantu.bantendev.id
```

## 🛠️ Manual Recovery

### Restart Everything
```bash
# Di VM
ssh simantu@10.255.100.140
cd /var/www/simantu

# Stop PM2
pm2 stop all
pm2 delete all

# Restart PM2
pm2 start ecosystem.config.js --env production
pm2 status
```

### Rebuild Application
```bash
# Di VM
cd /var/www/simantu

# Clean install
cd client
rm -rf node_modules
npm install
npm run build

cd ../server
rm -rf node_modules
npm install

# Restart PM2
pm2 restart simantu-backend
```

### Database Recovery
```bash
# Di VM
mysql -u simantu_user -psimantu_password_2024 simantu_db -e "SHOW TABLES;"

# Import schema jika perlu
mysql -u simantu_user -psimantu_password_2024 simantu_db < database/schema.sql
```

## 📞 Emergency Contacts

### Quick Fixes
```bash
# Restart Nginx
sudo systemctl restart nginx

# Restart MySQL
sudo systemctl restart mysql

# Restart PM2
pm2 restart all
```

### Full Reset
```bash
# Di VM
cd /var/www/simantu
git pull origin main
cd client && npm install && npm run build
cd ../server && npm install
pm2 restart simantu-backend
```

## 🎯 Prevention Tips

### Before Deploy
- ✅ Test locally first
- ✅ Check git status
- ✅ Verify dependencies
- ✅ Test build process

### During Deploy
- ✅ Monitor deployment logs
- ✅ Check health endpoint
- ✅ Verify PM2 status
- ✅ Test login functionality

### After Deploy
- ✅ Check application URL
- ✅ Test all major features
- ✅ Monitor error logs
- ✅ Verify database connection

## 📊 Health Check Commands

```bash
# API Health
curl https://simantu.bantendev.id/api/health

# Frontend Health
curl -I https://simantu.bantendev.id

# Database Health
ssh simantu@10.255.100.140 "mysql -u simantu_user -psimantu_password_2024 simantu_db -e 'SELECT 1;'"

# PM2 Health
ssh simantu@10.255.100.140 "pm2 status"
```

## 🚀 Success Indicators

✅ **Deployment Success**:
- Git push successful
- VM pull successful
- Build completed
- PM2 restarted
- Health check passed
- Application accessible

❌ **Deployment Failed**:
- Any step failed
- Health check failed
- Application not accessible
- PM2 not running
- Database connection failed

---

**📖 Full Documentation**: [DEPLOYMENT-AUTOMATION.md](./DEPLOYMENT-AUTOMATION.md)  
**⚡ Quick Guide**: [QUICK-DEPLOY.md](./QUICK-DEPLOY.md)  
**🌐 Application**: https://simantu.bantendev.id
