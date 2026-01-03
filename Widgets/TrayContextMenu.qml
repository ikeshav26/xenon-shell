import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import qs.Modules.Corners

PanelWindow {
    id: root

    property var menuHandle: null
    property real menuX: 0
    property real menuY: 0
    property bool hasCurrent: false
    
    property int animLength: 400
    property var animCurve: [0.05, 0, 0.133, 0.06, 0.166, 0.4, 0.208, 0.82, 0.25, 1, 1, 1]

    property var colors: QtObject {
        property color bg: "#1e1e2e"
        property color fg: "#cdd6f4"
        property color accent: "#cba6f7"
        property color muted: "#45475a"
        property color border: "#313244"
    }

    function open(handle, x, y) {
        menuHandle = handle;
        
        let width = 240;
        let safeX = x - (width / 2);
        safeX = Math.max(8, Math.min(safeX, Screen.width - width - 8));

        menuX = safeX;
        menuY = y - 32
        hasCurrent = true;
    }

    function close() {
        hasCurrent = false;
    }

    color: "transparent"
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: wrapper.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    mask: Region {
        item: wrapper.visible ? wrapper : null
    }

    MouseArea {
        anchors.fill: parent
        enabled: wrapper.visible
        onClicked: root.close()
    }
    
    // Inverse rounded corners at top
    // Fixed: Scale is now bound to wrapper height. 
    // They will remain full size (scale 1) until the panel height drops below their size (30px),
    // creating the effect of "closing with" the panel.
    RoundCorner {
        corner: RoundCorner.CornerEnum.TopRight
        size: 30
        color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
        
        anchors.top: wrapper.top
        anchors.right: wrapper.left
        
        transformOrigin: Item.TopRight
        
        // Scale reduces only when height < 30
        scale: Math.min(1, wrapper.height / 30)
        visible: scale > 0
    }
    
    RoundCorner {
        corner: RoundCorner.CornerEnum.TopLeft
        size: 30
        color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
        
        anchors.top: wrapper.top
        anchors.left: wrapper.right
        
        transformOrigin: Item.TopLeft
        
        // Scale reduces only when height < 30
        scale: Math.min(1, wrapper.height / 30)
        visible: scale > 0
    }

    Item {
        id: wrapper
        
        x: root.menuX
        y: root.menuY
        width: 240
        
        readonly property real contentHeight: menuColumn.implicitHeight + 16
        
        visible: height > 0
        clip: true
        
        implicitHeight: root.hasCurrent ? contentHeight : 0
        
        Behavior on implicitHeight {
            NumberAnimation {
                duration: root.animLength
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.animCurve
            }
        }

        // Fixed: Menu Background is now sized to the wrapper (parent).
        // This ensures the bottom rounded corners move up as the wrapper shrinks,
        // preventing the "square bottom" look during animation.
        Rectangle {
            id: menuBg
            anchors.fill: parent
            color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
            clip: true // Clip the content that sits inside
            
            // Specific corners
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 14
            bottomRightRadius: 14
            
            QsMenuOpener {
                id: opener
                menu: root.menuHandle
            }
            
            Column {
                id: menuColumn
                
                // Content stays anchored to top, while parent (bg) shrinks from bottom
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 8
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 2

                Repeater {
                    model: opener.children

                    delegate: Item {
                        id: menuItem
                        
                        property bool isSeparator: modelData.isSeparator
                        property bool isHovered: itemMouse.containsMouse && !isSeparator
                        property bool hasChildren: modelData.hasChildren

                        width: menuColumn.width
                        height: isSeparator ? 12 : 36

                        Rectangle {
                            visible: isSeparator
                            anchors.centerIn: parent
                            width: parent.width - 16
                            height: 1
                            color: root.colors.border
                            opacity: 0.5
                        }

                        Rectangle {
                            visible: !isSeparator
                            anchors.fill: parent
                            radius: 8
                            color: isHovered ? root.colors.accent : "transparent"
                            opacity: isHovered ? 0.15 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        Rectangle {
                            visible: !isSeparator && isHovered
                            width: 3
                            height: 16
                            radius: 2
                            color: root.colors.accent
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        RowLayout {
                            visible: !isSeparator
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Item {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                
                                Image {
                                    anchors.centerIn: parent
                                    width: 16
                                    height: 16
                                    source: modelData.icon || ""
                                    fillMode: Image.PreserveAspectFit
                                    visible: modelData.icon !== undefined && modelData.icon !== ""
                                    layer.enabled: true
                                    layer.effect: ColorOverlay {
                                        color: isHovered ? root.colors.accent : root.colors.muted
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: !(modelData.icon !== undefined && modelData.icon !== "")
                                    text: ""
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 6
                                    color: isHovered ? root.colors.accent : root.colors.muted
                                }
                            }

                            Text {
                                text: modelData.text || ""
                                color: isHovered ? root.colors.fg : Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.8)
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 0.2
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                visible: (modelData.checkable && modelData.checked) || menuItem.hasChildren
                                text: menuItem.hasChildren ? "" : ""
                                font.family: "Symbols Nerd Font"
                                color: root.colors.accent
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: isSeparator ? Qt.ArrowCursor : Qt.PointingHandCursor
                            
                            onClicked: {
                                if (!menuItem.isSeparator) {
                                    if (modelData.hasChildren) {
                                        root.menuHandle = modelData;
                                    } else {
                                        modelData.triggered();
                                        root.close();
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