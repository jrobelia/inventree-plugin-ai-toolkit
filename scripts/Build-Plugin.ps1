<#
.SYNOPSIS
    Build an InvenTree plugin (Python package + Frontend if applicable)

.DESCRIPTION
    Builds both the Python package and frontend code (if the plugin has frontend).
    This creates a distributable .whl file and compiles TypeScript/React code.

.PARAMETER Plugin
    Name of the plugin folder in plugins/ directory

.PARAMETER SkipFrontend
    Skip building frontend code (Python only)

.PARAMETER Clean
    Clean build artifacts before building

.EXAMPLE
    .\Build-Plugin.ps1 -Plugin "my-custom-plugin"
    # Build everything

.EXAMPLE
    .\Build-Plugin.ps1 -Plugin "my-custom-plugin" -SkipFrontend
    # Build Python only

.EXAMPLE
    .\Build-Plugin.ps1 -Plugin "my-custom-plugin" -Clean
    # Clean build first, then rebuild

.NOTES
    This script handles both Python and frontend builds automatically.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Plugin,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipFrontend,
    
    [Parameter(Mandatory = $false)]
    [switch]$Clean
)

# Color output functions
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Step { Write-Host "`n>>> $args" -ForegroundColor Yellow }

# Get paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolkitRoot = Split-Path -Parent $ScriptDir
$PluginPath = Join-Path $ToolkitRoot "plugins\$Plugin"

# Validate plugin exists
if (-not (Test-Path $PluginPath)) {
    Write-Error "Plugin not found: $Plugin"
    Write-Info "Available plugins:"
    Get-ChildItem (Join-Path $ToolkitRoot "plugins") -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)"
    }
    exit 1
}

# Display banner
Write-Host ""
Write-Host "??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "???   Building Plugin: $Plugin" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

Push-Location $PluginPath

try {
    # Clean if requested
    if ($Clean) {
        Write-Step "Cleaning build artifacts..."
        if (Test-Path "dist") { Remove-Item -Recurse -Force "dist" }
        if (Test-Path "build") { Remove-Item -Recurse -Force "build" }
        if (Test-Path "*.egg-info") { Remove-Item -Recurse -Force "*.egg-info" }
        Write-Success "??? Cleaned"
    }
    
    # Check for frontend
    $HasFrontend = Test-Path "frontend"
    
    # Build frontend if it exists
    if ($HasFrontend -and -not $SkipFrontend) {
        Write-Step "Building frontend code..."
        
        Push-Location "frontend"
        
        # Check if node_modules exists
        if (-not (Test-Path "node_modules")) {
            Write-Info "Installing frontend dependencies..."
            npm install
            if ($LASTEXITCODE -ne 0) {
                Write-Error "npm install failed"
                exit 1
            }
        }
        
        # Check if translation is needed
        if (Test-Path ".linguirc") {
            Write-Info "Compiling translations..."
            npm run translate
        }
        
        # Build frontend
        Write-Info "Compiling frontend code..."
        npm run build
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "[OK] Frontend built successfully"
        } else {
            Write-Error "Frontend build failed"
            exit 1
        }
        
        Pop-Location
    } elseif ($HasFrontend -and $SkipFrontend) {
        Write-Warning "[WARN] Skipping frontend build (as requested)"
    }
    
    # Build Python package
    Write-Step "Building Python package..."
    
    python -m pip install --upgrade build wheel
    python -m build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[OK] Python package built successfully"
        
        # Show what was built
        Write-Host ""
        Write-Info "Build artifacts:"
        Get-ChildItem "dist" | ForEach-Object {
            Write-Host "  [PACKAGE] $($_.Name)" -ForegroundColor Green
        }
        Write-Host ""
        
        Write-Success "Build complete!"
        Write-Info "Next step: Deploy to server"
        Write-Host "  .\scripts\Deploy-Plugin.ps1 -Plugin '$Plugin' -Server staging"
        Write-Host ""
        
    } else {
        Write-Error "Python build failed"
        exit 1
    }
    
} finally {
    Pop-Location
}
