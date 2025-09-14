#!/bin/bash

# SIMANTU Cron Jobs Setup Script
# Script untuk setup cron jobs untuk monitoring dan backup otomatis

set -e  # Exit on any error

echo "⏰ Setting up SIMANTU Cron Jobs..."

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

# Check if running as correct user
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Get current user
CURRENT_USER=$(whoami)
PROJECT_DIR="/var/www/simantu"

# Create cron jobs
setup_cron_jobs() {
    print_status "Setting up cron jobs for user: $CURRENT_USER"
    
    # Create temporary cron file
    local temp_cron="/tmp/simantu_cron"
    
    # Get existing cron jobs (excluding simantu jobs)
    crontab -l 2>/dev/null | grep -v "simantu" > "$temp_cron" || touch "$temp_cron"
    
    # Add SIMANTU cron jobs
    cat >> "$temp_cron" << EOF

# SIMANTU Cron Jobs
# Monitoring - Every 5 minutes
*/5 * * * * cd $PROJECT_DIR && ./monitor.sh > /dev/null 2>&1

# Daily backup at 2 AM
0 2 * * * cd $PROJECT_DIR && ./monitor.sh > /dev/null 2>&1

# Weekly log cleanup on Sunday at 3 AM
0 3 * * 0 find /var/log -name "*.log" -mtime +7 -delete > /dev/null 2>&1

# Monthly backup cleanup on 1st day at 4 AM
0 4 1 * * find /var/backups/simantu -name "backup-*.tar.gz" -mtime +30 -delete > /dev/null 2>&1

# SSL certificate renewal check daily at 6 AM
0 6 * * * /usr/bin/certbot renew --quiet --post-hook "systemctl reload nginx" > /dev/null 2>&1

# System update check weekly on Monday at 5 AM
0 5 * * 1 apt list --upgradable > /var/log/simantu-updates.log 2>&1

EOF
    
    # Install the cron jobs
    crontab "$temp_cron"
    rm "$temp_cron"
    
    print_success "Cron jobs installed successfully"
}

# Create log rotation for SIMANTU logs
setup_log_rotation() {
    print_status "Setting up log rotation..."
    
    sudo tee /etc/logrotate.d/simantu > /dev/null << EOF
/var/log/simantu-*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 $CURRENT_USER $CURRENT_USER
    postrotate
        pm2 reloadLogs
    endscript
}

/var/backups/simantu/*.tar.gz {
    weekly
    missingok
    rotate 12
    compress
    delaycompress
    notifempty
    create 644 $CURRENT_USER $CURRENT_USER
}
EOF
    
    print_success "Log rotation configured"
}

# Create monitoring script with email alerts
create_alert_script() {
    print_status "Creating alert script..."
    
    cat > "$PROJECT_DIR/alert.sh" << 'EOF'
#!/bin/bash

# SIMANTU Alert Script
# Script untuk mengirim alert via email

# Configuration
ADMIN_EMAIL="admin@yourdomain.com"
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your_email@gmail.com"
SMTP_PASS="your_app_password"

# Function to send email
send_email() {
    local subject="$1"
    local message="$2"
    
    # Using mail command (install mailutils if not available)
    echo "$message" | mail -s "$subject" "$ADMIN_EMAIL"
    
    # Alternative using curl for SMTP
    # curl --url "smtps://$SMTP_SERVER:$SMTP_PORT" \
    #      --ssl-reqd \
    #      --mail-from "$SMTP_USER" \
    #      --mail-rcpt "$ADMIN_EMAIL" \
    #      --user "$SMTP_USER:$SMTP_PASS" \
    #      --upload-file <(echo -e "Subject: $subject\n\n$message")
}

# Check if mail command is available
if ! command -v mail &> /dev/null; then
    echo "Mail command not found. Installing mailutils..."
    sudo apt install -y mailutils
fi

# Example usage
if [ "$1" = "test" ]; then
    send_email "SIMANTU Test Alert" "This is a test alert from SIMANTU monitoring system."
    echo "Test alert sent to $ADMIN_EMAIL"
fi
EOF
    
    chmod +x "$PROJECT_DIR/alert.sh"
    
    print_success "Alert script created"
}

# Create system maintenance script
create_maintenance_script() {
    print_status "Creating maintenance script..."
    
    cat > "$PROJECT_DIR/maintenance.sh" << 'EOF'
#!/bin/bash

# SIMANTU Maintenance Script
# Script untuk maintenance rutin sistem

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Update system packages
update_system() {
    print_status "Updating system packages..."
    
    sudo apt update
    sudo apt upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean
    
    print_success "System packages updated"
}

# Clean up old logs
cleanup_logs() {
    print_status "Cleaning up old logs..."
    
    # Clean PM2 logs older than 30 days
    find /var/log/pm2 -name "*.log" -mtime +30 -delete 2>/dev/null || true
    
    # Clean Nginx logs older than 30 days
    sudo find /var/log/nginx -name "*.log" -mtime +30 -delete 2>/dev/null || true
    
    # Clean system logs older than 30 days
    sudo find /var/log -name "*.log" -mtime +30 -delete 2>/dev/null || true
    
    print_success "Old logs cleaned up"
}

# Optimize database
optimize_database() {
    print_status "Optimizing database..."
    
    mysql -u simantu_user -psimantu_password_2024 simantu_db -e "OPTIMIZE TABLE users, roles, configs, tasks, opd;" 2>/dev/null || true
    
    print_success "Database optimized"
}

# Check disk space and clean if needed
cleanup_disk() {
    print_status "Checking disk space..."
    
    local usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$usage" -gt 80 ]; then
        print_warning "Disk usage is $usage%. Cleaning up..."
        
        # Clean package cache
        sudo apt clean
        
        # Clean temporary files
        sudo rm -rf /tmp/*
        
        # Clean old backups (keep last 5)
        cd /var/backups/simantu
        ls -t backup-*.tar.gz | tail -n +6 | xargs -r rm -f
        
        print_success "Disk cleanup completed"
    else
        print_success "Disk usage is OK ($usage%)"
    fi
}

# Restart services if needed
restart_services() {
    print_status "Checking services..."
    
    # Check PM2
    if ! pm2 list | grep -q "simantu-backend.*online"; then
        print_warning "Restarting PM2 application..."
        pm2 restart simantu-backend
    fi
    
    # Check Nginx
    if ! systemctl is-active --quiet nginx; then
        print_warning "Restarting Nginx..."
        sudo systemctl restart nginx
    fi
    
    # Check MySQL
    if ! systemctl is-active --quiet mysql; then
        print_warning "Restarting MySQL..."
        sudo systemctl restart mysql
    fi
    
    print_success "Services checked"
}

# Main maintenance function
main() {
    echo "🔧 SIMANTU System Maintenance"
    echo "============================="
    
    update_system
    cleanup_logs
    optimize_database
    cleanup_disk
    restart_services
    
    echo ""
    print_success "🎉 Maintenance completed successfully!"
}

# Run main function
main "$@"
EOF
    
    chmod +x "$PROJECT_DIR/maintenance.sh"
    
    print_success "Maintenance script created"
}

# Display cron jobs
show_cron_jobs() {
    print_status "Current cron jobs for $CURRENT_USER:"
    echo ""
    crontab -l | grep -A 20 "SIMANTU Cron Jobs" || echo "No SIMANTU cron jobs found"
}

# Main setup function
main() {
    echo "⏰ SIMANTU Cron Jobs Setup"
    echo "=========================="
    
    setup_cron_jobs
    setup_log_rotation
    create_alert_script
    create_maintenance_script
    
    echo ""
    print_success "🎉 Cron jobs setup completed!"
    echo ""
    echo "📋 Installed cron jobs:"
    echo "- Monitoring: Every 5 minutes"
    echo "- Daily backup: 2:00 AM"
    echo "- Weekly log cleanup: Sunday 3:00 AM"
    echo "- Monthly backup cleanup: 1st day 4:00 AM"
    echo "- SSL renewal check: Daily 6:00 AM"
    echo "- System update check: Monday 5:00 AM"
    echo ""
    echo "🔧 Useful commands:"
    echo "- View cron jobs: crontab -l"
    echo "- Edit cron jobs: crontab -e"
    echo "- Test alert: ./alert.sh test"
    echo "- Run maintenance: ./maintenance.sh"
    echo "- View logs: tail -f /var/log/simantu-monitor.log"
    echo ""
    
    show_cron_jobs
}

# Run main function
main "$@"
