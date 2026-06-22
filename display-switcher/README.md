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

## switch_layout.sh snippet

```bash
if [ "$1" == "single" ]; then
	SOURCE_CONFIG="$MONITOR_DIR/single.kdl"
elif [ "$1" == "dual" ]; then
	SOURCE_CONFIG="$MONITOR_DIR/dual.kdl"
elif [ "$1" == "ultrawide" ]; then
	SOURCE_CONFIG="$MONITOR_DIR/ultrawide.kdl"
elif [ "$1" == "steamdeck" ]; then
	SOURCE_CONFIG="$MONITOR_DIR/steamdeck.kdl"
else
	exit 1
fi

cp -f "$SOURCE_CONFIG" "$CURRENT_CONFIG"
niri validate
```

## How it works

1. You click a layout button in the panel.
2. The plugin calls `switch_layout.sh` with the selected mode (`single`, `dual`, `ultrawide`, or `steamdeck`).
3. The script maps that mode to a preset `.kdl` file in `~/.config/niri/cfg/monitors`.
4. It copies the chosen preset into `~/.config/niri/cfg/display.kdl`.
5. Finally, it runs `niri validate`, which triggers Niri to re-read the config.

Note: the script intentionally uses `cp` (real file copy) instead of a symlink because Niri KDL configs do not support symlinked config files.

## Settings

Default setting in `manifest.json`:

- `scriptPath`: `$HOME/.config/niri/cfg/monitors/switch_layout.sh`

If needed, change `scriptPath` in plugin settings to point to a custom location.

## Troubleshooting

- Ensure the script is executable:
	- `chmod +x ~/.config/niri/cfg/monitors/switch_layout.sh`
- Verify it works directly:
	- `~/.config/niri/cfg/monitors/switch_layout.sh dual`

