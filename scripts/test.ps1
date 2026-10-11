# Run the curated test set for the overlay. The full codex-tui suite is NOT
# runnable on this fork: upstream snapshots were recorded against package
# version 0.0.0 while this workspace builds 0.162.0, so dozens of unrelated
# snapshot tests fail on version strings alone (see docs/development-log.md).
#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$SkipAssemble
)
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
if (-not $SkipAssemble) {
    & (Join-Path $PSScriptRoot 'assemble.ps1')
}

# Test-thread stack: the transcript search tests overflow the default stack in
# debug builds (upstream CI runs release tests).
$env:RUST_MIN_STACK = '33554432'

Push-Location (Join-Path $root 'work/codex')
try {
    cargo test -p codex-tui --lib -- context_sidebar sidebar empty_state daemon_startup owned_transcript plan_mode
    if ($LASTEXITCODE) { throw 'curated tests failed.' }
} finally {
    Pop-Location
}
Write-Host 'Curated overlay tests passed.' -ForegroundColor DarkCyan
