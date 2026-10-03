#!/bin/bash
# Adds a marked block to ~/.bashrc that loads this repo's bash config.
# The rest of ~/.bashrc is left untouched; re-running is safe.

DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BASHRC="$HOME/.bashrc"
BEGIN_MARKER="# >>> moilolon/dotfiles >>>"
END_MARKER="# <<< moilolon/dotfiles <<<"

echo "🚀 Installing dotfiles..."

touch "$BASHRC"

if grep -qF "$BEGIN_MARKER" "$BASHRC"; then
    # Drop the previous block so the path is refreshed if the repo moved.
    sed -i "\|^$BEGIN_MARKER$|,\|^$END_MARKER$|d" "$BASHRC"
fi

cat << EOF >> "$BASHRC"
$BEGIN_MARKER
if [ -f "$DOTFILES_DIR/bash/bashrc" ]; then
    source "$DOTFILES_DIR/bash/bashrc"
fi
$END_MARKER
EOF

echo "✅ Loader added to ~/.bashrc"
echo "✨ Done! Restart Git Bash."
