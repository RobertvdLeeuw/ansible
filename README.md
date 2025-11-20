# Debian Workstation Ansible Configuration

This repository contains an Ansible-based configuration for setting up a Debian workstation, migrated from NixOS.

## Quick Start

### Initial Setup

Run this command on a fresh Debian installation:

```bash
curl -sSL https://raw.githubusercontent.com/RobertVDLeeuw/ansible/main/setup.sh | bash
```

This will:
1. Install Ansible and Git
2. Clone this repository
3. Run the foundation setup (flatpak, snapd, etc.)

### Full Installation

After the initial setup, install everything:

```bash
cd ansible
ansible-playbook playbook.yml -K
```

### Selective Installation

Install only specific categories:

```bash
# Terminal tools only
ansible-playbook playbook.yml --tags terminal -K

# Development environment only
ansible-playbook playbook.yml --tags development -K

# Desktop applications only
ansible-playbook playbook.yml --tags desktop -K

# Gaming software only
ansible-playbook playbook.yml --tags gaming -K

# Multiple categories
ansible-playbook playbook.yml --tags terminal,development,desktop -K

# Dotfiles only
ansible-playbook playbook.yml --tags dotfiles
```

## Software Categories

### Foundation
- Package managers: flatpak, snapd
- Core system utilities

### Terminal
- **Terminal emulator**: Alacritty
- **Shell**: Zsh with syntax highlighting and autosuggestions
- **Prompt**: Starship
- **Tools**: bat, fd-find, fzf, zoxide, neofetch, tree, dust
- **Utilities**: wget, jq, unzip, zip

### Development
- **Languages**: Python 3, Rust (rustc, cargo)
- **Tools**: Git, GCC, Ninja, Docker, Jupyter
- **Package managers**: pip, uv
- **Editor**: Neovim (empty config - customize as needed)

### Desktop
- **Window Manager**: Sway
- **Bar**: Waybar (with custom modules for workspaces and system resources)
- **Launcher**: Wofi
- **Notifications**: Mako
- **Utilities**: playerctl, wl-clipboard, clipman, grim, slurp, redshift
- **File Manager**: Dolphin
- **Applications** (via Flatpak):
  - Spotify
  - Brave Browser
  - Discord
  - Microsoft Teams
  - Loupe (image viewer)
- **Cloud Storage**: Nextcloud (via Snap)
- **Custom Modules**: Rust-based waybar modules (see `waybar_modules/`)

### Gaming
- Steam (via Flatpak)
- PrismLauncher for Minecraft (via Flatpak)

### Uncategorized
- direnv
- copyq

## Directory Structure

```
ansible/
├── playbook.yml              # Main playbook
├── setup.sh                  # Initial setup script
├── .env.example              # Template for environment variables
├── .sops.yaml                # SOPS encryption configuration
├── .gitignore                # Git ignore rules
├── group_vars/
│   └── all.yml               # Software categories and dotfile mappings
├── tasks/
│   ├── foundation.yml        # Includes SOPS/age setup
│   ├── terminal.yml
│   ├── development.yml
│   ├── desktop.yml
│   ├── gaming.yml
│   ├── uncategorized.yml
│   ├── waybar_modules.yml    # Build custom waybar modules
│   └── dotfiles.yml
├── scripts/
│   ├── README.md             # Scripts documentation
│   ├── sops-setup.sh         # SOPS encryption setup
│   └── env-helper.sh         # Manage encrypted .env
├── waybar_modules/           # Custom Rust programs for waybar
│   ├── README.md
│   ├── workspaces/           # Workspace display module
│   └── resources/            # CPU/GPU monitoring module
└── dotfiles/
    ├── .bashrc
    ├── .gitconfig
    ├── .zshrc
    └── config/
        ├── alacritty/
        ├── sway/
        ├── waybar/
        ├── wofi/
        ├── mako/
        ├── nvim/
        └── starship.toml
```

## Dotfiles

Dotfiles are automatically symlinked to your home directory when you run the playbook with the `dotfiles` tag or run the full playbook.

### Customization

- **Git**: Edit `dotfiles/.gitconfig` to set your name and email
- **Zsh**: Customize `dotfiles/.zshrc` for shell aliases and settings
- **Sway**: Modify configs in `dotfiles/config/sway/`
- **Neovim**: Add your configuration to `dotfiles/config/nvim/init.lua`

## Post-Installation

### Configure Git

Edit `~/.gitconfig` or run:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Set Up Secrets Management (SOPS)

The foundation playbook installs SOPS and age for encrypted secrets management.
**Environment variables are automatically loaded in every new shell (zsh/bash)!**

```bash
# 1. Set up encryption key
./scripts/sops-setup.sh

# 2. Create and edit your .env file
./scripts/env-helper.sh init
./scripts/env-helper.sh edit

# 3. Fill in your API keys, homelab IPs, etc.
# File is automatically encrypted when you save

# 4. Reload shell to apply changes
env-reload  # or: source ~/.zshrc

# 5. Verify variables are loaded
echo $OPENAI_API_KEY

# 6. Commit encrypted .env
git add .env .sops.yaml
git commit -m "Add encrypted environment variables"
```

**Convenient aliases:**
- `env-edit` - Edit encrypted .env
- `env-view` - View decrypted .env
- `env-reload` - Reload shell configuration

**Important:** Back up your age key at `~/.config/sops/age/keys.txt` securely!

See `scripts/README.md` for detailed usage.

### Set Default Shell

The playbook automatically sets zsh as your default shell. Log out and back in for it to take effect.

### Docker Permissions

You've been added to the docker group. Log out and back in for permissions to take effect, or run:
```bash
newgrp docker
```

## Package Sources

Software is installed from multiple sources in this priority order:
1. **apt**: Official Debian packages (preferred for system tools)
2. **flatpak**: Cross-distro packages (good for desktop apps)
3. **snap**: Canonical packages (used sparingly)
4. **pip**: Python packages
5. **cargo**: Rust packages

## Notes

- The Sway configuration includes multi-monitor setup for 3 displays
- Waybar has 3 separate configs (one per monitor) with IPC control on horizontal screens
- Custom waybar modules (workspaces, resources) are included as Rust programs
- The waybar modules may need hardware-specific sensor path adjustments
- Neovim config is intentionally empty - customize as needed

## Troubleshooting

### Flatpak apps not launching
```bash
flatpak update
```

### Docker permission denied
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Sway won't start
Check logs:
```bash
journalctl -xe
```

## Migration from NixOS

This configuration was migrated from NixOS. Key differences:
- Package names may differ (e.g., `fd-find` instead of `fd`)
- Some NixOS-specific features are not available
- Configuration files are now standard dotfiles instead of Nix expressions

