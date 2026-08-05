import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
	id: root

	property var pluginApi: null

	property var cfg: pluginApi?.pluginSettings || ({})
	property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
	readonly property string configuredScriptPath: cfg.scriptPath ?? defaults.scriptPath ?? ""

	property bool isActing: false
	property string lastError: ""
	property string lastAction: ""
	property string lastMode: ""
	property bool lastRunSucceeded: false
	property int lastExitCode: -1

	StdioCollector {
		id: actionStdout
	}

	StdioCollector {
		id: actionStderr
	}

	Process {
		id: actionProc
		running: false
		stdout: actionStdout
		stderr: actionStderr

		onExited: (code) => {
			root.isActing = false;
			root.lastRunSucceeded = code === 0;
			root.lastExitCode = code;
			root.lastError = code === 0 ? "" : actionStderr.text.trim();
		}
	}

	function _shellQuote(value) {
		const s = "" + value;
		return "'" + s.replace(/'/g, "'\\''") + "'";
	}

	function _runCommand(action, command) {
		if (root.isActing)
			return;

		root.isActing = true;
		root.lastError = "";
		root.lastAction = action;
		root.lastRunSucceeded = false;
		root.lastExitCode = -1;

		actionProc.command = command;
		actionProc.running = true;
	}

	function _runLayout(mode) {
		if (root.isActing)
			return;

		const normalized = ("" + mode).trim().toLowerCase();
		if (["single", "dual", "ultrawide", "steamdeck"].indexOf(normalized) === -1)
			return;

		root.lastMode = normalized;

		const commandText = root._shellQuote(root.configuredScriptPath) + " " + root._shellQuote(normalized);
		root._runCommand("displayLayout", ["sh", "-lc", commandText]);
	}

	function switchToSingle() {
		_runLayout("single");
	}

	function switchToDual() {
		_runLayout("dual");
	}

	function switchToUltrawide() {
		_runLayout("ultrawide");
	}

	function switchToSteamdeck() {
		_runLayout("steamdeck");
	}

	function runPipewireFix() {
		_runCommand("pipewireFix", [
			"systemctl",
			"--user",
			"restart",
			"pipewire",
			"pipewire-pulse",
			"wireplumber"
		]);
	}

    // qs kill --pid "$(qs list --all | awk '/^[[:space:]]*Process ID:/ { print $3; exit }')" && hyprctl reload
    function reloadNoctalia() {
      _runCommand("reloadNoctalia", [
        "sh",
        "-c",
        "qs kill --pid \"$(qs list --all | awk '/^[[:space:]]*Process ID:/ { print $3; exit }')\" && hyprctl reload"
      ]);
    }}
}
