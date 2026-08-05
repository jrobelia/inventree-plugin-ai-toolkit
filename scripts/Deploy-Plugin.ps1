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

.PARAMETER SkipRestart
    Skip the InvenTree container restart after install

.PARAMETER SkipCollect
    Skip running collectplugins after restart

.PARAMETER NoVerify
    Skip the post-deploy health check

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
    - Server settings are read from config/servers.json
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Plugin,

    [Parameter(Mandatory = $true)]
    [ValidateSet('staging', 'production')]
    [string]$Server,

    [Parameter(Mandatory = $false)]
    [switch]$Build,

    [Parameter(Mandatory = $false)]
    [switch]$SkipRestart,

    [Parameter(Mandatory = $false)]
    [switch]$SkipCollect,

    [Parameter(Mandatory = $false)]
    [switch]$NoVerify
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
    Write-Info "Copy config\servers.json.example to config\servers.json and fill in your server details."
    exit 1
}

try {
    $Config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse $ConfigFile : $_"
    exit 1
}

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
    Write-Info "Building plugin inside the devcontainer..."

    $ContainerPluginPath = "/workspace/plugins/$Plugin"
    $BuildCmd = "bash /workspace/scripts/build-plugin.sh $ContainerPluginPath"

    $DockerArgs = @(
        "compose",
        "-f", "$ToolkitRoot\.devcontainer\docker-compose.yml",
        "-f", "$ToolkitRoot\.devcontainer\docker-compose.frontend-volumes.yml",
        "exec", "-u", "vscode", "-T", "toolkit",
        "bash", "-c", "cd /workspace && $BuildCmd"
    )

    $BuildOutput = & docker @DockerArgs 2>&1
    Write-Host $BuildOutput

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed. Deployment aborted."
        exit 1
    }
    $WheelFiles = Get-ChildItem $DistPath -Filter "*.whl" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
}

if ($WheelFiles.Count -eq 0) {
    Write-Error "No .whl package found in $DistPath"
    Write-Info "Run 'bash scripts/build-plugin.sh /workspace/plugins/$Plugin' inside the devcontainer, or use 'Deploy-Plugin.ps1 -Plugin $Plugin -Server $Server -Build'"
    exit 1
}

$WheelFile = $WheelFiles[0]
$WheelPath = $WheelFile.FullName
Write-Info "Package: $($WheelFile.Name)"

# Confirm production deployment
if ($Server -eq "production") {
    Write-Warning "You are about to deploy to PRODUCTION!"
    Write-Host ""
    $confirmation = Read-Host "Type 'yes' to confirm deployment to production"
    if ($confirmation -ne "yes") {
        Write-Info "Deployment cancelled."
        exit 0
    }
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
        if (-not (Test-Path $SSHKeyPath)) {
            Write-Error "SSH key file not found: $SSHKeyPath"
            exit 1
        }
        $SSHArgs += @("-i", $SSHKeyPath)
    }
    if ($SSHPort -ne 22) {
        $SSHArgs += @("-P", $SSHPort)  # Note: SCP uses -P, SSH uses -p
    }

    $SSHConnection = "${SSHUser}@${SSHHost}"

    # SSH uses -p for port, SCP uses -P
    $SSHCheckArgs = @()
    if ($SSHKeyFile) {
        $SSHKeyPath = $SSHKeyFile -replace '~', $env:USERPROFILE
        $SSHCheckArgs += @("-i", $SSHKeyPath)
    }
    if ($SSHPort -ne 22) {
        $SSHCheckArgs += @("-p", $SSHPort)
    }

    # Determine Docker command (v2 'docker compose' vs legacy 'docker-compose')
    $DockerCommand = if ($ServerConfig.docker_command) { $ServerConfig.docker_command } else { $null }
    if (-not $DockerCommand) {
        Write-Info "Detecting Docker Compose command on remote..."
        $DockerCheckCmd = 'if docker compose version >/dev/null 2>&1; then echo "docker compose"; elif docker-compose --version >/dev/null 2>&1; then echo "docker-compose"; else echo ""; fi'
        $DetectedDocker = (ssh @SSHCheckArgs $SSHConnection $DockerCheckCmd 2>$null) | Where-Object { $_ } | Select-Object -First 1
        if ([string]::IsNullOrWhiteSpace($DetectedDocker)) {
            Write-Error "Could not detect 'docker compose' or 'docker-compose' on the remote server"
            exit 1
        }
        $DockerCommand = $DetectedDocker.Trim()
    }
    Write-Info "Docker command: $DockerCommand"

    # Determine InvenTree compose directory
    $ComposeDir = if ($ServerConfig.compose_dir) { $ServerConfig.compose_dir } else { $null }
    if (-not $ComposeDir) {
        Write-Info "Locating InvenTree installation..."
        $FindDockerCmd = "for dir in /root/inventree/inventree ~/inventree /opt/inventree; do if [ -f `$dir/docker-compose.yml ] || [ -f `$dir/docker-compose.yaml ] || [ -f `$dir/compose.yaml ] || [ -f `$dir/compose.yml ]; then echo `$dir; exit 0; fi; done; echo ''"

        $ComposeDir = (ssh @SSHCheckArgs $SSHConnection $FindDockerCmd 2>$null) | Where-Object { $_ } | Select-Object -First 1

        if ([string]::IsNullOrWhiteSpace($ComposeDir)) {
            Write-Error "Could not locate InvenTree docker-compose directory"
            Write-Info "Checked: /root/inventree/inventree, ~/inventree, /opt/inventree"
            Write-Info "Set 'compose_dir' in config\servers.json to skip auto-detection."
            exit 1
        }
    }

    $ComposeDir = $ComposeDir.Trim()
    Write-Success "Found InvenTree at: $ComposeDir"

    # Determine service name and data paths
    $ServiceName = if ($ServerConfig.service_name) { $ServerConfig.service_name } else { "inventree-server" }
    $DataDir = if ($ServerConfig.data_dir) { $ServerConfig.data_dir } else { "$ComposeDir/inventree-data" }
    $ContainerDataPath = if ($ServerConfig.container_data_path) { $ServerConfig.container_data_path } else { "/home/inventree/data" }

    Write-Info "Service name: $ServiceName"
    Write-Info "Host data dir: $DataDir"
    Write-Info "Container data path: $ContainerDataPath"

    $RemoteWheelPath = "$DataDir/$($WheelFile.Name)"
    $ContainerWheelPath = "$ContainerDataPath/$($WheelFile.Name)"

    # Ensure data directory exists on remote
    ssh @SSHCheckArgs $SSHConnection "mkdir -p '$DataDir'" 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Could not ensure remote data directory exists"
    }

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
    $InstallCmd = "cd '$ComposeDir' && $DockerCommand exec -T $ServiceName pip install --upgrade --force-reinstall '$ContainerWheelPath'"

    $InstallOutput = ssh @SSHCheckArgs $SSHConnection $InstallCmd 2>&1
    Write-Host $InstallOutput

    if ($LASTEXITCODE -ne 0) {
        Write-Error "pip install failed"
        exit 1
    }

    Write-Success "[OK] Plugin installed successfully"

    # Clean up wheel file
    Write-Info "Cleaning up temporary files..."
    ssh @SSHCheckArgs $SSHConnection "rm -f '$RemoteWheelPath'" 2>&1 | Out-Null

    if (-not $SkipRestart) {
        # Restart InvenTree (this may trigger its own static file collection on startup)
        Write-Info "Restarting InvenTree..."
        $RestartCmd = "cd '$ComposeDir' && $DockerCommand restart $ServiceName"

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
        Write-Info "Skipping InvenTree restart (SkipRestart specified)"
    }

    if (-not $SkipCollect) {
        # Collect plugin static files AFTER restart so our version has the last word
        # (InvenTree's startup may re-collect stale static files from Django storage)
        Write-Info "Collecting plugin static files..."
        $CollectCmd = "cd '$ComposeDir' && $DockerCommand exec -T $ServiceName bash -c 'cd /home/inventree/src/backend/InvenTree && python manage.py collectplugins'"
        $CollectOutput = ssh @SSHCheckArgs $SSHConnection $CollectCmd 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Success "[OK] Static files collected"
        } else {
            Write-Warning "Static file collection may have failed - check manually"
            if ($CollectOutput) {
                Write-Host $CollectOutput
            }
        }
    } else {
        Write-Info "Skipping collectplugins (SkipCollect specified)"
    }

    if (-not $NoVerify -and $ServerConfig.url) {
        Write-Info "Verifying server health..."
        $HealthUrl = ($ServerConfig.url).TrimEnd('/') + '/api/system/health/'
        $Healthy = $false
        $MaxAttempts = 12
        $DelaySeconds = 5

        for ($Attempt = 1; $Attempt -le $MaxAttempts; $Attempt++) {
            try {
                $Response = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 30
                if ($Response.StatusCode -eq 200) {
                    Write-Success "[OK] Server is healthy at $HealthUrl"
                    $Healthy = $true
                    break
                } else {
                    Write-Info "Server returned status $($Response.StatusCode) at $HealthUrl; retrying..."
                }
            } catch {
                Write-Info "Server not ready at $HealthUrl (attempt $Attempt/$MaxAttempts): $_."
            }
            if ($Attempt -lt $MaxAttempts) {
                Start-Sleep -Seconds $DelaySeconds
            }
        }

        if (-not $Healthy) {
            Write-Warning "Server did not become healthy within $([int]($MaxAttempts * $DelaySeconds)) seconds. Check $HealthUrl manually."
        }
    }

} else {
    # Local Deployment - install via pip directly
    Write-Error "Local deployment not yet implemented for packaged plugins"
    Write-Info "For local deployments, manually run:"
    Write-Info "  pip install --upgrade $WheelPath"
    Write-Info "Then restart your InvenTree server and run collectplugins."
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
