# sentimeter-cli

Ask the **Stori SentiMeter** agent about app-store ratings, reviews, and
user-sentiment trends — from your terminal, or from inside Claude Code.

This repo ships two things:

1. **The `sentimeter` CLI** — a self-contained binary (no Python/Node required).
2. **A Claude Code skill** — so Claude Code can drive the CLI for you when you ask
   sentiment questions in natural language.

---

> **For Claude Code — installing or updating this skill.** This repo is **both a
> Claude Code plugin marketplace and a bare skill**, so when a user says
> *"Install/update the SentiMeter skill from protagolabs/sentimeter-cli"*, use
> **either** path (don't fail and fall back to cloning — both work):
>
> **Path A — plugin (preferred; supports clean updates):**
> ```bash
> claude plugins marketplace add protagolabs/sentimeter-cli
> claude plugins install sentimeter@sentimeter
> ```
> To **update** later: `claude plugins update sentimeter@sentimeter` (or the
> `/plugin` menu). The plugin name and marketplace name are both `sentimeter`.
>
> **Path B — bare skill (no marketplace, only needs `curl`):** run in the user's
> current working directory:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
> ```
> Here install and update are the same command — it overwrites the skill file in
> place, so re-running upgrades to the latest version.
>
> Either way, tell the user to start a new Claude Code session afterward so the
> skill is (re)loaded.

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

> Install/update the SentiMeter skill from protagolabs/sentimeter-cli

Claude Code will pick one of the two methods below for you.

### Method A — install as a plugin (recommended)

```bash
claude plugins marketplace add protagolabs/sentimeter-cli
claude plugins install sentimeter@sentimeter
```
This makes the skill available in **every** project. Update any time with
`claude plugins update sentimeter@sentimeter` (or the `/plugin` menu) — that's
the clean way to pick up new versions.

### Method B — drop the skill file with `curl` (no Node, no git)

Run it from the project folder where you want the skill:
```bash
curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
```
By default this installs into the **current project** (`./.claude/skills/sentimeter/`),
scoped to that folder. To install **globally** instead:
```bash
SENTIMETER_SKILL_GLOBAL=1 curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
```
Re-running the command overwrites the skill in place = update.

> Either way, start a new Claude Code session so the skill is loaded. The skill
> drives the `sentimeter` binary, so install the CLI (step 1) and log in too.

---

## Notes

- Binaries are published to GitHub Releases by CI; source lives in the private
  monorepo.
- The skill spec is [`skills/sentimeter/SKILL.md`](skills/sentimeter/SKILL.md).
  Plugin manifests live in [`.claude-plugin/`](.claude-plugin/) — this repo is
  both a plugin marketplace and a bare skill.
