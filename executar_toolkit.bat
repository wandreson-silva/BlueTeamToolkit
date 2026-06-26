@echo off
title Blue Team Toolkit

:menu
cls
echo ============================
echo BLUE TEAM TOOLKIT
echo ============================
echo 1 - Monitor de portas
echo 2 - Scanner de rede
echo 3 - Processos de rede
echo 4 - ARP Table
echo 5 - Sair
echo.

set /p op=Escolha:

if %op%==1 powershell -ExecutionPolicy Bypass -File monitor_portas.ps1
if %op%==2 powershell -ExecutionPolicy Bypass -File scanner_rede.ps1
if %op%==3 powershell -ExecutionPolicy Bypass -File processos_rede.ps1
if %op%==4 powershell -ExecutionPolicy Bypass -File detector_arp_spoof.ps1
if %op%==5 exit

pause
goto menu