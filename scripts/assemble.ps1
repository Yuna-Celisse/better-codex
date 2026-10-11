# Assemble the pinned upstream Codex checkout and apply the local TUI overlay.
# Shared by build.ps1 and test.ps1; safe to re-run (idempotent reset + copy).
#Requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$pin = Get-Content (Join-Path $root 'upstream.json') -Raw | ConvertFrom-Json
$work = Join-Path $root 'work/codex'
$overlay = Join-Path $root 'tui'

if (-not (Test-Path (Join-Path $work '.git'))) {
    New-Item -ItemType Directory -Force -Path (Split-Path $work) | Out-Null
    git clone --depth 1 --branch $pin.tag $pin.repository $work
    if ($LASTEXITCODE) { throw "Could not clone $($pin.repository) at $($pin.tag)." }
} else {
    git -C $work fetch --depth 1 origin tag $pin.tag
}
git -C $work checkout --force $pin.commit
if ($LASTEXITCODE) { throw "Could not check out pinned commit $($pin.commit)." }
$head = (git -C $work rev-parse HEAD | Out-String).Trim()
if ($head -ne $pin.commit) { throw "work/codex is at $head, but upstream.json pins $($pin.commit)." }

# Drop any overlay leftovers from previous builds, then apply the current files.
git -C $work clean -fdq -- codex-rs/tui
Get-ChildItem -Recurse -File $overlay | ForEach-Object {
    $relative = $_.FullName.Substring($overlay.Length + 1)
    $destination = Join-Path (Join-Path $work 'codex-rs/tui') $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $destination) | Out-Null
    Copy-Item $_.FullName $destination -Force
}
Write-Host "Assembled $($pin.tag) ($($pin.commit.Substring(0, 7))) with $(@(Get-ChildItem -Recurse -File $overlay).Count) overlay files."
