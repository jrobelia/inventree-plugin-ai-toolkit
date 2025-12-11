<#
.SYNOPSIS
    Run unit tests for an InvenTree plugin.

.DESCRIPTION
    This script runs the test suite for the specified InvenTree plugin.
    InvenTree plugins use Django's test framework via the 'invoke dev.test' command.
    
    The script:
    1. Sets required environment variables for plugin testing
    2. Discovers test files in the plugin directory
    3. Executes tests using InvenTree's test runner
    4. Reports results

.PARAMETER Plugin
    The plugin name (e.g., "FlatBOMGenerator")

.PARAMETER TestPath
    Optional: Specific test path to run (e.g., "flat_bom_generator.test_shortfall_calculation.ShortfallCalculationTests")
    If not specified, discovers and runs all tests in plugin's tests directory

.PARAMETER ServerUrl
    The InvenTree server URL to test against (default: uses staging from servers.json)

.PARAMETER ShowDetails
    Show detailed test output

.EXAMPLE
    .\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator"
    Runs all tests for the FlatBOMGenerator plugin

.EXAMPLE
    .\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -TestPath "flat_bom_generator.tests.test_shortfall_calculation.ShortfallCalculationTests"
    Runs a specific test class

.EXAMPLE
    .\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -ShowDetails
    Runs tests with detailed output
#>

param(
  [Parameter(Mandatory = $true)]
  [string]$Plugin,
    
  [Parameter(Mandatory = $false)]
  [string]$TestPath,
    
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

Write-Status "Testing InvenTree Plugin: $Plugin"
Write-Host "Plugin Directory: $pluginDir"
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

Write-Status "Looking for tests in: $testsDir"

if (-not (Test-Path $testsDir)) {
  Write-Warning "No tests directory found at: $testsDir"
  Write-Host ""
  Write-Host "InvenTree plugins should have a 'tests' directory structure:"
  Write-Host "  $packageName/"
  Write-Host "    tests/"
  Write-Host "      __init__.py"
  Write-Host "      test_*.py"
  Write-Host ""
    
  # Try to find test files in plugin root
  $testFiles = Get-ChildItem -Path $pluginDir -Filter "test_*.py" -Recurse
  if ($testFiles.Count -eq 0) {
    Write-Failure "No test files found in plugin directory"
    exit 1
  } else {
    Write-Warning "Found test files outside standard location:"
    $testFiles | ForEach-Object { Write-Host "  - $($_.FullName)" }
    Write-Host ""
  }
}

# Run tests
Write-Status "Running tests..."
Write-Host ""

try {
  # Check if running in InvenTree development environment
  $invokeTestAvailable = Get-Command "invoke" -ErrorAction SilentlyContinue
    
  if ($invokeTestAvailable) {
    # Use InvenTree's invoke test command
    Write-Host "Using InvenTree invoke test runner..."
        
    if ($TestPath) {
      $testCommand = "invoke dev.test -r $TestPath"
    } else {
      # Discover all test modules in plugin
      $testModules = Get-ChildItem -Path $testsDir -Filter "test_*.py" | ForEach-Object {
        $moduleName = $_.BaseName
        "$packageName.tests.$moduleName"
      }
            
      if ($testModules.Count -eq 0) {
        Write-Failure "No test modules found"
        exit 1
      }
            
      Write-Host "Discovered test modules:"
      $testModules | ForEach-Object { Write-Host "  - $_" }
      Write-Host ""
            
      # Run each test module
      $allPassed = $true
      foreach ($module in $testModules) {
        Write-Status "Running: $module"
        $testCommand = "invoke dev.test -r $module"
                
        if ($ShowDetails) {
          & invoke dev.test -r $module
        } else {
          & invoke dev.test -r $module 2>&1 | Out-String
        }
                
        if ($LASTEXITCODE -ne 0) {
          $allPassed = $false
          Write-Failure "Tests failed in: $module"
        } else {
          Write-Success "Tests passed in: $module"
        }
        Write-Host ""
      }
            
      if ($allPassed) {
        Write-Success "All tests passed!"
        exit 0
      } else {
        Write-Failure "Some tests failed"
        exit 1
      }
    }
        
    if ($ShowDetails) {
      & invoke dev.test -r $TestPath
    } else {
      & invoke dev.test -r $TestPath 2>&1
    }
        
    if ($LASTEXITCODE -eq 0) {
      Write-Success "Tests passed!"
    } else {
      Write-Failure "Tests failed"
      exit 1
    }
        
  } else {
    # Fallback to Python unittest runner (for standalone testing)
    Write-Warning "InvenTree invoke command not available"
    Write-Host "Falling back to Python unittest runner..."
    Write-Host "Note: This only works for pure Python tests (no Django models)"
    Write-Host ""
        
    $pythonCmd = Get-Command "python" -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
      Write-Failure "Python not found in PATH"
      exit 1
    }
        
    # Add plugin directory to PYTHONPATH so imports work
    $env:PYTHONPATH = $pluginDir
        
    # Run Python unittest discovery from plugin root
    Push-Location $pluginDir
    try {
      if ($TestPath) {
        & python -m unittest $TestPath -v
      } else {
        # Use absolute path to tests directory
        $testsPath = Join-Path $packageName "tests"
        if (Test-Path $testsPath) {
          & python -m unittest discover -s $testsPath -p "test_*.py" -v
        } else {
          Write-Failure "Tests directory not found: $testsPath"
          exit 1
        }
      }
            
      if ($LASTEXITCODE -eq 0) {
        Write-Success "Tests passed!"
      } else {
        Write-Failure "Tests failed"
        exit 1
      }
    } finally {
      Pop-Location
    }
  }
    
} catch {
  Write-Failure "Error running tests: $_"
  exit 1
}

Write-Host ""
Write-Success "Test run completed"
