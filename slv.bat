@echo off
cd /d "%~dp0"

git add . >nul 2>&1
git commit -m "Atualização automática" >nul 2>&1
git push >nul 2>&1

exit