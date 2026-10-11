# Build the Better Codex TUI: pinned upstream checkout + local overlay -> dist/codex.exe.
#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Release,
    [switch]$SkipAssemble
)
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
if (-not $SkipAssemble) {
    & (Join-Path $PSScriptRoot 'assemble.ps1')
}

Push-Location (Join-Path $root 'work/codex')
try {
    if ($Release) {
        cargo build -p codex-cli --release
    } else {
        cargo build -p codex-cli
    }
    if ($LASTEXITCODE) { throw 'cargo build failed.' }
} finally {
    Pop-Location
}

$configuration = if ($Release) { 'release' } else { 'debug' }
New-Item -ItemType Directory -Force -Path (Join-Path $root 'dist') | Out-Null
Copy-Item (Join-Path $root "work/codex/target/$configuration/codex.exe") (Join-Path $root 'dist/codex.exe') -Force
Write-Host "dist/codex.exe updated ($configuration build)." -ForegroundColor DarkCyan
