# Sets key bindings.

# Return if requirements are not found.
if [[ "$TERM" == 'dumb' ]]; then
  return 1
fi

# Options
# Beep on error in line editor.
setopt BEEP

# Variables
#

# Treat these characters as part of a word.
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

# Use human-friendly identifiers.
zmodload zsh/terminfo
typeset -gA key_info
key_info=(
  'Control'      '\C-'
  'ControlLeft'  '\e[1;5D \e[5D \e\e[D \eOd'
  'ControlRight' '\e[1;5C \e[5C \e\e[C \eOc'
  'Escape'       '\e'
  'Meta'         '\M-'
  'Backspace'    "^?"
  'Delete'       "^[[3~"
  'F1'           "$terminfo[kf1]"
  'F2'           "$terminfo[kf2]"
  'F3'           "$terminfo[kf3]"
  'F4'           "$terminfo[kf4]"
  'F5'           "$terminfo[kf5]"
  'F6'           "$terminfo[kf6]"
  'F7'           "$terminfo[kf7]"
  'F8'           "$terminfo[kf8]"
  'F9'           "$terminfo[kf9]"
  'F10'          "$terminfo[kf10]"
  'F11'          "$terminfo[kf11]"
  'F12'          "$terminfo[kf12]"
  'Insert'       "$terminfo[kich1]"
  'Home'         "$terminfo[khome]"
  'PageUp'       "$terminfo[kpp]"
  'End'          "$terminfo[kend]"
  'PageDown'     "$terminfo[knp]"
  'Up'           "$terminfo[kcuu1]"
  'Left'         "$terminfo[kcub1]"
  'Down'         "$terminfo[kcud1]"
  'Right'        "$terminfo[kcuf1]"
  'BackTab'      "$terminfo[kcbt]"
)

# Bind Shift-Space to space
#bindkey -s '\033[32;2u' ' '
#bindkey -s '\033[32;6u' ' '

# Set empty $key_info values to an invalid UTF-8 sequence to induce silent
# bindkey failure.
for key in "${(k)key_info[@]}"; do
  if [[ -z "$key_info[$key]" ]]; then
    key_info[$key]='�'
  fi
done

# External Editor

# Allow command line editing in an external editor.
autoload -Uz edit-command-line
zle -N edit-command-line

# Functions

# Runs bindkey but for all of the keymaps. Running it with no arguments will
# print out the mappings for all of the keymaps.
function bindkey-all {
  local keymap=''
  for keymap in $(bindkey -l); do
    [[ "$#" -eq 0 ]] && printf "#### %s\n" "${keymap}" 1>&2
    bindkey -M "${keymap}" "$@"
  done
}

# Enables terminal application mode and updates editor information.
function zle-line-init {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( $+terminfo[smkx] )); then
    # Enable terminal application mode.
    echoti smkx
  fi

  # Update editor information.
  zle reset-prompt
}
zle -N zle-line-init

# Disables terminal application mode and updates editor information.
function zle-line-finish {
  # The terminal must be in application mode when ZLE is active for $terminfo
  # values to be valid.
  if (( $+terminfo[rmkx] )); then
    # Disable terminal application mode.
    echoti rmkx
  fi

  # Update editor information.
  zle reset-prompt
}
zle -N zle-line-finish

# Toggles emacs overwrite mode and updates editor information.
function overwrite-mode {
  zle .overwrite-mode
  zle reset-prompt
}
zle -N overwrite-mode

# Enters vi insert mode and updates editor information.
function vi-insert {
  zle .vi-insert
  zle reset-prompt
}
zle -N vi-insert

# Moves to the first non-blank character then enters vi insert mode and updates
# editor information.
function vi-insert-bol {
  zle .vi-insert-bol
  zle reset-prompt
}
zle -N vi-insert-bol

# Enters vi replace mode and updates editor information.
function vi-replace  {
  zle .vi-replace
  zle reset-prompt
}
zle -N vi-replace

# Expands .... to ../..
function expand-dot-to-parent-directory-path {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N expand-dot-to-parent-directory-path

# Displays an indicator when completing.
function expand-or-complete-with-indicator {
  local indicator
  zstyle -s ':prezto:module:editor:info:completing' format 'indicator'
  print -Pn "$indicator"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-indicator

# Inserts 'sudo ' at the beginning of the line.
function prepend-sudo {
  if [[ "$BUFFER" != su(do|)\ * ]]; then
    BUFFER="sudo $BUFFER"
    (( CURSOR += 5 ))
  fi
}
zle -N prepend-sudo

# Reset to default key bindings.
bindkey -d

# Vi Key Bindings

# Edit command in an external editor emacs style (v is used for visual mode)
bindkey -M vicmd "$key_info[Control]X$key_info[Control]E" edit-command-line

# Undo/Redo
bindkey -M vicmd "u" undo
bindkey -M vicmd "$key_info[Control]R" redo

if (( $+widgets[history-incremental-pattern-search-backward] )); then
  bindkey -M vicmd "?" history-incremental-pattern-search-backward
  bindkey -M vicmd "/" history-incremental-pattern-search-forward
else
  bindkey -M vicmd "?" history-incremental-search-backward
  bindkey -M vicmd "/" history-incremental-search-forward
fi

# Emacs and Vi Key Bindings

# Unbound keys in vicmd and viins mode will cause really odd things to happen
# such as the casing of all the characters you have typed changing or other
# undefined things. In emacs mode they just insert a tilde, but bind these keys
# in the main keymap to a noop op so if there is no keybind in the users mode
# it will fall back and do nothing.
function _prezto-zle-noop {  ; }
zle -N _prezto-zle-noop
local -a unbound_keys
unbound_keys=(
  "${key_info[F1]}"
  "${key_info[F2]}"
  "${key_info[F3]}"
  "${key_info[F4]}"
  "${key_info[F5]}"
  "${key_info[F6]}"
  "${key_info[F7]}"
  "${key_info[F8]}"
  "${key_info[F9]}"
  "${key_info[F10]}"
  "${key_info[F11]}"
  "${key_info[F12]}"
  "${key_info[PageUp]}"
  "${key_info[PageDown]}"
)
for keymap in $unbound_keys; do
  bindkey -M viins "${keymap}" _prezto-zle-noop
  bindkey -M vicmd "${keymap}" _prezto-zle-noop
done
# Ctrl + Left and Ctrl + Right bindings to forward/backward word
for keymap in viins vicmd; do
  for key in "${(s: :)key_info[ControlLeft]}"
    bindkey -M "$keymap" "$key" vi-backward-word
  for key in "${(s: :)key_info[ControlRight]}"
    bindkey -M "$keymap" "$key" vi-forward-word
done


bindkey -M viins "$key_info[Home]" beginning-of-line
bindkey -M vicmd "$key_info[Home]" beginning-of-line
bindkey -M viins "$key_info[End]" end-of-line
bindkey -M vicmd "$key_info[End]" end-of-line

bindkey -M viins "$key_info[Insert]" overwrite-mode
bindkey -M viins "$key_info[Delete]" delete-char
bindkey -M vicmd "$key_info[Delete]" delete-char
bindkey -M viins "$key_info[Backspace]" backward-delete-char

bindkey -M viins "$key_info[Left]" backward-char
bindkey -M viins "$key_info[Right]" forward-char

# Expand history on space.
bindkey -M viins ' ' magic-space

# Search keys
bindkey -M viins "$key_info[PageUp]" history-beginning-search-backward 
bindkey -M viins "$key_info[PageDown]" history-beginning-search-forward

# Clear screen.
bindkey -M viins "$key_info[Control]L" clear-screen

## Expand command name to full path.
#for key in "$key_info[Escape]"{E,e}
#bindkey -M viins "$key" expand-cmd-path
#
## Duplicate the previous word.
#for key in "$key_info[Escape]"{M,m}
#bindkey -M viins "$key" copy-prev-shell-word
#
## Use a more flexible push-line.
#bindkey -M viins "$key_info[Control]Q" push-line-or-edit

# Bind Shift + Tab to go to the previous menu item.
bindkey -M viins "$key_info[BackTab]" reverse-menu-complete

# Display an indicator when completing.
bindkey -M viins "$key_info[Control]I" expand-or-complete-with-indicator

# Insert 'sudo ' at the beginning of the line.
bindkey -M viins "$key_info[Control]X$key_info[Control]S" prepend-sudo

# Set the key layout.
bindkey -v

unset key{,map,_bindings}
