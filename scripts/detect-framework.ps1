[CmdletBinding()]
param(
    [string]$Root = ".",

    [ValidateSet("json", "text")]
    [string]$Format = "json",

    [int]$MaxExamples = 10,

    [switch]$Help
)

$scriptPath = Join-Path $PSScriptRoot "detect-test-context.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Error "Compatibility wrapper failed because '$scriptPath' was not found."
    exit 1
}

& $scriptPath -Root $Root -Format $Format -MaxExamples $MaxExamples -Help:$Help
exit $LASTEXITCODE
