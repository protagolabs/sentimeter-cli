# sentimeter-cli

Ask the **Stori SentiMeter** agent about app-store ratings, reviews, and
user-sentiment trends — from your terminal, or from inside Claude Code.

This repo ships two things:

1. **The `sentimeter` CLI** — a self-contained binary (no Python/Node required).
2. **A Claude Code skill** — so Claude Code can drive the CLI for you when you ask
   sentiment questions in natural language.

---

> **For Claude Code — installing or updating this skill.** When a user says
> *"Install/update the SentiMeter skill from protagolabs/sentimeter-cli"*, run
> this in the user's current working directory:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
> ```
> **Install and update are the same command** — it overwrites the skill file in
> place, so re-running it upgrades to the latest version. Prefer this `curl` path
> (no dependencies) over `npx add-skill` (which needs Node). Tell the user to
> start a new Claude Code session afterward so the skill is (re)loaded.

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

Claude Code will run the installer below for you. **Updating is the same command
as installing** — it overwrites the skill in place, so re-run it any time to get
the latest version (then start a new session).

**Or run it yourself (only needs `curl` — no Node, no git).** Run it from the
project folder where you want the skill:
```bash
curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
```
By default this installs into the **current project** (`./.claude/skills/sentimeter/`),
so the skill is scoped to that folder — run Claude Code from there and it's
auto-discovered on the next session. To install **globally** for every project
instead:
```bash
SENTIMETER_SKILL_GLOBAL=1 curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
```

**If you already have Node** (uses the [agentskills.io](https://agentskills.io)
standard):
```bash
npx add-skill protagolabs/sentimeter-cli
```

> The skill drives the `sentimeter` binary, so install the CLI (step 1) and log
> in for it to work.

---

## Notes

- Binaries are published to GitHub Releases by CI; source lives in the private
  monorepo.
- The skill spec is [`SKILL.md`](SKILL.md) at the repo root.
