# Shell scripts

Little shell scripts and helpers.

## Worktree picker

`wt.zsh` defines `wt`, an interactive Git worktree picker using `fzf`.
Requires Git, fzf, and zsh. Run `wt` inside a Git repository.

- Enter: change to the selected worktree
- Ctrl-D: delete the selected worktree after confirmation
- Ctrl-X: force-delete the selected worktree after confirmation
- Ctrl-R: reload the list

Load it from `~/.zshrc`:

```zsh
[[ ! -r "$HOME/Workspace/shell-scripts/wt.zsh" ]] || source "$HOME/Workspace/shell-scripts/wt.zsh"
```

Add more helpers here and source them from `~/.zshrc` as needed.
