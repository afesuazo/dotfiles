# dotfiles

Single source of truth for my dev environment — managed with [chezmoi](https://www.chezmoi.io/).
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

chezmoi-managed tree — each `dot_*` / `dot_config/*` entry maps to `~/.*` or `~/.config/*`:

```
.
├── bootstrap/install.sh     # Entry point — installs chezmoi + applies repo
├── dot_zshrc                # → ~/.zshrc
├── dot_tmux.conf            # → ~/.tmux.conf
├── dot_gitconfig            # → ~/.gitconfig
├── dot_config/
│   ├── nvim/                # → ~/.config/nvim
│   ├── git/ignore           # → ~/.config/git/ignore
│   └── starship.toml        # → ~/.config/starship.toml
└── .chezmoiignore           # Paths in the repo that should NOT materialize to $HOME
```

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
