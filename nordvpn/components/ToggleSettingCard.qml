import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

NBox {
    id: root

    required property var pluginApi
    required property string iconName
    required property string labelKey
    required property string enabledDescKey
    required property string disabledDescKey
    required property string currentValue        // "enabled" | "disabled" | "unknown"
    required property bool acting
    required property var onToggleRequested      // (isChecked: bool) => void

    Layout.fillWidth: true
    Layout.preferredHeight: Math.round(cardRow.implicitHeight + Style.marginM * 2)

    RowLayout {
        id: cardRow
        anchors.fill: parent
        anchors.margins: Style.marginM
        spacing: Style.marginM

        NIcon {
            icon: root.iconName
            pointSize: Style.fontSizeL
            color: root.currentValue === "enabled"
                   ? Color.mPrimary : Color.mOnSurfaceVariant
        }

        NLabel {
            label: root.pluginApi?.tr(root.labelKey) ?? ""
            description: {
                if (root.currentValue === "enabled")
                    return root.pluginApi?.tr(root.enabledDescKey) ?? "";
                if (root.currentValue === "disabled")
                    return root.pluginApi?.tr(root.disabledDescKey) ?? "";
                return root.pluginApi?.tr("panel.loading") ?? "Loading...";
            }
            Layout.fillWidth: true
        }

        NToggle {
            checked: root.currentValue === "enabled"
            enabled: !root.acting && root.currentValue !== "unknown"
            onToggled: (isChecked) => root.onToggleRequested(isChecked)
        }
    }
}
