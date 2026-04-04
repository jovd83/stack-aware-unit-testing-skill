[CmdletBinding()]
param(
    [string]$Root = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path

function Assert-PathExists {
    param([string]$RelativePath)
    $fullPath = Join-Path $resolvedRoot $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Missing required path: $RelativePath"
    }
}

$requiredPaths = @(
    "SKILL.md",
    "README.md",
    "VERSION",
    "CHANGELOG.md",
    "LICENSE",
    "RELEASE_CHECKLIST.md",
    ".gitignore",
    "agents/openai.yaml",
    "evals/evals.json",
    "scripts/detect-test-context.ps1",
    "scripts/detect-framework.ps1",
    "scripts/import-testing-policy.ps1",
    "references/analysis-workflow.md",
    "references/framework-selection.md",
    "references/test-authoring-playbook.md",
    "references/reporting-contract.md",
    "references/evaluation.md",
    "references/org-policy-integration.md"
)

foreach ($path in $requiredPaths) {
    Assert-PathExists -RelativePath $path
}

$evalsPath = Join-Path $resolvedRoot "evals/evals.json"
$null = Get-Content -Raw -LiteralPath $evalsPath | ConvertFrom-Json

$version = (Get-Content -Raw -LiteralPath (Join-Path $resolvedRoot "VERSION")).Trim()
if (-not ($version -match '^\d+\.\d+\.\d+$')) {
    throw "VERSION must use semantic versioning like 2.1.0."
}

$skillContent = Get-Content -Raw -LiteralPath (Join-Path $resolvedRoot "SKILL.md")
if ($skillContent -notmatch 'name:\s*stack-aware-unit-testing-skill') {
    throw "SKILL.md frontmatter must contain the renamed skill identifier."
}

$fixtureRoot = Join-Path $resolvedRoot "evals/fixtures"
$fixtures = Get-ChildItem -LiteralPath $fixtureRoot -Directory | Sort-Object Name
foreach ($fixture in $fixtures) {
    & (Join-Path $resolvedRoot "scripts/detect-test-context.ps1") -Root $fixture.FullName -Format json | Out-Null
}

$skillsRef = Get-Command "skills-ref" -ErrorAction SilentlyContinue
if ($skillsRef) {
    & $skillsRef.Source "validate" $resolvedRoot | Out-Host
} else {
    Write-Host "skills-ref not found; skipping external spec validation."
}

Write-Host "Validated $($fixtures.Count) fixtures and core repository files successfully."
