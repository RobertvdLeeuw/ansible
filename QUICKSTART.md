# Quick Start Guide

## Fresh Debian Installation

### Step 1: Run Setup Script

```bash
curl -sSL https://raw.githubusercontent.com/RobertVDLeeuw/ansible/main/setup.sh | bash
```

**What this does:**
- Installs Ansible and Git
- Checks for SSH key (prompts if missing)
- Clones this repository
- Runs foundation setup (flatpak, snapd)

### Step 2: Install Everything

```bash
cd ansible
ansible-playbook playbook.yml -K
```

Enter your sudo password when prompted (`-K` flag).

**What this installs:**
- Terminal tools (zsh, alacritty, starship, bat, fzf, etc.)
- Development environment (python, rust, docker, git, nvim)
- Desktop environment (sway, waybar with custom modules, wofi, mako)
- Desktop apps (spotify, brave, discord, teams via flatpak)
- Gaming (steam, prismlauncher via flatpak)
- Custom waybar modules (workspaces and resources monitoring)
- All dotfiles symlinked to your home directory

### Step 3: Set Up Secrets Management

```bash
# Set up SOPS encryption
./scripts/sops-setup.sh

# Create and edit your .env file
./scripts/env-helper.sh init
./scripts/env-helper.sh edit
# Fill in your API keys, homelab IPs, etc.

# Commit encrypted .env
git add .env .sops.yaml
git commit -m "Add encrypted environment variables"
```

**Important:** Back up `~/.config/sops/age/keys.txt` securely!

### Step 4: Post-Installation

1. **Configure Git:**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **Log out and back in** for:
   - Zsh to become default shell
   - Docker group permissions to take effect

3. **Start Sway:**
   ```bash
   sway
   ```

## Selective Installation

### Install Only What You Need

```bash
# Just terminal tools
ansible-playbook playbook.yml --tags terminal -K

# Just development tools
ansible-playbook playbook.yml --tags development -K

# Just desktop apps
ansible-playbook playbook.yml --tags desktop -K

# Multiple categories
ansible-playbook playbook.yml --tags terminal,development -K
```

### Available Tags

- `foundation` - Package managers (flatpak, snapd)
- `terminal` - Terminal emulator and CLI tools
- `development` - Programming languages and dev tools
- `desktop` - GUI apps and window manager
- `gaming` - Games and game platforms
- `uncategorized` - Misc utilities
- `waybar_modules` - Build and install custom waybar modules
- `dotfiles` - Just symlink dotfiles (no package installation)

## Common Tasks

### Update All Software

```bash
# Update apt packages
sudo apt update && sudo apt upgrade -y

# Update flatpak apps
flatpak update -y

# Update cargo packages
cargo install-update -a  # Requires cargo-update

# Or create an alias in .zshrc:
# alias update="sudo apt update && sudo apt upgrade -y && flatpak update -y"
```

### Re-apply Dotfiles

```bash
ansible-playbook playbook.yml --tags dotfiles
```

### Add New Software

1. Edit `group_vars/all.yml`
2. Add package to appropriate category
3. Run playbook for that category:
   ```bash
   ansible-playbook playbook.yml --tags <category> -K
   ```

### Check What Would Change

```bash
ansible-playbook playbook.yml --check -K
```

## Customization

### Dotfiles Location

All dotfiles are in `dotfiles/`:
- `dotfiles/.zshrc` - Shell configuration
- `dotfiles/.gitconfig` - Git configuration
- `dotfiles/config/alacritty/` - Terminal emulator
- `dotfiles/config/sway/` - Window manager
- `dotfiles/config/waybar/` - Status bar
- `dotfiles/config/nvim/` - Text editor (empty - customize!)
- `dotfiles/config/starship.toml` - Shell prompt

### Edit and Re-apply

1. Edit files in `dotfiles/`
2. Re-run dotfiles task:
   ```bash
   ansible-playbook playbook.yml --tags dotfiles
   ```

## Troubleshooting

### SSH Key Not Found

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub
# Add this to GitHub: Settings → SSH Keys → New SSH Key
```

### Flatpak Apps Not Launching

```bash
flatpak update
# Log out and back in
```

### Docker Permission Denied

```bash
sudo usermod -aG docker $USER
newgrp docker
# Or log out and back in
```

### Sway Won't Start

Check if you're in a graphical session:
```bash
echo $DISPLAY
# Should be empty for Sway to start
```

From TTY (Ctrl+Alt+F2):
```bash
sway
```

### Fonts Look Wrong

Install JetBrainsMono Nerd Font manually:
```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
# Download from https://www.nerdfonts.com/
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -fv
```

## Next Steps

1. **Customize Neovim** - Add your config to `dotfiles/config/nvim/init.lua`
2. **Set up Sway backgrounds** - Add images to `~/.config/sway/backgrounds/`
3. **Configure monitors** - Edit `dotfiles/config/sway/monitor.conf`
4. **Customize waybar modules** - Adjust sensor paths in `waybar_modules/resources/src/main.rs`
5. **Add more software** - Edit `group_vars/all.yml`
6. **Explore keybindings** - Check `dotfiles/config/sway/controls.conf`

## Key Bindings (Sway)

- `Super+Return` - Open terminal
- `Super+Space` - Application launcher (wofi)
- `Super+B` - Open Brave browser
- `Super+S` - Open Spotify
- `Super+Shift+W` - Close window
- `Super+Shift+C` - Reload Sway config
- `Super+Shift+E` - Exit Sway
- `Super+1/2/3/4` - Switch workspace
- `Super+Shift+1/2/3/4` - Move window to workspace
- `Super+H/J/K/L` - Navigate windows (vim-style)
- `Super+Shift+S` - Screenshot area
- `Super+V` - Clipboard manager

See `dotfiles/config/sway/controls.conf` for all keybindings.

