#!/usr/bin/env bash
# Bootstrap entry point - installs chezmoi and applies this dotfiles repo.
#
# Usage:
#   Remote (fresh machine):
#     sh -c "$(curl -fsLS https://raw.githubusercontent.com/afesuazo/dotfiles/main/bootstrap/install.sh)"
#   Local (clone already present):
#     ./bootstrap/install.sh

set -euo pipefail

GITHUB_USER="${DOTFILES_GITHUB_USER:-afesuazo}"
REPO_URL="${DOTFILES_REPO_URL:-https://github.com/${GITHUB_USER}/dotfiles.git}"
CHEZMOI_BIN_DIR="${HOME}/.local/bin"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m  %s\n' "$*" >&2; exit 1; }

detect_os() {
  case "$(uname -s)" in
    Darwin) OS="darwin" ;;
    Linux)  OS="linux"  ;;
    *)      die "Unsupported OS: $(uname -s) - this repo targets macOS and Linux only." ;;
  esac

  DISTRO=""
  if [ "$OS" = "linux" ] && [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    DISTRO="${ID:-}"
  fi

  log "Detected OS: ${OS}${DISTRO:+ (${DISTRO})}"
}

ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

install_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    log "chezmoi already installed: $(command -v chezmoi)"
    return
  fi

  log "Installing chezmoi into ${CHEZMOI_BIN_DIR}"
  mkdir -p "${CHEZMOI_BIN_DIR}"

  # Upstream installer - works on macOS and all major Linux distros without sudo.
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${CHEZMOI_BIN_DIR}"
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget -qO- get.chezmoi.io)" -- -b "${CHEZMOI_BIN_DIR}"
  else
    die "Need curl or wget to install chezmoi."
  fi

  case ":${PATH}:" in
    *":${CHEZMOI_BIN_DIR}:"*) ;;
    *) export PATH="${CHEZMOI_BIN_DIR}:${PATH}"
       warn "Added ${CHEZMOI_BIN_DIR} to PATH for this session. Your shell rc should also include it." ;;
  esac

  ensure_cmd chezmoi
}

apply_dotfiles() {
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  repo_root="$(cd "${script_dir}/.." && pwd)"

  if [ -f "${repo_root}/.chezmoiignore" ] || [ -d "${repo_root}/dot_config" ]; then
    log "Applying dotfiles from local clone: ${repo_root}"
    chezmoi init --apply --source "${repo_root}"
  else
    log "Applying dotfiles from remote: ${REPO_URL}"
    chezmoi init --apply "${REPO_URL}"
  fi
}

install_packages() {
  if [ "${SKIP_PACKAGES:-0}" = "1" ]; then
    log "SKIP_PACKAGES=1 - skipping package install"
    return
  fi
  local pkg_script="${repo_root}/packages/install.sh"
  if [ -x "${pkg_script}" ]; then
    log "Running package installer"
    "${pkg_script}"
  else
    warn "Package installer not found or not executable: ${pkg_script}"
  fi
}

main() {
  detect_os
  install_chezmoi
  apply_dotfiles
  install_packages
  log "Done. Open a new shell (or 'exec \$SHELL') to pick up changes."
}

main "$@"
