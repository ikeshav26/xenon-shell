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
                    text: "󰁮" // Back arrow
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: theme.text
                }
                
                HoverHandler { id: backBtn }
                TapHandler { onTapped: root.backRequested() }
            }
            
            Text {
                text: "Wi-Fi"
                font.bold: true
                font.pixelSize: 18
                color: theme.text
            }
            
            Item { Layout.fillWidth: true }
            
            // Toggle Switch (Visual only for now)
            Rectangle {
                width: 40
                height: 20
                radius: 10
                color: theme.accentActive
                
                Rectangle {
                    x: parent.width - width - 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    radius: 8
                    color: theme.bg
                }
            }
        }

        // --- Network List ---
        
        // Current Network
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 64
            radius: 14
            color: theme.surface
            border.width: 1
            border.color: theme.accent
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 14
                
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.2)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰖩"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 20
                        color: theme.accentActive
                    }
                }
                
                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Home_WiFi_5G"
                        color: theme.text
                        font.bold: true
                        font.pixelSize: 14
                    }
                    Text {
                        text: "Connected"
                        color: theme.accentActive
                        font.pixelSize: 12
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: "" // Checkmark
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: theme.accentActive
                }
            }
        }
        
        Text {
            Layout.topMargin: 20
            Layout.bottomMargin: 8
            text: "Available Networks"
            color: theme.muted
            font.pixelSize: 12
            font.bold: true
            Layout.leftMargin: 4
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 200
            clip: true
            spacing: 4
            model: 5 // Mock model
            
            delegate: Rectangle {
                width: parent.width
                height: 52
                radius: 10
                color: hoverHandler.containsMouse ? theme.tile : "transparent"
                
                HoverHandler { id: hoverHandler }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 14
                    
                    Text {
                        text: "󰖩"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: theme.subtext
                    }
                    
                    Text {
                        text: "Neighbor_Net_" + index
                        color: theme.text
                        font.pixelSize: 14
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "󰌾"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: theme.muted
                    }
                }
            }
        }
    }
}
