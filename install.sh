#!/usr/bin/env bash
# SentiMeter CLI installer (macOS / Linux).
#
#   curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install.sh | bash
#
# Detects OS + arch, downloads the matching prebuilt binary from the latest
# GitHub Release of the public releases repo, and installs it onto your PATH.
# No Python required.
#
# Env overrides:
#   SENTIMETER_VERSION      tag to install (default: latest)
#   SENTIMETER_INSTALL_DIR  target dir (default: /usr/local/bin, else ~/.local/bin)
set -euo pipefail

# Public releases repo (binaries live here, NOT the private source monorepo).
REPO="protagolabs/sentimeter-cli"
VERSION="${SENTIMETER_VERSION:-latest}"

err() { echo "error: $*" >&2; exit 1; }

os="$(uname -s)"
arch="$(uname -m)"
case "$os" in
  Darwin)
    case "$arch" in
      arm64)          asset="sentimeter-macos-arm64" ;;
      x86_64)         asset="sentimeter-macos-x86_64" ;;
      *)              err "unsupported macOS arch: $arch" ;;
    esac ;;
  Linux)
    case "$arch" in
      x86_64|amd64)   asset="sentimeter-linux-x86_64" ;;
      *)              err "unsupported Linux arch: $arch (only x86_64 is published)" ;;
    esac ;;
  *) err "unsupported OS: $os (use install.ps1 on Windows)" ;;
esac

if [ "$VERSION" = "latest" ]; then
  url="https://github.com/$REPO/releases/latest/download/$asset"
else
  url="https://github.com/$REPO/releases/download/$VERSION/$asset"
fi

# Pick an install dir we can write to without sudo when possible.
if [ -n "${SENTIMETER_INSTALL_DIR:-}" ]; then
  bindir="$SENTIMETER_INSTALL_DIR"
elif [ -w "/usr/local/bin" ]; then
  bindir="/usr/local/bin"
else
  bindir="$HOME/.local/bin"
fi
mkdir -p "$bindir"

tmp="$(mktemp)"
echo "Downloading $asset ($VERSION)…"
curl -fSL --progress-bar "$url" -o "$tmp" || err "download failed: $url"
chmod +x "$tmp"
mv "$tmp" "$bindir/sentimeter"

echo "Installed sentimeter -> $bindir/sentimeter"

# Make sure the install dir is on PATH for future shells. If it isn't, append an
# export line to the right shell rc file (idempotently) so `sentimeter` just
# works next time the user opens a terminal — no manual step required.
persist_path() {
  local dir="$1"
  case ":$PATH:" in
    *":$dir:"*) return 0 ;;   # already on PATH, nothing to do
  esac

  local shell_name rc line
  shell_name="$(basename "${SHELL:-}")"
  case "$shell_name" in
    zsh)  rc="${ZDOTDIR:-$HOME}/.zshrc"; line="export PATH=\"$dir:\$PATH\"" ;;
    bash)
      if [ -f "$HOME/.bashrc" ]; then rc="$HOME/.bashrc"; else rc="$HOME/.bash_profile"; fi
      line="export PATH=\"$dir:\$PATH\"" ;;
    fish)
      rc="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
      mkdir -p "$(dirname "$rc")"
      line="fish_add_path $dir" ;;   # fish doesn't understand `export PATH=...`
    *)    rc="$HOME/.profile"; line="export PATH=\"$dir:\$PATH\"" ;;
  esac

  if [ -f "$rc" ] && grep -Fq "$dir" "$rc"; then
    :   # already referenced in the rc file, don't duplicate
  else
    printf '\n# Added by SentiMeter CLI installer\n%s\n' "$line" >> "$rc"
    echo "Added $dir to your PATH in $rc"
  fi
  echo "To use sentimeter in THIS shell right now, run:  source $rc"
}
persist_path "$bindir"

echo "Run: sentimeter login"
