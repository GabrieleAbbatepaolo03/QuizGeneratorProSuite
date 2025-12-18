@echo off
cd backend
start /min quiz_backend.exe
cd ..
timeout /t 2 /nobreak >nul
start frontend.exe
exit