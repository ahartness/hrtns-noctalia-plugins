# Noctalia Plugins Repository

This repository contains Noctalia plugins. It is structured to support multiple plugins over time.

Currently, the only plugin included is the NordVPN plugin in `nordvpn/`.

## Current Plugin: NordVPN

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

## Planned Improvement

- [ ] For the NordVPN plugin, a planned enhancement is to add a connect option that offers a city dropdown list generated via `nordvpn cities <country>`.
- [ ] Fix the tooltip on the `BarWidget.qml`
