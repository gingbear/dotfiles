NEWLINE='
'

# Machine name.
function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || echo $HOST
}

PROMPT_TRUNC=3
PREFIX_SHOW=true
PREFIX_GIT=" on "
PREFIX_DIR=" in "
PREFIX_HOST=" at "

# Time
TIME_PREFIX="🕙"
current_time() {
  echo -n "%{$fg_bold[yellow]%}[%D{%T}]"
  echo -n "%{$reset_color%} "
}

current_date() {
  echo -n "%{$fg_bold[white]%}[%D{%D}]"
  echo -n "%{$reset_color%} "
}

# Username.
# If user is root, then pain it in red. Otherwise, just print in yellow.
user() {
  if [[ $USER == 'root' ]]; then
    echo -n "%{$fg_bold[red]%}"
  else
    echo -n "%{$fg_bold[yellow]%}"
  fi
  echo -n "%n"
  echo -n "%{$reset_color%}"
}

# Username and SSH host
# If there is an ssh connections, then show user and current machine.
# If user is not $USER, then show username.
host() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo -n "$(user)"

    # Do not show directory prefix if prefixes are disabled
    [[ $PREFIX_SHOW == true ]] && echo -n "%B${PREFIX_DIR}%b" || echo -n ' '
    # Display machine name
    echo -n "%{$fg_bold[green]%}%m%{$reset_color%}"
    # Do not show host prefix if prefixes are disabled
    [[ $PREFIX_SHOW == true ]] && echo -n "%B${PREFIX_HOST}%b" || echo -n ' '

  elif [[ $LOGNAME != $USER ]] || [[ $USER == 'root' ]]; then
    echo -n "$(user)"

    # Do not show host prefix if prefixes are disabled
    [[ $PREFIX_SHOW == true ]] && echo -n "%B${PREFIX_HOST}%b" || echo -n ' '

    echo -n "%{$reset_color%}"
  fi
}

# Directory info.
current_dir() {
  echo -n "%{$fg_bold[blue]%}"
  echo -n "%${PROMPT_TRUNC}~";
  echo -n "%{$reset_color%}"
}

# GIT
GIT_SHOW="${GIT_SHOW:-true}"
GIT_UNCOMMITTED="${GIT_UNCOMMITTED:-+}"
GIT_UNSTAGED="${GIT_UNSTAGED:-!}"
GIT_UNTRACKED="${GIT_UNTRACKED:-?}"
GIT_STASHED="${GIT_STASHED:-$}"
GIT_UNPULLED="${GIT_UNPULLED:-⇣}"
GIT_UNPUSHED="${GIT_UNPUSHED:-⇡}"

# Uncommitted changes.
# Check for uncommitted changes in the index.
git_uncomitted() {
  if ! $(git diff --quiet --ignore-submodules --cached); then
    echo -n "${GIT_UNCOMMITTED}"
  fi
}

# Unstaged changes.
# Check for unstaged changes.
git_unstaged() {
  if ! $(git diff-files --quiet --ignore-submodules --); then
    echo -n "${GIT_UNSTAGED}"
  fi
}

# Untracked files.
# Check for untracked files.
git_untracked() {
  if [ -n "$(git ls-files --others --exclude-standard)" ]; then
    echo -n "${GIT_UNTRACKED}"
  fi
}

# Stashed changes.
# Check for stashed changes.
git_stashed() {
  if $(git rev-parse --verify refs/stash &>/dev/null); then
    echo -n "${GIT_STASHED}"
  fi
}

# Unpushed and unpulled commits.
# Get unpushed and unpulled commits from remote and draw arrows.
git_unpushed_unpulled() {
  # check if there is an upstream configured for this branch
  command git rev-parse --abbrev-ref @'{u}' &>/dev/null || return

  local count
  count="$(command git rev-list --left-right --count HEAD...@'{u}' 2>/dev/null)"
  # exit if the command failed
  (( !$? )) || return

  # counters are tab-separated, split on tab and store as array
  count=(${(ps:\t:)count})
  local arrows left=${count[1]} right=${count[2]}

  (( ${right:-0} > 0 )) && arrows+="${GIT_UNPULLED}"
  (( ${left:-0} > 0 )) && arrows+="${GIT_UNPUSHED}"

  [ -n $arrows ] && echo -n "${arrows}"
}

# Git status.
# Collect indicators, git branch and pring string.
git_status() {
  [[ $GIT_SHOW == false ]] && return

  # Check if the current directory is in a Git repository.
  command git rev-parse --is-inside-work-tree &>/dev/null || return

  # Check if the current directory is in .git before running git checks.
  if [[ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]]; then
    # Ensure the index is up to date.
    git update-index --really-refresh -q &>/dev/null

    # String of indicators
    local indicators=''

    indicators+="$(git_uncomitted)"
    indicators+="$(git_unstaged)"
    indicators+="$(git_untracked)"
    indicators+="$(git_stashed)"
    indicators+="$(git_unpushed_unpulled)"

    [ -n "${indicators}" ] && indicators=" [${indicators}]";

    # Do not show git prefix if prefixes are disabled
    [[ $PREFIX_SHOW == true ]] && echo -n "%B${PREFIX_GIT}%b" || echo -n ' '

    echo -n "%{$fg_bold[magenta]%}"
    echo -n "$(git_current_branch)"
    echo -n "%{$reset_color%}"
    echo -n "%{$fg_bold[red]%}"
    echo -n "$indicators"
    echo -n "%{$reset_color%}"
  fi
}

# Ruby
RUBY_SHOW=true
PREFIX_RUBY=" via "
RUBY_SYMBOL="💎"
# Show current version of Ruby
ruby_version() {
  [[ $RUBY_SHOW == false ]] && return

  # Show versions only for Ruby-specific folders
  [[ -f Gemfile || -f Rakefile || -n *.rb(#qN) ]] || return

  if command -v rvm-prompt > /dev/null 2>&1; then
    ruby_version=$(rvm-prompt i v g)
  elif command -v chruby > /dev/null 2>&1; then
    ruby_version=$(chruby | sed -n -e 's/ \* //p')
  elif command -v rbenv > /dev/null 2>&1; then
    ruby_version=$(rbenv version | sed -e 's/ (set.*$//')
  else
    return
  fi

  [[ "${ruby_version}" == "system" ]] && return

  # Do not show ruby prefix if prefixes are disabled
  [[ $PREFIX_SHOW == true ]] && echo -n "%B${PREFIX_RUBY}%b" || echo -n ' '

  # Add 'v' before ruby version that starts with a number
  [[ "${ruby_version}" =~ ^[0-9].+$ ]] && ruby_version="v${ruby_version}"

  echo -n "%{$fg_bold[red]%}"
  echo -n "${RUBY_SYMBOL}  ${ruby_version}"
  echo -n "%{$reset_color%}"
}

symbol() {
  if [[ $USER == 'root' ]]; then
    echo -n "#"
  else
    echo -n "$"
  fi
}

return_status() {
  echo -n "%(?.%{$fg[green]%}.%{$fg[red]%})"
  echo -n "%B$(symbol)%b "
  echo -n "%{$reset_color%}"
}

# Entry point
# Compose whole prompt from smaller parts
prompt() {
  echo -n "$ "
  current_time
  host
  current_dir
  git_status
  ruby_version
  echo -n "$NEWLINE"
  return_status
}

PROMPT='$(prompt)'
RPROMPT='$(current_date)'
