import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Widgets

Control {
    id: root
    padding: 16

    required property var globalState
    required property var theme
    
    signal backRequested()

    contentItem: ColumnLayout {
        spacing: 0

        // --- Header ---
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 16
            spacing: 12
            
            Rectangle {
                width: 32
                height: 32
                radius: 10
                color: backBtn.containsMouse ? theme.tile : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "󰁮"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: theme.text
                }
                
                HoverHandler { id: backBtn }
                TapHandler { onTapped: root.backRequested() }
            }
            
            Text {
                text: "Bluetooth Devices"
                font.bold: true
                font.pixelSize: 16
                color: theme.text
            }
            
            Item { Layout.fillWidth: true }
            
            // Toggle Switch
            Rectangle {
                width: 44
                height: 24
                radius: 12
                color: theme.accentActive
                
                Rectangle {
                    x: 22
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    height: 20
                    radius: 10
                    color: "#FFFFFF"
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: 3 // Mock model
            
            delegate: Rectangle {
                width: parent.width
                height: 60
                radius: 12
                color: hoverHandler.containsMouse ? Qt.rgba(theme.tile.r, theme.tile.g, theme.tile.b, 0.5) : "transparent"
                
                HoverHandler { id: hoverHandler }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "󰂯"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: index === 0 ? theme.accentActive : theme.secondary
                    }
                    
                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        Text {
                            text: index === 0 ? "JBL Flip 6" : "MX Master 3S"
                            color: theme.text
                            font.pixelSize: 14
                            font.bold: true
                        }
                        Text {
                            text: index === 0 ? "Connected" : "Saved"
                            color: index === 0 ? theme.accentActive : theme.muted
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
