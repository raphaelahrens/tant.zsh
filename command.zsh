# Defines general aliases and functions.


# Aliases


alias less="less -R"
alias feh="feh --conversion-timeout 0"
# Disable correction.
alias ack='nocorrect ack'
alias cd='nocorrect cd'
alias cp='nocorrect cp'
alias heroku='nocorrect heroku'
alias ln='nocorrect ln'
alias man='nocorrect man'
alias mkdir='nocorrect mkdir'
alias mv='nocorrect mv'
alias rm='nocorrect rm'

# Disable globbing.
alias fc='noglob fc'
alias history='noglob history'
alias locate='noglob locate'
alias rake='noglob rake'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'

# Define general aliases.
alias ln="${aliases[ln]:-ln} -i"
alias mkdir="${aliases[mkdir]:-mkdir} -p"
alias type='type -a'

alias ls="${aliases[ls]:-ls} -G"

if (( $+commands[xclip] )); then
  alias pbcopy='xclip -selection clipboard -in'
  alias pbpaste='xclip -selection clipboard -out'
elif (( $+commands[xsel] )); then
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
fi

# File Download
if (( $+commands[curl] )); then
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
elif (( $+commands[wget] )); then
  alias get='wget --continue --progress=bar --timestamping'
fi

# Resource Usage
alias df='df -kh'
alias du='du -kh'

#
# Functions
#

# Makes a directory and changes to it.
function mkcd {
  [[ -n "$1" ]] && mkdir -p "$1" && builtin cd "$1"
}

# Changes to a directory and lists its contents.
function cdls {
  builtin cd "$argv[-1]" && ls "${(@)argv[1,-2]}"
}

# Prints columns 1 2 3 ... n.
function slit {
  awk "{ print ${(j:,:):-\$${^@}} }"
}

# Finds files and executes a command on them.
#function find-exec {
#  find . -type f -iname "*${1:-}*" -exec "${2:-file}" '{}' \;
#}

# Displays user owned processes status.
function psu {
  ps -U "${1:-$LOGNAME}" -o 'pid,%cpu,%mem,command' "${(@)argv[2,-1]}"
}
function owner_path {
	if [[ $# -eq 0 ]]; then
        printf 'usage:\n   owner_path $dir\n'
        return 1
	fi
	l_path=$1
	while [[ $l_path != "/" && $l_path != "." ]]; do
        ls -ld $l_path
        l_path=$(dirname $l_path)
	done | sed '1!G;h;$!d' | column -t
}

#disable all screenssaving features for x hours
function watch_movie {
    if [[ $# -ge 1 ]]; then
        if [[ $1 -gt 0 ]]; then
           sleep_time=$1
        else
            printf "Usage:\n watch_movie [time in h]\n"
            return 1
        fi
    else
        sleep_time=3
    fi
	xset s off -dpms;
	(sleep $(( 60*60*$sleep_time )); xset s on +dpms)&
}

# Print the current tasks and appointments
if (( $+commands[ttdl] )); then
  if [[ -t 0 || -t 1 ]]; then
    ttdl
    print
  fi
fi
