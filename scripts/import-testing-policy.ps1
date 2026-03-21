[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Source,

    [string]$Destination = "references/local-testing-policy.md",

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Source)) {
    Write-Error "Source policy file '$Source' was not found."
    exit 1
}

if ((Test-Path -LiteralPath $Destination) -and (-not $Force)) {
    Write-Error "Destination '$Destination' already exists. Re-run with -Force to overwrite."
    exit 1
}

$sourcePath = (Resolve-Path -LiteralPath $Source).Path
$destinationDirectory = Split-Path -Path $Destination -Parent
if ($destinationDirectory -and (-not (Test-Path -LiteralPath $destinationDirectory))) {
    New-Item -ItemType Directory -Path $destinationDirectory | Out-Null
}

$content = Get-Content -Raw -LiteralPath $sourcePath
$header = @"
# Local Testing Policy

Imported from: $sourcePath
Imported at (UTC): $((Get-Date).ToUniversalTime().ToString("o"))

---

"@

Set-Content -LiteralPath $Destination -Value ($header + $content)
Write-Host "Imported policy to $Destination"
