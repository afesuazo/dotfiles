#!/usr/bin/env bash
# Package installer - called by bootstrap/install.sh (or standalone).
# Installs OS-appropriate packages and zsh plugins that aren't in package managers.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZSH_PLUGIN_DIR="${HOME}/.local/share/zsh-plugins"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }

detect_os() {
  case "$(uname -s)" in
    Darwin) OS="darwin" ;;
    Linux)  OS="linux"  ;;
    *)      die "Unsupported OS: $(uname -s)" ;;
  esac
}

# ---------- macOS ----------

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed"
    return
  fi
  log "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Ensure brew on PATH for the rest of this script (Apple Silicon path).
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_macos_packages() {
  install_homebrew
  log "Running brew bundle"
  brew bundle --file="${SCRIPT_DIR}/Brewfile"
}

# ---------- Linux (Ubuntu/Debian) ----------

require_debian() {
  [ -r /etc/os-release ] || die "Missing /etc/os-release - unsupported Linux"
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}:${ID_LIKE:-}" in
    *debian*|ubuntu*|*:*debian*|*:*ubuntu*) : ;;
    *) die "This repo only supports Debian/Ubuntu Linux - detected ID=${ID:-?}" ;;
  esac
}

install_linux_packages() {
  require_debian
  log "Updating apt and installing base packages"
  sudo apt-get update -y
  # shellcheck disable=SC2046
  sudo apt-get install -y $(grep -vE '^\s*(#|$)' "${SCRIPT_DIR}/apt.txt")

  install_gh_linux
  install_eza_linux
  install_starship_linux
  install_fnm_linux
  install_ghostty_linux
  install_jetbrains_mono_linux
}

install_gh_linux() {
  command -v gh >/dev/null 2>&1 && { log "gh already installed"; return; }
  log "Installing gh (GitHub CLI) via official apt repo"
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y gh
}

install_eza_linux() {
  command -v eza >/dev/null 2>&1 && { log "eza already installed"; return; }
  log "Installing eza via official apt repo"
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update -y
  sudo apt-get install -y eza
}

install_starship_linux() {
  command -v starship >/dev/null 2>&1 && { log "starship already installed"; return; }
  log "Installing starship via official installer"
  curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_fnm_linux() {
  command -v fnm >/dev/null 2>&1 && { log "fnm already installed"; return; }
  log "Installing fnm via official installer"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
}

install_ghostty_linux() {
  if [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    log "No display detected - skipping Ghostty install"
    return
  fi
  command -v ghostty >/dev/null 2>&1 && { log "ghostty already installed"; return; }
  warn "Ghostty has no official Debian/Ubuntu package yet. See https://ghostty.org for install options; skipping."
}

install_jetbrains_mono_linux() {
  if [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    log "No display detected - skipping font install"
    return
  fi
  local font_dir="${HOME}/.local/share/fonts"
  if compgen -G "${font_dir}/JetBrainsMonoNerd*.ttf" >/dev/null 2>&1; then
    log "JetBrains Mono Nerd Font already installed"
    return
  fi
  log "Installing JetBrains Mono Nerd Font"
  mkdir -p "${font_dir}"
  local tmp; tmp="$(mktemp -d)"
  curl -fsSL -o "${tmp}/JetBrainsMono.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -qo "${tmp}/JetBrainsMono.zip" -d "${font_dir}"
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f "${font_dir}" >/dev/null
  rm -rf "${tmp}"
}

# ---------- Cross-platform ----------

install_zsh_plugins() {
  mkdir -p "${ZSH_PLUGIN_DIR}"
  _clone_or_update() {
    local url="$1" dest="$2"
    if [ -d "${dest}/.git" ]; then
      log "Updating $(basename "${dest}")"
      git -C "${dest}" pull --ff-only --quiet
    else
      log "Cloning $(basename "${dest}")"
      git clone --depth 1 --quiet "${url}" "${dest}"
    fi
  }
  # fzf-tab: not in brew or apt. Git-clone is the only sensible path.
  _clone_or_update https://github.com/Aloxaf/fzf-tab           "${ZSH_PLUGIN_DIR}/fzf-tab"
  # Autosuggestions + syntax-highlighting come from package managers on both
  # platforms; clone only as a fallback if the package wasn't installed.
  [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] \
    || [ -f "$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    || _clone_or_update https://github.com/zsh-users/zsh-autosuggestions \
                        "${ZSH_PLUGIN_DIR}/zsh-autosuggestions"
  [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] \
    || [ -f "$(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
    || _clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting \
                        "${ZSH_PLUGIN_DIR}/zsh-syntax-highlighting"
}

main() {
  detect_os
  case "${OS}" in
    darwin) install_macos_packages ;;
    linux)  install_linux_packages ;;
  esac
  install_zsh_plugins
  log "Packages installed."
}

main "$@"
