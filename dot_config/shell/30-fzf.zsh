# fzf keybindings + completion, cross-platform.

if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    # Debian / Ubuntu packaged paths
    [ -r /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -r /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh
    # Homebrew paths
    if command -v brew >/dev/null 2>&1; then
      local _fzf_prefix; _fzf_prefix="$(brew --prefix fzf 2>/dev/null || true)"
      [ -n "${_fzf_prefix}" ] && [ -r "${_fzf_prefix}/shell/key-bindings.zsh" ] \
        && source "${_fzf_prefix}/shell/key-bindings.zsh"
      [ -n "${_fzf_prefix}" ] && [ -r "${_fzf_prefix}/shell/completion.zsh" ] \
        && source "${_fzf_prefix}/shell/completion.zsh"
    fi
  fi
fi
