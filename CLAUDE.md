# dotfiles — Project Memory

A two-line prompt for Git Bash on Windows, installed as one marked block in `~/.bashrc` by
`install.sh`.

`README.md` is the cover for visitors, laid out like every moilolon repo: *What this is*, *How
it works*, *Getting started* and the shared footer, with no folder tree, long code or roadmap.
The details below are for Claude.

## Structure

- `install.sh` / `uninstall.sh` add and remove the block between `# >>> moilolon/dotfiles >>>`
  and `# <<< moilolon/dotfiles <<<` in `~/.bashrc`; both are idempotent.
- `bash/bashrc` is the loader (guards against double loading); `bash/prompt.sh` is the prompt:
  icons (`DIR_ICON`, `USER_ICON`, `PROMPT_SYMBOL`, `GIT_ICON`, `ARROW`), colours (`BG_*`,
  `ARR*`, 256-colour palette) and the layout in `build_ps1()`.
- `assets/draw-images.ps1` (`powershell -NoProfile -File assets/draw-images.ps1`) draws, from
  shapes, the README cover (`cover.png`), the icon (`icon.png`, also the project's icon in
  Orca) and the GitHub social preview (`social-preview.png`, uploaded by hand in Settings) in the colours of `bash/prompt.sh`;
  redraw it when the prompt changes.
- `test/install.sh` (`bash test/install.sh`) installs, loads and uninstalls the prompt in a
  throwaway `HOME` and checks each step. `.github/workflows/checks.yml` (job `checks`) runs it
  with ShellCheck on every pull request, on `windows-latest` with Git Bash, the shell the prompt
  is for. A new script goes into its ShellCheck line.

## Git

- **Commits:** English, imperative, sentence case, one line of at most 72 characters with no
  prefix and no trailing period (`Restore the Nerd Font git branch icon`). A body only when the
  why is not obvious: a blank line, then lines wrapped at 72. No `Co-Authored-By` or other
  attribution.
- **Branches:** `<type>/<short-description>`, lowercase kebab-case, off `main`. Types: `feature`,
  `bugfix`, `docs`, `style`, `refactor`, `chore`.
- **Pull requests:** title like a commit; body with *What changes*, *Why* and *How to check it*;
  assigned to `moilolon` (the labeler workflow does it if missing, and Dependabot's come assigned).
  Merged by squash, with the PR title and body as the commit.
- **`gh`:** always as `GH_TOKEN=$(gh auth token --user moilolon) gh …`, command by command. gh's
  active account is the work one, which must not act on this repo; do not switch it. `git`
  already uses `moilolon` through the `includeIf` of `C:/Developer/PERSONAL/`.
