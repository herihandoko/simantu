#!/bin/bash

# Install Node.js on Ubuntu VM
# Run this script on the VM

echo "Installing Node.js 18.x on Ubuntu..."

# Update package list
sudo apt update

# Install curl if not present
sudo apt install -y curl

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Verify installation
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "PM2 version: $(pm2 --version)"

echo "Node.js installation completed!"
