import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets
import "./components"

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

    Component.onCompleted: {
        if (!main) return;
        main.refresh();
        main.fetchUsCities(false);
    }

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
                        onClicked: {
                            main?.refresh();
                            main?.fetchUsCities(true);
                        }
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

            // ── Connect to city ────────────────────────────────────────────
            NBox {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(cityCol.implicitHeight + Style.marginM * 2)

                ColumnLayout {
                    id: cityCol
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginS

                    NLabel {
                        label: pluginApi?.tr("panel.city-country", {
                            country: (main?.selectedCountry ?? "us").toUpperCase()
                        })
                        labelColor: Color.mOnSurfaceVariant
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS

                        ComboBox {
                            id: cityCombo
                            Layout.fillWidth: true
                            model: main?.usCities ?? []
                            enabled: !root.acting && !(main?.isLoadingCities ?? false) && (main?.usCities?.length ?? 0) > 0

                            currentIndex: {
                                const cities = main?.usCities ?? [];
                                const selected = main?.selectedCity ?? "";
                                return cities.indexOf(selected);
                            }

                            onActivated: {
                                const cities = main?.usCities ?? [];
                                if (index >= 0 && index < cities.length)
                                    main.selectedCity = cities[index];
                            }
                        }

                        NButton {
                            text: pluginApi?.tr("panel.connect-city")
                            enabled: !root.acting
                                && !(main?.isLoadingCities ?? false)
                                && ((main?.selectedCity ?? "") !== "")
                            onClicked: main?.connectToCity(main?.selectedCity ?? "")
                        }
                    }

                    NLabel {
                        visible: (main?.isLoadingCities ?? false)
                        label: pluginApi?.tr("panel.loading-cities-country", {
                            country: (main?.selectedCountry ?? "us").toUpperCase()
                        })
                        labelColor: Color.mOnSurfaceVariant
                    }
                }
            }

            // ── Kill switch ──────────────────────────────────────────────────
            ToggleSettingCard {
                pluginApi: root.pluginApi
                iconName: "bolt"
                labelKey: "panel.kill-switch"
                enabledDescKey: "panel.kill-switch-desc"
                disabledDescKey: "panel.kill-switch-disabled"
                currentValue: main?.killSwitch ?? "unknown"
                acting: root.acting
                onToggleRequested: (isChecked) => main?.setKillSwitch(isChecked ? "on" : "off")
            }

            // ── Meshnet ──────────────────────────────────────────────────
            ToggleSettingCard {
                pluginApi: root.pluginApi
                iconName: "cloud-network"
                labelKey: "panel.meshnet"
                enabledDescKey: "panel.meshnet-desc"
                disabledDescKey: "panel.meshnet-disabled"
                currentValue: main?.meshnet ?? "unknown"
                acting: root.acting
                onToggleRequested: (isChecked) => main?.setMeshnet(isChecked ? "on" : "off")
            }

            // ── LAN Discovery ──────────────────────────────────────────────────
            ToggleSettingCard {
                pluginApi: root.pluginApi
                iconName: "devices-pc"
                labelKey: "panel.lan-discovery"
                enabledDescKey: "panel.lan-discovery-desc"
                disabledDescKey: "panel.lan-discovery-disabled"
                currentValue: main?.lanDiscovery ?? "unknown"
                acting: root.acting
                onToggleRequested: (isChecked) => main?.setLanDiscovery(isChecked ? "on" : "off")
            }
          }
    }
}
