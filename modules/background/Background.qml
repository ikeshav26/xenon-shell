import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        // 1. Link to the screen
        screen: modelData

        // 2. FIXED: Use the attached property for Layer
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        // 3. FIXED: Windows use boolean anchors for edges
        // (You cannot use 'anchors.fill: parent' on a Window)
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "black"

        // Content
        Wallpaper {
            id: wallpaper
            anchors.fill: parent
        }
    }
}
