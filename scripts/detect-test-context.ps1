<#
.SYNOPSIS
Detect repository test context for unit and component testing work.

.DESCRIPTION
Scans a repository for build manifests, common test frameworks, test directories,
and sample test files. Emits either structured JSON or a compact text summary
that an agent can use for routing and planning.

.EXAMPLE
./scripts/detect-test-context.ps1 -Root . -Format json

.EXAMPLE
./scripts/detect-test-context.ps1 -Root C:\repo -Format text
#>

[CmdletBinding()]
param(
    [string]$Root = ".",

    [ValidateSet("json", "text")]
    [string]$Format = "json",

    [int]$MaxExamples = 10,

    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

function Get-NormalizedPath {
    param([string]$Path)
    return [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).Path)
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$FullPath
    )

    $normalizedBasePath = Get-NormalizedPath $BasePath
    $normalizedFullPath = Get-NormalizedPath $FullPath
    $trimChars = [char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $baseWithSeparator = $normalizedBasePath.TrimEnd($trimChars) + [System.IO.Path]::DirectorySeparatorChar

    if ($normalizedFullPath.StartsWith($baseWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativePath = $normalizedFullPath.Substring($baseWithSeparator.Length)
    } elseif ($normalizedFullPath.Equals($normalizedBasePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativePath = "."
    } else {
        $baseUri = New-Object System.Uri($baseWithSeparator)
        $fullUri = New-Object System.Uri($normalizedFullPath)
        $relativePath = [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($fullUri).ToString())
    }

    return $relativePath.Replace([System.IO.Path]::AltDirectorySeparatorChar, '\').Replace([System.IO.Path]::DirectorySeparatorChar, '\')
}

function Get-ChildFilesSafe {
    param([string]$BasePath)

    $skipDirectoryNames = @(
        ".git",
        ".hg",
        ".svn",
        ".venv",
        "venv",
        "node_modules",
        "dist",
        "build",
        "target",
        "coverage",
        ".next",
        ".nuxt",
        "out",
        "vendor",
        "bin",
        "obj"
    )

    Get-ChildItem -LiteralPath $BasePath -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $segments = $_.FullName.Substring($BasePath.Length).TrimStart('\').Split('\')
            -not ($segments | Where-Object { $skipDirectoryNames -contains $_ })
        }
}

function Add-Detection {
    param(
        [hashtable]$Map,
        [string]$Name,
        [string]$Source,
        [string]$Confidence
    )

    if (-not $Map.ContainsKey($Name)) {
        $Map[$Name] = [ordered]@{
            name = $Name
            sources = @($Source)
            confidence = $Confidence
        }
        return
    }

    $existing = $Map[$Name]
    if ($existing.sources -notcontains $Source) {
        $existing.sources += $Source
    }

    $rank = @{
        low = 1
        medium = 2
        high = 3
    }

    if ($rank[$Confidence] -gt $rank[$existing.confidence]) {
        $existing.confidence = $Confidence
    }
}

function Test-ContentMatch {
    param(
        [string]$Content,
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($Content -match $pattern) {
            return $true
        }
    }

    return $false
}

if (-not (Test-Path -LiteralPath $Root)) {
    Write-Error "Root path '$Root' does not exist."
    exit 1
}

$resolvedRoot = Get-NormalizedPath $Root
$files = @(Get-ChildFilesSafe -BasePath $resolvedRoot)
$relativeFiles = $files | ForEach-Object { Get-RelativePath -BasePath $resolvedRoot -FullPath $_.FullName }

$manifestFiles = @(
    "package.json",
    "pnpm-workspace.yaml",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    "pyproject.toml",
    "requirements.txt",
    "setup.py",
    "go.mod",
    "*.csproj",
    "*.sln",
    "Cargo.toml",
    "Gemfile",
    "composer.json"
)

$manifestMatches = $files | Where-Object {
    $name = $_.Name
    $manifestFiles | Where-Object { $name -like $_ } | Select-Object -First 1
}

$ecosystem = "unknown"
$ecosystemEvidence = @()

function Add-EcosystemEvidence {
    param([string]$Value)
    if ($script:ecosystemEvidence -notcontains $Value) {
        $script:ecosystemEvidence += $Value
    }
}

if ($relativeFiles -contains "package.json") {
    $ecosystem = "javascript-typescript"
    Add-EcosystemEvidence "package.json"
}
if (($relativeFiles -contains "pom.xml") -or ($relativeFiles -contains "build.gradle") -or ($relativeFiles -contains "build.gradle.kts")) {
    if ($ecosystem -eq "unknown") { $ecosystem = "java-jvm" }
    Add-EcosystemEvidence "jvm-build-file"
}
if (($relativeFiles -contains "pyproject.toml") -or ($relativeFiles -contains "requirements.txt") -or ($relativeFiles -contains "setup.py")) {
    if ($ecosystem -eq "unknown") { $ecosystem = "python" }
    Add-EcosystemEvidence "python-manifest"
}
if ($relativeFiles -contains "go.mod") {
    if ($ecosystem -eq "unknown") { $ecosystem = "go" }
    Add-EcosystemEvidence "go.mod"
}
if (($files | Where-Object { $_.Name -like "*.csproj" -or $_.Name -like "*.sln" } | Select-Object -First 1)) {
    if ($ecosystem -eq "unknown") { $ecosystem = "dotnet" }
    Add-EcosystemEvidence ".csproj-or-.sln"
}
if ($relativeFiles -contains "Cargo.toml") {
    if ($ecosystem -eq "unknown") { $ecosystem = "rust" }
    Add-EcosystemEvidence "Cargo.toml"
}
if ($relativeFiles -contains "Gemfile") {
    if ($ecosystem -eq "unknown") { $ecosystem = "ruby" }
    Add-EcosystemEvidence "Gemfile"
}
if ($relativeFiles -contains "composer.json") {
    if ($ecosystem -eq "unknown") { $ecosystem = "php" }
    Add-EcosystemEvidence "composer.json"
}

$detections = @{}
$existingTestFiles = New-Object System.Collections.Generic.List[string]
$testDirectories = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
    $relativePath = Get-RelativePath -BasePath $resolvedRoot -FullPath $file.FullName
    $lowerPath = $relativePath.ToLowerInvariant()
    $hasTestDirectory = $lowerPath -match '(^|\\)(test|tests|__tests__|spec)(\\|$)'
    $looksLikeTestSource = (
        $lowerPath -match '(^|\\).*(\.spec|\.test)\.(js|jsx|ts|tsx)$' -or
        $lowerPath -match '(^|\\)test_.*\.py$' -or
        $lowerPath -match '(^|\\).+_test\.go$' -or
        $lowerPath -match '(^|\\).+tests?\.cs$' -or
        $lowerPath -match '(^|\\).*(test|spec)\.rb$' -or
        $lowerPath -match '(^|\\).*(test|spec)\.php$' -or
        $lowerPath -match '(^|\\).*(test|spec)\.rs$' -or
        $lowerPath -match '(^|\\).*(test|spec)\.kt$' -or
        $lowerPath -match '(^|\\).*(test|spec)\.java$'
    )

    if ($looksLikeTestSource -or ($hasTestDirectory -and $file.Extension -in @(".js", ".jsx", ".ts", ".tsx", ".py", ".go", ".cs", ".rb", ".php", ".rs", ".kt", ".java")) ) {
        $existingTestFiles.Add($relativePath)
        $directoryName = Split-Path -Path $relativePath -Parent
        if ($directoryName -and ($testDirectories -notcontains $directoryName)) {
            [void]$testDirectories.Add($directoryName)
        }
    }
}

$packageJsonPath = Join-Path $resolvedRoot "package.json"
if (Test-Path $packageJsonPath) {
    try {
        $packageJson = Get-Content -Raw -LiteralPath $packageJsonPath | ConvertFrom-Json
        $dependencyNames = @()
        foreach ($propertyName in @("dependencies", "devDependencies", "peerDependencies")) {
            $property = $packageJson.PSObject.Properties[$propertyName]
            if ($null -ne $property -and $null -ne $property.Value) {
                $dependencyNames += $property.Value.PSObject.Properties.Name
            }
        }

        if ($dependencyNames -contains "jest") { Add-Detection -Map $detections -Name "jest" -Source "package.json dependency" -Confidence "high" }
        if ($dependencyNames -contains "vitest") { Add-Detection -Map $detections -Name "vitest" -Source "package.json dependency" -Confidence "high" }
        if ($dependencyNames -contains "mocha") { Add-Detection -Map $detections -Name "mocha" -Source "package.json dependency" -Confidence "medium" }
        if ($dependencyNames -contains "@playwright/test") { Add-Detection -Map $detections -Name "playwright" -Source "package.json dependency" -Confidence "medium" }
        if ($dependencyNames -contains "cypress") { Add-Detection -Map $detections -Name "cypress" -Source "package.json dependency" -Confidence "medium" }
    } catch {
        Write-Warning "Could not parse package.json: $($_.Exception.Message)"
    }
}

$contentFiles = @(
    "pyproject.toml",
    "requirements.txt",
    "setup.py",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "Cargo.toml",
    "Gemfile",
    "composer.json"
)

$csprojFiles = $files | Where-Object { $_.Name -like "*.csproj" }
foreach ($csprojFile in $csprojFiles) {
    $content = Get-Content -Raw -LiteralPath $csprojFile.FullName
    if (Test-ContentMatch -Content $content -Patterns @("xunit")) {
        Add-Detection -Map $detections -Name "xunit" -Source (Get-RelativePath -BasePath $resolvedRoot -FullPath $csprojFile.FullName) -Confidence "high"
    }
    if (Test-ContentMatch -Content $content -Patterns @("nunit")) {
        Add-Detection -Map $detections -Name "nunit" -Source (Get-RelativePath -BasePath $resolvedRoot -FullPath $csprojFile.FullName) -Confidence "high"
    }
    if (Test-ContentMatch -Content $content -Patterns @("mstest")) {
        Add-Detection -Map $detections -Name "mstest" -Source (Get-RelativePath -BasePath $resolvedRoot -FullPath $csprojFile.FullName) -Confidence "high"
    }
}

foreach ($contentFile in $contentFiles) {
    $fullPath = Join-Path $resolvedRoot $contentFile
    if (-not (Test-Path $fullPath)) {
        continue
    }

    $content = Get-Content -Raw -LiteralPath $fullPath

    switch ($contentFile) {
        "pyproject.toml" {
            if (Test-ContentMatch -Content $content -Patterns @("pytest", "tool\.pytest", "pytest-cov")) {
                Add-Detection -Map $detections -Name "pytest" -Source $contentFile -Confidence "high"
            }
            if (Test-ContentMatch -Content $content -Patterns @("unittest")) {
                Add-Detection -Map $detections -Name "unittest" -Source $contentFile -Confidence "medium"
            }
        }
        "requirements.txt" {
            if (Test-ContentMatch -Content $content -Patterns @("pytest", "pytest-cov")) {
                Add-Detection -Map $detections -Name "pytest" -Source $contentFile -Confidence "medium"
            }
        }
        "setup.py" {
            if (Test-ContentMatch -Content $content -Patterns @("pytest")) {
                Add-Detection -Map $detections -Name "pytest" -Source $contentFile -Confidence "medium"
            }
        }
        "pom.xml" {
            if (Test-ContentMatch -Content $content -Patterns @("junit-jupiter", "org\.junit\.jupiter")) {
                Add-Detection -Map $detections -Name "junit5" -Source $contentFile -Confidence "high"
            }
            if (Test-ContentMatch -Content $content -Patterns @("mockito")) {
                Add-Detection -Map $detections -Name "mockito" -Source $contentFile -Confidence "medium"
            }
            if (Test-ContentMatch -Content $content -Patterns @("testng")) {
                Add-Detection -Map $detections -Name "testng" -Source $contentFile -Confidence "medium"
            }
        }
        "build.gradle" {
            if (Test-ContentMatch -Content $content -Patterns @("junit-jupiter", "org\.junit\.jupiter")) {
                Add-Detection -Map $detections -Name "junit5" -Source $contentFile -Confidence "high"
            }
            if (Test-ContentMatch -Content $content -Patterns @("mockito")) {
                Add-Detection -Map $detections -Name "mockito" -Source $contentFile -Confidence "medium"
            }
        }
        "build.gradle.kts" {
            if (Test-ContentMatch -Content $content -Patterns @("junit-jupiter", "org\.junit\.jupiter")) {
                Add-Detection -Map $detections -Name "junit5" -Source $contentFile -Confidence "high"
            }
            if (Test-ContentMatch -Content $content -Patterns @("mockito")) {
                Add-Detection -Map $detections -Name "mockito" -Source $contentFile -Confidence "medium"
            }
        }
        "Cargo.toml" {
            if (Test-ContentMatch -Content $content -Patterns @("^\[dev-dependencies\]", "rstest", "tokio")) {
                Add-Detection -Map $detections -Name "cargo-test" -Source $contentFile -Confidence "medium"
            }
        }
        "Gemfile" {
            if (Test-ContentMatch -Content $content -Patterns @("rspec")) {
                Add-Detection -Map $detections -Name "rspec" -Source $contentFile -Confidence "high"
            }
        }
        "composer.json" {
            if (Test-ContentMatch -Content $content -Patterns @("phpunit")) {
                Add-Detection -Map $detections -Name "phpunit" -Source $contentFile -Confidence "high"
            }
        }
    }
}

foreach ($relativePath in $existingTestFiles) {
    switch -Regex ($relativePath.ToLowerInvariant()) {
        '\.(spec|test)\.(ts|tsx|js|jsx)$' { Add-Detection -Map $detections -Name "jest-or-vitest-style" -Source "test filename" -Confidence "medium"; break }
        'test_.*\.py$' { Add-Detection -Map $detections -Name "pytest-style" -Source "test filename" -Confidence "medium"; break }
        '.+_test\.go$' { Add-Detection -Map $detections -Name "go test" -Source "test filename" -Confidence "high"; break }
        '.+test\.java$' { Add-Detection -Map $detections -Name "junit-style" -Source "test filename" -Confidence "medium"; break }
        '.+tests?\.cs$' { Add-Detection -Map $detections -Name "dotnet-test-style" -Source "test filename" -Confidence "medium"; break }
    }
}

$specializedSkill = $null
if ($detections.ContainsKey("junit5")) {
    $specializedSkill = "junit5-skill"
}

$primaryFrameworkSignals = @(
    "jest",
    "vitest",
    "mocha",
    "pytest",
    "unittest",
    "junit5",
    "testng",
    "xunit",
    "nunit",
    "mstest",
    "rspec",
    "phpunit",
    "cargo-test",
    "go test"
)

$hasPrimaryFrameworkSignal = @($detections.Keys | Where-Object { $primaryFrameworkSignals -contains $_ }).Count -gt 0
$hasReusableTestSignal = ($existingTestFiles.Count -gt 0) -or $hasPrimaryFrameworkSignal

$recommendation = if ($hasReusableTestSignal -and $specializedSkill) {
    "Reuse the detected test framework and local test conventions, and route detailed implementation to the specialized skill when available."
} elseif ($hasReusableTestSignal) {
    "Reuse the detected test framework and local test conventions."
} elseif ($specializedSkill) {
    "Route to the specialized skill after confirming the target module and test scope."
} elseif ($ecosystem -eq "javascript-typescript") {
    "No existing tests found. Prefer the repository's dominant JS/TS tooling and add the smallest viable test runner if the user wants new tests."
} elseif ($ecosystem -eq "python") {
    "No existing tests found. Prefer pytest as the default fallback unless repository constraints say otherwise."
} elseif ($ecosystem -eq "java-jvm") {
    "No existing tests found. Prefer JUnit 5 as the default fallback unless repository constraints say otherwise."
} elseif ($ecosystem -eq "go") {
    "No existing tests found. Prefer the standard testing package."
} elseif ($ecosystem -eq "dotnet") {
    "No existing tests found. Prefer xUnit unless the repository already signals MSTest or NUnit."
} else {
    "Repository test context is unclear. Inspect target code manually and keep assumptions explicit before adding dependencies."
}

$result = [ordered]@{
    root = $resolvedRoot
    scanned_at_utc = (Get-Date).ToUniversalTime().ToString("o")
    ecosystem = $ecosystem
    ecosystem_evidence = $ecosystemEvidence
    manifests = @($manifestMatches | ForEach-Object { Get-RelativePath -BasePath $resolvedRoot -FullPath $_.FullName } | Sort-Object -Unique)
    detected_frameworks = @($detections.Values | Sort-Object name)
    test_directories = @($testDirectories | Sort-Object -Unique)
    existing_test_files = @($existingTestFiles | Sort-Object | Select-Object -First $MaxExamples)
    existing_test_file_count = $existingTestFiles.Count
    recommended_specialized_skill = $specializedSkill
    recommendation = $recommendation
}

if ($Format -eq "json") {
    $result | ConvertTo-Json -Depth 6
    exit 0
}

Write-Host "Repository: $($result.root)"
Write-Host "Ecosystem: $($result.ecosystem)"

if ($result.manifests.Count -gt 0) {
    Write-Host "Manifests: $($result.manifests -join ', ')"
}

if ($result.detected_frameworks.Count -gt 0) {
    $frameworkSummary = $result.detected_frameworks | ForEach-Object { "$($_.name) [$($_.confidence)]" }
    Write-Host "Detected frameworks: $($frameworkSummary -join ', ')"
} else {
    Write-Host "Detected frameworks: none"
}

Write-Host "Existing test files: $($result.existing_test_file_count)"
if ($result.existing_test_files.Count -gt 0) {
    foreach ($item in $result.existing_test_files) {
        Write-Host " - $item"
    }
}

if ($result.recommended_specialized_skill) {
    Write-Host "Recommended specialized skill: $($result.recommended_specialized_skill)"
}

Write-Host "Recommendation: $($result.recommendation)"
