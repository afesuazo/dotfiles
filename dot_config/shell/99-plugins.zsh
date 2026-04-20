# Zsh plugins - sourcing order matters:
#   1. zsh-autosuggestions
#   2. fzf-tab  (must come before syntax-highlighting)
#   3. zsh-syntax-highlighting  (must be last)
#
# We look in package-manager locations first, falling back to a local git clone
# at ~/.local/share/zsh-plugins (populated by packages/install.sh).

_source_plugin() {
  local name="$1"; shift
  local candidate
  for candidate in "$@"; do
    if [ -r "${candidate}" ]; then
      source "${candidate}"
      return 0
    fi
  done
  return 1
}

_brew_prefix=""
command -v brew >/dev/null 2>&1 && _brew_prefix="$(brew --prefix 2>/dev/null)"
_plugin_home="${HOME}/.local/share/zsh-plugins"

_source_plugin zsh-autosuggestions \
  "${_brew_prefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "${_plugin_home}/zsh-autosuggestions/zsh-autosuggestions.zsh"

_source_plugin fzf-tab \
  "${_plugin_home}/fzf-tab/fzf-tab.plugin.zsh"

_source_plugin zsh-syntax-highlighting \
  "${_brew_prefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "${_plugin_home}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

unset -f _source_plugin
unset _brew_prefix _plugin_home
