typeset -a files
files=(
    "completion.zsh"
    "editor.zsh"
    "env.zsh"
    "freebsd.zsh"
    "history.zsh"
    "command.zsh"
)


for key in "${files[@]}"; do
    source ${0:A:h}/$key
done
