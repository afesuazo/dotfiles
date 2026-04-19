# Aliases

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Debian renames a couple of binaries; normalize them.
command -v fdfind >/dev/null 2>&1 && ! command -v fd  >/dev/null 2>&1 && alias fd='fdfind'
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat='batcat'

# Prefer eza for ls if installed; otherwise fall back silently.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -lah --git'
  alias lt='eza --tree --level=2'
fi
