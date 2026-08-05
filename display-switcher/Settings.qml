import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
	id: root

	property var pluginApi: null
	property var cfg: pluginApi?.pluginSettings || ({})
	property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
	property string editScriptPath: cfg.scriptPath ?? defaults.scriptPath ?? ""

	spacing: Style.marginL

	NTextInput {
		Layout.fillWidth: true
		label: pluginApi?.tr("settings.scriptPath.label")
		description: pluginApi?.tr("settings.scriptPath.description")
		text: root.editScriptPath
		onTextChanged: root.editScriptPath = text
	}

	function saveSettings() {
		if (!pluginApi)
			return;

		pluginApi.pluginSettings.scriptPath = root.editScriptPath.trim();
		pluginApi.saveSettings();
		Logger.i("DisplaySwitcher", "Settings saved");
	}
}
