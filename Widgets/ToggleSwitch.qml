import QtQuick
import QtQuick.Controls

Item {
    id: root

    property bool checked: false
    property var theme: null
    // Colors
    property color activeColor: theme ? theme.accent : "#CBA6F7"
    property color inactiveColor: theme ? theme.surface : "#313244"
    property color thumbColor: theme ? theme.fg : "#CDD6F4"

    // Size configuration
    implicitWidth: 44
    implicitHeight: 24

    Rectangle {
        id: track

        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.activeColor : root.inactiveColor
        border.width: 1
        border.color: root.checked ? root.activeColor : (theme ? theme.border : "#45475A")

        Rectangle {
            id: thumb

            width: parent.height - 4
            height: width
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 2 : 2
            color: root.thumbColor

            Behavior on x {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    TapHandler {
        onTapped: root.checked = !root.checked
        cursorShape: Qt.PointingHandCursor
    }

}
