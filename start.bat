@echo off
title Teddy POS Server
cd /d "%~dp0"

echo Installing dependencies...
call npm install

echo.
echo Starting Teddy POS...
start http://localhost:3001
node server.js
