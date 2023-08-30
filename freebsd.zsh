# Return if requirements are not found.
if [[ "$OSTYPE" != freebsd* ]]; then
  return 1
fi

# BSD Core Utilities
# Define colors for BSD ls.
export LSCOLORS='exfxcxdxbxGxDxabagacad'

# Paths
path=(
  /usr/games/
  /usr/local/{bin,sbin}
  /usr/{bin,sbin}
  $path
)

#
# Aliases
#

#quicksearch through the ports

function quicksearch {
    (
    if [ -d /usr/local/poudriere/ports/ ]; then
        builtin cd /usr/local/poudriere/ports/local/
    else
        builtin cd /usr/ports/
    fi
    make quicksearch name="$1" | less
    )
}
