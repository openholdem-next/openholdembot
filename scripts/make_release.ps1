<#
.SYNOPSIS
    Assembles a distributable OpenHoldem Next package from a completed build.

.DESCRIPTION
    Replaces prepare_release_semi_automatically.au3, which required AutoIt,
    7-zip and HTML Help Workshop. This script needs none of them.

    It does not build anything. Build the solution in Visual Studio first
    (Release | Win32), then run this.

.EXAMPLE
    .\tools\make_release.ps1

.EXAMPLE
    .\tools\make_release.ps1 -OutputDir D:\releases -NoZip
#>

[CmdletBinding()]
param(
    # Where the finished package is written. Defaults to <repo>\_release
    [string]$OutputDir,

    # Build configuration to package
    [string]$Configuration = 'Release',

    # Skip creating the .zip archive
    [switch]$NoZip
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

$RepoRoot   = Split-Path -Parent $PSScriptRoot
$BinDir     = Join-Path $RepoRoot $Configuration
$SkeletonDir= Join-Path $RepoRoot '##_OpenHoldem_Release_Directory_##'
$OpenPPLDir = Join-Path $RepoRoot 'OpenPPL\OpenPPL_Library'
if (-not $OutputDir) { $OutputDir = Join-Path $RepoRoot '_release' }

# The C# tool writes to its own bin\ directory, not to the shared output folder
$CsBinDir   = Join-Path $RepoRoot "OpenReplayShooter\bin\$Configuration"

function Fail($message) {
    Write-Host ''
    Write-Host "ERROR: $message" -ForegroundColor Red
    exit 1
}

function Step($message) {
    Write-Host "  $message"
}

Write-Host ''
Write-Host 'OpenHoldem Next - release packaging' -ForegroundColor Cyan
Write-Host ''

# ---------------------------------------------------------------------------
# What goes where
# ---------------------------------------------------------------------------

# DLLs and the main executable, placed in the package root
$RootBinaries = @(
    'OpenHoldem.exe',
    'debug.dll',
    'files.dll',
    'GamestateValidation.dll',
    'globals.dll',
    'keyboard.dll',
    'mouse.dll',
    'pokertracker_query_definitions.dll',
    'Preferences.dll',
    'string_functions.dll',
    'user.dll',
    'window_functions.dll'
)

# Tools, placed in tools\ (string_functions and window_functions are needed
# there too: OpenScrape loads them from its own directory)
$ToolBinaries = @(
    'ManualMode.exe',
    'OHReplay.exe',
    'OpenReplayShooter.exe',
    'OpenScrape.exe',
    'string_functions.dll',
    'window_functions.dll'
)

# ---------------------------------------------------------------------------
# 1. Preflight
# ---------------------------------------------------------------------------

Write-Host 'Checking prerequisites' -ForegroundColor Yellow

if (-not (Test-Path $SkeletonDir)) { Fail "Release skeleton not found at $SkeletonDir" }
if (-not (Test-Path $OpenPPLDir))  { Fail "OpenPPL library not found at $OpenPPLDir" }
if (-not (Test-Path $BinDir))      { Fail "No '$Configuration' build directory. Build the solution first." }

# Most projects write to <repo>\Release, the C# tool writes to its own bin\.
function Find-Binary($name) {
    foreach ($dir in @($BinDir, $CsBinDir)) {
        $p = Join-Path $dir $name
        if (Test-Path $p) { return $p }
    }
    return $null
}

$missing = @()
foreach ($f in ($RootBinaries + $ToolBinaries | Select-Object -Unique)) {
    if (-not (Find-Binary $f)) { $missing += $f }
}
if ($missing.Count -gt 0) {
    Fail "Not found in $BinDir or ${CsBinDir}:`n  $($missing -join "`n  ")`nBuild the whole solution ($Configuration | Win32) and try again."
}
Step "All $(($RootBinaries + $ToolBinaries | Select-Object -Unique).Count) binaries present"

# ---------------------------------------------------------------------------
# 2. Version
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host 'Determining version' -ForegroundColor Yellow

# Read it from the built executable rather than parsing the .rc file:
# whatever the binary reports is what users will actually see.
$exe     = Get-Item (Join-Path $BinDir 'OpenHoldem.exe')
$Version = $exe.VersionInfo.FileVersion.Trim()
if ([string]::IsNullOrWhiteSpace($Version)) { Fail 'OpenHoldem.exe carries no version information.' }
Step "OpenHoldem.exe reports $Version"

# The version lives in two places that have drifted apart before. Warn loudly
# rather than shipping a package whose version means nothing.
$stdafx = Join-Path $RepoRoot 'OpenHoldem\stdafx.h'
if (Test-Path $stdafx) {
    $versionText = (Select-String -Path $stdafx -Pattern 'VERSION_TEXT\s+"([^"]+)"').Matches.Groups[1].Value
    if ($versionText -and ($versionText -ne $Version)) {
        Write-Host ''
        Write-Host "  WARNING: stdafx.h says VERSION_TEXT `"$versionText`" but the binary says `"$Version`"." -ForegroundColor Yellow
        Write-Host '  The version must be updated in both OpenHoldem.rc and stdafx.h.' -ForegroundColor Yellow
        Write-Host ''
        $answer = Read-Host '  Continue anyway? (y/N)'
        if ($answer -ne 'y') { Fail 'Aborted. Fix the version and rebuild.' }
    } else {
        Step "stdafx.h agrees"
    }
}

$PackageName = "OpenHoldem_$Version"
$PackageDir  = Join-Path $OutputDir $PackageName

# ---------------------------------------------------------------------------
# 3. Assemble
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host 'Assembling package' -ForegroundColor Yellow

if (Test-Path $PackageDir) {
    Remove-Item $PackageDir -Recurse -Force
    Step 'Removed previous package directory'
}
New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

# 3a. The skeleton: bot_logic, documents, scraper, tools, the INI and the .bat
Copy-Item -Path (Join-Path $SkeletonDir '*') -Destination $PackageDir -Recurse -Force
Step 'Copied release skeleton'

# 3b. Binaries
foreach ($f in $RootBinaries) {
    Copy-Item (Find-Binary $f) $PackageDir -Force
}
Step "Copied $($RootBinaries.Count) files to the package root"

$toolsDir = Join-Path $PackageDir 'tools'
New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
foreach ($f in $ToolBinaries) {
    Copy-Item (Find-Binary $f) $toolsDir -Force
}
Step "Copied $($ToolBinaries.Count) files to tools\"

# 3c. The OpenPPL library lives outside the skeleton in the repository
$libDir = Join-Path $PackageDir 'bot_logic\OpenPPL_Library'
New-Item -ItemType Directory -Path $libDir -Force | Out-Null
$ohf = Get-ChildItem (Join-Path $OpenPPLDir '*.ohf')
Copy-Item $ohf $libDir -Force
Step "Copied $($ohf.Count) OpenPPL library files"

# 3d. Runtime directories the bot expects to exist
New-Item -ItemType Directory -Path (Join-Path $PackageDir 'logs') -Force | Out-Null
Step 'Created logs\'

# ---------------------------------------------------------------------------
# 4. Clean up
# ---------------------------------------------------------------------------

Write-Host ''
Write-Host 'Cleaning' -ForegroundColor Yellow

$junk = Get-ChildItem $PackageDir -Recurse -Include '*.exp','*.pdb','*.ilk','*.lib','*.iobj','*.ipdb','Thumbs.db','Desktop.ini' -Force
if ($junk) {
    $junk | Remove-Item -Force
    Step "Removed $($junk.Count) build artefacts"
} else {
    Step 'Nothing to remove'
}

# The default bot and the OpenPPL library are read-only on purpose: people
# edited them, broke them, and then reported the breakage as a bug.
foreach ($d in @($libDir, (Join-Path $PackageDir 'bot_logic\DefaultBot'))) {
    if (Test-Path $d) {
        Get-ChildItem $d -Recurse -File | ForEach-Object { $_.IsReadOnly = $true }
    }
}
Step 'Marked DefaultBot and OpenPPL_Library read-only'

# ---------------------------------------------------------------------------
# 5. Archive
# ---------------------------------------------------------------------------

if (-not $NoZip) {
    Write-Host ''
    Write-Host 'Creating archive' -ForegroundColor Yellow
    $zipPath = Join-Path $OutputDir "$PackageName.zip"
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Compress-Archive -Path $PackageDir -DestinationPath $zipPath -Force
    $sizeMb = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
    Step "$PackageName.zip ($sizeMb MB)"
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

$fileCount = (Get-ChildItem $PackageDir -Recurse -File).Count

Write-Host ''
Write-Host "Done. $fileCount files." -ForegroundColor Green
Write-Host "  $PackageDir"
if (-not $NoZip) { Write-Host "  $(Join-Path $OutputDir "$PackageName.zip")" }
Write-Host ''
Write-Host 'Before publishing:' -ForegroundColor Cyan
Write-Host '  - Unpack the zip somewhere clean and check that OpenHoldem starts'
Write-Host '  - Connect to a table and confirm the bot reads it correctly'
Write-Host '  - Update the release notes in documents\'
Write-Host '  - Tag the commit, then attach the zip to a GitHub release'
Write-Host ''
