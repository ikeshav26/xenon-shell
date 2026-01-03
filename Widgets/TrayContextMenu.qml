import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: root

    // --- Inputs ---
    property var menuHandle: null
    property real menuX: 0
    property real menuY: 0
    property bool isOpen: false

    // Theme Interface (Matugen colors expected)
    // Defaults provided for standalone testing (Catppuccin Mocha style)
    property var colors: QtObject {
        property color bg: "#1e1e2e"       // Base
        property color fg: "#cdd6f4"       // Text
        property color accent: "#cba6f7"   // Mauve
        property color muted: "#45475a"    // Surface 1
        property color border: "#313244"   // Surface 0
    }

    function open(handle, x, y) {
        menuHandle = handle;
        
        // Smart Positioning Logic
        // Ensures the menu stays fully within screen bounds
        let width = 260; // Menu width
        let estimatedHeight = 320; // Cap
        
        let safeX = Math.min(x, Screen.width - width - 12);
        let safeY = Math.min(y, Screen.height - estimatedHeight - 12);
        
        // Prevent going off left/top edges
        safeX = Math.max(12, safeX); 
        safeY = Math.max(12, safeY);

        menuX = safeX;
        menuY = safeY;
        
        visible = true;
        isOpen = true;
    }

    function close() {
        isOpen = false;
        closeTimer.start();
    }

    Timer {
        id: closeTimer
        interval: 250
        onTriggered: root.visible = false
    }

    // --- Window Configuration ---
    color: "transparent"
    visible: false
    
    // Overlay layer to float above everything
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Cover full screen to detect clicks outside
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // --- Background Dimmer / Click-out Handler ---
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.close()
        
        // Subtle dimming effect for focus
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: root.isOpen ? 0.2 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }
    }

    // --- Main Menu Visuals ---
    Item {
        id: menuContainer
        
        x: root.menuX
        width: 280
        height: menuBox.height
        
        transformOrigin: Item.TopLeft
        
        // Entrance Animation State - Smooth scaling with slight Y translation
        scale: root.isOpen ? 1.0 : 0.92
        opacity: root.isOpen ? 1.0 : 0.0
        y: root.isOpen ? root.menuY : root.menuY - 8
        
        // Elastic spring physics for premium feel
        Behavior on scale { 
            NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.08 } 
        }
        Behavior on opacity { 
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
        }
        Behavior on y {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }

        // Multi-layered shadow system for realistic depth
        Rectangle {
            id: shadowSource
            anchors.fill: menuBox
            anchors.margins: 2
            radius: 18
            color: "black"
            visible: false
        }
        
        // Primary shadow - soft and large
        DropShadow {
            anchors.fill: menuBox
            source: shadowSource
            color: Qt.rgba(0, 0, 0, 0.35)
            radius: 32
            samples: 48
            verticalOffset: 12
            horizontalOffset: 0
            transparentBorder: true
        }
        
        // Secondary shadow - tight and dark for definition
        DropShadow {
            anchors.fill: menuBox
            source: shadowSource
            color: Qt.rgba(0, 0, 0, 0.25)
            radius: 8
            samples: 16
            verticalOffset: 4
            horizontalOffset: 0
            transparentBorder: true
        }

        // The Card - Premium glassmorphic design
        Rectangle {
            id: menuBox
            width: parent.width
            height: column.implicitHeight + 28
            
            // Rich gradient background with glassmorphism
            gradient: Gradient {
                GradientStop { 
                    position: 0.0
                    color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
                }
                GradientStop { 
                    position: 1.0
                    color: Qt.tint(
                        Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.92),
                        Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.08)
                    )
                }
            }
            
            radius: 18
            clip: true
            
            // Gradient border overlay
            border.width: 0
            
            // Outer glow border
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.width: 1.5
                border.color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.35)
            }
            
            // Inner highlight for depth
            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: parent.radius - 1
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.08)
            }
            
            // Top gradient accent bar
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.3; color: root.colors.accent }
                    GradientStop { position: 0.7; color: Qt.lighter(root.colors.accent, 1.3) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                opacity: 0.6
            }

            QsMenuOpener {
                id: opener
                menu: root.menuHandle
            }

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: 14
                anchors.topMargin: 16
                anchors.bottomMargin: 16
                spacing: 3

                Repeater {
                    model: opener.children

                    delegate: Item {
                        id: menuItem
                        
                        property bool isSeparator: modelData.isSeparator
                        property bool isHovered: hover.containsMouse && !isSeparator

                        Layout.fillWidth: true
                        Layout.preferredHeight: isSeparator ? 18 : 48

                        // --- Separator ---
                        Item {
                            visible: isSeparator
                            anchors.centerIn: parent
                            width: parent.width - 20
                            height: 1
                            
                            Rectangle {
                                anchors.fill: parent
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.2; color: Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.4) }
                                    GradientStop { position: 0.8; color: Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.4) }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }
                        }

                        // --- Menu Item ---
                        Rectangle {
                            visible: !isSeparator
                            anchors.fill: parent
                            radius: 11
                            
                            // Gradient background on hover
                            color: !isHovered ? "transparent" : Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.16)
                            
                            // Gradient overlay for depth
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                visible: isHovered
                                opacity: isHovered ? 1.0 : 0.0
                                gradient: Gradient {
                                    GradientStop { 
                                        position: 0.0
                                        color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.20) 
                                    }
                                    GradientStop { 
                                        position: 1.0
                                        color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.12) 
                                    }
                                }
                                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            }
                            
                            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            
                            // Glow border on hover
                            border.width: isHovered ? 1 : 0
                            border.color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.4)

                            // Ultra-smooth transitions
                            Behavior on border.width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            
                            // Subtle scale effect
                            scale: isHovered ? 1.02 : 1.0
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                            MouseArea {
                                id: hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: parent.isSeparator ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onClicked: {
                                    if (!parent.isSeparator) {
                                        modelData.triggered();
                                        root.close();
                                    }
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 14

                                // Icon Container with gradient
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    visible: !isSeparator
                                    radius: 10
                                    
                                    // Base background
                                    color: isHovered 
                                        ? root.colors.accent
                                        : Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.20)
                                    
                                    // Gradient overlay
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        gradient: Gradient {
                                            GradientStop { 
                                                position: 0.0
                                                color: isHovered 
                                                    ? Qt.rgba(255, 255, 255, 0.2)
                                                    : Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.1)
                                            }
                                            GradientStop { position: 1.0; color: "transparent" }
                                        }
                                    }
                                    
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    
                                    border.width: 1
                                    border.color: isHovered 
                                        ? Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.5)
                                        : Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.3)
                                    
                                    Behavior on border.color { ColorAnimation { duration: 200 } }
                                    
                                    // Subtle rotation animation on hover
                                    rotation: isHovered ? 3 : 0
                                    Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

                                    Image {
                                        anchors.centerIn: parent
                                        width: 16
                                        height: 16
                                        source: modelData.icon || ""
                                        fillMode: Image.PreserveAspectFit
                                        visible: modelData.icon !== undefined && modelData.icon !== ""
                                        // Tint icon white if hovered, else accent
                                        layer.enabled: true
                                        layer.effect: ColorOverlay {
                                            color: isHovered ? root.colors.bg : root.colors.accent
                                        }
                                    }

                                    // Fallback icon (dot)
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 6; height: 6; radius: 3
                                        color: isHovered ? root.colors.bg : root.colors.accent
                                        visible: !(modelData.icon !== undefined && modelData.icon !== "")
                                    }
                                }

                                // Text Label with enhanced typography
                                Text {
                                    text: modelData.text || ""
                                    color: isHovered 
                                        ? Qt.lighter(root.colors.accent, 1.1)
                                        : Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.92)
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    font.pixelSize: 14
                                    font.weight: isHovered ? Font.Bold : Font.DemiBold
                                    font.letterSpacing: 0.3
                                    verticalAlignment: Text.AlignVCenter
                                    
                                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                    Behavior on font.weight { NumberAnimation { duration: 150 } }
                                    
                                    // Subtle scale on hover
                                    scale: isHovered ? 1.03 : 1.0
                                    transformOrigin: Item.Left
                                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                }
                                
                                // Checkmark / Status with animation
                                Rectangle {
                                    visible: modelData.checkable && modelData.checked
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    radius: 6
                                    color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.25)
                                    border.width: 1
                                    border.color: root.colors.accent
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        font.family: "Symbols Nerd Font"
                                        color: root.colors.accent
                                        font.pixelSize: 14
                                        font.bold: true
                                        
                                        scale: parent.visible ? 1.0 : 0.0
                                        Behavior on scale { 
                                            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } 
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}