#!/bin/bash
# Removes the block install.sh added to ~/.bashrc; nothing else is touched.

BASHRC="$HOME/.bashrc"
BEGIN_MARKER="# >>> moilolon/dotfiles >>>"
END_MARKER="# <<< moilolon/dotfiles <<<"

if [ -f "$BASHRC" ] && grep -qF "$BEGIN_MARKER" "$BASHRC"; then
    sed -i "\|^$BEGIN_MARKER$|,\|^$END_MARKER$|d" "$BASHRC"
    echo "🗑️  Loader removed from ~/.bashrc"
else
    echo "ℹ️  No loader found in ~/.bashrc"
fi

echo "✅ Uninstalled. Restart Git Bash."
