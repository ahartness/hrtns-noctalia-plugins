import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var pluginApi: null

  IpcHandler {
    target: "plugin:onepassword-launcher"

    function toggle(): void {
      if (!root.pluginApi) {
        console.warn("1Password: plugin API is not available");
        return;
      }

      root.pluginApi.withCurrentScreen(function(screen) {
        root.pluginApi.toggleLauncher(screen);
      });
    }

    function open(): void {
      if (!root.pluginApi) {
        console.warn("1Password: plugin API is not available");
        return;
      }

      root.pluginApi.withCurrentScreen(function(screen) {
        root.pluginApi.openLauncher(screen);
      });
    }

    function close(): void {
      if (!root.pluginApi) {
        return;
      }

      root.pluginApi.withCurrentScreen(function(screen) {
        root.pluginApi.closeLauncher(screen);
      });
    }

    function refresh(): void {
      if (!root.pluginApi) {
        console.warn("1Password: plugin API is not available");
        return;
      }

      Quickshell.execDetached([
        root.pluginApi.pluginDir + "/op-launcher",
        "refresh"
      ]);
    }
  }
}
