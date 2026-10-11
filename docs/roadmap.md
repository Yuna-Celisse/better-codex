# Roadmap

## 0.1 — Context sidebar (shipped)

- Right-hand panel at >= 120 columns: token usage, context window, session
  totals, working directory; responsive hide below the breakpoint without
  losing the composer draft.
- Welcome blossom and every chat surface constrained to the left column.
- Fixed a double width deduction in `note_rendered_width` introduced by the
  first sidebar pass.

## 0.2 — Pure client (shipped)

- opencode-style plan checklist (`✓/●/○`, `N/M done`) fed by `update_plan`
  and `TurnPlanUpdated`.
- Daemon-only: release builds refuse the embedded server; discovery, official
  auto-start, and explicit failure messaging.
- `Backend` line showing the connected server version.
- Repository restructured as an overlay-only client repo (AxonSSH pattern);
  monorepo history archived on the `codex` fork's `better-codex` branch.

## 0.3 — Candidates

- Sidebar: per-turn cost estimate, model/provider badge, MCP server health.
- Plan checklist: collapse completed items when the plan exceeds the panel.
- CI: release build artifacts + signed Windows installer.
- Upgrade drill: scripted bump of `upstream.json` + overlay conflict report.
