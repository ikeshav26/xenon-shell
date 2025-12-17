import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Widgets
import qs.Modules.Notifications
import "Views" as Views

PanelWindow {
    id: root
    
    // Position on the right side
    anchors {
        top: true
        bottom: true
        right: true
    }
    
    implicitWidth: Screen.width
    implicitHeight: Screen.height
    
    color: "transparent"
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    
    // Removed redundant MouseArea/mask definitions as they were updated in previous step
    // But need to make sure I don't leave duplicate blocks.
    // The previous edit to SidePanel.qml replaced the timer block AND prepended the MouseArea/Mask logic.
    // So I should check if I need to delete the old one.
    // Ah, the previous `replace_file_content` targeted StartLine 117 endLine 141 (Timers) but inserted a huge block.
    // Let me check if strict duplication happened.
    // Actually, line 26-50 has the OLD MouseArea and mask logic. I need to remove that if I moved it down or update it there.
    // I put the new logic near the top in the previous edit (lines 117+). Ideally mask logic should be near the top.
    // I will remove the old mask logic at lines 26-50.

    
    Region {
        id: fullMask
        regions: [
            Region {
                x: 0
                y: 0
                width: root.width
                height: root.height
            }
        ]
    }

    Region {
        id: splitMask
        regions: [
            Region {
                x: controlBox.x
                y: controlBox.y
                width: controlBox.width
                height: controlBox.height
            },
            Region {
                x: notifBox.x
                y: notifBox.y
                width: notifBox.width
                height: notifBox.height
            },
            // Static Peek Strips
            Region {
                x: root.width - root.peekWidth
                y: controlBox.y
                width: root.peekWidth
                height: controlBox.height
            },
            Region {
                x: root.width - root.peekWidth
                y: notifBox.y
                width: root.peekWidth
                height: notifBox.height
            }
        ]
    }

    // Required properties
    required property var globalState
    required property var notifManager
    property alias theme: theme

    QtObject {
        id: theme
        property color bg:           "#1e1e2e"
        property color surface:      "#313244" // Surface0
        property color border:       "#45475a" // Surface1
        property color text:         "#cdd6f4" // Text
        property color subtext:      "#a6adc8" // Subtext0
        property color secondary:    "#bac2de" // Subtext1
        property color muted:        "#585b70" // Surface2
        property color urgent:       "#f38ba8" // Red
        property color accent:       "#89b4fa" // Blue
        property color accentActive: "#89b4fa"
        property color tileActive:   "#313244"
        
        property int borderRadius:   16
        property int contentMargins: 16
        property int spacing:        12
    }
    
    // --- Layout State ---
    
    // Peeking width
    readonly property int peekWidth: 10
    // Full width of boxes
    readonly property int boxWidth: 320
    
    // State trackers
    property bool forcedOpen: false
    property bool controlHovered: controlHandler.hovered || controlPeekHandler.hovered
    property bool notifHovered: notifHandler.hovered || notifPeekHandler.hovered
    
    // Delayed closing to prevent jitter
    property bool controlOpen: false
    property bool notifOpen: false
    
    function show() {
        forcedOpen = true
        controlOpen = true
        notifOpen = true
    }
    
    function hide() {
        forcedOpen = false
        // Let hover logic take over, or force close
        controlOpen = false
        notifOpen = false
        menuLoader.active = false
    }

    // Mask logic
    mask: (menuLoader.active || forcedOpen) ? fullMask : splitMask
    
    // Background Closer (Modal)
    MouseArea {
        anchors.fill: parent
        z: -100
        enabled: menuLoader.active || forcedOpen
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (menuLoader.active) toggleMenu("")
            if (forcedOpen) hide()
        }
    }

    // De-bounce Timers
    Timer {
        id: controlTimer
        interval: 100
        repeat: false
        running: !root.controlHovered && !menuLoader.active && !root.forcedOpen
        onTriggered: root.controlOpen = false
    }
    
    Timer {
        id: notifTimer
        interval: 100
        repeat: false
        running: !root.notifHovered && !root.forcedOpen
        onTriggered: root.notifOpen = false
    }
    
    /* Auto-open (immediate) - removed to rely simply on bindings again? 
       Actually, mixing explicit timers + bindings + forcedOpen is complex.
       Let's stick to the timers being the "closer" and hover being the "opener".
    */
    
    onControlHoveredChanged: {
        if (controlHovered) {
            controlTimer.stop()
            controlOpen = true
        }
    }
    
    onNotifHoveredChanged: {
        if (notifHovered) {
            notifTimer.stop()
            notifOpen = true
        }
    }
    
    // Logic:
    function getX(isOpen) {
        return isOpen ? (root.width - root.boxWidth - 20) : (root.width - root.peekWidth)
    }

    // --- Control Box (Top) ---
    Rectangle {
        id: controlBox
        width: root.boxWidth
        
        // Dynamic height based on content
        height: contentCol.height + 32 // 16px top + 16px bottom padding
        
        y: 60 // Top margin to clear Top Bar
        x: root.getX(root.controlOpen || menuLoader.active || root.forcedOpen)
        
        radius: 16
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        border.width: 1
        border.color: theme.border
        
        clip: true // Ensure content doesn't bleed during animation
        
        // Shadow
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }

        Column {
            id: contentCol
            width: parent.width - 32
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            
            // Main Controls
            Views.ControlBoxContent {
                id: controlContent
                width: parent.width
                
                globalState: root.globalState
                theme: root.theme
                notifManager: root.notifManager
                
                onRequestWifiMenu: toggleMenu("wifi")
                onRequestBluetoothMenu: toggleMenu("bluetooth")
                onRequestPowerMenu: root.globalState.powerMenuOpen = true
            }
            
            // Separator (only visible when menu is open)
            Rectangle {
                width: parent.width
                height: 1
                color: theme.border
                visible: menuLoader.active
                opacity: menuLoader.active ? 1 : 0
                
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
            
            // Menu Loader (Wifi/BT)
            Loader {
                id: menuLoader
                width: parent.width
                active: false
                visible: active
                
                // Animate height of the loader container? 
                // Actually, controlBox height animates. This just needs to assert its height.
                
                sourceComponent: {
                    if (root.currentMenu === "wifi") return wifiComp
                    if (root.currentMenu === "bluetooth") return btComp
                    return null
                }
                
                onLoaded: {
                    // Optional: fade in content
                    item.opacity = 0
                    fadeIn.start()
                }
                
                NumberAnimation {
                    id: fadeIn
                    target: menuLoader.item
                    property: "opacity"
                    to: 1
                    duration: 200
                }
            }
        }
        
        // Interaction Handlers (Only internal hover)
        HoverHandler { id: controlHandler }

        // Animation
        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }
        }
        
        // Height Expansion Animation
        Behavior on height {
            NumberAnimation {
                duration: 500
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }
        }
    }

    // Shared State for Menu
    property string currentMenu: ""

    function toggleMenu(menu) {
        if (root.currentMenu === menu) {
            // Close
            menuLoader.active = false
            root.currentMenu = ""
        } else {
            // Open
            root.currentMenu = menu
            menuLoader.active = true
        }
    }

    // Components for submenus
    Component {
        id: wifiComp
        Views.WifiView {
            theme: root.theme
            globalState: root.globalState
            onBackRequested: toggleMenu("") // Close
        }
    }
    Component {
        id: btComp
        Views.BluetoothView {
            theme: root.theme
            globalState: root.globalState
            onBackRequested: toggleMenu("") // Close
        }
    }

    // --- Notification Box (Bottom) ---
    Rectangle {
        id: notifBox
        width: root.boxWidth
        
        // Dynamic Y position: follows controlBox directly
        property int baseY: controlBox.y + controlBox.height + 12
        y: baseY
        
        // Height dynamics: Fill available space to bottom, minus margin
        // If content is smaller, shrink to content.
        property int maxAvailableHeight: root.height - baseY - 20 // 20px bottom margin
        height: Math.min(Math.max(100, maxAvailableHeight), notifContent.implicitHeight + 32)
        
        x: root.getX(root.notifOpen || root.forcedOpen)
        
        radius: 16
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        border.width: 1
        border.color: theme.border
        
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 17
            color: "#40000000"
        }
        
        Views.NotificationBoxContent {
            id: notifContent
            anchors.fill: parent
            anchors.margins: 16
            // We use anchors to fill allowing ListView to stretch
            
            theme: theme
            notifManager: root.notifManager
        }

        HoverHandler { id: notifHandler }
        
        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }
        }
    }
    
    // --- Edge Peek Handlers (Static) ---
    // Make them cover the right edge of the *screen* (parent)
    // and extend slightly inwards to catch the hover.
    
    // Control Peek
    Rectangle {
        color: "transparent"
        x: parent.width - 20
        y: controlBox.y
        width: 20
        height: controlBox.height
        HoverHandler { id: controlPeekHandler }
    }
    
    // Notif Peek
    Rectangle {
        color: "transparent"
        x: parent.width - 20
        y: notifBox.y
        width: 20
        height: notifBox.height
        HoverHandler { 
            // We can reuse notifHandler? No, separate logic.
            // But we want it to trigger notifOpen.
            // root.notifOpen is bound to notifHandler.hovered.
            // We need to update that binding.
            id: notifPeekHandler 
        }
    }
    
    // Update state trackers to include new static handlers
    // property bool controlHovered: controlHandler.hovered || controlHeaderHandler.hovered || menuHandler.hovered
    // property bool notifHovered: notifHandler.hovered || notifPeekHandler.hovered
}