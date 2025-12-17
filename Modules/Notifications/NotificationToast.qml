import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: root

    required property var manager
    
    // --- Data Latching ---
    // We capture the notification data locally so it persists even if the manager clears it.
    property string notifTitle: ""
    property string notifBody: ""
    property string notifIcon: ""
    property string notifImage: ""
    property int notifUrgency: 1
    
    // State
    property bool showing: false
    
    // Configuration
    property int displayTime: 6000
    
    // Positioning
    anchors {
        top: true
        right: true
    }
    
    // Margins to avoid top bar
    WlrLayershell.margins.top: 60
    WlrLayershell.margins.right: 20
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "notifications-toast"
    WlrLayershell.exclusiveZone: -1
    
    implicitWidth: 380
    implicitHeight: content.implicitHeight + 20 // Padding for shadow
    
    color: "transparent"
    
    // --- Logic ---
    
    Connections {
        target: manager
        function onPopupVisibleChanged() {
            if (manager.popupVisible && manager.currentPopup) {
                // Capture data
                root.notifTitle = manager.currentPopup.summary || "Notification"
                root.notifBody = manager.currentPopup.body || ""
                root.notifIcon = manager.currentPopup.appIcon || ""
                root.notifImage = manager.currentPopup.image || ""
                root.notifUrgency = manager.currentPopup.urgency
                
                // Show and restart timer
                root.showing = true
                dismissTimer.restart()
                
                console.log("[Toast] New notification captured: " + root.notifTitle)
            }
        }
    }
    
    Timer {
        id: dismissTimer
        interval: root.displayTime
        onTriggered: root.showing = false
    }
    
    QtObject {
        id: theme
        property color bg: "#1e1e2e" // Base
        property color surface: "#313244" // Surface0
        property color text: "#cdd6f4" // Text
        property color subtext: "#a6adc8" // Subtext0
        property color border: "#45475a" // Surface1
        property color accent: "#89b4fa" // Blue
        property color urgent: "#f38ba8" // Red
    }
    
    // --- Visuals ---
    
    Item {
        id: content
        width: 360
        implicitHeight: mainLayout.implicitHeight + 32
        x: root.showing ? 0 : 400 // Slide out to right
        opacity: root.showing ? 1 : 0
        
        Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 300 } }
        
        // Shadow/Glow
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#60000000"
            verticalOffset: 4
        }
        
        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
            
            border.width: 1
            border.color: root.notifUrgency === 2 ? theme.urgent : theme.border
            
            // Progress Bar (Time remaining)
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 2
                radius: 1
                color: root.notifUrgency === 2 ? theme.urgent : theme.accent
                
                width: parent.width - 32
                // Animate width from full to 0 over displayTime
                // We use a separate rect for animation to avoid complex bindings on 'width'
                Rectangle {
                    anchors.fill: parent
                    color: root.notifUrgency === 2 ? theme.urgent : theme.accent
                    visible: false // Just use parent for now or implement animation
                }
                
                // Simple animation:
                Behavior on width { enabled: false } // Disable default behavior
                NumberAnimation on width {
                    id: progressAnim
                    from: 328 // (360 - 32)
                    to: 0
                    duration: root.displayTime
                    running: root.showing
                }
                
                // Reset width when showing
                onVisibleChanged: {
                    if (visible) {
                        width = 328
                        progressAnim.restart()
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        root.showing = false // Dismiss locally
                        manager.closePopup() // Tell server we're done
                    } else {
                        // Left click: Just dismiss or maybe invoke action?
                        // For now, just dismiss.
                         root.showing = false
                         manager.closePopup()
                    }
                }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
            }
            
            RowLayout {
                id: mainLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                // Icon / Image
                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignTop
                    radius: 12
                    color: theme.surface
                    
                    Image {
                        id: imgDisplay
                        anchors.fill: parent
                        anchors.margins: 0
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle { width: 48; height: 48; radius: 12 }
                        }
                        
                        source: {
                            if (root.notifImage.startsWith("/")) return "file://" + root.notifImage
                            if (root.notifImage.indexOf("://") !== -1) return root.notifImage
                            
                            // If no image, try icon
                            if (root.notifIcon.indexOf("/") !== -1) return "file://" + root.notifIcon
                            if (root.notifIcon !== "") return "image://icon/" + root.notifIcon
                            
                            return ""
                        }
                        
                        visible: status === Image.Ready
                    }
                    
                    // Fallback Icon
                    Text {
                        anchors.centerIn: parent
                        text: "󰂚"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 24
                        color: theme.subtext
                        visible: !imgDisplay.visible
                    }
                }
                
                // Content
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: root.notifTitle
                        Layout.fillWidth: true
                        font.bold: true
                        font.pixelSize: 14
                        color: theme.text
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        text: root.notifBody
                        Layout.fillWidth: true
                        Layout.maximumHeight: 60 // Limit height
                        font.pixelSize: 13
                        color: theme.subtext
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                    }
                }
                
                // Close Button (Small X)
                Rectangle {
                     Layout.alignment: Qt.AlignTop | Qt.AlignRight
                     width: 16
                     height: 16
                     color: "transparent"
                     Text {
                         anchors.centerIn: parent
                         text: "✕"
                         color: theme.subtext
                         font.pixelSize: 10
                         opacity: 0.7
                     }
                }
            }
        }
    }
}

