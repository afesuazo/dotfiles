# dotfiles

Single source of truth for my dev environment - managed with [chezmoi](https://www.chezmoi.io/).
Targets **macOS** and **Linux** (no Windows).

## Quick start (fresh machine)

```sh
sh -c "$(curl -fsLS https://raw.githubusercontent.com/afesuazo/dotfiles/main/bootstrap/install.sh)"
```

This detects the OS, installs chezmoi, and applies the repo to `$HOME`.

## Quick start (local clone)

```sh
git clone https://github.com/afesuazo/dotfiles.git ~/Dev/dotfiles
cd ~/Dev/dotfiles
./bootstrap/install.sh
```

## Layout

chezmoi-managed tree - each `dot_*` / `dot_config/*` entry maps to `~/.*` or `~/.config/*`:

```
.
├── bootstrap/install.sh         # Entry point - installs chezmoi + applies repo
├── packages/                    # Software install (not config)
│   ├── Brewfile                 # macOS formulae + casks
│   ├── apt.txt                  # Debian/Ubuntu package list
│   └── install.sh               # OS-aware dispatcher + non-package-manager installs
├── dot_zshrc                    # → ~/.zshrc
├── dot_tmux.conf                # → ~/.tmux.conf
├── dot_gitconfig.tmpl           # → ~/.gitconfig  (templated per identity)
├── dot_claude/
│   └── CLAUDE.md                # → ~/.claude/CLAUDE.md  (global Claude Code instructions)
├── private_dot_ssh/
│   └── config                   # → ~/.ssh/config  (skeleton; real hosts in ~/.ssh/config.d/)
├── dot_config/
│   ├── shell/                   # → ~/.config/shell/  (sourced by ~/.zshrc)
│   │   ├── 10-path.zsh          # PATH + brew shellenv
│   │   ├── 20-aliases.zsh
│   │   ├── 30-fzf.zsh
│   │   ├── 40-tools.zsh         # zoxide / direnv / fnm
│   │   └── 99-plugins.zsh       # autosuggestions / fzf-tab / syntax-highlighting
│   ├── ghostty/                 # → ~/.config/ghostty/
│   │   ├── config
│   │   └── themes/dawnfox
│   ├── nvim/                    # → ~/.config/nvim/  (lazy.nvim + plugins)
│   ├── git/ignore               # → ~/.config/git/ignore
│   └── starship.toml            # → ~/.config/starship.toml
├── .chezmoi.toml.tmpl           # Schema of per-machine prompts (runs on `chezmoi init`)
├── .chezmoiignore               # Paths the repo keeps but DOESN'T deploy to $HOME
└── .gitignore
```

## Per-machine setup (prompts)

On first `chezmoi init`, you'll be prompted for:

| Prompt | Choices / Format | Used for |
|---|---|---|
| `identity` | `personal` / `work` / `hobby` | Just a category label - keeps machines straight |
| `name` | Free-form (e.g., "Andres Suazo") | `[user] name` in git, nvim greeting |
| `email` | Free-form | `[user] email` in git |
| `git_username` | Free-form (e.g., `andres_suazo`, `afesuazo`) | Branch prefix in `~/.claude/CLAUDE.md`, TODO author |
| `signing_key` | Path to SSH pubkey (blank to skip) | Git commit signing via SSH |

Answers are saved to `~/.config/chezmoi/chezmoi.toml` - **never** committed to the repo.

To inspect current values: `chezmoi data`.
To re-prompt (e.g., after changing identity): delete `~/.config/chezmoi/chezmoi.toml` and run `chezmoi init` again.

## SSH config

The repo deploys a **skeleton** at `~/.ssh/config` with sensible defaults (keep-alives, macOS keychain, hashed known-hosts) and an `Include ~/.ssh/config.d/*.conf` directive. Real host entries (hostnames, IPs, identity files) live in `~/.ssh/config.d/*.conf` - **per-machine, never committed to the repo.**

Suggested split:

```
~/.ssh/config.d/personal.conf   # github.com, homelab, personal servers
~/.ssh/config.d/work.conf       # work hosts
~/.ssh/config.d/hobby.conf      # hobby project hosts
```

**Migration (first time, on machines with an existing `~/.ssh/config`):**

```sh
mkdir -p ~/.ssh/config.d
cp ~/.ssh/config ~/.ssh/config.d/legacy.conf   # preserve existing hosts
chezmoi apply                                  # now safe to replace skeleton
# later, split legacy.conf into personal.conf / work.conf / hobby.conf
```

**Example host patterns:** see [docs/ssh-config.d.example.conf](docs/ssh-config.d.example.conf) — commented templates for GitHub (single + multi-account), aliased servers, multi-key auth, `ProxyJump`, wildcards, agent forwarding, and `Match exec`. The `docs/` directory is chezmoi-ignored, so this file lives in the repo but never deploys.

## Day-to-day

Apply local changes after editing files in this repo:

```sh
chezmoi apply
```

Or, if you edit files in `$HOME` and want to pull them back into the repo:

```sh
chezmoi re-add        # re-add files already managed
chezmoi add ~/.foo    # start managing a new file
```

Check what chezmoi would change without applying:

```sh
chezmoi diff
```

## Roadmap

- [x] Phase 1 - chezmoi layout, cross-platform bootstrap, repo cleanup
- [x] Phase 2 - `packages/Brewfile` (macOS) + apt list (Linux), shared shell modules, Ghostty config, Dawnfox theme
- [x] Phase 3 - chezmoi templates: per-machine identity, git config, nvim greeting
- [ ] ~~Phase 4 - devtools CLI~~ (removed; revisit when there are concrete commands)
- [x] Phase 5 - modernize nvim LSP (mason-lspconfig, basedpyright, conform.nvim), tmux TPM, Dawnfox status bar
- [x] Phase 6 - SSH config scaffolding (skeleton + Include); secrets deferred (no concrete need yet)
- [ ] Phase 7 - Claude Code config (in progress: CLAUDE.md done), atuin, CI on fresh macOS + Ubuntu runners
