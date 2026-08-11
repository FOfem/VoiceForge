@echo off
REM ============================================================
REM VoiceForge Windows Build Script
REM ============================================================

REM Set UTF-8 encoding to handle Unicode characters
chcp 65001 >nul

setlocal enabledelayedexpansion

echo ============================================================
echo VoiceForge Windows Build Script
echo ============================================================
echo.

set VERSION=1.0.0
set APP_NAME=VoiceForge

echo Build Configuration:
echo   Version: %VERSION%
echo   App Name: %APP_NAME%
echo.

REM ============================================================
REM Step 1: Clean previous builds
REM ============================================================
echo Cleaning previous builds...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist *.egg-info rmdir /s /q *.egg-info
if exist *.spec del *.spec
echo Clean complete
echo.

REM ============================================================
REM Step 2: Check Python installation
REM ============================================================
echo Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found! Please install Python 3.9+
    pause
    exit /b 1
)
python --version
echo Python found
echo.

REM ============================================================
REM Step 3: Verify src directory exists
REM ============================================================
echo Verifying src directory...
if not exist "src\main.py" (
    echo ERROR: src\main.py not found!
    echo Current directory: %CD%
    dir /b
    pause
    exit /b 1
)
echo src directory verified
echo.

REM ============================================================
REM Step 4: Install/upgrade build tools
REM ============================================================
echo Installing build tools...
python -m pip install --upgrade pip setuptools wheel
python -m pip install --upgrade build
echo Build tools installed
echo.

REM ============================================================
REM Step 5: Install dependencies
REM ============================================================
echo Installing dependencies...
echo This may take several minutes...

echo Installing PyTorch CPU...
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

echo Installing audio and scientific packages...
pip install sounddevice soundfile numpy scipy

echo Installing TTS and utilities...
pip install TTS pyyaml requests

echo Installing build tools...
pip install pyinstaller pytest pytest-cov

echo Dependencies installed
echo.

REM ============================================================
REM Step 6: Install application
REM ============================================================
echo Installing VoiceForge...
pip install .
echo Application installed
echo.

REM ============================================================
REM Step 7: Test import
REM ============================================================
echo Testing import...
python -c "import src; print('Import successful')"
if errorlevel 1 (
    echo WARNING: Import test failed, but continuing...
)
echo.

REM ============================================================
REM Step 8: Build with PyInstaller
REM ============================================================
echo Building %APP_NAME%...
echo This may take several minutes...

pyinstaller --name="VoiceForge" --windowed --onefile --paths=src src/main.py

if errorlevel 1 (
    echo Build failed!
    echo Trying with console mode for debugging...
    pyinstaller --name="VoiceForge_Debug" --console --onefile --paths=src src/main.py
)

echo Build complete
echo.

REM ============================================================
REM Step 9: Verify build
REM ============================================================
echo Verifying build...
if exist "dist\VoiceForge.exe" (
    echo Build successful!
    echo Output: dist\VoiceForge.exe
    dir dist\VoiceForge.exe
) else if exist "dist\VoiceForge_Debug.exe" (
    echo Debug build found: dist\VoiceForge_Debug.exe
) else (
    echo Build failed - no executable found
    pause
    exit /b 1
)
echo.

REM ============================================================
REM Build complete
REM ============================================================
echo ============================================================
echo Build complete!
echo.
echo Output files:
if exist "dist\VoiceForge.exe" echo    dist\VoiceForge.exe
if exist "dist\VoiceForge_Debug.exe" echo    dist\VoiceForge_Debug.exe
echo.
echo To run: double-click VoiceForge.exe
echo.
echo ============================================================
pause
