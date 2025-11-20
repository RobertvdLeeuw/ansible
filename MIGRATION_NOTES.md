# NixOS to Debian Migration Notes

## Package Name Mappings

### NixOS → Debian

| NixOS Package | Debian Package | Source | Notes |
|---------------|----------------|--------|-------|
| `fd` | `fd-find` | apt | Binary is still `fd` |
| `ninja` | `ninja-build` | apt | |
| `mako` | `mako-notifier` | apt | |
| `libnotify` | `libnotify-bin` | apt | |
| `python312/313` | `python3` | apt | Debian uses default Python 3 |
| `jupyter` | `python3-jupyter` | apt | |
| `docker` | `docker.io` | apt | |
| `dust` | `du-dust` | cargo | Not in Debian repos |
| `steam` | `com.valvesoftware.Steam` | flatpak | Better isolation |
| `brave` | `com.brave.Browser` | flatpak | Not in Debian repos |
| `spotify` | `com.spotify.Client` | flatpak | Not in Debian repos |
| `discord` | `com.discordapp.Discord` | flatpak | Not in Debian repos |
| `teams` | `com.microsoft.Teams` | flatpak | Not in Debian repos |
| `loupe` | `org.gnome.Loupe` | flatpak | GNOME image viewer |
| `prismlauncher` | `org.prismlauncher.PrismLauncher` | flatpak | Minecraft launcher |

## Configuration Changes

### Alacritty
- Converted from Nix expression to TOML format
- All colors and fonts preserved
- Opacity setting preserved

### Zsh
- Converted from NixOS module to standard `.zshrc`
- Plugins now loaded from system packages:
  - `zsh-syntax-highlighting`
  - `zsh-autosuggestions`
- Removed NixOS-specific aliases (`rebuild`, `cnfnix`, `try`)
- Added Debian-specific `update` alias
- All keybindings preserved
- History settings preserved

### Starship
- Converted from Nix expression to TOML format
- All prompt formatting preserved
- Removed `nix_shell` indicator (not relevant on Debian)

### Sway
- Converted from NixOS module to standard config
- Split into multiple files (main config + includes)
- Monitor configuration preserved
- Keybindings preserved
- Startup applications preserved
- Created placeholder scripts for workspace management

### Waybar
- Converted from single Nix expression to 3 separate configs (one per monitor)
- **Bar 1 (DP-1 - Ultrawide)**: IPC enabled, full modules including network/CPU/GPU
- **Bar 2 (HDMI-A-1 - Top)**: IPC enabled, full modules including network/CPU/GPU
- **Bar 3 (DP-3 - Vertical)**: No IPC, minimal modules (no right-side modules to save space)
- Custom modules (workspaces, resources) migrated as Rust programs in `waybar_modules/`
- Style CSS preserved unchanged

### Wofi
- Converted from Nix expression to standard config
- Style CSS preserved unchanged

## Waybar Custom Modules

### Migrated Successfully

1. **Custom Waybar Modules** ✅
   - `workspaces` module - Rust program in `waybar_modules/workspaces/`
   - `resources` module - Rust program in `waybar_modules/resources/`
   - Both modules are built and installed via Ansible task `waybar_modules.yml`
   - See `waybar_modules/README.md` for details and customization

### Features
- **Workspaces module**: Shows workspace status with app-specific icons per monitor
- **Resources module**: Displays CPU/GPU usage, temperature, and memory
- **Hardware-specific**: Sensor paths may need adjustment for your system

## Missing Features

### From NixOS Config

1. **Sway Background Images**
   - NixOS config referenced `/etc/nixos/modules/sway/backgrounds/`
   - Need to copy background images to `~/.config/sway/backgrounds/`
   - Update sway config to reference new location

2. **Nix-specific Tools**
   - `nix-shell` for trying packages
   - `nixos-rebuild` for system updates
   - Replaced with Debian equivalents

3. **Direnv Nix Integration**
   - `nix-direnv` not available
   - Standard direnv still works for other use cases

## Manual Steps Required

### 1. Set Up Secrets Management
```bash
# Set up SOPS encryption
./scripts/sops-setup.sh

# Create and edit .env
./scripts/env-helper.sh init
./scripts/env-helper.sh edit

# Back up your age key!
cp ~/.config/sops/age/keys.txt /secure/backup/location/
```

### 2. Configure Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. Set Up Sway Backgrounds
```bash
mkdir -p ~/.config/sway/backgrounds
# Copy your background images to this directory
# Update dotfiles/config/sway/config to reference them
```

### 4. Install JetBrainsMono Nerd Font
The `fonts-jetbrains-mono` package may not include Nerd Font glyphs. If icons don't display:
```bash
# Download from https://www.nerdfonts.com/
mkdir -p ~/.local/share/fonts
# Extract font files to ~/.local/share/fonts/
fc-cache -fv
```

### 5. Configure Sway for Your Monitors
Edit `dotfiles/config/sway/monitor.conf` to match your monitor setup.

### 6. Customize Waybar Modules for Your Hardware
The waybar custom modules may need hardware-specific adjustments:

```bash
# Find your sensor paths
sensors -j | jq '.'

# Edit the resources module
nano waybar_modules/resources/src/main.rs
# Update lines 73 and 95 with your sensor paths

# Rebuild and reinstall
cd waybar_modules/resources
cargo build --release
sudo cp target/release/resources /usr/local/bin/
```

For NVIDIA GPUs, see `waybar_modules/README.md` for instructions to replace `rocm-smi` with `nvidia-smi`.

### 7. Enable Sway at Login
Add to your display manager or use:
```bash
# Add to ~/.bash_profile or ~/.zprofile
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec sway
fi
```

## Software Not Migrated

### Intentionally Excluded
- `which` - Built into bash/zsh
- `gcc` - Included via `build-essential`
- `gettext` - Usually pre-installed

### Needs Manual Installation
- **Navi** - Installed via pip, may need manual setup
- **Ydotool** - Not included (was in sway startup)
- **Pick** - Color picker, not in Debian repos

## Known Issues

### 1. Clipman
- `clipman` package availability varies by Debian version
- May need to install from source or use alternative (e.g., `copyq`)

### 2. Redshift
- May conflict with newer alternatives like `gammastep`
- Consider switching if issues arise

### 3. Font Rendering
- JetBrainsMono Nerd Font may need manual installation
- Waybar/Sway icons may not display without Nerd Fonts

### 4. Flatpak First Run
- First flatpak install may be slow
- Flatpak apps may need logout/login to appear in launcher

## Recommended Additional Software

### Not in Original Config
- `neovim` - Already in development category
- `htop` or `btop` - System monitoring
- `ripgrep` - Better grep
- `tldr` - Simplified man pages
- `tmux` - Terminal multiplexer

## Testing Checklist

- [ ] Ansible playbook runs without errors
- [ ] All apt packages install successfully
- [ ] Flatpak repository configured
- [ ] Flatpak apps install and launch
- [ ] Dotfiles symlinked correctly
- [ ] Zsh is default shell
- [ ] Starship prompt displays correctly
- [ ] Alacritty launches with correct theme
- [ ] Sway starts and displays correctly
- [ ] Waybar displays on all monitors
- [ ] Wofi launcher works
- [ ] Mako notifications appear
- [ ] Docker works without sudo
- [ ] Git configured with user info
- [ ] Neovim opens (even if empty config)

## Future Improvements

1. Add more package managers (e.g., `nix` for specific tools)
2. Implement custom waybar modules
3. Add backup/restore functionality
4. Create update script (like `topgrade`)
5. Add system monitoring/health checks
6. Implement the command-line tools from migration doc:
   - `search <name>` - Find package in all package managers
   - `try <match>` - Test package in distrobox
   - `add <match>` - Install and add to ansible
   - `fromwhere <name>` - Find where package is installed
   - `status` - Show ansible vs actual state
   - `clean` - Remove orphaned packages

