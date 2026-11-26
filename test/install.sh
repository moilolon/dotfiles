#!/bin/bash
# Installs and uninstalls the prompt into a throwaway HOME, as Git Bash would load it, and checks
# what the README promises: one marked block however many times install.sh runs, the rest of
# ~/.bashrc untouched, the prompt built (with its git segment only inside a repo) and nothing
# left after uninstall.sh. Run from anywhere: bash test/install.sh
set -u

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BEGIN_MARKER="# >>> moilolon/dotfiles >>>"
FAILED=0

check() { # check <description> <command...>
    local what=$1
    shift
    if "$@"; then echo "ok   $what"; else echo "FAIL $what"; FAILED=1; fi
}
# shellcheck disable=SC2329 # called through check
lacks() { ! grep -qF "$1" <<< "$2"; }
blocks() { grep -cF "$BEGIN_MARKER" "$HOME/.bashrc"; }
# The PS1 an interactive shell gets in a folder: ~/.bashrc loaded, PROMPT_COMMAND run once.
ps1_in() { (cd "$1" && bash -i -c 'eval "$PROMPT_COMMAND"; printf %s "$PS1"' 2>/dev/null); }

# A shell that already has the prompt loaded would skip it (DOTFILES_LOADED)
unset DOTFILES_LOADED
HOME=$(mktemp -d)
export HOME
OUTSIDE=$(mktemp -d)
trap 'rm -rf "$HOME" "$OUTSIDE"' EXIT

# No ~/.bashrc yet
bash "$REPO/install.sh" >/dev/null
check "install.sh creates ~/.bashrc with the block" test "$(blocks)" = 1
bash "$REPO/uninstall.sh" >/dev/null

# A ~/.bashrc of its own
printf 'export KEEP_ME=1\nalias ll="ls -l"\n' > "$HOME/.bashrc"
cp "$HOME/.bashrc" "$OUTSIDE/before"
bash "$REPO/install.sh" >/dev/null
bash "$REPO/install.sh" >/dev/null
check "installing twice leaves one block" test "$(blocks)" = 1
check "the block loads this checkout" grep -qF "$REPO/bash/bashrc" "$HOME/.bashrc"
check "the rest of ~/.bashrc is kept" grep -qxF 'export KEEP_ME=1' "$HOME/.bashrc"

inside=$(ps1_in "$REPO")
outside=$(ps1_in "$OUTSIDE")
check "an interactive shell gets the prompt" grep -qF '└─' <<< "$inside"
check "inside a repo the prompt has the git segment" grep -qF '48;5;110' <<< "$inside"
check "outside a repo it does not" lacks '48;5;110' "$outside"

bash "$REPO/uninstall.sh" >/dev/null
check "uninstall.sh removes the block" test "$(blocks)" = 0
check "and leaves ~/.bashrc as it was" cmp -s "$HOME/.bashrc" "$OUTSIDE/before"
bash "$REPO/uninstall.sh" >/dev/null
check "uninstalling again changes nothing" cmp -s "$HOME/.bashrc" "$OUTSIDE/before"

exit $FAILED
