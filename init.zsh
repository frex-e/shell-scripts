# Source this entrypoint from zsh to load personal shell helpers.
ws() {
  local selected
  local -a directories=( "$HOME"/Workspace/*(N-/) )

  if (( ${#directories} == 0 )); then
    print -u2 'No directories found in ~/Workspace.'
    return 1
  fi

  selected=$(
    printf '%s\0' "${directories[@]}" |
    fzf \
      --read0 \
      --height=60% \
      --layout=reverse \
      --border \
      --prompt='workspace> ' \
      --header='enter: cd'
  ) || return

  [[ -n "$selected" ]] || return
  cd -- "$selected"
}

wt() {
  local selected

  selected=$(
    git worktree list |
    fzf \
      --with-nth='{3..}  {1}  {2}' \
      --height=60% \
      --layout=reverse \
      --border \
      --prompt='worktree> ' \
      --header='enter: cd   ctrl-a: create   ctrl-d: delete   ctrl-x: force delete   ctrl-r: reload' \
      --preview='git -C {1} status --short --branch' \
      --preview-window='right:50%' \
      --bind='ctrl-a:execute(
        printf "Branch for new worktree (blank to cancel): ";
        IFS= read -r branch;
        if [ -n "$branch" ]; then
          if git check-ref-format --branch "$branch" >/dev/null 2>&1 &&
             common_dir=$(git rev-parse --path-format=absolute --git-common-dir); then
            repo=${common_dir##*/};
            if [ "$repo" = .git ]; then
              repo_dir=${common_dir%/*};
              repo=${repo_dir##*/};
            fi;
            repo=${repo%.git};
            destination="$HOME/Workspace/worktrees/$repo/$branch";
            if mkdir -p "${destination%/*}"; then
              if git show-ref --verify --quiet "refs/heads/$branch"; then
                git worktree add "$destination" "$branch";
              else
                git worktree add -b "$branch" "$destination";
              fi;
            fi;
          else
            printf "Invalid branch name or repository.\n";
          fi;
          printf "Press Enter to return to the picker...";
          IFS= read -r reply;
        fi
      )+reload(git worktree list)' \
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

br() {
  local selected selected_ref

  git rev-parse --show-toplevel >/dev/null || return

  selected=$(
    git for-each-ref \
      --sort=-committerdate \
      --format='%(if)%(symref)%(then)%(else)%(refname)%09%(refname:short)%(end)' \
      refs/heads refs/remotes |
    sed '/^$/d' |
    fzf \
      --delimiter=$'\t' \
      --with-nth=2 \
      --height=60% \
      --layout=reverse \
      --border \
      --prompt='branch> ' \
      --header='enter: switch   ctrl-a: create and switch   ctrl-r: reload' \
      --preview='git log --color=always --graph --oneline -20 {1} --' \
      --preview-window='right:50%' \
      --bind='ctrl-a:execute(
        printf "New branch (blank to cancel): ";
        IFS= read -r branch;
        if [ -n "$branch" ]; then
          git switch -c "$branch";
          printf "Press Enter to return to the picker...";
          IFS= read -r reply;
        fi
      )+reload(git for-each-ref --sort=-committerdate --format="%(if)%(symref)%(then)%(else)%(refname)%09%(refname:short)%(end)" refs/heads refs/remotes | sed "/^$/d")' \
      --bind='ctrl-r:reload(git for-each-ref --sort=-committerdate --format="%(if)%(symref)%(then)%(else)%(refname)%09%(refname:short)%(end)" refs/heads refs/remotes | sed "/^$/d")'
  ) || return

  [[ -n "$selected" ]] || return
  selected_ref="${selected%%$'\t'*}"

  case "$selected_ref" in
    refs/heads/*) git switch -- "${selected_ref#refs/heads/}" ;;
    refs/remotes/*) git switch --track -- "$selected_ref" ;;
  esac
}
