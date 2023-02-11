@echo off
cd /d "%~dp0"

del  /Q modelsim.ini 2>nul
del  /Q transcript 2>nul
rd /s /Q work 2>nul

