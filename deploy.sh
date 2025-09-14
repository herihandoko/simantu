#!/bin/bash

# SIMANTU Production Deployment Script
# Script untuk deploy aplikasi SIMANTU ke VM production

set -e  # Exit on any error

echo "🚀 Starting SIMANTU Production Deployment..."

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
NGINX_CONFIG="/etc/nginx/sites-available/simantu"
NGINX_ENABLED="/etc/nginx/sites-enabled/simantu"
SERVICE_NAME="simantu-backend"
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

# Check if required commands exist
check_requirements() {
    print_status "Checking system requirements..."
    
    local missing_deps=()
    
    if ! command -v node &> /dev/null; then
        missing_deps+=("nodejs")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    fi
    
    if ! command -v nginx &> /dev/null; then
        missing_deps+=("nginx")
    fi
    
    if ! command -v pm2 &> /dev/null; then
        missing_deps+=("pm2")
    fi
    
    if ! command -v mysql &> /dev/null; then
        missing_deps+=("mysql-server")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Please install them first:"
        echo "sudo apt update"
        echo "sudo apt install -y nodejs npm nginx mysql-server"
        echo "sudo npm install -g pm2"
        exit 1
    fi
    
    print_success "All requirements satisfied"
}

# Install system dependencies
install_dependencies() {
    print_status "Installing system dependencies..."
    
    # Update package list
    sudo apt update
    
    # Install Node.js (if not installed)
    if ! command -v node &> /dev/null; then
        print_status "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Install PM2 globally
    if ! command -v pm2 &> /dev/null; then
        print_status "Installing PM2..."
        sudo npm install -g pm2
    fi
    
    # Install Nginx
    if ! command -v nginx &> /dev/null; then
        print_status "Installing Nginx..."
        sudo apt install -y nginx
    fi
    
    # Install MySQL
    if ! command -v mysql &> /dev/null; then
        print_status "Installing MySQL..."
        sudo apt install -y mysql-server
    fi
    
    print_success "Dependencies installed"
}

# Setup project directory
setup_project_directory() {
    print_status "Setting up project directory..."
    
    # Create project directory
    sudo mkdir -p $PROJECT_DIR
    sudo chown $USER:$USER $PROJECT_DIR
    
    # Create backup directory
    sudo mkdir -p $BACKUP_DIR
    sudo chown $USER:$USER $BACKUP_DIR
    
    print_success "Project directory setup complete"
}

# Backup existing deployment
backup_existing() {
    if [ -d "$PROJECT_DIR" ] && [ "$(ls -A $PROJECT_DIR)" ]; then
        print_status "Backing up existing deployment..."
        
        local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
        sudo cp -r $PROJECT_DIR $BACKUP_DIR/$backup_name
        
        print_success "Backup created: $BACKUP_DIR/$backup_name"
    fi
}

# Deploy application
deploy_application() {
    print_status "Deploying application..."
    
    # Copy project files
    cp -r . $PROJECT_DIR/
    cd $PROJECT_DIR
    
    # Install dependencies
    print_status "Installing dependencies..."
    npm run install-all
    
    # Build frontend
    print_status "Building frontend..."
    npm run build
    
    print_success "Application deployed"
}

# Setup database
setup_database() {
    print_status "Setting up database..."
    
    # Start MySQL service
    sudo systemctl start mysql
    sudo systemctl enable mysql
    
    # Create database and user
    print_status "Creating database and user..."
    
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS simantu_db;"
    sudo mysql -e "CREATE USER IF NOT EXISTS 'simantu_user'@'localhost' IDENTIFIED BY 'simantu_password_2024';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON simantu_db.* TO 'simantu_user'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
    
    # Import schema
    print_status "Importing database schema..."
    mysql -u simantu_user -psimantu_password_2024 simantu_db < database/schema.sql
    
    # Import seed data (optional)
    if [ -f "database/seed.sql" ]; then
        print_status "Importing seed data..."
        mysql -u simantu_user -psimantu_password_2024 simantu_db < database/seed.sql
    fi
    
    print_success "Database setup complete"
}

# Create production environment file
create_production_env() {
    print_status "Creating production environment configuration..."
    
    cat > $PROJECT_DIR/server/.env << EOF
# Production Environment Configuration
NODE_ENV=production
DB_HOST=localhost
DB_USER=simantu_user
DB_PASSWORD=simantu_password_2024
DB_NAME=simantu_db
JWT_SECRET=simantu_jwt_secret_production_2024_$(openssl rand -hex 32)
PORT=5001
CORS_ORIGIN=https://yourdomain.com
EOF
    
    print_success "Production environment file created"
}

# Setup PM2 process
setup_pm2() {
    print_status "Setting up PM2 process..."
    
    cd $PROJECT_DIR
    
    # Create PM2 ecosystem file
    cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: '$PM2_APP_NAME',
    script: 'server/server.js',
    cwd: '$PROJECT_DIR',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 5001
    },
    error_file: '/var/log/pm2/simantu-error.log',
    out_file: '/var/log/pm2/simantu-out.log',
    log_file: '/var/log/pm2/simantu-combined.log',
    time: true,
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
};
EOF
    
    # Start application with PM2
    pm2 start ecosystem.config.js
    pm2 save
    pm2 startup
    
    print_success "PM2 process setup complete"
}

# Setup Nginx
setup_nginx() {
    print_status "Setting up Nginx..."
    
    # Create Nginx configuration
    sudo tee $NGINX_CONFIG > /dev/null << EOF
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL Configuration (you need to obtain SSL certificates)
    # ssl_certificate /path/to/your/certificate.crt;
    # ssl_certificate_key /path/to/your/private.key;
    
    # For now, we'll use HTTP only
    # Remove the above SSL block and use this instead:
    # listen 80;
    # server_name yourdomain.com www.yourdomain.com;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;
    
    # Frontend (Vue.js build)
    location / {
        root $PROJECT_DIR/client/dist;
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Backend API
    location /api {
        proxy_pass http://localhost:5001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://localhost:5001/api/health;
        access_log off;
    }
}
EOF
    
    # Enable site
    sudo ln -sf $NGINX_CONFIG $NGINX_ENABLED
    
    # Test Nginx configuration
    sudo nginx -t
    
    # Reload Nginx
    sudo systemctl reload nginx
    sudo systemctl enable nginx
    
    print_success "Nginx setup complete"
}

# Setup firewall
setup_firewall() {
    print_status "Setting up firewall..."
    
    # Allow SSH, HTTP, and HTTPS
    sudo ufw allow ssh
    sudo ufw allow 'Nginx Full'
    sudo ufw --force enable
    
    print_success "Firewall configured"
}

# Setup log rotation
setup_log_rotation() {
    print_status "Setting up log rotation..."
    
    sudo tee /etc/logrotate.d/simantu > /dev/null << EOF
/var/log/pm2/simantu-*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 $USER $USER
    postrotate
        pm2 reloadLogs
    endscript
}
EOF
    
    print_success "Log rotation configured"
}

# Main deployment function
main() {
    echo "🚀 SIMANTU Production Deployment"
    echo "================================"
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ] || [ ! -d "server" ] || [ ! -d "client" ]; then
        print_error "Please run this script from the simantu project root directory"
        exit 1
    fi
    
    # Run deployment steps
    check_requirements
    install_dependencies
    setup_project_directory
    backup_existing
    deploy_application
    setup_database
    create_production_env
    setup_pm2
    setup_nginx
    setup_firewall
    setup_log_rotation
    
    echo ""
    print_success "🎉 Deployment completed successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Update your domain name in $NGINX_CONFIG"
    echo "2. Obtain SSL certificates and update Nginx config"
    echo "3. Update DNS records to point to this server"
    echo "4. Test the application: http://yourdomain.com"
    echo ""
    echo "🔧 Useful commands:"
    echo "- Check PM2 status: pm2 status"
    echo "- View logs: pm2 logs $PM2_APP_NAME"
    echo "- Restart app: pm2 restart $PM2_APP_NAME"
    echo "- Check Nginx status: sudo systemctl status nginx"
    echo "- View Nginx logs: sudo tail -f /var/log/nginx/error.log"
    echo ""
    echo "📁 Project location: $PROJECT_DIR"
    echo "🗄️  Database: simantu_db (user: simantu_user)"
    echo "🌐 Web server: Nginx"
    echo "⚡ Process manager: PM2"
}

# Run main function
main "$@"
