import QtQuick
import Quickshell
import qs.Modules.Bar
import qs.Services

Variants {
    id: root

    required property Context context

    model: Quickshell.screens

    PanelWindow {
        property var modelData
        property string position: root.context.config.barPosition || "top"

        screen: modelData
        implicitHeight: 34
        color: "transparent"

        anchors {
            top: position === "top"
            bottom: position === "bottom"
            left: true
            right: true
        }

        margins {
            top: (position === "top" && root.context.config.floatingBar) ? 5 : 0
            bottom: (position === "bottom" && root.context.config.floatingBar) ? 5 : 0
            left: root.context.config.floatingBar ? 8 : 0
            right: root.context.config.floatingBar ? 8 : 0
        }

        Bar {
            floating: root.context.config.floatingBar
            colors: root.context.colors
            fontFamily: root.context.config.fontFamily
            fontSize: root.context.config.fontSize
            kernelVersion: root.context.os.version
            cpuUsage: root.context.cpu.usage
            memUsage: root.context.mem.usage
            diskUsage: root.context.disk.usage
            volumeLevel: root.context.volume.level
            activeWindow: root.context.activeWindow.title
            currentLayout: root.context.layout.layout
            time: root.context.time.currentTime
            volumeService: root.context.volume
            networkService: root.context.network
            globalState: root.context.appState
        }

    }

}
