# sentimeter-cli

Ask the **Stori SentiMeter** agent about app-store ratings, reviews, and
user-sentiment trends — from your terminal, or from inside Claude Code.

## 🚀 Quickest start: just say this to Claude Code

> **Install the SentiMeter skill from https://github.com/protagolabs/sentimeter-cli into this folder**

That's it. This installs the skill **only for the current folder**
(`./.claude/skills/sentimeter/`) — so first `cd` into the project where you want
SentiMeter, then say it. Claude Code installs the skill, and the next time you
ask a sentiment question it sets up the rest for you (installs the `sentimeter`
CLI if needed and walks you through a one-click Google login). Then just ask,
e.g.:

> *"Why did Stori's App Store rating drop last week?"*

Start a new Claude Code session **in that same folder** afterward so the skill
loads. Want SentiMeter available in **every** project instead? Use the global
plugin install in [Install / update the skill](#2-install--update-the-claude-code-skill) below.

---

This repo ships two things:

1. **The `sentimeter` CLI** — a self-contained binary (no Python/Node required).
2. **A Claude Code skill** — so Claude Code can drive the CLI for you when you ask
   sentiment questions in natural language.

---

> **For Claude Code — installing or updating this skill.** The user will point you
> here by URL, e.g. *"Install the SentiMeter skill from
> https://github.com/protagolabs/sentimeter-cli into this folder"* — read this
> README and follow it. This repo is **both a Claude Code plugin marketplace and a
> bare skill**; pick the path by the scope the user asked for (don't fail and fall
> back to blindly cloning — both paths below work):
>
> **Default — current folder only.** When the user says *"…into this folder"* or
> doesn't mention scope, install the **bare skill into their current working
> directory** (scoped to that folder, `./.claude/skills/sentimeter/`):
> ```bash
> curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
> ```
> Install and update are the same command — it overwrites the skill file in
> place, so re-running upgrades to the latest version.
>
> **Only if the user wants it in _every_ project — install globally as a plugin:**
> ```bash
> claude plugins marketplace add protagolabs/sentimeter-cli
> claude plugins install sentimeter@sentimeter
> ```
> Update later with `claude plugins update sentimeter@sentimeter` (or the
> `/plugin` menu). Plugin name and marketplace name are both `sentimeter`.
> (For a global, no-`claude`-CLI alternative, the curl command also accepts
> `SENTIMETER_SKILL_GLOBAL=1`.)
>
> Either way, tell the user to start a new Claude Code session afterward (in the
> same folder, for a folder-scoped install) so the skill is (re)loaded.

---

## 1. Install the CLI

macOS / Linux:
```bash
curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install.sh | bash
```
Windows (PowerShell):
```powershell
irm https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install.ps1 | iex
```

Then log in once (24h Google login, whitelisted accounts only):
```bash
sentimeter login
sentimeter ask "Why did Stori's rating drop last week?"
```

See the full guide for usage, `--lang`, `--json`, troubleshooting, etc.

---

## 2. Install / update the Claude Code skill

The skill lets you ask Claude Code questions in plain language (e.g. *"What are
Stori users complaining about this week?"*) and have it run the CLI for you.

**Easiest — just tell Claude Code (works for both install and update):**

> Install the SentiMeter skill from https://github.com/protagolabs/sentimeter-cli into this folder

Claude Code will pick the right method below based on the scope you ask for.

### Method A — current folder only (default)

Run it from the project folder where you want the skill:
```bash
curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
```
This installs into the **current project only** (`./.claude/skills/sentimeter/`),
so it's scoped to that folder — run Claude Code from here to use it. Re-running
the command overwrites the skill in place = update. Needs only `curl` (no Node,
no git).

### Method B — every project (global plugin)

Only if you want SentiMeter available everywhere:
```bash
claude plugins marketplace add protagolabs/sentimeter-cli
claude plugins install sentimeter@sentimeter
```
Update any time with `claude plugins update sentimeter@sentimeter` (or the
`/plugin` menu). (No `claude` CLI? `SENTIMETER_SKILL_GLOBAL=1` on the Method A
curl command installs globally too.)

> Either way, start a new Claude Code session (in the same folder, for a
> folder-scoped install) so the skill is loaded. The skill drives the
> `sentimeter` binary, so install the CLI (step 1) and log in too.

---

## Notes

- Binaries are published to GitHub Releases by CI; source lives in the private
  monorepo.
- The skill spec is [`skills/sentimeter/SKILL.md`](skills/sentimeter/SKILL.md).
  Plugin manifests live in [`.claude-plugin/`](.claude-plugin/) — this repo is
  both a plugin marketplace and a bare skill.
