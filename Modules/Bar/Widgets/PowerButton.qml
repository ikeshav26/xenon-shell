import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Widgets

Rectangle {
    required property var colors

    Layout.preferredHeight: 26
    Layout.preferredWidth: 26
    radius: height / 2
    color: "transparent"
    border.color: colors.muted
    border.width: 1

    Icon {
        anchors.centerIn: parent
        icon: Icons.power
        font.pixelSize: 16
        color: colors.red
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: parent.color = Qt.rgba(colors.red.r, colors.red.g, colors.red.b, 0.2)
        onExited: parent.color = "transparent"
        onClicked: Ipc.togglePowerMenu()
    }

}
