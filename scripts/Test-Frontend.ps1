<#
.SYNOPSIS
    Run frontend tests and TypeScript validation for an InvenTree plugin.

.DESCRIPTION
    Validates frontend code by running Vitest unit tests and TypeScript compilation.
    Provides consistent testing interface matching backend Test-Plugin.ps1.

.PARAMETER Plugin
    Plugin folder name (e.g., "FlatBOMGenerator")

.PARAMETER TestOnly
    Run Vitest tests only, skip TypeScript compilation

.PARAMETER TypeScriptOnly
    Run TypeScript compilation only, skip Vitest tests

.EXAMPLE
    .\scripts\Test-Frontend.ps1 -Plugin "FlatBOMGenerator"
    Run both Vitest tests and TypeScript compilation

.EXAMPLE
    .\scripts\Test-Frontend.ps1 -Plugin "FlatBOMGenerator" -TestOnly
    Run only Vitest unit tests
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Plugin,

  [Parameter(Mandatory = $false)]
  [switch]$TestOnly,

  [Parameter(Mandatory = $false)]
  [switch]$TypeScriptOnly
)

$ErrorActionPreference = "Stop"

# Resolve plugin path
$pluginPath = Join-Path $PSScriptRoot "..\plugins\$Plugin"
if (-not (Test-Path $pluginPath)) {
  Write-Error "Plugin not found: $pluginPath"
  exit 1
}

$frontendPath = Join-Path $pluginPath "frontend"
if (-not (Test-Path $frontendPath)) {
  Write-Error "Frontend folder not found: $frontendPath"
  exit 1
}

# Check for package.json
$packageJsonPath = Join-Path $frontendPath "package.json"
if (-not (Test-Path $packageJsonPath)) {
  Write-Error "package.json not found in frontend folder"
  exit 1
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Frontend Testing: $Plugin" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

$testsFailed = $false

# Run Vitest tests
if (-not $TypeScriptOnly) {
  Write-Host "[INFO] Running Vitest unit tests..." -ForegroundColor Yellow
  Push-Location $frontendPath
  try {
    npm test
    if ($LASTEXITCODE -ne 0) {
      $testsFailed = $true
      Write-Host "[ERROR] Vitest tests failed" -ForegroundColor Red
    } else {
      Write-Host "[OK] Vitest tests passed" -ForegroundColor Green
    }
  } finally {
    Pop-Location
  }
  Write-Host ""
}

# Run TypeScript compilation
if (-not $TestOnly) {
  Write-Host "[INFO] Running TypeScript validation..." -ForegroundColor Yellow
  Push-Location $frontendPath
  try {
    npx tsc -b --noEmit
    if ($LASTEXITCODE -ne 0) {
      $testsFailed = $true
      Write-Host "[ERROR] TypeScript validation failed" -ForegroundColor Red
    } else {
      Write-Host "[OK] TypeScript validation passed" -ForegroundColor Green
    }
  } finally {
    Pop-Location
  }
  Write-Host ""
}

# Summary
if ($testsFailed) {
  Write-Host "=======================================" -ForegroundColor Red
  Write-Host "  Frontend Testing FAILED" -ForegroundColor Red
  Write-Host "=======================================" -ForegroundColor Red
  exit 1
} else {
  Write-Host "=======================================" -ForegroundColor Green
  Write-Host "  Frontend Testing PASSED" -ForegroundColor Green
  Write-Host "=======================================" -ForegroundColor Green
  exit 0
}
