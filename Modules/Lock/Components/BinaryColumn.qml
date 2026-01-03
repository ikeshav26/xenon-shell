import QtQuick
import QtQuick.Layouts

Column {
    id: root

    property int value: 0
    property int bits: 4
    property real dotSize: 10
    property color activeColor: "white"

    spacing: dotSize * 0.4
    Layout.alignment: Qt.AlignBottom

    Repeater {
        model: root.bits

        Rectangle {
            required property int index
            property int bitIndex: (root.bits - 1) - index
            property bool isActive: (root.value >> bitIndex) & 1

            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: isActive ? root.activeColor : (root.activeColor ? Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.2) : "transparent")

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

    }

}
