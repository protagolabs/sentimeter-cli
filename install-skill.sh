#!/usr/bin/env bash
# SentiMeter Claude Code skill installer (macOS / Linux).
#
#   curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install-skill.sh | bash
#
# By default, drops the SentiMeter SKILL.md into the CURRENT PROJECT's skills
# directory (./.claude/skills/sentimeter/) so the skill is scoped to this folder.
# No Node, npm, or git required — just curl. Claude Code auto-discovers it when
# you run Claude Code in this directory (next session).
#
# Override the target:
#   CLAUDE_SKILLS_DIR=/path/to/.claude/skills   install into a specific dir
#   SENTIMETER_SKILL_GLOBAL=1                    install globally (~/.claude/skills)
#
# This installs the *skill* (so Claude Code can drive the CLI for you). It does
# NOT install the `sentimeter` binary itself — for that, run install.sh.
set -euo pipefail

REPO="protagolabs/sentimeter-cli"
BRANCH="${SENTIMETER_SKILL_BRANCH:-main}"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}/skills/sentimeter/SKILL.md"

# Default: project-local (current dir). Opt into global with SENTIMETER_SKILL_GLOBAL=1.
if [ -n "${CLAUDE_SKILLS_DIR:-}" ]; then
  SKILLS_ROOT="$CLAUDE_SKILLS_DIR"
elif [ "${SENTIMETER_SKILL_GLOBAL:-0}" = "1" ]; then
  SKILLS_ROOT="$HOME/.claude/skills"
else
  SKILLS_ROOT="$(pwd)/.claude/skills"
fi
DEST_DIR="$SKILLS_ROOT/sentimeter"

err() { echo "error: $*" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || err "curl is required but not found."

mkdir -p "$DEST_DIR"
curl -fsSL "$RAW" -o "$DEST_DIR/SKILL.md" \
  || err "Could not download SKILL.md from $RAW"

echo "✓ Installed SentiMeter skill to $DEST_DIR/SKILL.md"
echo
echo "Next:"
echo "  • This skill is scoped to this folder. Run Claude Code from here"
echo "    ($(pwd)) — start a new session so it picks up the skill."
echo "    (To install globally instead, re-run with SENTIMETER_SKILL_GLOBAL=1.)"
echo "  • Make sure the 'sentimeter' CLI is installed and you're logged in:"
echo "      curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh | bash"
echo "      sentimeter login"
echo "  • Then just ask Claude things like: \"Why did Stori's rating drop last week?\""
