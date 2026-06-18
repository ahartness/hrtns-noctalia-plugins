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
    readonly property string vpnStatus: main?.vpnStatus ?? "unknown"
    readonly property bool connected: vpnStatus === "connected"
    readonly property bool acting: main?.isActing ?? false

    property real contentPreferredWidth:  Math.round(360 * Style.uiScaleRatio)
    property real contentPreferredHeight: Math.round(mainCol.implicitHeight + Style.marginL * 2)

    Component.onCompleted: { if (main) main.refresh(); }

    Rectangle {
        id: container
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            id: mainCol
            anchors.fill: parent
            anchors.margins: Style.marginL
            spacing: Style.marginM

            // ── Header ───────────────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(headerRow.implicitHeight + Style.marginM * 2)

                RowLayout {
                    id: headerRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    NIcon {
                        icon: root.connected ? "brand-nord-vpn" : "brand-nord-vpn"
                        pointSize: Style.fontSizeXL
                        color: root.connected ? Color.mPrimary : Color.mOnSurfaceVariant
                    }

                    NLabel {
                        label: pluginApi?.tr("panel.title")
                        Layout.fillWidth: true
                    }

                    NIconButton {
                        icon: "refresh"
                        tooltipText: pluginApi?.tr("panel.refresh")
                        baseSize: Style.baseWidgetSize * 0.8
                        enabled: !root.acting
                        onClicked: main?.refresh()
                    }

                    NIconButton {
                        icon: "close"
                        tooltipText: pluginApi?.tr("panel.close")
                        baseSize: Style.baseWidgetSize * 0.8
                        onClicked: pluginApi.closePanel(pluginApi.panelOpenScreen)
                    }
                }
            }

            // ── Status card ──────────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(statusCol.implicitHeight + Style.marginM * 2)

                ColumnLayout {
                    id: statusCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginS

                    RowLayout {
                        spacing: Style.marginS

                        Rectangle {
                            width: Math.round(8 * Style.uiScaleRatio)
                            height: width
                            radius: width / 2
                            color: {
                                if (root.acting)    return Color.mTertiary;
                                if (root.connected) return Color.mPrimary;
                                if (root.vpnStatus === "disconnected") return Color.mError;
                                return Color.mOnSurfaceVariant;
                            }
                        }

                        NLabel {
                            label: {
                                if (root.acting)    return pluginApi?.tr("panel.status-connecting");
                                if (root.connected) return pluginApi?.tr("panel.status-connected");
                                if (root.vpnStatus === "disconnected") return pluginApi?.tr("panel.status-disconnected");
                                return pluginApi?.tr("panel.status-unknown");
                            }
                            labelColor: {
                                if (root.acting)    return Color.mTertiary;
                                if (root.connected) return Color.mPrimary;
                                if (root.vpnStatus === "disconnected") return Color.mError;
                                return Color.mOnSurfaceVariant;
                            }
                        }

                        NLabel {
                            visible: root.connected && (main?.protocol ?? "") !== ""
                            label: (main?.protocol ?? "").toUpperCase()
                            labelColor: Color.mOnSurfaceVariant
                            Layout.fillWidth: true
                        }
                    }

                    // Server name + location
                    NLabel {
                        visible: root.connected && (main?.serverLocation ?? "") !== ""
                        label: (main?.serverLocation ?? "") + ", " + (main?.serverName ?? "")
                        labelColor: Color.mOnSurface
                        Layout.fillWidth: true
                    }

                    // Transfer
                    NLabel {
                        visible: root.connected && (main?.transfer ?? "") !== ""
                        label: main?.transfer ?? ""
                        labelColor: Color.mOnSurface
                        Layout.fillWidth: true
                    }

                    // uptime
                    NLabel {
                        visible: root.connected && (main?.uptime ?? "") !== ""
                        label: main?.uptime ?? ""
                        labelColor: Color.mOnSurface
                        Layout.fillWidth: true
                    }

                    // Load bar
                    RowLayout {
                        visible: root.connected && (main?.serverLoad ?? -1) >= 0
                        spacing: Style.marginS

                        NLabel {
                            label: pluginApi?.tr("panel.load")
                            labelColor: Color.mOnSurfaceVariant
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: Math.round(4 * Style.uiScaleRatio)
                            radius: height / 2
                            color: Color.mSurfaceVariant

                            Rectangle {
                                width: parent.width * Math.min(1, Math.max(0, (main?.serverLoad ?? 0) / 100))
                                height: parent.height
                                radius: parent.radius
                                color: (main?.serverLoad ?? 0) > 80 ? Color.mError
                                     : (main?.serverLoad ?? 0) > 50 ? Color.mTertiary
                                     : Color.mPrimary
                                Behavior on width { NumberAnimation { duration: 300 } }
                            }
                        }

                        NLabel {
                            label: (main?.serverLoad ?? 0) + "%"
                            labelColor: Color.mOnSurfaceVariant
                        }
                    }

                    // Error message
                    NLabel {
                        visible: (main?.lastError ?? "") !== ""
                        label: main?.lastError ?? ""
                        labelColor: Color.mError
                        Layout.fillWidth: true
                    }
                }
            }

            // ── Primary action ───────────────────────────────────────────────
            NButton {
                Layout.fillWidth: true
                text: root.connected ? pluginApi?.tr("panel.disconnect") : pluginApi?.tr("panel.connect")
                enabled: !root.acting && root.vpnStatus !== "unknown"
                onClicked: root.connected ? main?.disconnect() : main?.connect()
            }

            // ── Kill switch ──────────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(ksRow.implicitHeight + Style.marginM * 2)

                RowLayout {
                    id: ksRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    NIcon {
                        icon: "bolt"
                        pointSize: Style.fontSizeL
                        color: (main?.killSwitch ?? "disabled") === "enabled"
                               ? Color.mPrimary : Color.mOnSurfaceVariant
                    }

                    NLabel {
                        label: pluginApi?.tr("panel.kill-switch")
                        description: {
                            const ks = main?.killSwitch ?? "unknown";
                            if (ks === "enabled")      return pluginApi?.tr("panel.kill-switch-desc");
                            if (ks === "disabled")      return pluginApi?.tr("panel.kill-switch-disabled");
                            return pluginApi?.tr("panel.loading");
                        }
                        Layout.fillWidth: true
                    }

                    NToggle {
                        checked: (main?.killSwitch ?? "disabled") === "enabled"
                        enabled: !root.acting && (main?.killSwitch ?? "unknown") !== "unknown"
                        onToggled: (isChecked) => main?.setKillSwitch(isChecked ? "on" : "off")
                    }
                }
            }

            // ── Meshnet ──────────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(mnRow.implicitHeight + Style.marginM * 2)

                RowLayout {
                    id: mnRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    NIcon {
                        icon: "cloud-network"
                        pointSize: Style.fontSizeL
                        color: (main?.meshnet ?? "disabled") === "enabled"
                               ? Color.mPrimary : Color.mOnSurfaceVariant
                    }

                    NLabel {
                        label: pluginApi?.tr("panel.meshnet")
                        description: {
                            const mn = main?.meshnet ?? "unknown";
                            if (mn === "enabled")      return pluginApi?.tr("panel.meshnet-desc");
                            if (mn === "disabled")      return pluginApi?.tr("panel.meshnet-disabled");
                            return pluginApi?.tr("panel.loading");
                        }
                        Layout.fillWidth: true
                    }

                    NToggle {
                        checked: (main?.meshnet ?? "disabled") === "enabled"
                        enabled: !root.acting && (main?.meshnet ?? "unknown") !== "unknown"
                        onToggled: (isChecked) => main?.setMeshnet(isChecked ? "on" : "off")
                    }
                }
            }

            // ── LAN Discovery ──────────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(ldRow.implicitHeight + Style.marginM * 2)

                RowLayout {
                    id: ldRow
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginM

                    NIcon {
                        icon: "devices-pc"
                        pointSize: Style.fontSizeL
                        color: (main?.lanDiscovery ?? "disabled") === "enabled"
                               ? Color.mPrimary : Color.mOnSurfaceVariant
                    }

                    NLabel {
                        label: pluginApi?.tr("panel.lan-discovery")
                        description: {
                            const mn = main?.lanDiscovery ?? "unknown";
                            if (mn === "enabled")      return pluginApi?.tr("panel.lan-discovery-desc");
                            if (mn === "disabled")      return pluginApi?.tr("panel.lan-discovery-disabled");
                            return pluginApi?.tr("panel.loading");
                        }
                        Layout.fillWidth: true
                    }

                    NToggle {
                        checked: (main?.lanDiscovery ?? "disabled") === "enabled"
                        enabled: !root.acting && (main?.lanDiscovery ?? "unknown") !== "unknown"
                        onToggled: (isChecked) => main?.setLanDiscovery(isChecked ? "on" : "off")
                    }
                }
            }
          }
    }
}
