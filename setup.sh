#!/bin/bash

echo "🚀 SIMANTU Setup Script"
echo "======================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL is not installed. Please install MySQL first."
    exit 1
fi

echo "✅ Node.js and MySQL are installed"

# Install dependencies
echo "📦 Installing dependencies..."
npm run install-all

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"

# Create .env file if it doesn't exist
if [ ! -f "server/.env" ]; then
    echo "📝 Creating .env file..."
    cat > server/.env << EOF
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=Nd45mulh0!
DB_NAME=simantu_db
JWT_SECRET=simantu_jwt_secret_key_2024
PORT=5001
EOF
    echo "✅ .env file created"
else
    echo "✅ .env file already exists"
fi

# Database setup
echo "🗄️  Setting up database..."
echo "Please enter your MySQL root password (press Enter if no password):"
read -s mysql_password

if [ -z "$mysql_password" ]; then
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS simantu_db;" 2>/dev/null
    if [ $? -eq 0 ]; then
        mysql -u root simantu_db < database/schema.sql 2>/dev/null
        if [ $? -eq 0 ]; then
            mysql -u root simantu_db < database/seed.sql 2>/dev/null
            echo "✅ Database setup completed"
        else
            echo "⚠️  Database created but schema import failed. Please run manually:"
            echo "   mysql -u root simantu_db < database/schema.sql"
        fi
    else
        echo "⚠️  Failed to create database. Please run manually:"
        echo "   mysql -u root -p -e 'CREATE DATABASE IF NOT EXISTS simantu_db;'"
        echo "   mysql -u root -p simantu_db < database/schema.sql"
        echo "   mysql -u root -p simantu_db < database/seed.sql"
    fi
else
    mysql -u root -p"$mysql_password" -e "CREATE DATABASE IF NOT EXISTS simantu_db;" 2>/dev/null
    if [ $? -eq 0 ]; then
        mysql -u root -p"$mysql_password" simantu_db < database/schema.sql 2>/dev/null
        if [ $? -eq 0 ]; then
            mysql -u root -p"$mysql_password" simantu_db < database/seed.sql 2>/dev/null
            echo "✅ Database setup completed"
        else
            echo "⚠️  Database created but schema import failed. Please run manually:"
            echo "   mysql -u root -p simantu_db < database/schema.sql"
        fi
    else
        echo "⚠️  Failed to create database. Please run manually:"
        echo "   mysql -u root -p -e 'CREATE DATABASE IF NOT EXISTS simantu_db;'"
        echo "   mysql -u root -p simantu_db < database/schema.sql"
        echo "   mysql -u root -p simantu_db < database/seed.sql"
    fi
fi

echo ""
echo "🎉 Setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Start the application: npm run dev"
echo "2. Open your browser: http://localhost:3000"
echo "3. Login with: admin@simantu.com / admin123"
echo ""
echo "🔧 If you encounter issues, check the README.md troubleshooting section"
