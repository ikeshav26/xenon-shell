pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "bar"
import "core"
import "background"
import "services"
import "launcher"
import "clipboard"

ShellRoot {
    id: root

    Colors { id: colors }

    CpuService { id: cpuService }
    OsService { id: osService }
    MemService { id: memService }
    DiskService { id: diskService }
    VolumeService { id: volumeService }
    TimeService { id: timeService }
    ActiveWindowService { id: activeWindowService }
    LayoutService { id: layoutService }

    // Font
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    // System info properties
    property string kernelVersion: osService.version
    property int cpuUsage: cpuService.usage
    property int memUsage: memService.usage
    property int diskUsage: diskService.usage
    property int volumeLevel: volumeService.level
    property string activeWindow: activeWindowService.title
    property string currentLayout: layoutService.layout

    Background {}
    
    AppLauncher {
        id: launcher
        visible: false
        colors: colors
    }

    IpcHandler {
        target: "launcher"
        function toggle() {
            launcher.visible = !launcher.visible
        }
    }
    Clipboard {
        id: clipboard
    }

    // 1. Toggle Handler (For your keybind: Super+V)
    IpcHandler {
        target: "clipboard"
        function toggle() { clipboard.visible = !clipboard.visible }
    }

    // 2. UPDATE Handler (For the script you found)
    // Listens for: qs -c mannu ipc call cliphistService update
    IpcHandler {
        target: "cliphistService"
        
        function update() {
            // This runs the refresh() function we just added to Clipboard.qml
            clipboard.refresh() 
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30
            color: colors.bg

            margins {
                top: 0
                bottom: 0
                left: 0
                right: 0
            }

            Bar {
                colors: colors
                fontFamily: root.fontFamily
                fontSize: root.fontSize
                kernelVersion: root.kernelVersion
                cpuUsage: root.cpuUsage
                memUsage: root.memUsage
                diskUsage: root.diskUsage
                volumeLevel: root.volumeLevel
                activeWindow: root.activeWindow
                currentLayout: root.currentLayout
                time: timeService.currentTime
            }
        }
    }
}