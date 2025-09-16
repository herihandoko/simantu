#!/bin/bash

# Deploy SIMANTU with OPD data to production
# This script will deploy the application and import OPD data

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting SIMANTU deployment with OPD data...${NC}"

# Navigate to project directory
cd /var/www/simantu

# Pull latest changes
echo -e "${BLUE}📥 Pulling latest changes from GitHub...${NC}"
git pull origin main

# Install dependencies and build
echo -e "${BLUE}🔧 Installing dependencies and building...${NC}"
cd client && npm install && npm run build
cd ../server && npm install

# Import OPD data to production database
echo -e "${BLUE}📊 Importing OPD data to production database...${NC}"
mysql -u simantu_user -psimantu_password_2024 simantu_db < database/insert_opd_data.sql

# Check if OPD data was imported successfully
OPD_COUNT=$(mysql -u simantu_user -psimantu_password_2024 simantu_db -e "SELECT COUNT(*) as count FROM opd;" -s -N)
echo -e "${GREEN}✅ OPD data imported successfully! Total OPD: $OPD_COUNT${NC}"

# Restart PM2
echo -e "${BLUE}🔄 Restarting PM2 processes...${NC}"
pm2 restart simantu-backend

# Check status
echo -e "${BLUE}📊 Checking PM2 status...${NC}"
pm2 status

# Health check
echo -e "${BLUE}🏥 Performing health check...${NC}"
sleep 3
curl -s http://localhost:5001/api/health | grep -q '"status":"OK"' && echo -e "${GREEN}✅ Health check passed!${NC}" || echo -e "${RED}❌ Health check failed!${NC}"

# Test OPD API endpoint
echo -e "${BLUE}🔍 Testing OPD API endpoint...${NC}"
OPD_API_RESPONSE=$(curl -s http://localhost:5001/api/opd | head -c 200)
if [[ $OPD_API_RESPONSE == *"kode_opd"* ]]; then
    echo -e "${GREEN}✅ OPD API endpoint working!${NC}"
else
    echo -e "${RED}❌ OPD API endpoint failed!${NC}"
fi

echo -e "${GREEN}🎉 Deployment with OPD data completed successfully!${NC}"
echo -e "${GREEN}🌐 Application URL: https://simantu.bantendev.id${NC}"
echo -e "${GREEN}📊 OPD data: $OPD_COUNT organizations imported${NC}"
