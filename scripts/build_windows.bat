@echo off
REM ============================================================
REM VoiceForge Windows Build Script
REM Builds standalone executable for Windows 10/11
REM ============================================================

setlocal enabledelayedexpansion

echo ============================================================
echo 🎙️ VoiceForge Windows Build Script
echo ============================================================
echo.

REM Set variables
set VERSION=1.0.0
set APP_NAME=VoiceForge
set BUILD_DIR=build
set DIST_DIR=dist
set SPEC_FILE=voiceforge.spec

echo 📋 Build Configuration:
echo   Version: %VERSION%
echo   App Name: %APP_NAME%
echo   Build Dir: %BUILD_DIR%
echo   Dist Dir: %DIST_DIR%
echo.

REM ============================================================
REM Step 1: Clean previous builds
REM ============================================================
echo 🧹 Cleaning previous builds...
if exist %BUILD_DIR% rmdir /s /q %BUILD_DIR%
if exist %DIST_DIR% rmdir /s /q %DIST_DIR%
if exist *.spec del *.spec
echo ✅ Clean complete
echo.

REM ============================================================
REM Step 2: Check Python installation
REM ============================================================
echo 🔍 Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found! Please install Python 3.9+
    echo    Download from: https://www.python.org/downloads/
    echo    Make sure to check "Add Python to PATH"
    pause
    exit /b 1
)
python --version
echo ✅ Python found
echo.

REM ============================================================
REM Step 3: Check pip
REM ============================================================
echo 🔍 Checking pip...
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ pip not found! Please ensure pip is installed
    pause
    exit /b 1
)
echo ✅ pip found
echo.

REM ============================================================
REM Step 4: Install/upgrade build tools
REM ============================================================
echo 📦 Installing/upgrading build tools...
python -m pip install --upgrade pip setuptools wheel
python -m pip install --upgrade pyinstaller
echo ✅ Build tools installed
echo.

REM ============================================================
REM Step 5: Install dependencies
REM ============================================================
echo 📦 Installing dependencies...
echo This may take several minutes...

REM Install core dependencies
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
if errorlevel 1 (
    echo ⚠️ PyTorch CPU install failed, trying alternative...
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
)

pip install sounddevice soundfile numpy scipy
pip install TTS pyyaml requests
pip install pyinstaller pytest pytest-cov

echo ✅ Dependencies installed
echo.

REM ============================================================
REM Step 6: Install application
REM ============================================================
echo 📦 Installing VoiceForge...
pip install -e .
if errorlevel 1 (
    echo ⚠️ Editable install failed, continuing...
)
echo ✅ Application installed
echo.

REM ============================================================
REM Step 7: Create PyInstaller spec file
REM ============================================================
echo 📝 Creating PyInstaller spec file...

(
echo # -*- mode: python ; coding: utf-8 -*-
echo.
echo block_cipher = None
echo.
echo a = Analysis(
echo     ['src/main.py'],
echo     pathex=[],
echo     binaries=[],
echo     datas=[],
echo     hiddenimports=[
echo         'tkinter',
echo         'sounddevice',
echo         'soundfile',
echo         'torch',
echo         'torch.nn',
echo         'torch.utils',
echo         'TTS',
echo         'numpy',
echo         'scipy',
echo         'pyyaml',
echo         'requests',
echo     ],
echo     hookspath=[],
echo     hooksconfig={},
echo     runtime_hooks=[],
echo     excludes=[],
echo     win_no_prefer_redirects=False,
echo     win_private_assemblies=False,
echo     cipher=block_cipher,
echo     noarchive=False,
echo )
echo.
echo pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)
echo.
echo exe = EXE(
echo     pyz,
echo     a.scripts,
echo     a.binaries,
echo     a.zipfiles,
echo     a.datas,
echo     [],
echo     name='VoiceForge',
echo     debug=False,
echo     bootloader_ignore_signals=False,
echo     strip=False,
echo     upx=True,
echo     upx_exclude=[],
echo     runtime_tmpdir=None,
echo     console=False,
echo     disable_windowed_traceback=False,
echo     argv_emulation=False,
echo     target_arch=None,
echo     codesign_identity=None,
echo     entitlements_file=None,
echo     icon=None,
echo )
) > %SPEC_FILE%

echo ✅ Spec file created
echo.

REM ============================================================
REM Step 8: Build with PyInstaller
REM ============================================================
echo 🚀 Building %APP_NAME%...
echo This may take several minutes...

pyinstaller %SPEC_FILE% --clean --noconfirm --onefile --windowed --name="VoiceForge"

if errorlevel 1 (
    echo ❌ Build failed!
    echo Trying with console mode for debugging...
    pyinstaller %SPEC_FILE% --clean --noconfirm --onefile --console --name="VoiceForge_Debug"
    echo.
    echo 📋 Debug build created as VoiceForge_Debug.exe
    echo    Run this to see error messages
)

echo.
echo ✅ Build complete
echo.

REM ============================================================
REM Step 9: Verify build
REM ============================================================
echo 🔍 Verifying build...
if exist "%DIST_DIR%\VoiceForge.exe" (
    echo ✅ Build successful!
    echo 📁 Output: %DIST_DIR%\VoiceForge.exe
    dir "%DIST_DIR%\VoiceForge.exe"
) else (
    echo ❌ Build failed - no executable found
    echo Checking for alternate output...
    if exist "%DIST_DIR%\VoiceForge_Debug.exe" (
        echo ✅ Debug build found: %DIST_DIR%\VoiceForge_Debug.exe
    )
    pause
    exit /b 1
)
echo.

REM ============================================================
REM Step 10: Create installer (optional)
REM ============================================================
echo 📦 Creating installer...
echo Checking for Inno Setup...

if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    echo Found Inno Setup, creating installer...
    if exist "installer.iss" (
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss
        echo ✅ Installer created
    ) else (
        echo ⚠️ installer.iss not found, skipping installer creation
    )
) else (
    echo ℹ️ Inno Setup not found, skipping installer creation
    echo    Download from: https://jrsoftware.org/isdl.php
)
echo.

REM ============================================================
REM Step 11: Create portable ZIP
REM ============================================================
echo 📦 Creating portable ZIP...
if exist "%DIST_DIR%\VoiceForge.exe" (
    cd %DIST_DIR%
    powershell -command "Compress-Archive -Path VoiceForge.exe -DestinationPath VoiceForge-Portable.zip"
    cd ..
    echo ✅ Portable ZIP created: %DIST_DIR%\VoiceForge-Portable.zip
)
echo.

REM ============================================================
REM Build complete
REM ============================================================
echo ============================================================
echo ✅ Build complete!
echo.
echo 📁 Output files:
echo    %DIST_DIR%\VoiceForge.exe
if exist "%DIST_DIR%\VoiceForge-Portable.zip" (
echo    %DIST_DIR%\VoiceForge-Portable.zip
)
if exist "%DIST_DIR%\VoiceForgeSetup.exe" (
echo    %DIST_DIR%\VoiceForgeSetup.exe
)
echo.
echo 🚀 To run: double-click VoiceForge.exe
echo.
echo ============================================================
pause