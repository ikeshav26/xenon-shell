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
        text: "Services"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "Debug Mode"
        sublabel: "Enable verbose logging"
        icon: "󰃤"
        active: Config.debug
        theme: colors
        onActiveChanged: {
            if (Config.debug !== active)
                Config.debug = active;

        }
    }

    // OpenRGB Devices
    SettingItem {
        label: "OpenRGB Devices"
        sublabel: "Device indices (comma separated)"
        icon: "󰌌"
        colors: context.colors

        TextField {
            Layout.preferredWidth: 350
            // Hacky check for array
            text: (Config.openRgbDevices && Array.isArray(Config.openRgbDevices)) ? Config.openRgbDevices.join(", ") : (Config.openRgbDevices || "")
            placeholderText: "e.g. 0, 1"
            font.pixelSize: 13
            color: colors.fg
            background: null
            horizontalAlignment: TextInput.AlignRight
            onEditingFinished: {
                var parts = text.split(",").map(Number).filter((n) => {
                    return !isNaN(n);
                });
                if (parts.length > 0)
                    Config.openRgbDevices = parts;

            }
        }

    }

}
