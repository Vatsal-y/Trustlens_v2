@echo off
echo ==========================================
echo Starting TrustLens (Backend + Frontend)
echo ==========================================

echo [1/2] Launching Backend Server...
start "TrustLens Backend" cmd /k "cd backend && pip install -r requirements.txt && python run_api.py"

echo [2/2] Launching Frontend...
start "TrustLens Frontend" cmd /k "cd frontend && npm install && npm run dev"

echo ==========================================
echo Servers are starting in new windows!
echo Backend API: http://localhost:5000
echo Frontend UI: http://localhost:5173 (usually)
echo ==========================================
pause
