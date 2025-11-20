# Waybar Custom Modules

These are custom Rust programs that provide enhanced waybar modules for workspace display and system resource monitoring.

## Modules

### 1. Workspaces Module

**Purpose:** Displays workspace status with custom icons for running applications.

**Features:**
- Shows icons for applications in each workspace
- Different icons for: Spotify, Alacritty, Brave, Firefox, Steam, Teams, etc.
- Highlights visible/focused workspaces
- Per-monitor workspace display (workspaces 1-4, 11-14, 21-24)

**Dependencies:**
- `swaymsg` (from sway)
- `jq` (JSON processor)

### 2. Resources Module

**Purpose:** Displays CPU and GPU usage, temperature, and memory.

**Features:**
- CPU: Usage %, temperature, memory %
- GPU: Usage %, temperature, VRAM %
- Custom temperature monitoring via `sensors` and specific hardware paths

**Dependencies:**
- `lm-sensors` (for temperature monitoring)
- `rocm-smi` (for AMD GPU monitoring - adjust for NVIDIA if needed)
- `jq` (JSON processor)
- Rust crate: `sysinfo`

**Hardware-specific:**
- CPU temp reads from Kraken cooler sensor
- GPU temp reads from NVMe sensor (adjust paths in code for your hardware)

## Installation

### Prerequisites

```bash
# Install dependencies
sudo apt install -y lm-sensors jq

# For AMD GPUs
sudo apt install -y rocm-smi

# For NVIDIA GPUs (alternative)
# sudo apt install -y nvidia-smi
```

### Build and Install

```bash
cd waybar_modules

# Build workspaces module
cd workspaces
cargo build --release
sudo cp target/release/workspaces /usr/local/bin/
cd ..

# Build resources module
cd resources
cargo build --release
sudo cp target/release/resources /usr/local/bin/
cd ..
```

### Configure Sensors

```bash
# Detect sensors
sudo sensors-detect

# Test sensors output
sensors -j

# Find your specific sensor paths
sensors -j | jq '.'
```

Update the sensor paths in `resources/src/main.rs`:
- Line 73: CPU temperature sensor path
- Line 95: GPU temperature sensor path

Then rebuild the resources module.

## Usage in Waybar

The waybar config already includes these modules:

```json
"custom/workspaces": {
    "exec": "workspaces DP-1",
    "return-type": "json",
    "format": "{}",
    "tooltip": false,
    "escape": false
}

"custom/cpu_info": {
    "exec": "resources CPU",
    "return-type": "json",
    "format": "{}",
    "tooltip": false,
    "escape": false
}

"custom/gpu_info": {
    "exec": "resources GPU",
    "return-type": "json",
    "format": "{}",
    "tooltip": false,
    "escape": false
}
```

## Customization

### Workspaces Module

Edit `workspaces/src/main.rs`:

**Add application icons** (line 48-66):
```rust
match app {
    "YourApp" => "󰊫 ",  // Add your app and icon
    // ...
}
```

**Change workspace ranges** (line 28):
```rust
for ws_id in (1..=4).chain(11..=14).chain(20..=24) {
    // Adjust ranges for your setup
}
```

**Change monitor mappings** (line 116-123):
```rust
match screen_name {
    "HDMI-A-1" => vec!["1", "2", "3", "4"],
    "DP-1" => vec!["11", "12", "13", "14"],
    "DP-3" => vec!["21", "22", "23", "24"],
    // Update for your monitors
}
```

### Resources Module

Edit `resources/src/main.rs`:

**Change sensor paths** (lines 73, 95):
```rust
get_device_temp("your_sensor_path_here")
```

**For NVIDIA GPUs**, replace `rocm-smi` calls (line 78-96) with `nvidia-smi`:
```rust
let nvidia = Command::new("nvidia-smi")
    .args(["--query-gpu=utilization.gpu,utilization.memory", "--format=csv,noheader,nounits"])
    .stdout(Stdio::piped())
    .spawn()
    .expect("Failed to spawn nvidia-smi command.");
```

## Troubleshooting

### Workspaces module not showing

```bash
# Test manually
workspaces DP-1

# Check if swaymsg works
swaymsg -t get_workspaces

# Check if jq is installed
which jq
```

### Resources module errors

```bash
# Test manually
resources CPU
resources GPU

# Check sensors
sensors -j

# Check GPU monitoring
rocm-smi --showuse --showmemuse --json
# or for NVIDIA:
nvidia-smi
```

### Temperature not showing

```bash
# List all sensors
sensors -j | jq 'keys'

# Find your specific sensor
sensors -j | jq '.["your-sensor-name"]'

# Update the paths in resources/src/main.rs
```

## Notes

- Both modules run in infinite loops, updating every 100ms (workspaces) or 1000ms (resources)
- The workspaces module is monitor-aware and shows only relevant workspaces per screen
- The resources module is hardware-specific and may need adjustment for your system
- Icons use Nerd Font glyphs - ensure you have a Nerd Font installed

