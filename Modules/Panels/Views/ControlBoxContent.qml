import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Widgets
import qs.Modules.Notifications
import "." as Views

// This component represents the "Top Box" - Controls & Profile
ColumnLayout {
    id: root
    width: 320 // Fixed width for the panel
    spacing: 12

    required property var globalState
    required property var theme
    required property var notifManager // Passed but maybe not used heavily here? Actually Notifications are separate now.

    signal requestWifiMenu()
    signal requestBluetoothMenu()
    signal requestPowerMenu()

    // --- Header Section (Profile & Power) ---
    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: 4
        spacing: 12

        // Avatar
        Rectangle {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42
            radius: 14
            gradient: Gradient {
                GradientStop { position: 0.0; color: theme.tileActive }
                GradientStop { position: 1.0; color: theme.accentActive }
            }
            Text {
                anchors.centerIn: parent
                text: "󰣇"
                font.pixelSize: 24
                font.family: "Symbols Nerd Font"
                color: "#FFFFFF"
            }
        }

        // Greeting
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                text: "Hey, " + Quickshell.env("USER")
                color: theme.text
                font.bold: true
                font.pixelSize: 15
                font.capitalization: Font.Capitalize
            }
            Text {
                text: Qt.formatDate(new Date(), "ddd, MMM d")
                color: theme.secondary
                font.pixelSize: 12
            }
        }

        // Power Button
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 12
            color: powerBtn.pressed ? Qt.rgba(theme.urgent.r, theme.urgent.g, theme.urgent.b, 0.2) : "transparent"
            border.width: 1
            border.color: powerBtn.pressed ? theme.urgent : theme.border

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.pixelSize: 16
                font.family: "Symbols Nerd Font"
                color: theme.urgent
            }
            TapHandler {
                id: powerBtn
                onTapped: root.requestPowerMenu()
            }
        }
    }

    // --- Quick Settings Grid ---
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 10
        columnSpacing: 10

        // WiFi
        Views.ToggleButton {
            Layout.fillWidth: true
            implicitHeight: 64
            label: "WiFi"
            sublabel: "Connected"
            icon: "󰖩"
            active: true
            showChevron: true
            theme: root.theme
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        root.requestWifiMenu()
                    } else {
                        parent.active = !parent.active
                        parent.sublabel = parent.active ? "Connected" : "Off"
                    }
                }
            }
        }

        // Bluetooth
        Views.ToggleButton {
            Layout.fillWidth: true
            implicitHeight: 64
            label: "Bluetooth"
            sublabel: "On"
            icon: "󰂯"
            active: true
            showChevron: true
            theme: root.theme
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        root.requestBluetoothMenu()
                    } else {
                        parent.active = !parent.active
                        parent.sublabel = parent.active ? "On" : "Off"
                    }
                }
            }
        }
        
        // Airplane
        Views.ToggleButton {
            Layout.fillWidth: true
            implicitHeight: 56
            label: "Airplane"
            sublabel: "Off"
            icon: "󰀝"
            active: false
            showChevron: false
            theme: root.theme
        }

        // DND
        Views.ToggleButton {
            Layout.fillWidth: true
            implicitHeight: 56
            label: "DND"
            sublabel: "Off"
            icon: "󰂛"
            active: false
            showChevron: false
            theme: root.theme
        }
    }

    // --- Sliders ---
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12
        Layout.topMargin: 4
        
        Views.SliderControl {
            label: "Volume"
            icon: "󰕾"
            value: 0.65
            theme: root.theme
        }

        Views.SliderControl {
            label: "Brightness"
            icon: "󰃠"
            value: 0.80
            theme: root.theme
        }
    }
}
