# Launch the Better Codex TUI. This build only speaks to the official Codex
# background server; if it is unavailable the client exits with instructions.
#Requires -Version 5.1
# Do not declare a CodexArgs parameter: PowerShell would bind CLI's -c/-C to
# that parameter and drop the flag. Unbound $args preserves every CLI flag.
$ErrorActionPreference = 'Stop'
$CodexArgs = @($args)
$root = Split-Path -Parent $PSScriptRoot
# An owned transcript keeps the sidebar fixed while chat history scrolls.
$CodexArgs = @('-c', 'tui.fullscreen_transcript=true') + $CodexArgs
$binary = Join-Path $root 'dist/codex.exe'
if (-not (Test-Path -LiteralPath $binary)) {
    throw 'dist/codex.exe not found. Run scripts/build.ps1 first.'
}
& $binary @CodexArgs
exit $LASTEXITCODE
