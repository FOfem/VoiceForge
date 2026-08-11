#!/usr/bin/env pwsh
# ============================================================
# VoiceForge Windows Build Script (PowerShell)
# ============================================================

# Set UTF-8 encoding for console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "VoiceForge Windows Build Script" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$Version = "1.0.0"
$AppName = "VoiceForge"

Write-Host "Build Configuration:" -ForegroundColor Yellow
Write-Host "  Version: $Version"
Write-Host "  App Name: $AppName"
Write-Host ""

# Step 1: Clean
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "build") { Remove-Item -Recurse -Force build }
if (Test-Path "dist") { Remove-Item -Recurse -Force dist }
if (Test-Path "*.egg-info") { Remove-Item -Recurse -Force *.egg-info }
if (Test-Path "*.spec") { Remove-Item -Force *.spec }
Write-Host "Clean complete" -ForegroundColor Green
Write-Host ""

# Step 2: Verify src directory
Write-Host "Verifying src directory..." -ForegroundColor Yellow
if (-not (Test-Path "src\main.py")) {
    Write-Host "ERROR: src\main.py not found!" -ForegroundColor Red
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
    Get-ChildItem
    exit 1
}
Write-Host "src directory verified" -ForegroundColor Green
Write-Host ""

# Step 3: Check Python
Write-Host "Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Python not found!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Install build tools
Write-Host "Installing build tools..." -ForegroundColor Yellow
python -m pip install --upgrade pip setuptools wheel
python -m pip install --upgrade build
Write-Host "Build tools installed" -ForegroundColor Green
Write-Host ""

# Step 5: Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray

Write-Host "  Installing PyTorch CPU..." -ForegroundColor Gray
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

Write-Host "  Installing audio packages..." -ForegroundColor Gray
pip install sounddevice soundfile numpy scipy

Write-Host "  Installing TTS..." -ForegroundColor Gray
pip install TTS pyyaml requests

Write-Host "  Installing build tools..." -ForegroundColor Gray
pip install pyinstaller pytest pytest-cov

Write-Host "Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 6: Install application
Write-Host "Installing VoiceForge..." -ForegroundColor Yellow
pip install .
Write-Host "Application installed" -ForegroundColor Green
Write-Host ""

# Step 7: Test import
Write-Host "Testing import..." -ForegroundColor Yellow
try {
    python -c "import src; print('Import successful')"
} catch {
    Write-Host "WARNING: Import test failed, continuing..." -ForegroundColor Yellow
}
Write-Host ""

# Step 8: Build
Write-Host "Building $AppName..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray

pyinstaller --name=$AppName --windowed --onefile --paths=src src/main.py

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host "Trying with console mode..." -ForegroundColor Yellow
    pyinstaller --name="${AppName}_Debug" --console --onefile --paths=src src/main.py
}
Write-Host ""

# Step 9: Verify
Write-Host "Verifying build..." -ForegroundColor Yellow
if (Test-Path "dist\VoiceForge.exe") {
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "Output: dist\VoiceForge.exe" -ForegroundColor Cyan
    Get-ChildItem dist\VoiceForge.exe
} elseif (Test-Path "dist\VoiceForge_Debug.exe") {
    Write-Host "Debug build found: dist\VoiceForge_Debug.exe" -ForegroundColor Green
} else {
    Write-Host "Build failed - no executable found" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Build complete!" -ForegroundColor Green
Write-Host ""
if (Test-Path "dist\VoiceForge.exe") { Write-Host "dist\VoiceForge.exe" -ForegroundColor Cyan }
if (Test-Path "dist\VoiceForge_Debug.exe") { Write-Host "dist\VoiceForge_Debug.exe" -ForegroundColor Cyan }
Write-Host ""
Write-Host "To run: double-click VoiceForge.exe" -ForegroundColor Green
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
