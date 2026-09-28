# Source this file from zsh so wt can change the current directory.
wt() {
  local selected

  selected=$(
    git worktree list |
    fzf \
      --height=60% \
      --layout=reverse \
      --border \
      --prompt='worktree> ' \
      --header='enter: cd   ctrl-d: delete   ctrl-x: force delete   ctrl-r: reload' \
      --preview='git -C {1} status --short --branch' \
      --preview-window='right:50%' \
      --bind='ctrl-d:execute(
        printf "Delete %s? [y/N] " {1};
        read ans;
        [ "$ans" = y ] && git worktree remove {1}
      )+reload(git worktree list)' \
      --bind='ctrl-x:execute(
        printf "FORCE delete %s? [y/N] " {1};
        read ans;
        [ "$ans" = y ] && git worktree remove --force {1}
      )+reload(git worktree list)' \
      --bind='ctrl-r:reload(git worktree list)'
  )

  [[ -n "$selected" ]] || return
  cd "$(awk '{print $1}' <<< "$selected")"
}
