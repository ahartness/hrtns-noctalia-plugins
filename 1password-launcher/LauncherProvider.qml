import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var pluginApi: null
  property var launcher: null
  property string name: "1Password"
  property bool handleSearch: false
  property string supportedLayouts: "list"
  property bool supportsAutoPaste: false
  property var database: []
  property bool loaded: false

  function openLauncher(query) {
    if (!launcher) {
      console.warn("1Password: Launcher is not available");
      return;
    }

    var searchText = ">op";

    if (query && query.trim() !== "") {
      searchText += " " + query.trim();
    } else {
      searchText += " ";
    }

    launcher.setSearchText(searchText);
    launcher.open();
  }

  IpcHandler {
    target: "onepassword"

    function open(): void {
      root.openLauncher("");
    }

    function search(query: string): void {
      root.openLauncher(query);
    }

    function refresh(): void {
      root.refresh();
    }
  }

  function helperPath() {
    return pluginApi.pluginDir + "/op-launcher";
  }

  function refresh() {
    Quickshell.execDetached([helperPath(), "refresh"]);
  }

  function loadDatabase() {
    try {
      var contents = databaseLoader.text();

      if (!contents || contents.trim() === "") {
        database = [];
        loaded = true;
        return;
      }

      database = JSON.parse(contents);
      loaded = true;

      if (launcher) {
        launcher.updateResults();
      }
    } catch (error) {
      console.warn("Unable to load 1Password index:", error);
      database = [];
      loaded = true;
    }
  }

  function matchesCommand(searchText) {
    return searchText === ">op" || searchText.startsWith(">op ");
  }

  function handleCommand(searchText) {
    return matchesCommand(searchText);
  }

  function commands() {
    return [
      {
        "name": ">op",
        "description": "Search 1Password login items",
        "icon": "key",
        "isTablerIcon": true,
        "onActivate": function() {
          launcher.setSearchText(">op ");
        }
      }
    ];
  }

  function copyField(item, field) {
    Quickshell.execDetached([
      helperPath(),
      "copy",
      item.id,
      item.vaultId,
      field
    ]);

    if (launcher) {
      launcher.close();
    }
  }

  function formatResult(item) {
    var description = item.username || "No username";

    if (item.vaultName) {
      description += " · " + item.vaultName;
    }

    return {
      "name": item.title,
      "description": description,
      "icon": "key",
      "isTablerIcon": true,
      "provider": root,
      "opItem": item,
      "onActivate": function() {
        root.copyField(item, "password");
      }
    };
  }

  function getResults(searchText) {
    if (!matchesCommand(searchText)) {
      return [];
    }

    var query = searchText.slice(3).trim().toLowerCase();

    if (query === "!refresh") {
      return [
        {
          "name": "Refresh 1Password index",
          "description": "Reload login metadata from 1Password",
          "icon": "refresh",
          "isTablerIcon": true,
          "onActivate": function() {
            root.refresh();

            if (launcher) {
              launcher.close();
            }
          }
        }
      ];
    }

    if (!loaded) {
      return [
        {
          "name": "Loading 1Password items",
          "description": "Please wait",
          "icon": "loader",
          "isTablerIcon": true,
          "onActivate": function() {}
        }
      ];
    }

    var matches = database.filter(function(item) {
      if (query === "") {
        return true;
      }

      var searchable = [
        item.title || "",
        item.username || "",
        item.vaultName || "",
        (item.urls || []).join(" ")
      ].join(" ").toLowerCase();

      return searchable.indexOf(query) !== -1;
    });

    matches.sort(function(a, b) {
      return (a.title || "").localeCompare(b.title || "");
    });

    return matches.slice(0, 50).map(function(item) {
      return root.formatResult(item);
    });
  }

  function getItemActions(result) {
    if (!result || !result.opItem) {
      return [];
    }

    var item = result.opItem;

    return [
      {
        "icon": "user",
        "tooltip": "Copy username",
        "action": function() {
          root.copyField(item, "username");
        }
      },
      {
        "icon": "key",
        "tooltip": "Copy password",
        "action": function() {
          root.copyField(item, "password");
        }
      }
    ];
  }

  Component.onCompleted: {
    loadDatabase();

    if (database.length === 0) {
      refresh();
    }
  }

  FileView {
    id: databaseLoader

    path: pluginApi
      ? pluginApi.pluginDir + "/items.json"
      : ""

    watchChanges: true

    onLoaded: root.loadDatabase()

    onFileChanged: {
      reload();
    }
  }
}
