import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

ColumnLayout {
    property var context
    property var colors: context.colors

    spacing: 16

    Text {
        text: "Interface"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Disable Hover Effects"
        sublabel: "Reduce animations for performance"
        icon: "󰏇"
        active: Config.disableHover
        theme: colors
        onActiveChanged: {
            if (Config.disableHover !== active)
                Config.disableHover = active;

        }
    }

}
