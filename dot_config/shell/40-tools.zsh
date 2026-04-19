# Tool integrations - all gated so machines without the tool stay quiet.

command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv  >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v fnm     >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"
