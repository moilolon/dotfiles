# dotfiles

Custom prompt for **Git Bash** on Windows: a two-line, powerline-style prompt with
time, user@host, current folder and git branch.

```
.
├── install.sh      # Adds the loader block to ~/.bashrc
├── uninstall.sh    # Removes that block
└── bash/
    ├── bashrc      # Loader
    └── prompt.sh   # The prompt
```

## Requirements

- **Git Bash** (Git for Windows).
- A **[Nerd Font](https://www.nerdfonts.com/)** in the terminal (e.g. *JetBrainsMono NF*).
  Without one, export `USE_NERD_FONTS=false` before the loader block for plain icons.

## Install

```bash
git clone https://github.com/moilolon/dotfiles.git
cd dotfiles
bash install.sh
```

`install.sh` appends a block between `# >>> moilolon/dotfiles >>>` markers to
`~/.bashrc`. Anything else in that file is kept. Re-running it refreshes the block
(e.g. after moving the clone).

## Uninstall

```bash
bash uninstall.sh
```

Removes only the marked block from `~/.bashrc`.
