#!/usr/bin/env bash

# Exit immediately if not on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script is only for macOS." >&2
    exit 1
fi

set -euo pipefail
echo "Script executed on: $(date) | Ran by: $(whoami) | Script location: $0 | Working dir: $(pwd)" >> $HOME/.dotfiles/logs/rebuild-app-aliases.sh.log

DEST="$HOME/Apps"

SRC_SYS="/Applications"
SRC_USER="$HOME/Applications"
SRC_SYSTEM="/System/Applications"

EXCLUDE_UTILS_SYS="/Applications/Utilities"
EXCLUDE_UTILS_SYSTEM="/System/Applications/Utilities"

mkdir -p "$DEST"

STAGING="$(mktemp -d "${DEST}.staging.XXXXXX")"
SEEN_FILE="$(mktemp)"
trap 'rm -rf "$STAGING" "$SEEN_FILE"' EXIT

mark_seen() { echo "$1" >> "$SEEN_FILE"; }
is_seen() { /usr/bin/grep -Fxq "$1" "$SEEN_FILE"; }

should_skip_name() {
  # Skip anything with "uninstall" in the displayed .app name (case-insensitive)
  echo "$1" | /usr/bin/grep -Eiq 'uninstall'
}

link_app() {
  local app_path="$1"
  local name
  name="$(basename "$app_path")"

  if should_skip_name "$name"; then
    return 0
  fi

  # Create symlink named exactly like the .app bundle (keeps Dock behavior familiar)
  /bin/ln -s "$app_path" "$STAGING/$name"
}

# Find apps without descending into bundles; allow 1 subfolder deep (maxdepth 2)
# Also prune Utilities folders.
find_apps() {
  local base="$1"
  local maxdepth="$2"

  /usr/bin/find "$base" -maxdepth "$maxdepth" \
    \( -path "$EXCLUDE_UTILS_SYS" -o -path "$EXCLUDE_UTILS_SYS/*" \
       -o -path "$EXCLUDE_UTILS_SYSTEM" -o -path "$EXCLUDE_UTILS_SYSTEM/*" \) -prune -o \
    -type d -name "*.app" -print -prune 2>/dev/null
}

# Order matters for "wins" in dedupe:
# 1) /Applications (wins)
# 2) /System/Applications
# 3) ~/Applications

# Pass 1: /Applications
while IFS= read -r app; do
  name="$(basename "$app")"
  mark_seen "$name"
  link_app "$app"
done < <(find_apps "$SRC_SYS" 2)

# Pass 2: /System/Applications (only if not already seen)
if [ -d "$SRC_SYSTEM" ]; then
  while IFS= read -r app; do
    name="$(basename "$app")"
    if ! is_seen "$name"; then
      mark_seen "$name"
      link_app "$app"
    fi
  done < <(find_apps "$SRC_SYSTEM" 2)
fi

# Pass 3: ~/Applications (only if not already seen)
if [ -d "$SRC_USER" ]; then
  while IFS= read -r app; do
    name="$(basename "$app")"
    if ! is_seen "$name"; then
      mark_seen "$name"
      link_app "$app"
    fi
  done < <(find_apps "$SRC_USER" 2)
fi

# Atomically swap into place
OLD="${DEST}​"
rm -rf "$OLD"
if [ -d "$DEST" ]; then
  mv "$DEST" "$OLD"
fi
mv "$STAGING" "$DEST"
rm -rf "$OLD"

echo "Symlinks rebuilt at $(date): $DEST"
