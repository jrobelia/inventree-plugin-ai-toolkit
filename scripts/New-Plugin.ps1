<#
.SYNOPSIS
    Create a new InvenTree plugin using the plugin-creator tool.

.DESCRIPTION
    This script creates a new InvenTree plugin by running the plugin-creator
    interactively. The new plugin will be created in the plugins/ folder and
    automatically initialized as a git repository.

.PARAMETER Name
    The name of your plugin (optional - will prompt if not provided)

.PARAMETER OutputDir
    Where to create the plugin (default: plugins/)

.EXAMPLE
    .\New-Plugin.ps1
    # Interactive mode - asks you questions

.EXAMPLE
    .\New-Plugin.ps1 -Name "My Custom Plugin"
    # Pre-fill the plugin name

.NOTES
    Author: Generated for InvenTree Plugin Development
    This script assumes the plugin-creator is installed and accessible.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Name,
    
    [Parameter(Mandatory = $false)]
    [string]$OutputDir = "plugins"
)

# Color output functions
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolkitRoot = Split-Path -Parent $ScriptDir

# Load configuration
$ConfigFile = Join-Path $ToolkitRoot "config\servers.json"
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Configuration file not found: $ConfigFile"
    Write-Info "Please copy servers.json.example to servers.json and configure it."
    exit 1
}

$Config = Get-Content $ConfigFile | ConvertFrom-Json

# Check if plugin-creator is available
$PluginCreatorPath = Join-Path $ToolkitRoot $Config.paths.plugin_creator
if (-not (Test-Path $PluginCreatorPath)) {
    Write-Error "Plugin creator not found at: $PluginCreatorPath"
    Write-Info "Please ensure the plugin-creator repository is cloned."
    exit 1
}

# Check for virtual environment
$VenvPath = Join-Path $PluginCreatorPath ".venv"
$PythonExe = Join-Path $VenvPath "Scripts\python.exe"

if (-not (Test-Path $PythonExe)) {
    Write-Warning "Virtual environment not found. Creating one..."
    Push-Location $PluginCreatorPath
    python -m venv .venv
    & $PythonExe -m pip install --upgrade pip
    & $PythonExe -m pip install -e .
    Pop-Location
}

# Ensure output directory exists
$OutputPath = Join-Path $ToolkitRoot $OutputDir
if (-not (Test-Path $OutputPath)) {
    Write-Info "Creating output directory: $OutputPath"
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# Display banner
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   InvenTree Plugin Creator - New Plugin Wizard        " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Run the plugin creator
Write-Info "Starting plugin creator..."
Write-Info "Output directory: $OutputPath"
Write-Host ""

Push-Location $OutputPath

try {
    # Activate virtual environment and run plugin creator
    & $PythonExe -m plugin_creator.cli --output "."
    
    # Find the newly created plugin directory (even if plugin-creator had errors)
    $NewestPlugin = Get-ChildItem -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1
    
    if ($LASTEXITCODE -ne 0) {
        # Plugin creator failed - check if it was the git init issue
        if ($NewestPlugin -and (Test-Path $NewestPlugin.FullName)) {
            Write-Warning "Plugin creator encountered an error during git initialization."
            Write-Info "Attempting to fix git repository..."
            
            Push-Location $NewestPlugin.FullName
            try {
                # Check if .git directory exists
                if (-not (Test-Path ".git")) {
                    git init 2>&1 | Out-Null
                    git checkout -b main 2>&1 | Out-Null
                    git add . 2>&1 | Out-Null
                    git commit -m "Initial plugin structure from plugin-creator" 2>&1 | Out-Null
                    Write-Success "Git repository initialized successfully!"
                } else {
                    Write-Info "Git repository already exists."
                }
            } catch {
                Write-Warning "Could not initialize git repository. You can do this manually later."
            } finally {
                Pop-Location
            }
        } else {
            Write-Error "Plugin creation failed and no plugin directory was found."
            exit 1
        }
    }
    
    if ($NewestPlugin) {
        Write-Host ""
        Write-Success "Plugin created successfully!"
        Write-Host ""
        Write-Info "Plugin location: $($NewestPlugin.FullName)"
        Write-Host ""
        Write-Info "Next steps:"
        Write-Host "  1. Edit your plugin code in VS Code"
        Write-Host "  2. Build: .\scripts\Build-Plugin.ps1 -Plugin '$($NewestPlugin.Name)'"
        Write-Host "  3. Deploy: .\scripts\Deploy-Plugin.ps1 -Plugin '$($NewestPlugin.Name)' -Server staging"
        Write-Host ""
    }
} finally {
    Pop-Location
}
