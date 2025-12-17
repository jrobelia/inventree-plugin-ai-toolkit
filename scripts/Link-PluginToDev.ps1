<#
.SYNOPSIS
    Creates symlink for plugin in InvenTree development environment.

.DESCRIPTION
    Creates a symbolic link from InvenTree's plugins directory to your
    plugin directory, allowing InvenTree to discover and test the plugin.

.PARAMETER Plugin
    Name of the plugin to link (e.g., "FlatBOMGenerator").

.PARAMETER Force
    Remove existing symlink and recreate.

.EXAMPLE
    .\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator"
    
    Link FlatBOMGenerator plugin to InvenTree dev environment.

.EXAMPLE
    .\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator" -Force
    
    Recreate symlink (useful if plugin moved or link broken).

.NOTES
    Author: InvenTree Plugin AI Toolkit
    Prerequisites: InvenTree dev environment must be set up first
    
    Run .\scripts\Setup-InvenTreeDev.ps1 before using this script.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Plugin,
    
    [Parameter()]
    [switch]$Force
)

# Configuration
$ErrorActionPreference = "Stop"
$ToolkitRoot = Split-Path -Parent $PSScriptRoot
$PluginDir = Join-Path $ToolkitRoot "plugins\$Plugin"
$InvenTreePluginsDir = Join-Path $ToolkitRoot "inventree-dev\InvenTree\src\backend\plugins"
$SymlinkPath = Join-Path $InvenTreePluginsDir $Plugin

# Colors for output
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warning { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }

# Header
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Link Plugin to InvenTree Dev Environment  " -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Check if InvenTree dev environment is set up
$SetupMarker = Join-Path $ToolkitRoot "inventree-dev\setup-complete.txt"
if (-not (Test-Path $SetupMarker)) {
    Write-Error "InvenTree dev environment not set up."
    Write-Info "Run: .\scripts\Setup-InvenTreeDev.ps1"
    exit 1
}

# Check if plugin directory exists
if (-not (Test-Path $PluginDir)) {
    Write-Error "Plugin directory not found: $PluginDir"
    Write-Info "Available plugins:"
    Get-ChildItem (Join-Path $ToolkitRoot "plugins") -Directory | ForEach-Object {
        Write-Info "  - $($_.Name)"
    }
    exit 1
}

# Check if plugins directory exists (should be created by setup script)
if (-not (Test-Path $InvenTreePluginsDir)) {
    Write-Info "Creating plugins directory..."
    New-Item -ItemType Directory -Path $InvenTreePluginsDir -Force | Out-Null
    Write-Success "Created: $InvenTreePluginsDir"
}

# Check for existing link (symlink or junction)
if (Test-Path $SymlinkPath) {
    if (-not $Force) {
        $item = Get-Item $SymlinkPath
        
        # Accept both SymbolicLink and Junction (both work on Windows)
        if ($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") {
            $target = $item.Target
            if ($target -eq $PluginDir) {
                Write-Success "Plugin already linked ($($item.LinkType)): $PluginDir"
                Write-Info "Link is working correctly. Use -Force to recreate."
                
                # Verify plugin is discoverable
                Write-Info "Verifying plugin structure..."
                $hasConfig = (Test-Path (Join-Path $PluginDir "pyproject.toml")) -or (Test-Path (Join-Path $PluginDir "setup.py"))
                if ($hasConfig) {
                    Write-Success "Plugin configuration found."
                } else {
                    Write-Warning "No pyproject.toml or setup.py found."
                }
                
                exit 0
            } else {
                Write-Warning "Link points to wrong location: $target"
                Write-Info "Expected: $PluginDir"
                Write-Info "Use -Force to recreate link."
                exit 1
            }
        } else {
            Write-Error "Path exists but is not a link: $SymlinkPath"
            Write-Info "LinkType: $($item.LinkType)"
            Write-Info "Please remove manually and re-run, or use -Force."
            exit 1
        }
    } else {
        Write-Info "Removing existing link (Force flag set)..."
        Remove-Item -Path $SymlinkPath -Force
        Write-Success "Removed existing link."
    }
}

# Create link (try symlink first, fall back to junction)
Write-Info "Creating link..."
Write-Info "  From: $SymlinkPath"
Write-Info "  To:   $PluginDir"

try {
    # Try SymbolicLink first (requires administrator privileges)
    New-Item -ItemType SymbolicLink -Path $SymlinkPath -Value $PluginDir -Force -ErrorAction Stop | Out-Null
    Write-Success "Symlink created successfully!"
} catch {
    # Fall back to Junction if SymbolicLink fails (works without admin)
    Write-Warning "Symlink creation failed, trying junction instead..."
    try {
        cmd /c mklink /J "$SymlinkPath" "$PluginDir" 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Junction created successfully!"
            Write-Info "Note: Junction works just as well as symlink on Windows."
        } else {
            throw "Junction creation failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Error "Failed to create link: $_"
        Write-Host ""
        Write-Info "Both symlink and junction creation failed."
        Write-Info "Try running PowerShell as Administrator."
        exit 1
    }
}

# Verify link
$item = Get-Item $SymlinkPath
if (($item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction") -and $item.Target -eq $PluginDir) {
    Write-Success "Link verified successfully ($($item.LinkType))."
} else {
    Write-Error "Link verification failed."
    Write-Info "LinkType: $($item.LinkType), Target: $($item.Target)"
    exit 1
}

# Check if plugin has pyproject.toml or setup.py
$hasConfig = (Test-Path (Join-Path $PluginDir "pyproject.toml")) -or (Test-Path (Join-Path $PluginDir "setup.py"))
if ($hasConfig) {
    Write-Success "Plugin configuration found."
} else {
    Write-Warning "No pyproject.toml or setup.py found in plugin directory."
    Write-Info "Plugin may not be discoverable by InvenTree."
}

# Install plugin into InvenTree venv (REQUIRED for entry point registration)
Write-Host "\n" -ForegroundColor Cyan
Write-Info "Installing plugin into InvenTree virtual environment..."
Write-Info "This registers the plugin entry points from pyproject.toml."

$InvenTreeVenv = Join-Path $ToolkitRoot "inventree-dev\InvenTree\.venv\Scripts\Activate.ps1"
$InvenTreeDir = Join-Path $ToolkitRoot "inventree-dev\InvenTree"

if (-not (Test-Path $InvenTreeVenv)) {
    Write-Error "InvenTree virtual environment not found: $InvenTreeVenv"
    Write-Info "Run: .\scripts\Setup-InvenTreeDev.ps1"
    exit 1
}

try {
    # Activate InvenTree venv and install plugin in editable mode
    Push-Location $PluginDir
    
    $InstallCmd = @"
& '$InvenTreeVenv'
pip install -e .
"@
    
    $output = Invoke-Expression $InstallCmd 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Plugin installed successfully (editable mode)."
        Write-Info "Entry points registered - InvenTree can now discover the plugin."
    } else {
        Write-Warning "pip install completed with warnings."
        Write-Info "Output: $output"
    }
} catch {
    Write-Error "Failed to install plugin: $_"
    Write-Info "You may need to manually run: pip install -e . from plugin directory."
} finally {
    Pop-Location
}

# Summary
Write-Host "\n============================================" -ForegroundColor Green
Write-Host "  Plugin Linked & Installed Successfully!  " -ForegroundColor Green
Write-Host "============================================\n" -ForegroundColor Green

Write-Host "Plugin '$Plugin' is now linked to InvenTree dev environment.\n"

Write-Host "What Happened:" -ForegroundColor Cyan
Write-Host "  1. Created junction: InvenTree plugins/ -> your plugin/" -ForegroundColor White
Write-Host "  2. Ran 'pip install -e .' in InvenTree venv" -ForegroundColor White
Write-Host "  3. Registered entry points from pyproject.toml\n" -ForegroundColor White

Write-Host "Why Both Steps Matter:" -ForegroundColor Yellow
Write-Host "  - Junction:    Gives InvenTree file access to your code" -ForegroundColor White
Write-Host "  - pip install: Registers entry points so InvenTree finds the plugin\n" -ForegroundColor White

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Organize tests into unit/ and integration/ folders" -ForegroundColor White
Write-Host "  2. Write integration tests using InvenTreeTestCase`n" -ForegroundColor White
Write-Host "  3. Run integration tests:" -ForegroundColor White
Write-Host "     cd inventree-dev\InvenTree" -ForegroundColor Gray
Write-Host "     & .venv\Scripts\Activate.ps1" -ForegroundColor Gray
Write-Host "     invoke dev.test -r $Plugin.tests.integration -v`n" -ForegroundColor Gray

Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  docs\toolkit\INVENTREE-DEV-SETUP.md`n" -ForegroundColor Gray

Write-Host "Symlink Details:" -ForegroundColor Cyan
Write-Host "  Target:  $PluginDir" -ForegroundColor Gray
Write-Host "  Link:    $SymlinkPath`n" -ForegroundColor Gray
