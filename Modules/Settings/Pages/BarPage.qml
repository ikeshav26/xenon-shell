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
        text: "Bar"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Floating Bar"
        sublabel: "Detach bar from screen edges"
        icon: "󰖲"
        active: Config.floatingBar
        theme: colors
        onActiveChanged: {
            if (Config.floatingBar !== active)
                Config.floatingBar = active;

        }
    }

}
