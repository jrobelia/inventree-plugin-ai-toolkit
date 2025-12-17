<#
.SYNOPSIS
    Sets up InvenTree development environment for plugin integration testing.

.DESCRIPTION
    Automates the setup of InvenTree development environment:
    - Clones InvenTree stable branch
    - Creates virtual environment
    - Installs dependencies
    - Configures for development + testing
    - Runs initial database migrations
    - Creates test superuser

    This is a one-time setup that creates shared testing infrastructure
    for all plugins in the toolkit.

.PARAMETER Force
    Remove existing installation and reinstall from scratch.

.PARAMETER Branch
    InvenTree branch to clone (default: stable).

.PARAMETER SkipMigrations
    Skip database migrations (faster, but may need manual migration later).

.EXAMPLE
    .\scripts\Setup-InvenTreeDev.ps1
    
    Standard setup with all defaults.

.EXAMPLE
    .\scripts\Setup-InvenTreeDev.ps1 -Force
    
    Remove existing setup and reinstall from scratch.

.EXAMPLE
    .\scripts\Setup-InvenTreeDev.ps1 -Branch "main"
    
    Install from main branch instead of stable.

.NOTES
    Author: InvenTree Plugin AI Toolkit
    Prerequisites: Git, Python 3.9+, SQLite3
    Time: 1-2 hours
    
    See docs/toolkit/INVENTREE-DEV-SETUP.md for detailed documentation.
#>

[CmdletBinding()]
param(
  [Parameter()]
  [switch]$Force,
    
  [Parameter()]
  [string]$Branch = "stable",
    
  [Parameter()]
  [switch]$SkipMigrations
)

# Configuration
$ErrorActionPreference = "Stop"
$ToolkitRoot = Split-Path -Parent $PSScriptRoot
$DevDir = Join-Path $ToolkitRoot "inventree-dev"
$InvenTreeDir = Join-Path $DevDir "InvenTree"
$DataDir = Join-Path $DevDir "data"
$SetupMarker = Join-Path $DevDir "setup-complete.txt"

# Colors for output
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warning { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }

# Header
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  InvenTree Development Environment Setup  " -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check Git
try {
  $gitVersion = git --version
  Write-Success "Git: $gitVersion"
} catch {
  Write-Error "Git not found. Please install Git from https://git-scm.com/"
  exit 1
}

# Check Python
try {
  $pythonVersion = python --version
  Write-Success "Python: $pythonVersion"
} catch {
  Write-Error "Python not found. Please install Python 3.9+ from https://www.python.org/"
  exit 1
}

# Check Python version
$pythonVersionOutput = python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
$majorMinor = [version]$pythonVersionOutput
if ($majorMinor -lt [version]"3.9") {
  Write-Error "Python 3.9+ required. Found: $pythonVersionOutput"
  exit 1
}

# Check SQLite
try {
  $sqliteVersion = sqlite3 --version
  Write-Success "SQLite3: $sqliteVersion"
} catch {
  Write-Warning "SQLite3 not in PATH. Continuing (Python has built-in sqlite3 module)."
}

Write-Host ""

# Check for existing installation
if (Test-Path $SetupMarker) {
  if (-not $Force) {
    Write-Warning "InvenTree dev environment already set up."
    Write-Info "Setup marker found: $SetupMarker"
    $content = Get-Content $SetupMarker -Raw
    Write-Info $content
    Write-Host ""
    Write-Info "To reinstall, use: .\scripts\Setup-InvenTreeDev.ps1 -Force"
    Write-Info "To link a plugin: .\scripts\Link-PluginToDev.ps1 -Plugin 'PluginName'"
    exit 0
  } else {
    Write-Warning "Force flag set. Removing existing installation..."
    if (Test-Path $DevDir) {
      Remove-Item -Path $DevDir -Recurse -Force
      Write-Success "Removed existing inventree-dev directory."
    }
  }
}

# Create directories
Write-Info "Creating directory structure..."
New-Item -ItemType Directory -Path $DevDir -Force | Out-Null
New-Item -ItemType Directory -Path $DataDir -Force | Out-Null

# Create subdirectories for data storage
New-Item -ItemType Directory -Path (Join-Path $DataDir "media") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $DataDir "static") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $DataDir "backup") -Force | Out-Null
Write-Success "Created inventree-dev/, data/, and storage directories."

# Clone InvenTree repository
Write-Info "Cloning InvenTree repository (branch: $Branch)..."
Write-Info "This may take 5-10 minutes..."
try {
  Set-Location $DevDir
  git clone --branch $Branch --depth 1 https://github.com/inventree/inventree.git InvenTree
  Write-Success "Cloned InvenTree repository."
} catch {
  Write-Error "Failed to clone InvenTree: $_"
  exit 1
}

# Create virtual environment
Write-Info "Creating Python virtual environment..."
Set-Location $InvenTreeDir
try {
  python -m venv .venv
  Write-Success "Created virtual environment."
} catch {
  Write-Error "Failed to create virtual environment: $_"
  exit 1
}

# Activate virtual environment
Write-Info "Activating virtual environment..."
$ActivateScript = Join-Path $InvenTreeDir ".venv\Scripts\Activate.ps1"
if (-not (Test-Path $ActivateScript)) {
  Write-Error "Virtual environment activation script not found: $ActivateScript"
  exit 1
}
& $ActivateScript

# Upgrade pip
Write-Info "Upgrading pip..."
python -m pip install --upgrade pip | Out-Null
Write-Success "Pip upgraded."

# Install InvenTree backend dependencies
Write-Info "Installing InvenTree backend dependencies..."
Write-Info "This may take 15-20 minutes..."
try {
  # Locate requirements file (handle both old and new structure)
  $requirementsFile = "requirements.txt"
  if (Test-Path "src\backend\requirements.txt") {
    $requirementsFile = "src\backend\requirements.txt"
  }
  
  if (-not (Test-Path $requirementsFile)) {
    Write-Error "Requirements file not found: $requirementsFile"
    exit 1
  }
  
  # Strip hashes from requirements.txt for development install
  Write-Info "Preparing requirements (removing hash verification)..."
  $tempRequirements = Join-Path $env:TEMP "inventree-requirements-nohash.txt"
  Get-Content $requirementsFile | ForEach-Object {
    # Remove hash verification and line continuations
    $line = $_ -replace '\s*--hash=[^\s]+', '' # Remove --hash=...
    $line = $line -replace '\s*\\$', ''         # Remove trailing backslash
    $line = $line.Trim()
    
    # Skip empty lines and comments
    if ($line -and -not $line.StartsWith('#')) {
      $line
    }
  } | Out-File -FilePath $tempRequirements -Encoding utf8
  
  # Install from cleaned requirements file
  Write-Info "Installing packages (with dependencies)..."
  pip install -r $tempRequirements 2>&1 | Out-Null
  
  # Clean up temp file
  Remove-Item $tempRequirements -ErrorAction SilentlyContinue
  
  Write-Success "Installed backend dependencies."
} catch {
  Write-Error "Failed to install backend dependencies: $_"
  exit 1
}

# Install InvenTree in editable mode (optional, for development)
Write-Info "Installing InvenTree in editable mode..."
try {
  pip install -e . --quiet 2>&1 | Out-Null
  Write-Success "Installed InvenTree (editable mode)."
} catch {
  Write-Warning "Editable install failed. Continuing with backend dependencies only."
}

# Install development dependencies
Write-Info "Installing development dependencies..."
try {
  if (Test-Path "src\backend\requirements-dev.txt") {
    pip install -r src\backend\requirements-dev.txt --quiet
  } elseif (Test-Path "requirements-dev.txt") {
    pip install -r requirements-dev.txt --quiet
  }
  Write-Success "Installed development dependencies."
} catch {
  Write-Warning "Failed to install some development dependencies. Continuing..."
}

# Create .env configuration file
Write-Info "Creating .env configuration..."
# Use absolute paths to avoid issues with working directory
$dbPath = Join-Path $DataDir "inventree_test.sqlite3"
$mediaPath = Join-Path $DataDir "media"
$staticPath = Join-Path $DataDir "static"
$backupPath = Join-Path $DataDir "backup"

# Check for MSYS2 and auto-install Pango if present
$msys2Bin = "C:\msys64\mingw64\bin"
$msys2Bash = "C:\msys64\usr\bin\bash.exe"
$weasyPrintDirs = ""

if (Test-Path $msys2Bash) {
  Write-Info "MSYS2 detected. Installing Pango for WeasyPrint PDF support..."
  
  try {
    # Use bash directly with pacman - more reliable than msys2_shell.cmd
    # --needed: only install if not already present
    # --noconfirm: skip all confirmation prompts
    # 2>&1: capture stderr so we can suppress warnings
    $output = & $msys2Bash -lc "pacman -S --noconfirm --needed mingw-w64-x86_64-pango 2>&1"
    
    # Check if pango DLLs are now present
    $pangoDll = Join-Path $msys2Bin "libpango-1.0-0.dll"
    if (Test-Path $pangoDll) {
      Write-Success "Pango installed successfully."
      $weasyPrintDirs = "WEASYPRINT_DLL_DIRECTORIES=$msys2Bin"
    } else {
      Write-Warning "Pango DLLs not found after installation."
      Write-Info "Manual install: Open MSYS2 terminal, run: pacman -S mingw-w64-x86_64-pango"
    }
  } catch {
    Write-Warning "Could not auto-install Pango: $_"
    Write-Info "Manual install: Open MSYS2 terminal, run: pacman -S mingw-w64-x86_64-pango"
  }
} else {
  Write-Warning "MSYS2 not found. PDF generation (WeasyPrint) will not work."
  Write-Info "Optional: Install MSYS2 from https://www.msys2.org/ for PDF support"
}

$envContent = @"
# InvenTree Configuration for Plugin Testing
# Generated by Setup-InvenTreeDev.ps1 on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# Debug mode (safe for development, required for testing)
INVENTREE_DEBUG=True
INVENTREE_LOG_LEVEL=WARNING

# Database configuration (SQLite for simplicity)
INVENTREE_DB_ENGINE=sqlite3
INVENTREE_DB_NAME=$dbPath

# File storage (absolute paths)
INVENTREE_MEDIA_ROOT=$mediaPath
INVENTREE_STATIC_ROOT=$staticPath
INVENTREE_BACKUP_DIR=$backupPath

# Plugin configuration (CRITICAL for testing)
INVENTREE_PLUGINS_ENABLED=True
INVENTREE_PLUGIN_TESTING=True
INVENTREE_PLUGIN_TESTING_SETUP=True

# Performance (optional)
INVENTREE_CACHE_ENABLED=False

# Disable external services (optional, speeds up tests)
INVENTREE_BACKUP_ENABLE=False

# WeasyPrint PDF support (requires MSYS2 on Windows)
$weasyPrintDirs
"@

$envContent | Out-File -FilePath (Join-Path $InvenTreeDir ".env") -Encoding utf8
Write-Success "Created .env configuration."

# Load .env variables into PowerShell environment
Write-Info "Loading environment variables from .env..."
$envFile = Join-Path $InvenTreeDir ".env"
Get-Content $envFile | ForEach-Object {
  if ($_ -match '^([^#][^=]+)=(.*)$') {
    $name = $matches[1].Trim()
    $value = $matches[2].Trim()
    [Environment]::SetEnvironmentVariable($name, $value, "Process")
  }
}
Write-Success "Environment variables loaded."

# Determine manage.py location (handle both old and new InvenTree structure)
$ManagePy = "manage.py"
if (Test-Path "src\backend\InvenTree\manage.py") {
  $ManagePy = "src\backend\InvenTree\manage.py"
}

# Run database migrations
if (-not $SkipMigrations) {
  Write-Info "Running database migrations..."
  Write-Info "This may take 2-5 minutes..."
  try {
    python $ManagePy migrate --noinput
    Write-Success "Database migrations complete."
  } catch {
    Write-Error "Failed to run migrations: $_"
    exit 1
  }
    
  # Collect static files
  Write-Info "Collecting static files..."
  try {
    python $ManagePy collectstatic --noinput --clear | Out-Null
    Write-Success "Static files collected."
  } catch {
    Write-Warning "Failed to collect static files. Continuing..."
  }
    
  # Create superuser
  Write-Info "Creating test superuser (username: admin, password: admin)..."
  try {
    python $ManagePy shell -c @"
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin')
    print('Superuser created')
else:
    print('Superuser already exists')
"@
    Write-Success "Test superuser ready."
  } catch {
    Write-Warning "Failed to create superuser. You can create one manually later."
  }
} else {
  Write-Warning "Skipping migrations (--SkipMigrations flag set)."
  Write-Info "Run manually: python $ManagePy migrate"
}

# Create plugins directory for symlinks
$PluginsDir = Join-Path $InvenTreeDir "src\backend\plugins"
if (-not (Test-Path $PluginsDir)) {
  New-Item -ItemType Directory -Path $PluginsDir -Force | Out-Null
  Write-Success "Created plugins directory for symlinks."
}

# Mark setup complete
$markerContent = @"
InvenTree Development Environment Setup Complete
================================================

Setup Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Branch: $Branch
Python Version: $pythonVersionOutput
InvenTree Directory: $InvenTreeDir

Next Steps:
1. Link your plugin: .\scripts\Link-PluginToDev.ps1 -Plugin "PluginName"
2. Run integration tests: invoke dev.test -r PluginName.tests.integration
3. See docs: docs\toolkit\INVENTREE-DEV-SETUP.md

Environment Variables Set:
- INVENTREE_PLUGINS_ENABLED=True
- INVENTREE_PLUGIN_TESTING=True
- INVENTREE_PLUGIN_TESTING_SETUP=True

Test Superuser:
- Username: admin
- Password: admin
- Email: admin@example.com

Database:
- Type: SQLite3
- Location: inventree-dev\data\inventree_test.sqlite3
"@

$markerContent | Out-File -FilePath $SetupMarker -Encoding utf8
Write-Success "Setup marker created."

# Final verification
Write-Info "Verifying InvenTree installation..."
try {
  $versionOutput = python $ManagePy version
  Write-Success "InvenTree version: $versionOutput"
} catch {
  Write-Warning "Could not verify InvenTree version. Installation may be incomplete."
}

# Summary
Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  Setup Complete!  " -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Green

Write-Host "InvenTree dev environment is ready for integration testing.`n"

# Report on WeasyPrint status
if ($weasyPrintDirs) {
  Write-Success "WeasyPrint PDF generation configured (MSYS2 + Pango installed)."
} else {
  Write-Warning "WeasyPrint PDF generation not available."
  Write-Host ""
  Write-Info "To enable PDF generation (optional):"
  Write-Host "  1. Install MSYS2 from https://www.msys2.org/" -ForegroundColor Gray
  Write-Host "  2. Re-run this script - it will auto-install Pango" -ForegroundColor Gray
  Write-Host ""
}

Write-Host "`nQuick Start:" -ForegroundColor Yellow
Write-Host "  1. Link a plugin:" -ForegroundColor White
Write-Host "     .\scripts\Link-PluginToDev.ps1 -Plugin 'FlatBOMGenerator'`n" -ForegroundColor Gray
Write-Host "  2. Run integration tests:" -ForegroundColor White
Write-Host "     .\scripts\Test-Plugin.ps1 -Plugin 'FlatBOMGenerator' -Integration`n" -ForegroundColor Gray
Write-Host "  3. Read documentation:" -ForegroundColor White
Write-Host "     docs\toolkit\INVENTREE-DEV-SETUP.md`n" -ForegroundColor Gray

Write-Host "Setup details saved to: $SetupMarker`n" -ForegroundColor Cyan

# Return to toolkit root
Set-Location $ToolkitRoot
