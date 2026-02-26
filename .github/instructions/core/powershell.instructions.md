---
applyTo: "**/*.ps1,**/*.psm1,**/*.psd1"
---

# PowerShell Conventions

Patterns for PowerShell scripts on Windows. All scripts in this workspace
target PowerShell 5.1 (the version that ships with Windows 10/11).

---

## Naming

- **Cmdlet names:** `Verb-Noun` format. Use approved verbs (`Get-Verb`).
  e.g. `Build-Plugin`, `Deploy-Package`, `Test-Connection`.
- **Parameters:** `PascalCase`. e.g. `-PluginName`, `-Server`, `-Force`.
- **Variables:** `$camelCase` for local, `$PascalCase` for script-scope.
- **Files:** `Verb-Noun.ps1` matching the primary function inside.

---

## Script Structure

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PluginName,

    [ValidateSet('staging', 'production')]
    [string]$Server = 'staging',

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Main logic ---
```

- Always use `[CmdletBinding()]` and `param()` blocks.
- Always set `$ErrorActionPreference = 'Stop'` -- fail fast.
- Validate parameters with `[ValidateSet()]`, `[ValidateNotNullOrEmpty()]`, etc.

---

## Error Handling

```powershell
try {
    $result = Some-RiskyOperation -Path $path
}
catch [System.IO.FileNotFoundException] {
    Write-Error "[ERROR] File not found: $path"
    exit 1
}
catch {
    Write-Error "[ERROR] Unexpected failure: $_"
    exit 1
}
```

- Catch specific exceptions first, generic last.
- Use `Write-Error` for errors, `Write-Warning` for non-fatal issues.
- Never use `Write-Host` for data -- use `Write-Output` or return objects.
- Exit with non-zero codes on failure.

---

## Output

- Return **objects**, not formatted strings. Let the caller decide formatting.
- Use `[PSCustomObject]@{}` for structured output.
- Avoid `Format-Table` or `Format-List` inside scripts -- those are for
  interactive use only.

---

## Encoding

- **ASCII only** in script files. PowerShell 5.1 defaults to the system
  codepage and mangles Unicode characters.
- No emoji, no curly quotes, no en-dashes. Use `--` for dashes and `->` for
  arrows.
- If a script must write UTF-8, use:
  ```powershell
  [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
  ```

---

## Pipeline

- Use `ForEach-Object` for pipeline processing, not `foreach` statement
  (which breaks the pipeline).
- Use `Where-Object` for filtering, `Select-Object` for projection.
- Chain with `|` -- avoid temporary variables for intermediate results.

---

## Common Patterns

```powershell
# Check if a tool exists before using it
if (-not (Get-Command 'npm' -ErrorAction SilentlyContinue)) {
    Write-Error "[ERROR] npm is not installed or not in PATH"
    exit 1
}

# Ensure a directory exists
$outDir = Join-Path $PSScriptRoot 'output'
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# Confirm before destructive action
if (-not $Force) {
    $confirm = Read-Host "Deploy to $Server? (y/N)"
    if ($confirm -ne 'y') { return }
}
```
