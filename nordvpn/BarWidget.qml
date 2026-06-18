import QtQuick
import Quickshell
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Widgets

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property var pluginSettings: pluginApi?.pluginSettings ?? ({})
    readonly property var main: pluginApi?.mainInstance ?? ({})

    readonly property string screenName: screen?.name ?? ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"

    readonly property string displayMode: pluginSettings.displayMode ?? "alwaysShow"
    readonly property string connectedColor: pluginSettings.connectedColor ?? "primary"
    readonly property string disconnectedColor: pluginSettings.disconnectedColor ?? "error"

    readonly property string vpnStatus: main.vpnStatus ?? "unknown"
    readonly property bool connected: vpnStatus === "connected"
    readonly property bool isLoading: main.isLoading ?? false

    readonly property string pillIcon: {
        if (isLoading) return "reload";
        return "brand-nord-vpn";
    }

    readonly property string pillText: {
        if (isLoading) return pluginApi?.tr("bar.connecting-state") ?? "Connecting...";
        if (connected) return pluginApi?.tr("bar.connected-state", { location: main.serverLocation ?? "Unknown" }) ?? "VPN Connected";
        return pluginApi?.tr("bar.disconnected-state") ?? "VPN Disconnected";
    }

    readonly property color activeColor: connected ? connectedColor : disconnectedColor

    implicitWidth: pill.width
    implicitHeight: pill.height

    NPopupContextMenu {
        id: contextMenu
        model: [{
            label: pluginApi?.tr("settings.pluginSettings"),
            action: "plugin-settings",
            icon: "settings"
        }]
        onTriggered: (action) => {
            contextMenu.close();
            PanelService.closeContextMenu(screen);
            if (action === "plugin-settings" && pluginApi)
                BarService.openPluginSettings(screen, pluginApi.manifest);
        }
    }

    BarPill {
        id: pill
        screen: root.screen
        oppositeDirection: true 
        autoHide: false

        icon: root.pillIcon
        text: root.pillText
        tooltipText: {
            if (root.connected) {
                const loc = root.main.serverLocation ?? "";
                const name = root.main.serverName ?? "";
                const parts = [];
                if (loc) parts.push(loc);
                if (name) parts.push(name);
                return parts.length === 0 ? root.pillText : parts.join(" · ");
            }
            return pluginApi?.tr("bar.disconnected-state");
        }

        customIconColor: Color.resolveColorKeyOptional(root.activeColor)
        customTextColor: Color.resolveColorKeyOptional(root.activeColor)

        forceOpen: !root.isBarVertical && root.displayMode === "alwaysShow"
        forceClose: root.isBarVertical || root.displayMode === "alwaysHide"

        onClicked: {
            if (pluginApi)
                pluginApi.openPanel(root.screen, pill);
        }

        onRightClicked: {
            PanelService.showContextMenu(contextMenu, pill, screen);
        }
    }
}
