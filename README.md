# Poly for Codex

The official Codex plugin for [Poly](https://poly.app). It gives Codex access to your Poly files and automatically loads your Poly memory context at the start of every session.

## What the plugin adds

- **Automatic memory context** — a `SessionStart` hook runs `poly memory summary`, so Codex starts with your profile and recent Poly memories already in context.
- **The Poly agent skill** — guidance for searching, reading, creating, updating, and organizing files with the local Poly CLI or hosted MCP server.
- **Poly MCP** — a hosted MCP connection for working with Poly files from Codex.

The hook is a dependency-free Bash script. It does not require Node.js, Python, or `jq`.

## Requirements

The memory hook requires the Poly desktop app to be installed, open, and signed in. Install the CLI from **Poly → Downloads → Install CLI** before installing the plugin.

If Poly is unavailable, Codex still starts normally. The plugin shows a visible notice and tells Codex not to interpret the missing context as an empty memory. Start Poly and begin a new task to retry the hook.

## Install

```bash
codex plugin marketplace add withpoly/polycodex
codex plugin add poly@poly
```

On the next Codex session, open `/hooks`, review the Poly SessionStart hook, and trust it. Start another task after trusting it so the hook can load your memory context.

The MCP server authenticates with your Poly account through OAuth the first time Codex uses it.

## How it works

At session startup, resume, clear, and context compaction:

1. Codex runs `hooks/session-start.sh` from the installed plugin.
2. The hook requests `poly memory summary` from the locally running Poly app.
3. It wraps the result in `<poly-memory-context>` and returns it as SessionStart `additionalContext`.
4. Codex displays `Poly · memory context loaded`.

The skill does not request the summary again. It loads only when Codex needs to work with Poly files or search memory in more detail.

## Use Poly with Codex

Ask naturally:

```text
What was I focused on last week?

Find the product brief in Poly and summarize the open questions.

Move every approved launch asset into the shared Marketing drive.
```

See the [Poly + Codex guide](https://docs.poly.app/integrations/codex) for more.
