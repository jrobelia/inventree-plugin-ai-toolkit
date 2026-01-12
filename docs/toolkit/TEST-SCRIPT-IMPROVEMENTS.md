# Test-Plugin.ps1 Improvement Plan

**Purpose**: Document planned improvements for Test-Plugin.ps1 script  
**Status**: Planning/Backlog  
**Last Updated**: January 12, 2026

---

## Current State

**Test-Plugin.ps1** supports:
- ✅ Unit tests (fast, no database)
- ✅ Integration tests (InvenTree dev environment)
- ✅ Specific test path via `-TestPath` parameter
- ✅ Environment variable setup
- ✅ InvenTree dev environment detection

**Example Usage:**
```powershell
# Run all tests
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator"

# Run only unit tests
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit

# Run only integration tests
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration

# Run specific test class
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -TestPath "flat_bom_generator.tests.unit.test_shortfall_calculation.ShortfallCalculationTests"
```

---

## Improvement 1: Single Test File Support

### Problem
Cannot run tests from a specific file without specifying full module path.

**Current Workaround:**
```powershell
# Must use full dotted path
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -TestPath "flat_bom_generator.tests.integration.test_get_bom_items"
```

**Desired:**
```powershell
# Just the filename
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration -TestFile "test_get_bom_items.py"
```

### Solution Design

**Add `-TestFile` parameter:**
```powershell
param(
  # ... existing parameters ...
  
  [Parameter(Mandatory = $false)]
  [string]$TestFile,
  
  # ... rest of parameters ...
)
```

**Implementation Logic:**
```powershell
# If TestFile specified, convert to TestPath
if ($TestFile) {
  # Remove .py extension if present
  $testModule = $TestFile -replace '\.py$', ''
  
  # Determine test type (unit or integration)
  if ($Integration) {
    $TestPath = "$packageName.tests.integration.$testModule"
  } elseif ($Unit) {
    $TestPath = "$packageName.tests.unit.$testModule"
  } else {
    # Search both directories for the file
    $unitFile = Join-Path $unitTestsDir $TestFile
    $integrationFile = Join-Path $integrationTestsDir $TestFile
    
    if (Test-Path $unitFile) {
      $TestPath = "$packageName.tests.unit.$testModule"
      $runUnit = $true
      $runIntegration = $false
    } elseif (Test-Path $integrationFile) {
      $TestPath = "$packageName.tests.integration.$testModule"
      $runUnit = $false
      $runIntegration = $true
    } else {
      Write-Failure "Test file not found: $TestFile"
      Write-Host "Searched in:"
      Write-Host "  - $unitTestsDir"
      Write-Host "  - $integrationTestsDir"
      exit 1
    }
  }
  
  Write-Status "Running test file: $TestFile"
  Write-Host "Module path: $TestPath"
}
```

### Testing Plan
```powershell
# Test unit test file
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit -TestFile "test_categorization.py"

# Test integration test file
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration -TestFile "test_get_bom_items.py"

# Test auto-detection
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -TestFile "test_shortfall_calculation.py"
```

**Estimated Effort**: 1-2 hours

---

## Improvement 2: Test Pattern Matching

### Problem
Cannot run multiple related test files at once (e.g., all serializer tests).

**Current Workaround:**
```powershell
# Must run entire test suite or specific file
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit
```

**Desired:**
```powershell
# Run all tests matching pattern
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit -Pattern "*serializer*"
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration -Pattern "test_view*"
```

### Solution Design

**Add `-Pattern` parameter:**
```powershell
param(
  # ... existing parameters ...
  
  [Parameter(Mandatory = $false)]
  [string]$Pattern,
  
  # ... rest of parameters ...
)
```

**Implementation Logic:**
```powershell
# If Pattern specified, filter test files
if ($Pattern) {
  Write-Status "Finding tests matching pattern: $Pattern"
  
  if ($runUnit -and $hasUnitTests) {
    $unitFiles = Get-ChildItem -Path $unitTestsDir -Filter $Pattern -File
    Write-Host "Found $($unitFiles.Count) unit test files"
    
    foreach ($file in $unitFiles) {
      $testModule = $file.BaseName
      $testPath = "$packageName.tests.unit.$testModule"
      Write-Status "Running: $testPath"
      & python -m unittest $testPath -v
    }
  }
  
  if ($runIntegration -and $hasIntegrationTests) {
    # Use invoke dev.test with pattern
    Write-Status "Running integration tests matching: $Pattern"
    
    $integrationFiles = Get-ChildItem -Path $integrationTestsDir -Filter $Pattern -File
    Write-Host "Found $($integrationFiles.Count) integration test files"
    
    foreach ($file in $integrationFiles) {
      $testModule = $file.BaseName
      $testPath = "$Plugin.tests.integration.$testModule"
      Write-Status "Running: $testPath"
      & invoke dev.test -r $testPath
    }
  }
}
```

**Estimated Effort**: 2-3 hours

---

## Improvement 3: Direct Invoke Support

### Problem
Integration tests use invoke command but script doesn't expose invoke options.

**Current Behavior:**
```powershell
# Script uses: invoke dev.test -r <module>
# No way to pass additional invoke flags
```

**Desired:**
```powershell
# Pass through invoke flags
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration -InvokeArgs "--keepdb --parallel"
```

### Solution Design

**Add `-InvokeArgs` parameter:**
```powershell
param(
  # ... existing parameters ...
  
  [Parameter(Mandatory = $false)]
  [string[]]$InvokeArgs,
  
  # ... rest of parameters ...
)
```

**Implementation Logic:**
```powershell
# When running integration tests
if ($TestPath) {
  $invokeCmd = "invoke dev.test -r $($Plugin).tests.integration.$testModule"
  
  if ($InvokeArgs) {
    $invokeCmd += " " + ($InvokeArgs -join " ")
  }
  
  Write-Status "Running: $invokeCmd"
  Invoke-Expression $invokeCmd
}
```

**Common Use Cases:**
```powershell
# Keep test database between runs (faster)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration -InvokeArgs "--keepdb"

# Run tests in parallel
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration -InvokeArgs "--parallel"

# Verbose output
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration -InvokeArgs "-vv"
```

**Estimated Effort**: 1 hour

---

## Improvement 4: Test Summary Report

### Problem
No summary showing which tests passed/failed across multiple runs.

**Current Behavior:**
```powershell
# Just shows test output
# No summary at end
```

**Desired:**
```powershell
# After all tests complete:
# ========================================
#   TEST SUMMARY
# ========================================
# Unit Tests:        PASSED (164/164)
# Integration Tests: PASSED (90/90)
# Total Duration:    12.3s
```

### Solution Design

**Track results:**
```powershell
# Initialize tracking
$testResults = @{
  UnitPassed = 0
  UnitFailed = 0
  IntegrationPassed = 0
  IntegrationFailed = 0
  StartTime = Get-Date
}

# After unit tests
if ($LASTEXITCODE -eq 0) {
  $testResults.UnitPassed = $unitTestCount
} else {
  $testResults.UnitFailed = $unitTestCount
}

# After integration tests
# (similar tracking)

# Display summary
$duration = ((Get-Date) - $testResults.StartTime).TotalSeconds
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($runUnit) {
  $unitColor = if ($testResults.UnitFailed -eq 0) { "Green" } else { "Red" }
  Write-Host "Unit Tests:        " -NoNewline
  Write-Host "$($testResults.UnitPassed) passed, $($testResults.UnitFailed) failed" -ForegroundColor $unitColor
}

if ($runIntegration) {
  $integrationColor = if ($testResults.IntegrationFailed -eq 0) { "Green" } else { "Red" }
  Write-Host "Integration Tests: " -NoNewline
  Write-Host "$($testResults.IntegrationPassed) passed, $($testResults.IntegrationFailed) failed" -ForegroundColor $integrationColor
}

Write-Host "Total Duration:    $([Math]::Round($duration, 1))s"
```

**Estimated Effort**: 2 hours

---

## Improvement 5: Watch Mode

### Problem
Must manually re-run tests after code changes.

**Current Workaround:**
```powershell
# Must manually run after each change
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit
# Edit code
# Ctrl+C, Up arrow, Enter
```

**Desired:**
```powershell
# Watches for file changes and auto-runs tests
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit -Watch
```

### Solution Design

**Add `-Watch` parameter:**
```powershell
param(
  # ... existing parameters ...
  
  [Parameter(Mandatory = $false)]
  [switch]$Watch
)
```

**Implementation Logic:**
```powershell
if ($Watch) {
  Write-Status "Watch mode enabled - monitoring for changes..."
  Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
  
  $watcher = New-Object System.IO.FileSystemWatcher
  $watcher.Path = Join-Path $pluginDir $packageName
  $watcher.Filter = "*.py"
  $watcher.IncludeSubdirectories = $true
  $watcher.EnableRaisingEvents = $true
  
  $action = {
    Write-Host ""
    Write-Host "Change detected: $($Event.SourceEventArgs.Name)" -ForegroundColor Yellow
    Write-Host "Re-running tests..." -ForegroundColor Yellow
    
    # Run tests (reuse existing test logic)
    # ...
  }
  
  Register-ObjectEvent $watcher "Changed" -Action $action
  
  # Keep script running
  while ($true) {
    Start-Sleep -Seconds 1
  }
}
```

**Note**: Only for unit tests (integration tests too slow for watch mode)

**Estimated Effort**: 3-4 hours

---

## Implementation Priority

**Phase 1 (High Value, Low Effort):**
1. ✅ **TestFile parameter** (1-2 hours) - Most requested feature
2. **InvokeArgs support** (1 hour) - Enables advanced use cases

**Phase 2 (Medium Value, Medium Effort):**
3. **Test Summary Report** (2 hours) - Better feedback
4. **Pattern Matching** (2-3 hours) - Convenience feature

**Phase 3 (Nice to Have, High Effort):**
5. **Watch Mode** (3-4 hours) - TDD workflow improvement

**Total Estimated Effort**: 9-12 hours

---

## Breaking Changes

None - all improvements are additive (new optional parameters).

---

## Documentation Updates Required

After implementing improvements:

1. **Update Test-Plugin.ps1 help text** - Add new parameter examples
2. **Update WORKFLOWS.md** - Add examples of new features
3. **Update QUICK-REFERENCE.md** - Add new command variations
4. **Update TESTING-STRATEGY.md** - Show pattern matching examples

---

## Testing Checklist

For each improvement, test:
- [ ] Works with FlatBOMGenerator plugin
- [ ] Works with fresh plugin (no tests yet)
- [ ] Works with unit tests only
- [ ] Works with integration tests only
- [ ] Works with both test types
- [ ] Error messages are clear
- [ ] PowerShell help text is accurate

---

## Related Issues

When implementing, watch for:
- **PowerShell escaping** - Test with spaces in filenames
- **Invoke command issues** - Windows invoke vs Linux invoke behavior
- **Virtual environment activation** - Path issues with special characters
- **Test discovery** - Handling both old and new test structures

---

## Current Workarounds (Until Implemented)

**To run specific test file (workaround):**
```powershell
# Option 1: Use full module path with -TestPath
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -TestPath "flat_bom_generator.tests.integration.test_get_bom_items"

# Option 2: Run invoke directly
cd inventree-dev\InvenTree
& .venv\Scripts\Activate.ps1
invoke dev.test -r FlatBOMGenerator.tests.integration.test_get_bom_items

# Option 3: Run unittest directly (unit tests only)
cd plugins\FlatBOMGenerator
& .venv\Scripts\Activate.ps1
python -m unittest flat_bom_generator.tests.unit.test_categorization
```

---

**Next Steps:**
1. Get user approval on priority order
2. Implement Phase 1 improvements
3. Test with real plugins
4. Update documentation
5. Move to Phase 2

---

_Last Updated: January 12, 2026_
