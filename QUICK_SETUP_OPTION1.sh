#!/bin/bash

# OPTION 1: Quick Setup for Full-Stack VPS Deployment
# Run this script on your VPS/dedicated server after uploading files

echo "🏥 Dental Clinic Signage - Full-Stack Setup"
echo "============================================"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  This script should be run as root for system installations"
   echo "   You can run specific sections manually if needed"
fi

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "🔧 Installing Python, Node.js, MongoDB..."
apt install -y python3 python3-pip python3-venv nodejs npm mongodb

# Start and enable MongoDB
echo "🗄️ Starting MongoDB..."
systemctl start mongodb
systemctl enable mongodb

# Setup backend
echo "🐍 Setting up Python backend..."
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Setup frontend
echo "⚛️ Setting up React frontend..."
cd ../frontend
npm install
npm run build

# Create production environment files
echo "⚙️ Creating environment configuration..."

# Backend environment
cat > ../backend/.env << 'EOF'
MONGO_URL="mongodb://localhost:27017"
DB_NAME="dental_clinic_production"
CORS_ORIGINS="https://yourdomain.com,https://www.yourdomain.com"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="CHANGE-THIS-PASSWORD"
JWT_SECRET_KEY="CHANGE-THIS-JWT-SECRET-32-CHARS-LONG"
GOOGLE_CLOUD_PROJECT="your-gcp-project"
GOOGLE_CLOUD_BUCKET="your-gcs-bucket"
GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
EOF

# Frontend environment  
cat > .env << 'EOF'
REACT_APP_BACKEND_URL=https://yourdomain.com
EOF

# Create systemd service for backend
echo "🚀 Creating system service..."
cat > /etc/systemd/system/dental-clinic-backend.service << EOF
[Unit]
Description=Dental Clinic Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$(pwd)/../backend
Environment=PATH=$(pwd)/../backend/venv/bin
ExecStart=$(pwd)/../backend/venv/bin/uvicorn server:app --host 0.0.0.0 --port 8001
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Copy frontend build to web directory
echo "🌐 Setting up web files..."
cp -r build/* /var/www/html/

# Create .htaccess for Apache
cat > /var/www/html/.htaccess << 'EOF'
RewriteEngine On

# Security Headers
Header always set X-Frame-Options SAMEORIGIN
Header always set X-Content-Type-Options nosniff

# API Proxy to backend
RewriteRule ^api/(.*)$ http://localhost:8001/api/$1 [P,L]

# WebSocket Proxy
RewriteRule ^socket\.io/(.*)$ http://localhost:8001/socket.io/$1 [P,L]

# React Router Support
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable dental-clinic-backend
systemctl start dental-clinic-backend

echo ""
echo "✅ Setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Edit /backend/.env with your actual configuration"
echo "2. Update CORS_ORIGINS with your domain"
echo "3. Change ADMIN_PASSWORD to something secure"
echo "4. Set up SSL certificate for HTTPS"
echo "5. Upload Google Cloud service account JSON"
echo ""
echo "🔧 Service management:"
echo "   Start:   systemctl start dental-clinic-backend"
echo "   Stop:    systemctl stop dental-clinic-backend"
echo "   Status:  systemctl status dental-clinic-backend"
echo "   Logs:    journalctl -u dental-clinic-backend -f"
echo ""
echo "🌐 Access your application:"
echo "   Admin Panel: https://yourdomain.com/admin"
echo "   Display:     https://yourdomain.com/display/sako"
echo "   API Health:  https://yourdomain.com/api/health"
echo ""