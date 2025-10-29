#!/bin/bash
# Backend startup script

echo "Starting Dental Clinic Backend..."

# Activate virtual environment
cd backend
source venv/bin/activate

# Start the backend server
uvicorn server:app --host 0.0.0.0 --port 8001 --reload

echo "Backend started on port 8001"
