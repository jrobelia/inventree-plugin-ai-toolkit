<#
.SYNOPSIS
    Start live development server for plugin frontend code

.DESCRIPTION
    Starts a Vite development server that allows you to see frontend changes
    in real-time without rebuilding. This is useful when actively developing
    UI components, panels, or dashboard items.

.PARAMETER Plugin
    Name of the plugin folder in plugins/ directory

.PARAMETER Port
    Port to run the dev server on (default: 5174)

.EXAMPLE
    .\Dev-Frontend.ps1 -Plugin "my-custom-plugin"
    # Start dev server on default port 5174

.EXAMPLE
    .\Dev-Frontend.ps1 -Plugin "my-custom-plugin" -Port 5175
    # Start dev server on custom port

.NOTES
    You need to have InvenTree frontend dev server running on port 5173
    for this to work properly. Use 'invoke dev.frontend-server' in InvenTree.
    
    Press Ctrl+C to stop the dev server.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Plugin,
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 5174
)

# Color output functions
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# Get paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolkitRoot = Split-Path -Parent $ScriptDir
$PluginPath = Join-Path $ToolkitRoot "plugins\$Plugin"
$FrontendPath = Join-Path $PluginPath "frontend"

# Validate plugin exists
if (-not (Test-Path $PluginPath)) {
    Write-Error "Plugin not found: $Plugin"
    exit 1
}

# Validate frontend exists
if (-not (Test-Path $FrontendPath)) {
    Write-Error "This plugin does not have frontend code"
    Write-Info "Frontend directory not found: $FrontendPath"
    exit 1
}

# Display banner
Write-Host ""
Write-Host "??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "??'   Frontend Development Server: $Plugin" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

Push-Location $FrontendPath

try {
    # Check if node_modules exists
    if (-not (Test-Path "node_modules")) {
        Write-Info "Installing frontend dependencies..."
        npm install
        if ($LASTEXITCODE -ne 0) {
            Write-Error "npm install failed"
            exit 1
        }
    }
    
    Write-Info "Starting development server..."
    Write-Host ""
    Write-Success "Frontend dev server will start on http://localhost:$Port"
    Write-Host ""
    Write-Warning "Prerequisites:"
    Write-Host "  1. InvenTree frontend must be running on http://localhost:5173"
    Write-Host "  2. Run 'invoke dev.frontend-server' in InvenTree repository"
    Write-Host ""
    Write-Info "How to use:"
    Write-Host "  1. Open InvenTree at http://localhost:5173"
    Write-Host "  2. Navigate to a page where your plugin panel appears"
    Write-Host "  3. Edit your .tsx files in VS Code"
    Write-Host "  4. See changes instantly in the browser!"
    Write-Host ""
    Write-Warning "Press Ctrl+C to stop the server"
    Write-Host ""
    
    # Start the dev server
    npm run dev -- --port $Port
    
} finally {
    Pop-Location
}

