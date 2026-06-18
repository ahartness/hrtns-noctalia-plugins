import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    // Connection state
    property string vpnStatus: "unknown"   // "connected" | "disconnected" | "unknown"
    property string serverName: ""
    property string serverLocation: ""
    property string protocol: ""
    property string transfer: ""
    property string uptime: ""
    property int    serverLoad: -1
    property bool   isLoading: true        // true until first poll result
    property bool   isActing: false        // true while connect/disconnect/config runs
    property string lastError: ""

    // Config state
    property string killSwitch: "unknown"  // "disabled" | "enabled" | "unknown"
    property string meshnet: "unknown"
    property string lanDiscovery: "unknown"

    readonly property int pollInterval: pluginApi?.pluginSettings?.pollInterval ?? 5000

    // ── Status polling ────────────────────────────────────────────────────────

    function refresh() {
        if (!statusProc.running) statusProc.running = true;
        if (!configProc.running) configProc.running = true;
    }

    StdioCollector {
        id: statusOut
        onStreamFinished: {
            root.isLoading = false;
            const text = this.text.trim();
            const statusMatch = text.match(/Status:\s*(\S+)/i);
            if (!statusMatch) { root.vpnStatus = "unknown"; return; }

            if (statusMatch[1].toLowerCase() === "connected") {
                root.vpnStatus = "connected";
                const cityMatch = text.match(/City:\s+(\S+)/i);
                if (cityMatch) {
                    root.serverLocation = cityMatch[1].trim();
                }
                const transferMatch = text.match(/Transfer:\s*(.+)/i);
                const serverMatch = text.match(/Server:\s*(.+)/i);
                const uptimeMatch = text.match(/Uptime:\s*(.+)/i);
                root.transfer = transferMatch ? transferMatch[1] : "";
                root.serverName = serverMatch ? serverMatch[1] : "";
                root.uptime = uptimeMatch ? uptimeMatch[1] : "";
            } else {
                root.vpnStatus = "disconnected";
                root.serverName = root.serverLocation = "";
                root.serverLoad = -1;
            }
        }
    }

    Process {
        id: statusProc
        command: ["nordvpn", "status"]
        running: false
        stdout: statusOut
        onExited: (code) => {
            root.isLoading = false;
            if (code !== 0 && root.vpnStatus !== "connected")
                root.vpnStatus = "disconnected";
        }
    }

    StdioCollector {
        id: configOut
        onStreamFinished: {
            const ksMatch = this.text.match(/Kill Switch:\s+(\S+)/i);
            const mnMatch = this.text.match(/Meshnet:\s+(\S+)/i);
            const lanMatch = this.text.match(/LAN Discovery:\s+(\S+)/i)
            root.killSwitch = ksMatch ? ksMatch[1].toLowerCase() : "unknown";
            root.meshnet = mnMatch ? mnMatch[1].toLowerCase() : "unknown";
            root.lanDiscovery = lanMatch ? lanMatch[1].toLowerCase() : "unknown";
        }
    }

    Process {
        id: configProc
        command: ["nordvpn", "settings"]
        running: false
        stdout: configOut
    }

    Timer {
        interval: root.pollInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // ── Actions ───────────────────────────────────────────────────────────────

    StdioCollector { id: actionOut }
    StdioCollector { id: actionErr }

    Process {
        id: actionProc
        running: false
        stdout: actionOut
        stderr: actionErr
        onExited: (code) => {
            root.isActing = false;
            root.lastError = code !== 0 ? actionErr.text.trim() : "";
            root.refresh();
        }
    }

    function _run(cmd) {
        if (root.isActing) return;
        root.isActing = true;
        root.lastError = "";
        actionProc.command = cmd;
        actionProc.running = true;
    }

    function connect()           { _run(["nordvpn", "connect"]);                          }
    function disconnect()        { _run(["nordvpn", "disconnect"]);                       }

    function setKillSwitch(value) {
        // value: "off" | "on"
        _run(["nordvpn", "set", "killswitch", value]);
    }
    
    function setMeshnet(value) {
        // value: "off" | "on"
        _run(["nordvpn", "set", "meshnet", value]);
    }

    function setLanDiscovery(value) {
        // value: "off" | "on"
        _run(["nordvpn", "set", "lan-discovery", value]);
    }
}
