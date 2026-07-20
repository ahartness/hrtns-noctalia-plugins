# Noctalia Plugins

A collection of plugins for [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell), including launcher integrations, display controls, and network status tools.

## Plugins

| Plugin | Description | Entry point | Requirements |
| --- | --- | --- | --- |
| [1Password Launcher](./1password-launcher/) | Search 1Password Login items from the Noctalia launcher, then copy usernames or passwords to the clipboard. | Launcher provider | 1Password CLI (`op`), `jq`, `wl-copy` |
| [Display Switcher](./display-switcher/) | Switch between predefined monitor layouts from a Noctalia bar widget and panel. | Bar widget and panel | Niri and a layout-switching script |
| [NordVPN Status](./nordvpn/) | View NordVPN connection status and server details, connect or disconnect, refresh status, and manage selected VPN settings. | Bar widget and panel | NordVPN CLI and an authenticated session |

Use the linked plugin directory for detailed requirements, configuration, troubleshooting, and implementation notes.

## Installation

Install a plugin using the Noctalia plugin workflow, or clone/copy its directory into your Noctalia plugins directory. Enable the plugin by its manifest ID, then restart Noctalia or reload plugins.

Each plugin has its own `manifest.json` with the required entry points and default settings. Refer to the [Noctalia plugin documentation](https://docs.noctalia.dev/development/plugins/overview/) for current installation and configuration instructions.

## Requirements

All plugins require a compatible version of Noctalia Shell. Additional requirements are listed in the plugin catalog above and in each plugin’s README.

## Development

Plugins are implemented as QML components and follow Noctalia’s plugin API and widget conventions. When contributing a plugin or change:

- Keep the plugin manifest, entry points, and translations in sync.
- Route user-facing strings through the plugin translation system.
- Use Noctalia widgets and shared style constants for consistent theming.
- Test the plugin in Noctalia Shell, including relevant empty, loading, and error states.

See the [Noctalia development guidelines](https://docs.noctalia.dev/development/guideline/) for the broader plugin conventions.

## License

Licensing is specified per plugin in its `manifest.json`.
