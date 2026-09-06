@echo off
title WinDebloatCleanX64 - Inicializador
cd /d "%~dp0"

:: Auto-elevacao para Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Executa o script PowerShell WinDebloatCleanX64.ps1 com modo STA
powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0WinDebloatCleanX64.ps1"

if %errorLevel% neq 0 (
    echo.
    echo Ocorreu um erro ao carregar o WinDebloatCleanX64.ps1.
    pause
)