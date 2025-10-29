# Dental Clinic Signage - Installation Instructions

## Step 1: Upload Files
1. Compress this entire folder into a ZIP file
2. Login to your cPanel
3. Go to File Manager
4. Navigate to public_html (or your domain folder)
5. Upload and extract the ZIP file

## Step 2: Backend Setup
```bash
# SSH into your server
cd /path/to/your/app/backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Step 3: Frontend Setup
```bash
cd ../frontend

# Install dependencies
npm install

# Build for production
npm run build

# Copy build files to web root
cp -r build/* ../public_html/
```

## Step 4: Database Setup
```bash
# Install and start MongoDB
sudo apt update
sudo apt install mongodb
sudo systemctl start mongodb
sudo systemctl enable mongodb
```

## Step 5: Configure Environment
1. Copy `.env.production` to `.env` in both frontend and backend
2. Update all placeholder values with your actual configuration
3. Upload your Google Cloud service account JSON file
4. Update the path in GOOGLE_APPLICATION_CREDENTIALS

## Step 6: Start Services
```bash
# Start backend
./start_backend.sh
```

## Step 7: Test
Visit your domain to test the application.
- Admin panel: https://yourdomain.com/admin
- Display pages: https://yourdomain.com/display/sako
