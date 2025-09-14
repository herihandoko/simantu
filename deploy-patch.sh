#!/bin/bash

# SIMANTU Patch Deployment Script
# Usage: ./deploy-patch.sh [commit-message]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VM_HOST="10.255.100.140"
VM_USER="simantu"
VM_PASSWORD="S1m4ntu!pq2~)OcHK"
PROJECT_DIR="/var/www/simantu"

# Functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if commit message provided
if [ -z "$1" ]; then
    print_error "Please provide a commit message"
    echo "Usage: ./deploy-patch.sh \"Your commit message\""
    exit 1
fi

COMMIT_MESSAGE="$1"

print_status "Starting SIMANTU patch deployment..."

# Step 1: Commit and push to GitHub
print_status "Committing changes to GitHub..."
git add .
git commit -m "$COMMIT_MESSAGE"
git push origin main

if [ $? -eq 0 ]; then
    print_success "Changes pushed to GitHub"
else
    print_error "Failed to push to GitHub"
    exit 1
fi

# Step 2: Deploy to VM
print_status "Deploying to VM..."

sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" "
    cd $PROJECT_DIR
    
    # Pull latest changes
    git pull origin main
    
    # Install dependencies and build
    cd client && npm install && npm run build
    cd ../server && npm install
    
    # Restart PM2
    pm2 restart simantu-backend
    
    # Check status
    pm2 status
    
    echo 'Deployment completed successfully!'
"

if [ $? -eq 0 ]; then
    print_success "Deployment completed successfully!"
    print_status "Application is now running with latest changes"
else
    print_error "Deployment failed"
    exit 1
fi

# Step 3: Health check
print_status "Performing health check..."
sleep 5

HEALTH_CHECK=$(sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no "$VM_USER@$VM_HOST" "curl -s http://localhost:5001/api/health | grep -o '\"status\":\"OK\"' || echo 'FAILED'")

if [ "$HEALTH_CHECK" = '"status":"OK"' ]; then
    print_success "Health check passed - Application is running correctly"
else
    print_warning "Health check failed - Please check the application manually"
fi

print_success "Patch deployment completed!"
echo -e "${GREEN}🌐 Application URL: https://simantu.bantendev.id${NC}"
