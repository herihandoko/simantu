#!/bin/bash

# SIMANTU Monitoring Script
# Script untuk monitoring aplikasi SIMANTU di production

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/var/www/simantu"
BACKUP_DIR="/var/backups/simantu"
PM2_APP_NAME="simantu-backend"
LOG_FILE="/var/log/simantu-monitor.log"

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

# Log function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Check application status
check_app_status() {
    print_status "Checking application status..."
    
    # Check PM2 status
    if pm2 list | grep -q "$PM2_APP_NAME.*online"; then
        print_success "Application is running"
        log_message "Application status: OK"
        return 0
    else
        print_error "Application is not running"
        log_message "Application status: ERROR - Not running"
        return 1
    fi
}

# Check database connection
check_database() {
    print_status "Checking database connection..."
    
    if mysql -u simantu_user -psimantu_password_2024 -e "SELECT 1" simantu_db > /dev/null 2>&1; then
        print_success "Database connection OK"
        log_message "Database status: OK"
        return 0
    else
        print_error "Database connection failed"
        log_message "Database status: ERROR - Connection failed"
        return 1
    fi
}

# Check API health
check_api_health() {
    print_status "Checking API health..."
    
    local response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5001/api/health)
    
    if [ "$response" = "200" ]; then
        print_success "API health check OK"
        log_message "API health status: OK"
        return 0
    else
        print_error "API health check failed (HTTP $response)"
        log_message "API health status: ERROR - HTTP $response"
        return 1
    fi
}

# Check disk space
check_disk_space() {
    print_status "Checking disk space..."
    
    local usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$usage" -lt 80 ]; then
        print_success "Disk space OK ($usage% used)"
        log_message "Disk space: OK ($usage% used)"
        return 0
    elif [ "$usage" -lt 90 ]; then
        print_warning "Disk space warning ($usage% used)"
        log_message "Disk space: WARNING ($usage% used)"
        return 1
    else
        print_error "Disk space critical ($usage% used)"
        log_message "Disk space: CRITICAL ($usage% used)"
        return 2
    fi
}

# Check memory usage
check_memory() {
    print_status "Checking memory usage..."
    
    local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    
    if [ "$mem_usage" -lt 80 ]; then
        print_success "Memory usage OK ($mem_usage% used)"
        log_message "Memory usage: OK ($mem_usage% used)"
        return 0
    elif [ "$mem_usage" -lt 90 ]; then
        print_warning "Memory usage warning ($mem_usage% used)"
        log_message "Memory usage: WARNING ($mem_usage% used)"
        return 1
    else
        print_error "Memory usage critical ($mem_usage% used)"
        log_message "Memory usage: CRITICAL ($mem_usage% used)"
        return 2
    fi
}

# Check Nginx status
check_nginx() {
    print_status "Checking Nginx status..."
    
    if systemctl is-active --quiet nginx; then
        print_success "Nginx is running"
        log_message "Nginx status: OK"
        return 0
    else
        print_error "Nginx is not running"
        log_message "Nginx status: ERROR - Not running"
        return 1
    fi
}

# Check SSL certificate
check_ssl() {
    print_status "Checking SSL certificate..."
    
    # Check if SSL is configured
    if [ -f "/etc/letsencrypt/live" ]; then
        local domain=$(ls /etc/letsencrypt/live/ | head -1)
        if [ -n "$domain" ]; then
            local cert_expiry=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$domain/cert.pem" | cut -d= -f2)
            local cert_date=$(date -d "$cert_expiry" +%s)
            local current_date=$(date +%s)
            local days_left=$(( (cert_date - current_date) / 86400 ))
            
            if [ "$days_left" -gt 30 ]; then
                print_success "SSL certificate OK (expires in $days_left days)"
                log_message "SSL certificate: OK (expires in $days_left days)"
                return 0
            elif [ "$days_left" -gt 7 ]; then
                print_warning "SSL certificate expires soon ($days_left days)"
                log_message "SSL certificate: WARNING (expires in $days_left days)"
                return 1
            else
                print_error "SSL certificate expires very soon ($days_left days)"
                log_message "SSL certificate: CRITICAL (expires in $days_left days)"
                return 2
            fi
        fi
    fi
    
    print_warning "SSL certificate not configured"
    log_message "SSL certificate: Not configured"
    return 1
}

# Create backup
create_backup() {
    print_status "Creating backup..."
    
    local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    # Create backup directory
    mkdir -p "$backup_path"
    
    # Backup application files
    cp -r "$PROJECT_DIR" "$backup_path/app"
    
    # Backup database
    mysqldump -u simantu_user -psimantu_password_2024 simantu_db > "$backup_path/database.sql"
    
    # Create compressed archive
    cd "$BACKUP_DIR"
    tar -czf "${backup_name}.tar.gz" "$backup_name"
    rm -rf "$backup_name"
    
    print_success "Backup created: ${backup_name}.tar.gz"
    log_message "Backup created: ${backup_name}.tar.gz"
}

# Cleanup old backups
cleanup_backups() {
    print_status "Cleaning up old backups..."
    
    cd "$BACKUP_DIR"
    
    # Keep only last 7 backups
    ls -t backup-*.tar.gz | tail -n +8 | xargs -r rm -f
    
    print_success "Old backups cleaned up"
    log_message "Old backups cleaned up"
}

# Restart application if needed
restart_application() {
    print_status "Restarting application..."
    
    pm2 restart "$PM2_APP_NAME"
    sleep 5
    
    if pm2 list | grep -q "$PM2_APP_NAME.*online"; then
        print_success "Application restarted successfully"
        log_message "Application restarted successfully"
        return 0
    else
        print_error "Application restart failed"
        log_message "Application restart failed"
        return 1
    fi
}

# Send alert (placeholder for email/SMS integration)
send_alert() {
    local message="$1"
    local severity="$2"
    
    print_warning "ALERT [$severity]: $message"
    log_message "ALERT [$severity]: $message"
    
    # Here you can add email/SMS integration
    # Example: send email to admin
    # echo "$message" | mail -s "SIMANTU Alert [$severity]" admin@yourdomain.com
}

# Main monitoring function
main() {
    echo "🔍 SIMANTU System Monitoring"
    echo "============================"
    
    local errors=0
    local warnings=0
    
    # Run all checks
    check_app_status || ((errors++))
    check_database || ((errors++))
    check_api_health || ((errors++))
    check_disk_space || ((warnings++))
    check_memory || ((warnings++))
    check_nginx || ((errors++))
    check_ssl || ((warnings++))
    
    echo ""
    echo "📊 Monitoring Summary:"
    echo "- Errors: $errors"
    echo "- Warnings: $warnings"
    
    # Create backup if no critical errors
    if [ "$errors" -eq 0 ]; then
        create_backup
        cleanup_backups
    else
        print_error "Skipping backup due to critical errors"
        send_alert "Critical errors detected in SIMANTU system" "CRITICAL"
    fi
    
    # Send alerts for warnings
    if [ "$warnings" -gt 0 ]; then
        send_alert "$warnings warning(s) detected in SIMANTU system" "WARNING"
    fi
    
    # Log summary
    log_message "Monitoring completed - Errors: $errors, Warnings: $warnings"
    
    echo ""
    if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
        print_success "🎉 All systems operational"
    elif [ "$errors" -eq 0 ]; then
        print_warning "⚠️  System operational with warnings"
    else
        print_error "❌ System has critical issues"
    fi
}

# Check if running as correct user
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Run main function
main "$@"
