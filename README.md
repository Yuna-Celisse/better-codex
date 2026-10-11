# Better Codex

A standalone terminal UI for OpenAI Codex: the official Rust TUI, rebuilt as a **pure client** with a live context sidebar, an opencode-style plan checklist, and a background server it never embeds.

> **v0.2:** daemon-only. The client refuses to run without the official Codex background server — no silent embedded fallback. Terminal width ≥ 120 columns reveals a right-hand panel (token usage, context window, working directory, connected backend version, live plan progress); everything else stays left of the divider.

中文：Better Codex 是 OpenAI Codex 原生 TUI 的个人定制版，采用与 AxonSSH 相同的架构：仓库里只有客户端代码，推理与执行由系统里已安装的官方 Codex 后台服务承担。官方 Codex 更新时本客户端自动受益、无需重建；协议不兼容时客户端会明确报错而不是降级。宽终端下右侧显示上下文侧栏（token 用量、上下文窗口、目录、后端版本、update_plan 进度清单），窄终端自动隐藏且不清空草稿。

## Quick start

Requires **Windows**, the **official Codex** installed (Codex Desktop or CLI — it provides the background app-server), and Rust **1.95+** with Visual Studio C++ Build Tools and Windows SDK.

```powershell
git clone https://github.com/Yuna-Celisse/better-codex.git
cd better-codex
.\scripts\build.ps1        # fetches pinned upstream into work/, applies tui/ overlay, builds dist/codex.exe
.\start.cmd                # launches the TUI against the official background server
```

```powershell
.\scripts\test.ps1         # curated overlay test set (see docs/development-log.md for why not the full suite)
.\scripts\build.ps1 -Release
```

## Implemented

- **Context sidebar** (≥ 120 columns): last-request tokens, context-window percentage, input/cached/output/reasoning counters, session totals, working directory; hides responsively without losing the composer draft.
- **Plan checklist** (opencode-style): live `update_plan` / `TurnPlanUpdated` progress — `✓` done, `●` in progress (accent), `○` pending, with an `N/M done` counter.
- **Backend line**: shows `daemon v<version>` or `remote v<version>` — visible proof the embedded server is not in use.
- **Daemon-only enforcement**: release builds exit with instructions when the official background server is unreachable (not running, blocked launcher, elevated session, or incompatible features).
- **Centered welcome blossom** and all chat surfaces inside the left column, never crossing the divider.

## Architecture and references

```
+------------------+   unix socket    +---------------------+   HTTPS   +----------+
|  better-codex    | <==============> |  official Codex     | <=======> |  OpenAI  |
|  (this repo:     |  app-server      |  app-server daemon  |           |  cloud   |
|   TUI overlay)   |  protocol        |  (installed elsewhere)          |          |
+------------------+                  +---------------------+           +----------+
```

This repository contains only the **overlay** (`tui/`, mirroring `codex-rs/tui/` paths), the assembly scripts, and docs. `scripts/assemble.ps1` clones the tag pinned in `upstream.json` into `work/codex/` and replaces the overlay files before every build. The compiled binary still links upstream's server crates (the TUI's dependency closure requires them to compile), but the embedded code path is unreachable in release builds by design.

Built on [openai/codex](https://github.com/openai/codex) (`rust-v0.162.0`, Apache-2.0). The sidebar checklist interaction follows [opencode](https://opencode.ai)'s todo panel. The client-only repository layout follows [AxonSSH](https://github.com/Yuna-Celisse/AxonSSH). No upstream UI source is copied beyond the pinned baseline that this project patches.

## License

Apache-2.0. `LICENSE` and `NOTICE` are preserved from OpenAI's codex; the `codex-rs/` sources fetched at build time remain under their original terms.
