#!/bin/bash

# SIMANTU Quick Deployment Script
# Script untuk deployment cepat ke VM production

set -e  # Exit on any error

echo "⚡ SIMANTU Quick Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Configuration
PROJECT_DIR="/var/www/simantu"
PM2_APP_NAME="simantu-backend"

# Check if running as correct user
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory $PROJECT_DIR not found. Please run full deployment first."
    exit 1
fi

# Quick deployment function
quick_deploy() {
    print_status "Starting quick deployment..."
    
    # Go to project directory
    cd "$PROJECT_DIR"
    
    # Pull latest changes
    print_status "Pulling latest changes..."
    git pull origin main
    
    # Install dependencies
    print_status "Installing dependencies..."
    npm run install-all
    
    # Build frontend
    print_status "Building frontend..."
    npm run build
    
    # Restart application
    print_status "Restarting application..."
    pm2 restart "$PM2_APP_NAME"
    
    # Wait for application to start
    sleep 5
    
    # Test application
    print_status "Testing application..."
    if curl -f -s http://localhost:5001/api/health > /dev/null 2>&1; then
        print_success "Application is running"
    else
        print_error "Application failed to start"
        exit 1
    fi
    
    print_success "Quick deployment completed!"
}

# Main function
main() {
    echo "⚡ SIMANTU Quick Deployment"
    echo "==========================="
    
    quick_deploy
    
    echo ""
    print_success "🎉 Quick deployment completed successfully!"
    echo ""
    echo "🔧 Useful commands:"
    echo "- Check status: pm2 status"
    echo "- View logs: pm2 logs $PM2_APP_NAME"
    echo "- Monitor: pm2 monit"
    echo "- Test API: curl http://localhost:5001/api/health"
}

# Run main function
main "$@"
