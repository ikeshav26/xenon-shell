import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

ColumnLayout {
    property var context // Injected context
    property var colors: context.colors

    spacing: 16

    Text {
        text: "General"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    // Font Family Input
    SettingItem {
        label: "Font Family"
        sublabel: "Global font family"
        icon: "󰛖"
        colors: context.colors

        TextField {
            Layout.preferredWidth: 350
            text: Config.fontFamily
            font.family: Config.fontFamily
            font.pixelSize: 14
            color: colors.fg
            horizontalAlignment: TextInput.AlignRight
            onEditingFinished: {
                if (text !== "")
                    Config.fontFamily = text;

            }

            background: Rectangle {
                color: parent.activeFocus ? Qt.rgba(0, 0, 0, 0.2) : "transparent"
                radius: 6
                border.width: parent.activeFocus ? 1 : 0
                border.color: colors.accent
            }

        }

    }

    // Font Size Control
    SettingItem {
        label: "Font Size"
        sublabel: "Global font size"
        icon: "󰛂"
        colors: context.colors

        RowLayout {
            spacing: 12

            Text {
                text: Config.fontSize + "px"
                font.pixelSize: 14
                color: colors.fg
                font.bold: true
            }

            Spincircle {
                symbol: "–"
                onClicked: Config.fontSize = Math.max(10, Config.fontSize - 1)
            }

            Spincircle {
                symbol: "+"
                onClicked: Config.fontSize = Math.min(24, Config.fontSize + 1)
            }

            component Spincircle: Rectangle {
                property string symbol

                signal clicked()

                width: 32
                height: 32
                radius: 16
                color: hover.containsMouse ? colors.tile : "transparent"
                border.width: 1
                border.color: colors.border

                Text {
                    anchors.centerIn: parent
                    text: symbol
                    color: colors.fg
                    font.pixelSize: 16
                }

                TapHandler {
                    onTapped: clicked()
                    cursorShape: Qt.PointingHandCursor
                }

                HoverHandler {
                    id: hover

                    cursorShape: Qt.PointingHandCursor
                }

            }

        }

    }

}
