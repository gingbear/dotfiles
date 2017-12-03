alias git_reset='git reset --hard origin/$(git_current_branch)'
alias ICLOUD_DRIVE_PATH="~/Library/Mobile Documents/com~apple~CloudDocs/Environment"
# run local npm command
npmbin(){[ $# -ne 0 ] && $(npm bin)/$*}
alias git_less_untracked_files='less $(git ls-files --others --exclude-standard)'
alias git_push='git push -u origin $(git_current_branch)'

alias my_ip='curl inet-ip.info'

