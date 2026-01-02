import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    
    property var menuHandle: null
    property real menuX: 0
    property real menuY: 0
    
    // Fullscreen overlay to capture clicks outside
    anchors { top: true; bottom: true; left: true; right: true }
    
    color: "transparent"
    visible: false
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    function open(handle, x, y) {
        menuHandle = handle
        menuX = x
        menuY = y
        visible = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    }
    
    Item {
        id: animationContainer
        x: Math.min(root.menuX, Screen.width - width)
        y: Math.min(root.menuY, Screen.height - targetHeight)
        width: 200
        height: visible ? targetHeight : 0 // Start closed
        clip: true
        
        property int targetHeight: menuBox.height
        
        // Animation Logic
        Behavior on height {
            NumberAnimation { 
                duration: 250
                easing.type: Easing.OutQuart
            }
        }
        
        // Actual Menu Content
        Rectangle {
            id: menuBox
            width: parent.width
            height: column.implicitHeight + 10
            color: "#1e1e2e" // Dark background
            radius: 8
            border.color: "#313244"
            border.width: 1
            anchors.top: parent.top // Stick to top so it reveals downward
            
            QsMenuOpener {
                id: opener
                menu: root.menuHandle
            }
            
            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: 5
                spacing: 2
                
                Repeater {
                    model: opener.children
                    
                    Item {
                        id: menuItem
                        Layout.fillWidth: true
                        Layout.preferredHeight: modelData.isSeparator ? 1 : 30
                        visible: true
                        
                        // Separator
                        Rectangle {
                            visible: modelData.isSeparator
                            anchors.centerIn: parent
                            width: parent.width
                            height: 1
                            color: "#313244"
                        }
                        
                        // Menu Item Content
                        Rectangle {
                            visible: !modelData.isSeparator
                            anchors.fill: parent
                            color: hover.containsMouse ? "#313244" : "transparent"
                            radius: 4
                            
                            MouseArea {
                                id: hover
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    modelData.triggered()
                                    root.visible = false
                                }
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8
                                
                                // We could add an icon here if I figure out how to load it
                                // Loader { source: modelData.icon ... }
                                
                                Text {
                                    text: modelData.text
                                    color: "#cdd6f4"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Animate open
    // Uses binding on height above
}
