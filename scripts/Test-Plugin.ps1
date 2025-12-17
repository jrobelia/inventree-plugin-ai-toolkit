<#
.SYNOPSIS
    Run unit and/or integration tests for an InvenTree plugin.

.DESCRIPTION
    This script runs the test suite for the specified InvenTree plugin with support
    for both fast unit tests and InvenTree integration tests.
    
    Test Types:
    - Unit Tests: Fast, no database (tests/unit/). Use Python unittest directly.
    - Integration Tests: Use InvenTree models (tests/integration/). Require InvenTree dev environment.
    
    The script:
    1. Sets required environment variables for plugin testing
    2. Discovers test files in the plugin directory
    3. Executes tests using appropriate runner (unittest or invoke)
    4. Reports results

.PARAMETER Plugin
    The plugin name (e.g., "FlatBOMGenerator")

.PARAMETER TestPath
    Optional: Specific test path to run (e.g., "flat_bom_generator.tests.test_shortfall_calculation.ShortfallCalculationTests")

.PARAMETER Unit
    Run only unit tests (tests/unit/ folder). Fast, no InvenTree required.

.PARAMETER Integration
    Run only integration tests (tests/integration/ folder). Requires InvenTree dev environment.

.PARAMETER All
    Run all tests (unit + integration). Default if no flags specified.

.PARAMETER ShowDetails
    Show detailed test output

.EXAMPLE
    .\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator"
    Runs all tests (unit + integration if integration tests exist)

.EXAMPLE
    .\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit
    Runs only fast unit tests (no InvenTree dev environment needed)

.EXAMPLE
    .\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration
    Runs only integration tests (requires InvenTree dev setup)

.EXAMPLE
    .\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -TestPath "flat_bom_generator.tests.unit.test_shortfall_calculation"
    Runs specific test module
#>

param(
  [Parameter(Mandatory = $true)]
  [string]$Plugin,
    
  [Parameter(Mandatory = $false)]
  [string]$TestPath,
    
  [Parameter(Mandatory = $false)]
  [switch]$Unit,
    
  [Parameter(Mandatory = $false)]
  [switch]$Integration,
    
  [Parameter(Mandatory = $false)]
  [switch]$All,
    
  [Parameter(Mandatory = $false)]
  [string]$ServerUrl,
    
  [Parameter(Mandatory = $false)]
  [switch]$ShowDetails
)

# Script configuration
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$toolkitRoot = Split-Path -Parent $scriptDir
$pluginDir = Join-Path $toolkitRoot "plugins\$Plugin"

# Color output functions
function Write-Status {
  param([string]$Message)
  Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
  param([string]$Message)
  Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Failure {
  param([string]$Message)
  Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning {
  param([string]$Message)
  Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

# Validate plugin directory exists
if (-not (Test-Path $pluginDir)) {
  Write-Failure "Plugin directory not found: $pluginDir"
  exit 1
}

# Determine test mode (default to All if nothing specified)
$runUnit = $Unit -or $All -or (-not $Unit -and -not $Integration)
$runIntegration = $Integration -or $All

Write-Status "Testing InvenTree Plugin: $Plugin"
Write-Host "Plugin Directory: $pluginDir"

if ($runUnit -and $runIntegration) {
  Write-Host "Test Mode: Unit + Integration (All)" -ForegroundColor Yellow
} elseif ($runUnit) {
  Write-Host "Test Mode: Unit Only (Fast)" -ForegroundColor Yellow
} elseif ($runIntegration) {
  Write-Host "Test Mode: Integration Only (Requires InvenTree dev)" -ForegroundColor Yellow
}
Write-Host ""

# Load server configuration if needed
if (-not $ServerUrl) {
  $serversConfigPath = Join-Path $toolkitRoot "config\servers.json"
  if (Test-Path $serversConfigPath) {
    $serversConfig = Get-Content $serversConfigPath | ConvertFrom-Json
    $staging = $serversConfig.servers | Where-Object { $_.name -eq "staging" } | Select-Object -First 1
    if ($staging) {
      $ServerUrl = $staging.url
      Write-Host "Using staging server: $ServerUrl"
    }
  }
}

# Set environment variables required for InvenTree plugin testing
# See: https://docs.inventree.org/en/latest/plugins/test/
Write-Status "Setting test environment variables..."

# Load .env file if running integration tests (needs full InvenTree config)
if ($Integration -or $All) {
  $envFile = Join-Path $ToolkitRoot "inventree-dev\InvenTree\.env"
  if (Test-Path $envFile) {
    Write-Status "Loading InvenTree .env configuration..."
    Get-Content $envFile | ForEach-Object {
      if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        Set-Item -Path "env:$name" -Value $value
      }
    }
  } else {
    Write-Warning ".env file not found: $envFile"
    Write-Info "Run: .\scripts\Setup-InvenTreeDev.ps1"
  }
}

$env:INVENTREE_PLUGINS_ENABLED = "True"
$env:INVENTREE_PLUGIN_TESTING = "True"
$env:INVENTREE_PLUGIN_TESTING_SETUP = "True"

if ($ServerUrl) {
  $env:INVENTREE_SERVER_URL = $ServerUrl
}

# Discover test files in plugin directory
# Find the actual package directory (snake_case Python package)
$packageDirs = Get-ChildItem -Path $pluginDir -Directory | Where-Object { 
  $_.Name -notmatch '^(frontend|dist|build|\.)|_egg-info$' -and 
  (Test-Path (Join-Path $_.FullName "__init__.py"))
}

if ($packageDirs.Count -eq 0) {
  Write-Failure "No Python package found in plugin directory (looking for directory with __init__.py)"
  exit 1
}

$packageName = $packageDirs[0].Name
$testsDir = Join-Path $pluginDir "$packageName\tests"
$unitTestsDir = Join-Path $testsDir "unit"
$integrationTestsDir = Join-Path $testsDir "integration"

Write-Status "Looking for tests in: $testsDir"

# Check test directory structure
$hasUnitTests = Test-Path $unitTestsDir
$hasIntegrationTests = Test-Path $integrationTestsDir
$hasLegacyTests = (Test-Path $testsDir) -and (Get-ChildItem -Path $testsDir -Filter "test_*.py" -File).Count -gt 0

if (-not (Test-Path $testsDir)) {
  Write-Warning "No tests directory found at: $testsDir"
  Write-Host ""
  Write-Host "InvenTree plugins should have a 'tests' directory structure:"
  Write-Host "  $packageName/"
  Write-Host "    tests/"
  Write-Host "      __init__.py"
  Write-Host "      unit/           # Fast unit tests"
  Write-Host "        test_*.py"
  Write-Host "      integration/    # InvenTree integration tests"
  Write-Host "        test_*.py"
  Write-Host ""
  exit 1
}

Write-Host "Test Structure:"
Write-Host "  Unit Tests:        $(if ($hasUnitTests) { 'Found' } else { 'Not found' })" -ForegroundColor $(if ($hasUnitTests) { 'Green' } else { 'Yellow' })
Write-Host "  Integration Tests: $(if ($hasIntegrationTests) { 'Found' } else { 'Not found' })" -ForegroundColor $(if ($hasIntegrationTests) { 'Green' } else { 'Yellow' })
if ($hasLegacyTests) {
  Write-Host "  Legacy Tests:      Found (tests/*.py directly)" -ForegroundColor Yellow
  Write-Host "    Consider organizing into unit/ and integration/ folders"
}
Write-Host ""

# Validate requested test type exists
if ($runUnit -and -not $hasUnitTests -and -not $hasLegacyTests) {
  Write-Warning "No unit tests found in $unitTestsDir"
  if ($runIntegration) {
    Write-Host "Continuing with integration tests only..."
    $runUnit = $false
  } else {
    exit 0
  }
}

if ($runIntegration -and -not $hasIntegrationTests) {
  Write-Warning "No integration tests found in $integrationTestsDir"
  Write-Host "To create integration tests:"
  Write-Host "  1. Set up InvenTree dev: .\scripts\Setup-InvenTreeDev.ps1"
  Write-Host "  2. Link plugin: .\scripts\Link-PluginToDev.ps1 -Plugin '$Plugin'"
  Write-Host "  3. Create tests/integration/ folder"
  Write-Host ""
  if ($runUnit) {
    Write-Host "Continuing with unit tests only..."
    $runIntegration = $false
  } else {
    exit 0
  }
}

# Run tests
Write-Status "Running tests..."
Write-Host ""

$allPassed = $true

# === Run Unit Tests ===
if ($runUnit) {
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host "  UNIT TESTS (Fast, No InvenTree)" -ForegroundColor Cyan
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host ""
  
  try {
    $pythonCmd = Get-Command "python" -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
      Write-Failure "Python not found in PATH"
      $allPassed = $false
    } else {
      # Add plugin directory to PYTHONPATH
      $env:PYTHONPATH = $pluginDir
      
      Push-Location $pluginDir
      try {
        if ($TestPath) {
          # Run specific test path
          Write-Status "Running: $TestPath"
          & python -m unittest $TestPath -v
        } else {
          # Run all unit tests
          if ($hasUnitTests) {
            $testsPath = Join-Path $packageName "tests\unit"
            Write-Status "Running unit tests from: $testsPath"
            & python -m unittest discover -s $testsPath -p "test_*.py" -v
          } elseif ($hasLegacyTests) {
            # Fallback to legacy tests directory
            $testsPath = Join-Path $packageName "tests"
            Write-Status "Running legacy tests from: $testsPath"
            & python -m unittest discover -s $testsPath -p "test_*.py" -v
          }
        }
        
        if ($LASTEXITCODE -eq 0) {
          Write-Host ""
          Write-Success "Unit tests passed!"
        } else {
          Write-Host ""
          Write-Failure "Unit tests failed"
          $allPassed = $false
        }
      } finally {
        Pop-Location
      }
    }
  } catch {
    Write-Failure "Error running unit tests: $_"
    $allPassed = $false
  }
  
  Write-Host ""
}

# === Run Integration Tests ===
if ($runIntegration) {
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host "  INTEGRATION TESTS (InvenTree Models)" -ForegroundColor Cyan
  Write-Host "========================================" -ForegroundColor Cyan
  Write-Host ""
  
  # Check if InvenTree dev environment is set up
  $inventreeDevDir = Join-Path $toolkitRoot "inventree-dev\InvenTree"
  $setupMarker = Join-Path $toolkitRoot "inventree-dev\setup-complete.txt"
  
  if (-not (Test-Path $setupMarker)) {
    Write-Failure "InvenTree dev environment not set up"
    Write-Host ""
    Write-Host "To run integration tests:"
    Write-Host "  1. Set up InvenTree dev: .\scripts\Setup-InvenTreeDev.ps1"
    Write-Host "  2. Link plugin: .\scripts\Link-PluginToDev.ps1 -Plugin '$Plugin'"
    Write-Host "  3. Run tests: .\scripts\Test-Plugin.ps1 -Plugin '$Plugin' -Integration"
    Write-Host ""
    Write-Host "See: docs\toolkit\INVENTREE-DEV-SETUP.md"
    Write-Host ""
    $allPassed = $false
  } else {
    try {
      # Change to InvenTree directory
      Push-Location $inventreeDevDir
      
      # Activate InvenTree virtual environment (use dot-sourcing to persist in current session)
      $activateScript = Join-Path $inventreeDevDir ".venv\Scripts\Activate.ps1"
      if (Test-Path $activateScript) {
        Write-Status "Activating InvenTree virtual environment..."
        . $activateScript
      } else {
        Write-Failure "InvenTree virtual environment not found: $activateScript"
        Write-Host "Make sure InvenTree dev environment is properly set up."
        $allPassed = $false
        Pop-Location
        return
      }
      
      # On Windows, invoke has issues with python3 command (tasks.py hardcodes python3)
      # Use python manage.py directly instead
      # Reference: https://docs.inventree.org/en/latest/plugins/test/
      
      # Set plugin testing environment variables (must be set AFTER venv activation)
      $env:INVENTREE_PLUGINS_ENABLED = "True"
      $env:INVENTREE_PLUGIN_TESTING = "True"
      $env:INVENTREE_PLUGIN_TESTING_SETUP = "True"
      Write-Host "Plugin testing environment variables set" -ForegroundColor DarkGray
      
      # Add plugins directory to PYTHONPATH so Django can discover the plugin module
      $pluginsDir = Join-Path $inventreeDevDir "src\backend\plugins"
      $env:PYTHONPATH = "$pluginsDir;$env:PYTHONPATH"
      Write-Host "Added to PYTHONPATH: $pluginsDir" -ForegroundColor DarkGray
      
      # Navigate to InvenTree backend directory
      $backendDir = Join-Path $inventreeDevDir "src\backend\InvenTree"
      $managePy = Join-Path $backendDir "manage.py"
      
      if (-not (Test-Path $managePy)) {
        Write-Failure "InvenTree manage.py not found: $managePy"
        Write-Host "Make sure InvenTree dev environment is properly set up."
        $allPassed = $false
      } else {
        Push-Location $backendDir
        try {
          if ($TestPath) {
            # Run specific test path (user-provided path)
            Write-Status "Running: $TestPath"
            Write-Host "Command: python manage.py test $TestPath --keepdb" -ForegroundColor DarkGray
            python manage.py test $TestPath --keepdb
          } else {
            # Run all integration tests
            # InvenTree plugins require full path: PluginDir.package_name.tests.integration
            # where package_name is the snake_case Python package directory
            $integrationPath = "$Plugin.$packageName.tests.integration"
            Write-Status "Running integration tests: $integrationPath"
            Write-Host "Command: python manage.py test $integrationPath --keepdb" -ForegroundColor DarkGray
            python manage.py test $integrationPath --keepdb
          }
          
          if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Success "Integration tests passed!"
          } else {
            Write-Host ""
            Write-Failure "Integration tests failed"
            $allPassed = $false
          }
        } finally {
          Pop-Location
        }
      }
    } catch {
      Write-Failure "Error running integration tests: $_"
      $allPassed = $false
    } finally {
      Pop-Location
    }
  }
  
  Write-Host ""
}

# === Final Summary ===
Write-Host "========================================" -ForegroundColor $(if ($allPassed) { 'Green' } else { 'Red' })
if ($allPassed) {
  Write-Host "  ALL TESTS PASSED  " -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  exit 0
} else {
  Write-Host "  SOME TESTS FAILED  " -ForegroundColor Red
  Write-Host "========================================" -ForegroundColor Red
  exit 1
}
