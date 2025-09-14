#!/bin/bash

# SIMANTU VM Deployment Script
# Script khusus untuk deploy ke VM simantu.bantendev.id

set -e  # Exit on any error

echo "🚀 Starting SIMANTU VM Deployment..."
echo "Domain: simantu.bantendev.id"
echo "IP: 103.215.154.196"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# VM Configuration
VM_IP="103.215.154.196"
VM_DOMAIN="simantu.bantendev.id"
VM_USER="simantubantendev"
VM_PASSWORD="QvyZPrWUa-FsC%Ls"
PROJECT_NAME="simantu"
PROJECT_DIR="/var/www/simantu"
REPO_URL="https://github.com/herihandoko/simantu.git"

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

# Function to run commands on VM via SSH
run_on_vm() {
    local command="$1"
    print_status "Running on VM: $command"
    
    sshpass -p "$VM_PASSWORD" ssh -o StrictHostKeyChecking=no "$VM_USER@$VM_IP" "$command"
}

# Function to copy files to VM
copy_to_vm() {
    local source="$1"
    local destination="$2"
    print_status "Copying $source to VM:$destination"
    
    sshpass -p "$VM_PASSWORD" scp -o StrictHostKeyChecking=no -r "$source" "$VM_USER@$VM_IP:$destination"
}

# Check if sshpass is installed
check_sshpass() {
    if ! command -v sshpass &> /dev/null; then
        print_error "sshpass is required but not installed."
        print_status "Install it with:"
        echo "  macOS: brew install hudochenkov/sshpass/sshpass"
        echo "  Ubuntu: sudo apt install sshpass"
        exit 1
    fi
}

# Install system dependencies on VM
install_vm_dependencies() {
    print_status "Installing dependencies on VM..."
    
    run_on_vm "
        # Update system
        sudo apt update && sudo apt upgrade -y
        
        # Install basic tools
        sudo apt install -y curl wget git unzip nginx mysql-server
        
        # Install Node.js 18.x
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        
        # Install PM2 globally
        sudo npm install -g pm2
        
        # Start and enable services
        sudo systemctl start mysql
        sudo systemctl enable mysql
        sudo systemctl start nginx
        sudo systemctl enable nginx
        
        # Create project directory
        sudo mkdir -p $PROJECT_DIR
        sudo chown $VM_USER:$VM_USER $PROJECT_DIR
    "
    
    print_success "VM dependencies installed"
}

# Clone repository on VM
clone_repository() {
    print_status "Cloning repository on VM..."
    
    run_on_vm "
        cd /home/$VM_USER
        if [ -d 'simantu' ]; then
            echo 'Repository exists, updating...'
            cd simantu
            git pull origin main
        else
            echo 'Cloning repository...'
            git clone $REPO_URL
            cd simantu
        fi
        
        # Copy to project directory
        cp -r . $PROJECT_DIR/
        cd $PROJECT_DIR
        
        # Make scripts executable
        chmod +x deploy.sh update-deploy.sh setup-ssl.sh
    "
    
    print_success "Repository cloned and prepared"
}

# Setup database on VM
setup_database() {
    print_status "Setting up database on VM..."
    
    run_on_vm "
        # Create database and user
        sudo mysql -e \"CREATE DATABASE IF NOT EXISTS simantu_db;\"
        sudo mysql -e \"CREATE USER IF NOT EXISTS 'simantu_user'@'localhost' IDENTIFIED BY 'simantu_password_2024';\"
        sudo mysql -e \"GRANT ALL PRIVILEGES ON simantu_db.* TO 'simantu_user'@'localhost';\"
        sudo mysql -e \"FLUSH PRIVILEGES;\"
        
        # Import schema
        cd $PROJECT_DIR
        mysql -u simantu_user -psimantu_password_2024 simantu_db < database/schema.sql
        
        # Import seed data if exists
        if [ -f 'database/seed.sql' ]; then
            mysql -u simantu_user -psimantu_password_2024 simantu_db < database/seed.sql
        fi
    "
    
    print_success "Database setup complete"
}

# Deploy application on VM
deploy_application() {
    print_status "Deploying application on VM..."
    
    run_on_vm "
        cd $PROJECT_DIR
        
        # Install dependencies
        npm run install-all
        
        # Build frontend
        npm run build
        
        # Create production environment file
        cat > server/.env << 'EOF'
# Production Environment Configuration
NODE_ENV=production
DB_HOST=localhost
DB_USER=simantu_user
DB_PASSWORD=simantu_password_2024
DB_NAME=simantu_db
JWT_SECRET=simantu_jwt_secret_production_2024_$(openssl rand -hex 32)
PORT=5001
CORS_ORIGIN=https://simantu.bantendev.id
EOF
        
        # Start application with PM2
        pm2 start ecosystem.config.js
        pm2 save
        pm2 startup
    "
    
    print_success "Application deployed"
}

# Setup Nginx on VM
setup_nginx() {
    print_status "Setting up Nginx on VM..."
    
    run_on_vm "
        # Create Nginx configuration
        sudo tee /etc/nginx/sites-available/simantu > /dev/null << 'EOF'
server {
    listen 80;
    server_name simantu.bantendev.id www.simantu.bantendev.id;
    
    # Security headers
    add_header X-Frame-Options \"SAMEORIGIN\" always;
    add_header X-XSS-Protection \"1; mode=block\" always;
    add_header X-Content-Type-Options \"nosniff\" always;
    add_header Referrer-Policy \"no-referrer-when-downgrade\" always;
    
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
            add_header Cache-Control \"public, immutable\";
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
        sudo ln -sf /etc/nginx/sites-available/simantu /etc/nginx/sites-enabled/
        
        # Remove default site
        sudo rm -f /etc/nginx/sites-enabled/default
        
        # Test and reload Nginx
        sudo nginx -t
        sudo systemctl reload nginx
    "
    
    print_success "Nginx configured"
}

# Setup firewall on VM
setup_firewall() {
    print_status "Setting up firewall on VM..."
    
    run_on_vm "
        # Configure UFW firewall
        sudo ufw allow ssh
        sudo ufw allow 'Nginx Full'
        sudo ufw --force enable
    "
    
    print_success "Firewall configured"
}

# Test deployment
test_deployment() {
    print_status "Testing deployment..."
    
    # Test if services are running
    run_on_vm "
        echo '=== PM2 Status ==='
        pm2 status
        
        echo '=== Nginx Status ==='
        sudo systemctl status nginx --no-pager
        
        echo '=== MySQL Status ==='
        sudo systemctl status mysql --no-pager
        
        echo '=== Test API ==='
        curl -s http://localhost:5001/api/health || echo 'API not responding'
    "
    
    print_success "Deployment test completed"
}

# Main deployment function
main() {
    echo "🚀 SIMANTU VM Deployment"
    echo "Domain: $VM_DOMAIN"
    echo "IP: $VM_IP"
    echo "User: $VM_USER"
    echo "================================"
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ] || [ ! -d "server" ] || [ ! -d "client" ]; then
        print_error "Please run this script from the simantu project root directory"
        exit 1
    fi
    
    # Check sshpass
    check_sshpass
    
    # Run deployment steps
    install_vm_dependencies
    clone_repository
    setup_database
    deploy_application
    setup_nginx
    setup_firewall
    test_deployment
    
    echo ""
    print_success "🎉 VM Deployment completed successfully!"
    echo ""
    echo "📋 Deployment Summary:"
    echo "- Domain: https://$VM_DOMAIN"
    echo "- IP: $VM_IP"
    echo "- Project: $PROJECT_DIR"
    echo "- Database: simantu_db"
    echo "- Process Manager: PM2"
    echo "- Web Server: Nginx"
    echo ""
    echo "🔧 Next Steps:"
    echo "1. Update DNS records to point $VM_DOMAIN to $VM_IP"
    echo "2. Setup SSL certificate: ssh $VM_USER@$VM_IP 'cd $PROJECT_DIR && sudo ./setup-ssl.sh $VM_DOMAIN'"
    echo "3. Test the application: http://$VM_DOMAIN"
    echo ""
    echo "🔧 Useful Commands:"
    echo "- SSH to VM: ssh $VM_USER@$VM_IP"
    echo "- Check PM2: ssh $VM_USER@$VM_IP 'pm2 status'"
    echo "- View logs: ssh $VM_USER@$VM_IP 'pm2 logs simantu-backend'"
    echo "- Restart app: ssh $VM_USER@$VM_IP 'pm2 restart simantu-backend'"
    echo ""
    echo "⚠️  Important:"
    echo "- Make sure DNS is pointing to $VM_IP"
    echo "- SSL setup is recommended for production"
    echo "- Monitor logs regularly for any issues"
}

# Run main function
main "$@"

