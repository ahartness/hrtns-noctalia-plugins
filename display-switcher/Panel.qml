import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

Item {
	id: root

	property var pluginApi: null
	property ShellScreen screen

	readonly property var geometryPlaceholder: container
	readonly property bool allowAttach: true

	readonly property var main: pluginApi?.mainInstance ?? null
	readonly property bool acting: main?.isActing ?? false
	readonly property bool hasError: !acting
		&& (main?.lastExitCode ?? -1) !== -1
		&& (main?.lastExitCode ?? -1) !== 0
	readonly property bool hasSuccess: (main?.lastRunSucceeded ?? false) && !acting

	property real contentPreferredWidth: Math.round(360 * Style.uiScaleRatio)
	property real contentPreferredHeight: Math.round(contentColumn.implicitHeight + Style.marginL * 2)

	Rectangle {
		id: container
		anchors.fill: parent
		color: "transparent"

		ColumnLayout {
			id: contentColumn
			anchors.fill: parent
			anchors.margins: Style.marginL
			spacing: Style.marginM

			NBox {
				Layout.fillWidth: true
				Layout.preferredHeight: Math.round(headerRow.implicitHeight + Style.marginM * 2)

				RowLayout {
					id: headerRow
					anchors.fill: parent
					anchors.margins: Style.marginM
					spacing: Style.marginM

					NIcon {
						icon: "device-desktop"
						pointSize: Style.fontSizeXL
						color: Color.mPrimary
					}

					NLabel {
						Layout.fillWidth: true
						label: pluginApi?.tr("panel.title")
					}

					NIconButton {
						icon: "close"
						tooltipText: pluginApi?.tr("panel.close")
						baseSize: Style.baseWidgetSize * 0.8
						onClicked: {
							if (pluginApi)
								pluginApi.closePanel(pluginApi.panelOpenScreen);
						}
					}
				}
			}

			NBox {
				Layout.fillWidth: true
				Layout.preferredHeight: Math.round(buttonColumn.implicitHeight + Style.marginM * 2)

				ColumnLayout {
					id: buttonColumn
					anchors.fill: parent
					anchors.margins: Style.marginM
					spacing: Style.marginS

					NLabel {
						Layout.fillWidth: true
						label: pluginApi?.tr("panel.display-switcher.title")
						description: pluginApi?.tr("panel.display-switcher.description")
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.display-switcher.single")
						enabled: !root.acting
						onClicked: main?.switchToSingle()
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.display-switcher.dual")
						enabled: !root.acting
						onClicked: main?.switchToDual()
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.display-switcher.ultrawide")
						enabled: !root.acting
						onClicked: main?.switchToUltrawide()
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.display-switcher.steamdeck")
						enabled: !root.acting
						onClicked: main?.switchToSteamdeck()
					}
				}
			}

			NBox {
				Layout.fillWidth: true
				Layout.preferredHeight: Math.round(scriptColumn.implicitHeight + Style.marginM * 2)

				ColumnLayout {
					id: scriptColumn
					anchors.fill: parent
					anchors.margins: Style.marginM
					spacing: Style.marginS

					NLabel {
						Layout.fillWidth: true
						label: pluginApi?.tr("panel.scripts.title")
						description: pluginApi?.tr("panel.scripts.description")
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.scripts.pipewire-fix-steam")
						enabled: !root.acting
						onClicked: main?.runPipewireFix()
					}

                    NButton {
                      Layout.fillWidth: true
                      text: pluginApi?.tr("panel.scripts.noctalia-reload")
                      enabled: !root.acting
                      onClicked: main?.reloadNoctalia()
                    }
				}
			}

			NBox {
				visible: root.acting || root.hasSuccess || root.hasError
				Layout.fillWidth: true
				Layout.preferredHeight: Math.round(statusColumn.implicitHeight + Style.marginM * 2)

				ColumnLayout {
					id: statusColumn
					anchors.fill: parent
					anchors.margins: Style.marginM
					spacing: Style.marginXS

					NLabel {
						Layout.fillWidth: true
						visible: root.acting
						label: pluginApi?.tr("panel.status.running")
						labelColor: Color.mTertiary
					}

					NLabel {
						Layout.fillWidth: true
						visible: root.hasSuccess && (main?.lastAction ?? "") === "displayLayout"
						label: pluginApi?.tr("panel.status.layout-success", {
							mode: main?.lastMode ?? ""
						})
						labelColor: Color.mPrimary
					}

					NLabel {
						Layout.fillWidth: true
						visible: root.hasSuccess && (main?.lastAction ?? "") === "pipewireFix"
						label: pluginApi?.tr("panel.status.pipewire-success")
						labelColor: Color.mPrimary
					}

                    NLabel {
                      Layout.fillWidth: true
                      visible: root.hasSuccess && (main?.lastAction ?? "") === "noctaliaReload"
                      label: pluginApi?.tr("panel.status.noctalia-success")
                      labelColor: Color.mPrimary
                    }

					NLabel {
						Layout.fillWidth: true
						visible: root.hasError
						label: (main?.lastError ?? "") !== ""
							? pluginApi?.tr("panel.status.error-detail", { error: main?.lastError ?? "" })
							: pluginApi?.tr("panel.status.error-code", { code: main?.lastExitCode ?? -1 })
						labelColor: Color.mError
					}
				}
			}
		}
	}
}
