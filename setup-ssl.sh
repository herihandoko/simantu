#!/bin/bash

# SIMANTU SSL Setup Script
# Script untuk setup SSL certificate dengan Let's Encrypt

set -e  # Exit on any error

echo "🔒 Setting up SSL for SIMANTU..."

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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root for SSL setup"
   exit 1
fi

# Get domain name from user
get_domain() {
    if [ -z "$1" ]; then
        echo -n "Enter your domain name (e.g., example.com): "
        read DOMAIN
    else
        DOMAIN=$1
    fi
    
    if [ -z "$DOMAIN" ]; then
        print_error "Domain name is required"
        exit 1
    fi
    
    print_status "Domain: $DOMAIN"
}

# Install Certbot
install_certbot() {
    print_status "Installing Certbot..."
    
    # Update package list
    apt update
    
    # Install snapd if not installed
    if ! command -v snap &> /dev/null; then
        apt install -y snapd
    fi
    
    # Install certbot via snap
    snap install core; snap refresh core
    snap install --classic certbot
    
    # Create symlink
    ln -sf /snap/bin/certbot /usr/bin/certbot
    
    print_success "Certbot installed"
}

# Obtain SSL certificate
obtain_certificate() {
    print_status "Obtaining SSL certificate for $DOMAIN..."
    
    # Stop nginx temporarily
    systemctl stop nginx
    
    # Obtain certificate
    certbot certonly --standalone -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
    
    print_success "SSL certificate obtained"
}

# Update Nginx configuration
update_nginx_config() {
    print_status "Updating Nginx configuration for SSL..."
    
    local nginx_config="/etc/nginx/sites-available/simantu"
    
    # Backup current config
    cp $nginx_config $nginx_config.backup
    
    # Create new SSL-enabled config
    cat > $nginx_config << EOF
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
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
        root /var/www/simantu/client/dist;
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
    
    # Test configuration
    nginx -t
    
    # Start nginx
    systemctl start nginx
    systemctl enable nginx
    
    print_success "Nginx configuration updated for SSL"
}

# Setup auto-renewal
setup_auto_renewal() {
    print_status "Setting up SSL certificate auto-renewal..."
    
    # Create renewal script
    cat > /etc/cron.d/certbot-renew << EOF
# Renew Let's Encrypt certificates twice daily
0 12 * * * root certbot renew --quiet --post-hook "systemctl reload nginx"
0 0 * * * root certbot renew --quiet --post-hook "systemctl reload nginx"
EOF
    
    # Test renewal
    certbot renew --dry-run
    
    print_success "Auto-renewal configured"
}

# Update environment file
update_environment() {
    print_status "Updating environment configuration..."
    
    local env_file="/var/www/simantu/server/.env"
    
    if [ -f "$env_file" ]; then
        # Update CORS origin to use HTTPS
        sed -i "s|CORS_ORIGIN=.*|CORS_ORIGIN=https://$DOMAIN|" $env_file
        
        print_success "Environment configuration updated"
    else
        print_warning "Environment file not found at $env_file"
    fi
}

# Main SSL setup function
main() {
    echo "🔒 SIMANTU SSL Setup"
    echo "===================="
    
    get_domain "$1"
    install_certbot
    obtain_certificate
    update_nginx_config
    setup_auto_renewal
    update_environment
    
    echo ""
    print_success "🎉 SSL setup completed successfully!"
    echo ""
    echo "📋 SSL Configuration:"
    echo "- Domain: $DOMAIN"
    echo "- Certificate: /etc/letsencrypt/live/$DOMAIN/"
    echo "- Auto-renewal: Configured"
    echo ""
    echo "🌐 Your application is now available at:"
    echo "- https://$DOMAIN"
    echo "- https://www.$DOMAIN"
    echo ""
    echo "🔧 Useful commands:"
    echo "- Check certificate status: certbot certificates"
    echo "- Test renewal: certbot renew --dry-run"
    echo "- Check Nginx status: systemctl status nginx"
    echo "- View SSL logs: tail -f /var/log/letsencrypt/letsencrypt.log"
}

# Run main function
main "$@"
