# Display Switcher - Noctalia Bar Widget

This plugin adds a display icon to the Noctalia bar. Clicking the icon opens a panel with quick layout buttons:

- Single
- Dual
- Ultrawide
- Steam Deck

Each button runs your Niri layout switch script with the matching argument.

## Requirements

- Noctalia `>= 3.6.0`
- Niri installed
- Script available at:
	- `$HOME/.config/niri/cfg/monitors/switch_layout.sh`

## Behavior

- Bar widget shows icon only (no text)
- Left click opens panel
- Right click opens plugin context menu
- Panel buttons run:
	- `switch_layout.sh single`
	- `switch_layout.sh dual`
	- `switch_layout.sh ultrawide`
	- `switch_layout.sh steamdeck`

## Settings

Default setting in `manifest.json`:

- `scriptPath`: `$HOME/.config/niri/cfg/monitors/switch_layout.sh`

If needed, change `scriptPath` in plugin settings to point to a custom location.

## Troubleshooting

- Ensure the script is executable:
	- `chmod +x ~/.config/niri/cfg/monitors/switch_layout.sh`
- Verify it works directly:
	- `~/.config/niri/cfg/monitors/switch_layout.sh dual`

