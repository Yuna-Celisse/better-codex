# Development log

Dated decisions and gotchas. Newest first.

## 2026-10-11 — Pure-client restructure (v0.2)

- **Daemon-only guard placement**: the embedded-server refusal lives in
  `start_app_server` (tui/src/lib.rs) behind `#[cfg(not(test))]`. Rationale:
  production has five entry points (run_main, resume picker, archive command,
  reconnect, session queue); one chokepoint covers them all, while the 500+
  app tests that legitimately drive in-process servers keep working. The
  daemon-connection fallback arm (`LocalDaemon{allow_embedded_fallback:true}`
  -> embedded) is removed unconditionally; `daemon_startup_tests::
  daemon_startup_never_falls_back_to_embedded` locks that in.
- **Curated test set** (`scripts/test.ps1`): the full `codex-tui` suite has
  ~47 pre-existing failures on this fork — upstream snapshots were recorded
  with package version `0.0.0` while the workspace builds `0.162.0`, and the
  sidebar changes widths at >= 120 columns. CI and local runs use:
  `context_sidebar sidebar empty_state daemon_startup owned_transcript plan_mode`
  (verified: 0 failures; baseline drift lives under `startup/reconnect/resume`
  filters and is excluded on purpose).
- **Debug test stack**: transcript-search tests overflow the default test
  thread stack in debug builds; `RUST_MIN_STACK=33554432` is set by the test
  scripts.
- **Windows exe locking**: rebuilding while any `target/debug/codex.exe` is
  running fails with `os error 5`. Close the TUI before `scripts/build.ps1`.
- `--remote ws://…` remains supported (external server, not embedded).
- Compatibility-mismatch still surfaces as the generic daemon-required exit
  (the specific feature-mismatch reason is logged before the guard fires);
  improve if it ever bites.

## 2026-10-11 — Sidebar & checklist (v0.1)

- Breakpoint applies to the **terminal** width (`CONTEXT_SIDEBAR_MIN_WIDTH =
  120`), not the already-reduced chat area, so wrapping and cursor geometry
  agree. `history_wrap_width` is the single place that deducts the sidebar;
  `note_rendered_width` must therefore always receive the **full terminal
  width** (an early pass passed the reduced width and double-deducted:
  168 -> 136 -> 104).
- The welcome blossom stage centers horizontally inside the chat column
  (`render_first_screen` uses `available`, not `buffer.area`); vertical
  centering stays on the full screen.
- Plan data arrives as a complete checklist on every `update_plan` /
  `TurnPlanUpdated`; the sidebar stores the latest items
  (`transcript.last_plan`, cleared with `last_plan_progress` on thread switch).

## Baseline & environment facts

- Upstream pin: `rust-v0.162.0` @ `c1382380de69521303b416720a52f42d51af6248`,
  Apache-2.0 (`LICENSE`/`NOTICE` preserved).
- Official app-server daemon on this machine auto-updates independently
  (observed 0.162.1 while the client pins 0.162.0); the client attaches to
  the official binary's daemon, never its own.
- `~/.codex/config.toml` is shared with the official Codex desktop app. It
  once carried a stale `node_repl` MCP block (invalid `type` key + dead
  runtime path) producing two startup warnings; fixed 2026-10-11 (backup:
  `config.toml.bak-20261011`). Unknown-key warnings from official writes are
  expected noise, not fork bugs.
- The pre-restructure monorepo history (full codex workspace + sidebar work)
  is archived: local tag `archive/monorepo-2026-10-11` and remote branch
  `Yuna-Celisse/codex@better-codex`. The abandoned TypeScript/Ink prototype
  lives in `.legacy/ink-tui-2026-10-11` (git-excluded).
