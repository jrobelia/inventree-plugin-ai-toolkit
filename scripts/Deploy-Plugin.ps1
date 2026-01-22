<#
.SYNOPSIS
    Deploy an InvenTree plugin to staging or production server

.DESCRIPTION
    Installs a built plugin (.whl package) on the InvenTree server via pip.
    For packaged plugins with frontends, this is the correct deployment method.
    Supports both local/network paths and remote SSH deployments.
    Uses SSH/SCP for remote servers configured with SSH settings.

.PARAMETER Plugin
    Name of the plugin folder in plugins/ directory

.PARAMETER Server
    Target server: staging or production

.PARAMETER Build
    Build the plugin before deploying

.EXAMPLE
    .\Deploy-Plugin.ps1 -Plugin "my-custom-plugin" -Server staging
    # Build and deploy to staging via SSH

.EXAMPLE
    .\Deploy-Plugin.ps1 -Plugin "my-custom-plugin" -Server production
    # Deploy to production (with confirmation)

.EXAMPLE
    .\Deploy-Plugin.ps1 -Plugin "my-custom-plugin" -Server staging -Build
    # Explicitly build then deploy

.NOTES
    - Always test on staging before deploying to production!
    - For SSH deployments, ensure SSH key authentication is configured
    - The script installs via pip and automatically restarts InvenTree
    - Requires a built .whl package in the plugin's dist/ directory
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Plugin,
    
    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Server,
    
    [Parameter(Mandatory = $false)]
    [switch]$Build
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

# Validate plugin exists
if (-not (Test-Path $PluginPath)) {
    Write-Error "Plugin not found: $Plugin"
    exit 1
}

# Load configuration
$ConfigFile = Join-Path $ToolkitRoot "config\servers.json"
if (-not (Test-Path $ConfigFile)) {
    Write-Error "Configuration file not found: $ConfigFile"
    exit 1
}

$Config = Get-Content $ConfigFile | ConvertFrom-Json
$ServerConfig = $Config.servers.$Server

if (-not $ServerConfig) {
    Write-Error "Server configuration not found for: $Server"
    exit 1
}

# Display banner
Write-Host ""
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "  Deploying Plugin: $Plugin -> $Server" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

# Check for built wheel package
$DistPath = Join-Path $PluginPath "dist"
if (-not (Test-Path $DistPath)) {
    Write-Warning "No dist/ directory found - plugin needs to be built"
    $Build = $true
}

$WheelFiles = Get-ChildItem $DistPath -Filter "*.whl" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending

# Check if source files are newer than the wheel
if ($WheelFiles.Count -gt 0 -and -not $Build) {
    $WheelAge = $WheelFiles[0].LastWriteTime
    $SourceFiles = Get-ChildItem $PluginPath -Recurse -File | Where-Object { 
        $_.Extension -match '\.(py|tsx?|jsx?|json)$' -and 
        $_.FullName -notmatch '[\\/](dist|build|node_modules|__pycache__|\.venv|\.git)[\\/]'
    }
    $NewestSource = $SourceFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($NewestSource -and $NewestSource.LastWriteTime -gt $WheelAge) {
        Write-Warning "Source files modified since last build"
        Write-Info "Newest: $($NewestSource.Name) ($(Get-Date $NewestSource.LastWriteTime -Format 'yyyy-MM-dd HH:mm:ss'))"
        Write-Info "Package: $($WheelFiles[0].Name) ($(Get-Date $WheelAge -Format 'yyyy-MM-dd HH:mm:ss'))"
        $Build = $true
    }
}

if ($WheelFiles.Count -eq 0 -or $Build) {
    Write-Info "Building plugin..."
    & "$ScriptDir\Build-Plugin.ps1" -Plugin $Plugin
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed. Deployment aborted."
        exit 1
    }
    $WheelFiles = Get-ChildItem $DistPath -Filter "*.whl" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
}

if ($WheelFiles.Count -eq 0) {
    Write-Error "No .whl package found in $DistPath"
    Write-Info "Run Build-Plugin.ps1 first to create a package"
    exit 1
}

$WheelFile = $WheelFiles[0]
$WheelPath = $WheelFile.FullName
Write-Info "Package: $($WheelFile.Name)"

# Confirm production deployment
if ($Server -eq "production") {
    Write-Warning "??????  You are about to deploy to PRODUCTION!"
    Write-Host ""
    $confirmation = Read-Host "Type 'yes' to confirm deployment to production"
    if ($confirmation -ne "yes") {
        Write-Info "Deployment cancelled."
        exit 0
    }
}

# Get target directory (used as upload location)
$TargetDir = $ServerConfig.plugin_dir

if (-not $TargetDir) {
    Write-Error "Plugin directory not configured for $Server"
    Write-Info "Please configure 'plugin_dir' in config/servers.json"
    exit 1
}

# Check if this is a remote SSH deployment
$IsRemote = $ServerConfig.ssh -and $ServerConfig.ssh.host

Write-Info "Source: $WheelPath"
if ($IsRemote) {
    Write-Info "Method: SSH/SCP + pip install (Remote)"
    Write-Info "Host: $($ServerConfig.ssh.host)"
} else {
    Write-Info "Method: pip install (Local)"
}
Write-Host ""

# Deploy based on method (SSH or local)
if ($IsRemote) {
    # SSH/SCP Deployment with pip install
    Write-Info "Deploying via SSH/SCP..."
    
    # Build SSH connection string
    $SSHUser = $ServerConfig.ssh.user
    $SSHHost = $ServerConfig.ssh.host
    $SSHPort = if ($ServerConfig.ssh.port) { $ServerConfig.ssh.port } else { 22 }
    $SSHKeyFile = $ServerConfig.ssh.key_file
    
    # Build SSH command arguments
    $SSHArgs = @()
    if ($SSHKeyFile) {
        $SSHKeyPath = $SSHKeyFile -replace '~', $env:USERPROFILE
        $SSHArgs += @("-i", $SSHKeyPath)
    }
    if ($SSHPort -ne 22) {
        $SSHArgs += @("-P", $SSHPort)  # Note: SCP uses -P, SSH uses -p
    }
    
    $SSHConnection = "${SSHUser}@${SSHHost}"
    
    # Find InvenTree docker-compose directory
    Write-Info "Locating InvenTree installation..."
    $SSHCheckArgs = $SSHArgs | Where-Object { $_ -ne "-P" }
    if ($SSHPort -ne 22) {
        $SSHCheckArgs += @("-p", $SSHPort)
    }
    
    $FindDockerCmd = "for dir in /root/inventree/inventree ~/inventree /opt/inventree; do if [ -f `$dir/docker-compose.yml ] || [ -f `$dir/docker-compose.yaml ] || [ -f `$dir/compose.yaml ] || [ -f `$dir/compose.yml ]; then echo `$dir; exit 0; fi; done; echo ''"
    
    $DockerDir = (ssh @SSHCheckArgs $SSHConnection $FindDockerCmd 2>$null) | Where-Object { $_ } | Select-Object -First 1
    
    if ([string]::IsNullOrWhiteSpace($DockerDir)) {
        Write-Error "Could not locate InvenTree docker-compose directory"
        Write-Info "Checked: /root/inventree/inventree, ~/inventree, /opt/inventree"
        exit 1
    }
    
    $DockerDir = $DockerDir.Trim()
    Write-Success "Found InvenTree at: $DockerDir"
    
    # Determine data directory path (mounted in container as /home/inventree/data)
    $DataDir = "$DockerDir/inventree-data"
    $RemoteWheelPath = "$DataDir/$($WheelFile.Name)"
    $ContainerWheelPath = "/home/inventree/data/$($WheelFile.Name)"
    
    # Upload wheel file to data directory
    Write-Info "Uploading $($WheelFile.Name)..."
    $SCPArgs = $SSHArgs + @($WheelPath, "${SSHConnection}:${DataDir}/")
    
    scp @SCPArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "SCP transfer failed"
        exit 1
    }
    
    Write-Success "[OK] Uploaded successfully"
    
    # Install via pip in the Docker container
    Write-Info "Installing plugin via pip..."
    $InstallCmd = "cd $DockerDir && docker-compose exec -T inventree-server pip install --upgrade --force-reinstall $ContainerWheelPath"
    
    $InstallOutput = ssh @SSHCheckArgs $SSHConnection $InstallCmd 2>&1
    Write-Host $InstallOutput
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "pip install failed"
        exit 1
    }
    
    Write-Success "[OK] Plugin installed successfully"
    
    # Collect plugin static files (copies from pip package to served location)
    Write-Info "Collecting plugin static files..."
    $CollectCmd = "cd $DockerDir && docker-compose exec -T inventree-server bash -c 'cd /home/inventree/src/backend/InvenTree && python manage.py collectplugins'"
    $CollectOutput = ssh @SSHCheckArgs $SSHConnection $CollectCmd 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[OK] Static files collected"
    } else {
        Write-Warning "Static file collection may have failed - check manually"
        if ($CollectOutput) {
            Write-Host $CollectOutput
        }
    }
    
    # Clean up wheel file
    Write-Info "Cleaning up temporary files..."
    ssh @SSHCheckArgs $SSHConnection "rm -f $RemoteWheelPath" 2>&1 | Out-Null
    
    # Restart InvenTree
    Write-Info "Restarting InvenTree..."
    $RestartCmd = "cd $DockerDir && docker-compose restart inventree-server"
    
    $RestartOutput = ssh @SSHCheckArgs $SSHConnection $RestartCmd 2>&1
    if ($RestartOutput) {
        Write-Host $RestartOutput
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[OK] InvenTree restarted successfully"
    } else {
        Write-Warning "InvenTree restart may have failed - please check manually"
    }
    
} else {
    # Local Deployment - install via pip directly
    Write-Error "Local deployment not yet implemented for packaged plugins"
    Write-Info "For local deployments, manually run:"
    Write-Info "  pip install --upgrade $WheelPath"
    exit 1
}

# Display summary
Write-Host ""
Write-Success "========================================" 
Write-Success "    Deployment Complete!"
Write-Success "========================================" 
Write-Host ""
Write-Info "Deployment Details:"
Write-Host "  Server: $Server" -ForegroundColor White
Write-Host "  URL: $($ServerConfig.url)" -ForegroundColor White
Write-Host "  Package: $($WheelFile.Name)" -ForegroundColor White
Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. Visit $($ServerConfig.url) to verify the plugin" -ForegroundColor White
Write-Host "  2. Check plugin status in Admin > Plugins" -ForegroundColor White
Write-Host ""
