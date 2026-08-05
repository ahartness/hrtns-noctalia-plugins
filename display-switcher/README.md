# Script Utilities - Noctalia Plugin

Script Utilities adds a bar icon and panel for frequently used display and system maintenance actions.

## Features

### Display Switcher

The Display Switcher group keeps the existing monitor layout actions:

- Single 16:9 Monitor
- Dual Monitor Setup
- Ultrawide Monitor
- Steam Deck

Each button runs the configured display layout script with `single`, `dual`, `ultrawide`, or `steamdeck` as its first argument.

### Scripts

The Scripts group currently provides:

- **Pipewire Fix (Steam)** — restarts the Pipewire, Pipewire Pulse, and WirePlumber systemd user services with:

  ```bash
  systemctl --user restart pipewire pipewire-pulse wireplumber
  ```

## Requirements

- Noctalia `>= 3.6.0`
- An executable display layout script for the Display Switcher actions
- `systemctl` and systemd user services for the Pipewire Fix action

## Settings

Right-click the Script Utilities bar widget to open its settings. Enter the absolute path to the display layout script, then save the settings.

The configured script receives one of these values as its first argument:

- `single`
- `dual`
- `ultrawide`
- `steamdeck`

## Behavior

- Left-click the bar widget to open the Script Utilities panel.
- Right-click the bar widget to open plugin settings.
- Only one utility can run at a time.
- The panel reports whether the utility succeeded or failed, including stderr output when available.

## Troubleshooting

- Ensure the display layout script exists and is executable.
- Run the configured display command directly with a layout argument to verify it.
- If Pipewire Fix fails, verify that `pipewire`, `pipewire-pulse`, and `wireplumber` are systemd user services on your system.
