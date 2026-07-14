import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
	id: root

	property var pluginApi: null

	readonly property string configuredScriptPath: pluginApi?.pluginSettings?.scriptPath ?? "$HOME/.config/hypr/monitors/switch_layout.sh"

	property bool isActing: false
	property string lastError: ""
	property string lastMode: ""
	property bool lastRunSucceeded: false

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
			root.lastError = code === 0 ? "" : actionStderr.text.trim();
		}
	}

	function _shellQuote(value) {
		const s = "" + value;
		return "'" + s.replace(/'/g, "'\\''") + "'";
	}

	function _runLayout(mode) {
		if (root.isActing)
			return;

		const normalized = ("" + mode).trim().toLowerCase();
		if (["single", "dual", "ultrawide", "steamdeck"].indexOf(normalized) === -1)
			return;

		root.isActing = true;
		root.lastError = "";
		root.lastMode = normalized;
		root.lastRunSucceeded = false;

		const commandText = root._shellQuote(root.configuredScriptPath) + " " + root._shellQuote(normalized);
		actionProc.command = ["sh", "-lc", commandText];
		actionProc.running = true;
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
}
