#!/usr/bin/env pwsh
# ============================================================
# VoiceForge Windows Build Script (PowerShell)
# ============================================================

param(
    [string]$Version = "1.0.0",
    [string]$AppName = "VoiceForge",
    [switch]$Clean = $true,
    [switch]$CreateInstaller = $true
)

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "🎙️ VoiceForge Windows Build Script" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$BuildDir = "build"
$DistDir = "dist"
$SpecFile = "voiceforge.spec"

Write-Host "📋 Build Configuration:" -ForegroundColor Yellow
Write-Host "  Version: $Version"
Write-Host "  App Name: $AppName"
Write-Host "  Build Dir: $BuildDir"
Write-Host "  Dist Dir: $DistDir"
Write-Host ""

# Step 1: Clean
if ($Clean) {
    Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
    if (Test-Path $BuildDir) { Remove-Item -Recurse -Force $BuildDir }
    if (Test-Path $DistDir) { Remove-Item -Recurse -Force $DistDir }
    if (Test-Path "*.spec") { Remove-Item -Force *.spec }
    Write-Host "✅ Clean complete" -ForegroundColor Green
    Write-Host ""
}

# Step 2: Check Python
Write-Host "🔍 Checking Python installation..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python not found! Please install Python 3.9+" -ForegroundColor Red
    Write-Host "   Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 3: Install/upgrade build tools
Write-Host "📦 Installing build tools..." -ForegroundColor Yellow
python -m pip install --upgrade pip setuptools wheel
python -m pip install --upgrade pyinstaller
Write-Host "✅ Build tools installed" -ForegroundColor Green
Write-Host ""

# Step 4: Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray

$dependencies = @(
    "torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu",
    "sounddevice soundfile numpy scipy",
    "TTS pyyaml requests",
    "pyinstaller pytest pytest-cov"
)

foreach ($dep in $dependencies) {
    Write-Host "  Installing: $dep" -ForegroundColor Gray
    pip install $dep
}

Write-Host "✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 5: Install application
Write-Host "📦 Installing VoiceForge..." -ForegroundColor Yellow
pip install -e .
Write-Host "✅ Application installed" -ForegroundColor Green
Write-Host ""

# Step 6: Build with PyInstaller
Write-Host "🚀 Building $AppName..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray

$pyinstallerArgs = @(
    "--name=$AppName",
    "--windowed",
    "--onefile",
    "--paths=src",
    "src/main.py"
)

pyinstaller $pyinstallerArgs --clean --noconfirm

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Write-Host "Trying with console mode for debugging..." -ForegroundColor Yellow
    pyinstaller @pyinstallerArgs --console --name="${AppName}_Debug"
}

Write-Host ""

# Step 7: Verify build
Write-Host "🔍 Verifying build..." -ForegroundColor Yellow
if (Test-Path "$DistDir\VoiceForge.exe") {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host "📁 Output: $DistDir\VoiceForge.exe" -ForegroundColor Cyan
    Get-ChildItem $DistDir\VoiceForge.exe | Format-Table Name, Length, LastWriteTime
} else {
    Write-Host "❌ Build failed - no executable found" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 8: Create installer
if ($CreateInstaller) {
    Write-Host "📦 Creating installer..." -ForegroundColor Yellow
    
    $innosetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    if (Test-Path $innosetupPath) {
        if (Test-Path "installer.iss") {
            & $innosetupPath installer.iss
            if (Test-Path "$DistDir\VoiceForgeSetup.exe") {
                Write-Host "✅ Installer created: $DistDir\VoiceForgeSetup.exe" -ForegroundColor Green
            }
        } else {
            Write-Host "⚠️ installer.iss not found" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️ Inno Setup not found" -ForegroundColor Yellow
        Write-Host "   Download from: https://jrsoftware.org/isdl.php" -ForegroundColor Gray
    }
}
Write-Host ""

# Step 9: Create portable ZIP
Write-Host "📦 Creating portable ZIP..." -ForegroundColor Yellow
if (Test-Path "$DistDir\VoiceForge.exe") {
    Push-Location $DistDir
    Compress-Archive -Path VoiceForge.exe -DestinationPath VoiceForge-Portable.zip -Force
    Pop-Location
    Write-Host "✅ Portable ZIP created: $DistDir\VoiceForge-Portable.zip" -ForegroundColor Green
}
Write-Host ""

# Complete
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "✅ Build complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Output files:" -ForegroundColor Yellow
if (Test-Path "$DistDir\VoiceForge.exe") { Write-Host "   $DistDir\VoiceForge.exe" -ForegroundColor Cyan }
if (Test-Path "$DistDir\VoiceForge-Portable.zip") { Write-Host "   $DistDir\VoiceForge-Portable.zip" -ForegroundColor Cyan }
if (Test-Path "$DistDir\VoiceForgeSetup.exe") { Write-Host "   $DistDir\VoiceForgeSetup.exe" -ForegroundColor Cyan }
Write-Host ""
Write-Host "🚀 To run: double-click VoiceForge.exe" -ForegroundColor Green
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan