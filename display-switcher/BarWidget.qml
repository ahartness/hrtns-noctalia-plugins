import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI

Item {
	id: root

	property var pluginApi: null
	property ShellScreen screen
	readonly property var main: pluginApi?.mainInstance ?? null
	readonly property string lastMode: main?.lastMode ?? ""
	readonly property string barIcon: {
		if (lastMode === "dual")
			return "device-desktop-plus";
		if (lastMode === "steamdeck")
			return "device-gamepad";
		return "device-desktop";
	}

	implicitWidth: pill.width
	implicitHeight: pill.height

	BarPill {
		id: pill
		screen: root.screen
		oppositeDirection: true
		autoHide: false

		icon: root.barIcon
		text: ""
		tooltipText: pluginApi?.tr("bar.tooltip") ?? "Display layouts"

		onClicked: {
			if (pluginApi)
				pluginApi.openPanel(root.screen, pill);
		}

		onRightClicked: {
			if (pluginApi)
				BarService.openPluginSettings(screen, pluginApi.manifest);
		}
	}
}
