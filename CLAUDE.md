# dotfiles — Project Memory

A two-line prompt for Git Bash on Windows, installed as one marked block in `~/.bashrc` by
`install.sh`. What each file does is in `README.md`.

## Git

- **Commits:** English, imperative, sentence case, one line of at most 72 characters with no
  prefix and no trailing period (`Restore the Nerd Font git branch icon`). A body only when the
  why is not obvious: a blank line, then lines wrapped at 72. No `Co-Authored-By` or other
  attribution.
- **Branches:** `<type>/<short-description>`, lowercase kebab-case, off `main`. Types: `feature`,
  `bugfix`, `docs`, `style`, `refactor`, `chore`.
- **Pull requests:** title like a commit; body with *What changes*, *Why* and *How to check it*.
  Merged by squash, with the PR title and body as the commit.
