# Shell scripts

Little shell scripts and helpers.

## Workspace picker

Run `ws` to select a directory directly under `~/Workspace` with `fzf` and change
into it. Press Enter to select, or Escape to cancel. Requires fzf and zsh.

## Worktree picker

`init.zsh` defines `wt`, an interactive Git worktree picker using `fzf`.
Requires Git, fzf, and zsh. Run `wt` inside a Git repository.
Rows show the branch first, followed by the worktree path and commit.

- Enter: change to the selected worktree
- Ctrl-A: create a worktree in `~/Workspace/worktrees/<repo>/<branch>` using an existing local branch or a new branch from HEAD (blank cancels)
- Ctrl-D: delete the selected worktree after confirmation
- Ctrl-X: force-delete the selected worktree after confirmation
- Ctrl-R: reload the list

## Branch picker

Run `br` inside a Git repository to select a local or remote branch with `fzf`
and switch to it in the current worktree. Selecting a remote branch creates a
local branch that tracks it. Requires Git, fzf, and zsh.

- Enter: switch to the selected branch
- Ctrl-A: create a branch from HEAD and switch to it (blank cancels)
- Ctrl-R: reload the list
- Escape: cancel

The preview shows recent commits. Git checks for uncommitted changes and branches
already checked out in another worktree before switching.

Load it from `~/.zshrc`:

```zsh
[[ ! -r "$HOME/Workspace/shell-scripts/init.zsh" ]] || source "$HOME/Workspace/shell-scripts/init.zsh"
```

Add more helpers through `init.zsh` so `~/.zshrc` only needs this one entrypoint.
