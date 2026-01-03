import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Item {
    property string title: ""
    property bool isFullscreen: false

    Process {
        id: windowProc

        command: ["sh", "-c", "hyprctl activewindow -j | jq -c --argjson activeWs $(hyprctl monitors -j | jq '.[] | select(.focused) | .activeWorkspace.id') '{win: ., activeWs: $activeWs}'"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data || !data.trim())
                    return ;

                try {
                    const parsed = JSON.parse(data.trim());
                    const win = parsed.win;
                    const activeWs = parsed.activeWs;
                    if (win && win.workspace && activeWs && win.workspace.id === activeWs) {
                        title = win.title || "~";
                        isFullscreen = (win.fullscreen > 0);
                    } else {
                        title = "~";
                        isFullscreen = false;
                    }
                } catch (e) {
                    console.warn("Failed to parse active window data:", e);
                    title = "";
                    isFullscreen = false;
                }
            }
        }

    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }

}
