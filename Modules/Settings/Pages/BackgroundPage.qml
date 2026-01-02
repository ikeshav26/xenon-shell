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
        text: "Background"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    // Wallpaper Directory
    SettingItem {
        label: "Wallpaper Directory"
        sublabel: "Path to wallpaper folder"
        icon: "󰸉"
        colors: context.colors

        TextField {
            Layout.preferredWidth: 350
            text: Config.wallpaperDirectory
            font.pixelSize: 13
            color: colors.fg
            background: null
            horizontalAlignment: TextInput.AlignRight
            onEditingFinished: {
                if (text !== "")
                    Config.wallpaperDirectory = text;

            }
        }

    }

}
