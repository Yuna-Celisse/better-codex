# Architecture

## Process boundaries

Better Codex is one executable: a ratatui front-end that speaks the Codex
app-server JSON-RPC protocol to a server process it does not own.

```
+------------------------+        ~/.codex/app-server-control/
|  dist/codex.exe        |        app-server-control.sock
|  ┌──────────────────┐  |               |
|  │ TUI (this repo's |==|=== UDS ========+--> official codex.exe (app-server daemon)
|  │ overlay + upstream   |                |     ^
|  │ UI crates)       |  |                |     | auto-started by the client
|  └──────────────────┘  |                |     | from the official install
|  ┌──────────────────┐  |                |     +--> OpenAI cloud
|  │ embedded server  |  |   (release builds: unreachable; startup guard errors)
|  │ code (linked,    |  |
|  │ never launched)  |  |
|  └──────────────────┘  |
+------------------------+
```

- The client **discovers** the daemon socket at startup (`maybe_probe_default_daemon_socket`).
- If no daemon is running, the client asks the **official installed** Codex
  (`~/.codex/packages/app-server-daemon/current/bin/codex.exe`) to start one —
  never its own embedded copy.
- If neither works (not installed, restricted launcher, elevated session, or an
  incompatible server), the release build exits with instructions. The embedded
  in-process server exists only in `cfg(test)` builds, where the suite drives
  real app flows over it.

## Why the repo is an overlay

The TUI's compile-time dependency closure covers 90 of the 112 crates in the
codex workspace (protocol types, config, login, transport — and transitively
the server stack). A repository containing only `tui/` cannot compile. The
compromise is the overlay model:

- `tui/` mirrors `codex-rs/tui/` and holds **only files this fork changed**.
- `upstream.json` pins the exact tag and commit the overlay was written against.
- `scripts/assemble.ps1` materializes `work/codex/` (gitignored), resets it to
  the pinned commit, and copies the overlay on top. The build always starts
  from pristine upstream.

Upgrading = bump `upstream.json`, re-apply the overlay against the new tree
(three overlay files are whole upstream files that may conflict: `lib.rs`,
`startup_orchestration` consumers, `daemon_startup.rs`), run `scripts/test.ps1`.

## Protocol drift boundary

The app-server protocol is upstream-internal, not a stable API. Failure modes
when the official daemon outgrows the pinned client:

| Change | Effect on this client |
| --- | --- |
| New notification method | silently dropped (client tolerates parse failures) |
| New field in a payload the client reads | that notification dropped — feature degrades quietly |
| New enum variant in request/response data | that request errors visibly |
| Renamed/changed method | error with `METHOD_NOT_FOUND` |
| Incompatible daemon features at handshake | client exits with the daemon-required message |

The `Backend` line in the context sidebar records which server answered, so a
degraded session is at least diagnosable.
