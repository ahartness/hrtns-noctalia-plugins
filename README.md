# Noctalia Plugins Repository

This repository contains Noctalia plugins. It is structured to support multiple plugins over time.

## Included Plugins

- `display-switcher/` - Display layout switcher with bar icon and panel actions
- `nordvpn/` - NordVPN status and controls

## Plugin: Display Switcher

The Display Switcher plugin adds a display icon to the Noctalia bar and opens a panel with quick layout buttons.

### Features

- Icon-only bar widget
- Panel buttons to switch display presets:
  - Single
  - Dual
  - Ultrawide
  - Steam Deck
- Runs your Niri layout script with matching mode arguments
- Bar icon changes by last selected layout:
  - `device-desktop` for `single` and `ultrawide`
  - `device-desktop-plus` for `dual`
  - `device-gamepad` for `steamdeck`

### Requirements

- Noctalia `>= 3.6.0`
- Niri installed
- Script available at:
  - `$HOME/.config/niri/cfg/monitors/switch_layout.sh`

### Configuration

Default plugin settings in `display-switcher/manifest.json`:

- `scriptPath`: `$HOME/.config/niri/cfg/monitors/switch_layout.sh`

## Plugin: NordVPN

The NordVPN plugin adds a NordVPN status widget to the Noctalia bar and a control panel for common NordVPN actions.

### Features

- Shows VPN status directly in the bar (`connected`, `disconnected`, or `unknown` while loading)
- Displays server location in the bar when connected
- Opens a panel with connection details:
  - server/location
  - transfer stats
  - uptime
  - server load
- Quick actions in the panel:
  - connect
  - disconnect
  - refresh
- Toggle NordVPN settings from the panel:
  - Kill Switch
  - Meshnet
  - LAN Discovery

### Requirements

- Noctalia `>= 3.6.0`
- NordVPN CLI installed and available in `PATH`
- An authenticated NordVPN session (`nordvpn login`)

### Installation

Place this plugin folder under your Noctalia plugins directory and ensure Noctalia loads it.

Expected files:

- `manifest.json`
- `Main.qml`
- `BarWidget.qml`
- `Panel.qml`
- `i18n/en.json`

Add the id to the `plugins.json`

Finally, restart Noctalia or reload plugins.

[Full Noctalia Widget Docs](https://docs.noctalia.dev/v4/development/guidelines/)

### Configuration

Default plugin settings are defined in `manifest.json`:

- `displayMode`: `alwaysShow`
- `connectedColor`: `primary`
- `disconnectedColor`: `error`
- `country`: `us` (update this to your country if outside of US)
- `pollInterval`: `5000` (ms)

### How It Works

- Polls `nordvpn status` and `nordvpn settings` on an interval.
- Updates bar text/icon based on state.
- Runs actions through NordVPN CLI commands:
  - `nordvpn connect`
  - `nordvpn disconnect`
  - `nordvpn set killswitch <on|off>`
  - `nordvpn set meshnet <on|off>`
  - `nordvpn set lan-discovery <on|off>`

### Troubleshooting

- If status stays unknown or disconnected, confirm the CLI works in terminal:
  - `nordvpn status`
  - `nordvpn settings`
- If actions fail, check NordVPN authentication and permissions.
- If the widget does not appear, verify the plugin manifest and entry points.

### Project Metadata

- ID: `nordvpn`
- Version: `0.1.0`
- License: `MIT`

## Installation

Place plugin folders under your Noctalia plugins directory and ensure Noctalia loads them.

Each plugin directory should contain:

- `manifest.json`
- `Main.qml`
- `BarWidget.qml`
- `Panel.qml`
- `i18n/en.json`

Add desired plugin IDs to your `plugins.json`, then restart Noctalia or reload plugins.

[Full Noctalia Widget Docs](https://docs.noctalia.dev/v4/development/guidelines/)

## Planned Improvement

- [x] For the NordVPN plugin, a planned enhancement is to add a connect option that offers a city dropdown list generated via `nordvpn cities <country>`.
- [x] Fix the tooltip on the `BarWidget.qml`
