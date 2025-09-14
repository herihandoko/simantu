#!/bin/bash

# Quick Deploy Script for VM
# Run this script on the VM to update the application

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting quick deployment...${NC}"

# Navigate to project directory
cd /var/www/simantu

# Pull latest changes
echo -e "${BLUE}📥 Pulling latest changes from GitHub...${NC}"
git pull origin main

# Install dependencies and build
echo -e "${BLUE}🔧 Installing dependencies and building...${NC}"
cd client && npm install && npm run build
cd ../server && npm install

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

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Application URL: https://simantu.bantendev.id${NC}"