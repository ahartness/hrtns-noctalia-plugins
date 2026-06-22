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
	readonly property bool hasError: (main?.lastError ?? "") !== ""
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
						label: pluginApi?.tr("panel.title") ?? "Display Switcher"
					}

					NIconButton {
						icon: "close"
						tooltipText: pluginApi?.tr("panel.close") ?? "Close"
						baseSize: Style.baseWidgetSize * 0.8
						onClicked: pluginApi.closePanel(pluginApi.panelOpenScreen)
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
						label: pluginApi?.tr("panel.choose-layout") ?? "Choose a monitor layout"
						labelColor: Color.mOnSurfaceVariant
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.single") ?? "Single"
						enabled: !root.acting
						onClicked: main?.switchToSingle()
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.dual") ?? "Dual"
						enabled: !root.acting
						onClicked: main?.switchToDual()
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.ultrawide") ?? "Ultrawide"
						enabled: !root.acting
						onClicked: main?.switchToUltrawide()
					}

					NButton {
						Layout.fillWidth: true
						text: pluginApi?.tr("panel.steamdeck") ?? "Steam Deck"
						enabled: !root.acting
						onClicked: main?.switchToSteamdeck()
					}
				}
			}

			NBox {
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
						label: pluginApi?.tr("panel.switching") ?? "Switching display layout..."
						labelColor: Color.mTertiary
					}

					NLabel {
						Layout.fillWidth: true
						visible: root.hasSuccess
						label: pluginApi?.tr("panel.success", {
							mode: main?.lastMode ?? ""
						}) ?? "Layout switched"
						labelColor: Color.mPrimary
					}

					NLabel {
						Layout.fillWidth: true
						visible: root.hasError
						label: (pluginApi?.tr("panel.error-prefix") ?? "Failed:") + " " + (main?.lastError ?? "")
						labelColor: Color.mError
						wrapMode: Text.Wrap
					}
				}
			}
		}
	}
}
