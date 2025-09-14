#!/bin/bash

# SIMANTU Production Update Script
# Script untuk update aplikasi SIMANTU yang sudah di-deploy

set -e  # Exit on any error

echo "🔄 Starting SIMANTU Production Update..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="simantu"
PROJECT_DIR="/var/www/simantu"
BACKUP_DIR="/var/backups/simantu"
PM2_APP_NAME="simantu-backend"

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons"
   exit 1
fi

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Project directory $PROJECT_DIR not found. Please run deploy.sh first."
    exit 1
fi

# Backup current deployment
backup_current() {
    print_status "Creating backup of current deployment..."
    
    local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
    sudo cp -r $PROJECT_DIR $BACKUP_DIR/$backup_name
    
    print_success "Backup created: $BACKUP_DIR/$backup_name"
}

# Pull latest changes from Git
pull_latest() {
    print_status "Pulling latest changes from Git..."
    
    cd $PROJECT_DIR
    
    # Check if it's a git repository
    if [ ! -d ".git" ]; then
        print_error "Not a git repository. Please clone the repository first."
        exit 1
    fi
    
    # Pull latest changes
    git pull origin main
    
    print_success "Latest changes pulled"
}

# Update dependencies
update_dependencies() {
    print_status "Updating dependencies..."
    
    cd $PROJECT_DIR
    
    # Update root dependencies
    npm install
    
    # Update client dependencies
    cd client
    npm install
    cd ..
    
    # Update server dependencies
    cd server
    npm install
    cd ..
    
    print_success "Dependencies updated"
}

# Build frontend
build_frontend() {
    print_status "Building frontend..."
    
    cd $PROJECT_DIR
    npm run build
    
    print_success "Frontend built"
}

# Update database (if needed)
update_database() {
    print_status "Checking for database updates..."
    
    cd $PROJECT_DIR
    
    # Check if there are new SQL files
    if [ -f "database/update_*.sql" ]; then
        print_status "Found database update files. Applying..."
        
        for sql_file in database/update_*.sql; do
            if [ -f "$sql_file" ]; then
                print_status "Applying $sql_file..."
                mysql -u simantu_user -psimantu_password_2024 simantu_db < "$sql_file"
            fi
        done
        
        print_success "Database updates applied"
    else
        print_status "No database updates found"
    fi
}

# Restart application
restart_application() {
    print_status "Restarting application..."
    
    # Restart PM2 process
    pm2 restart $PM2_APP_NAME
    
    # Wait a moment for the application to start
    sleep 5
    
    # Check if application is running
    if pm2 list | grep -q "$PM2_APP_NAME.*online"; then
        print_success "Application restarted successfully"
    else
        print_error "Application failed to start. Check logs with: pm2 logs $PM2_APP_NAME"
        exit 1
    fi
}

# Test application
test_application() {
    print_status "Testing application..."
    
    # Test if the application is responding
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s http://localhost:5001/api/health > /dev/null 2>&1; then
            print_success "Application is responding"
            return 0
        fi
        
        print_status "Attempt $attempt/$max_attempts - waiting for application to start..."
        sleep 2
        ((attempt++))
    done
    
    print_error "Application is not responding after $max_attempts attempts"
    return 1
}

# Cleanup old backups
cleanup_backups() {
    print_status "Cleaning up old backups (keeping last 5)..."
    
    cd $BACKUP_DIR
    ls -t | tail -n +6 | xargs -r sudo rm -rf
    
    print_success "Old backups cleaned up"
}

# Main update function
main() {
    echo "🔄 SIMANTU Production Update"
    echo "============================"
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ] || [ ! -d "server" ] || [ ! -d "client" ]; then
        print_error "Please run this script from the simantu project root directory"
        exit 1
    fi
    
    # Run update steps
    backup_current
    pull_latest
    update_dependencies
    build_frontend
    update_database
    restart_application
    
    if test_application; then
        cleanup_backups
        
        echo ""
        print_success "🎉 Update completed successfully!"
        echo ""
        echo "📋 Application status:"
        echo "- Frontend: Built and ready"
        echo "- Backend: Running on PM2"
        echo "- Database: Updated (if needed)"
        echo ""
        echo "🔧 Useful commands:"
        echo "- Check status: pm2 status"
        echo "- View logs: pm2 logs $PM2_APP_NAME"
        echo "- Monitor: pm2 monit"
    else
        print_error "Update completed but application is not responding"
        echo "Please check the logs and fix any issues:"
        echo "pm2 logs $PM2_APP_NAME"
        exit 1
    fi
}

# Run main function
main "$@"
