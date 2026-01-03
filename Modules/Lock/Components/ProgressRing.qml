import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property real progress: 0.5
    property color ringColor: "white"
    property color bgColor: "gray"
    property string label: ""
    property color textColor: "white"
    property color mutedColor: "gray"

    Canvas {
        id: canvas

        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2, cy = height / 2, r = 18, lw = 4;
            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
            ctx.strokeStyle = Qt.rgba(root.bgColor.r, root.bgColor.g, root.bgColor.b, 0.2);
            ctx.lineWidth = lw;
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * root.progress));
            ctx.strokeStyle = root.ringColor;
            ctx.lineCap = "round";
            ctx.lineWidth = lw;
            ctx.stroke();
        }
        Component.onCompleted: requestPaint()

        Connections {
            function onProgressChanged() {
                canvas.requestPaint();
            }

            target: root
        }

    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        Text {
            text: Math.round(root.progress * 100) + "%"
            color: root.textColor
            font.pixelSize: 9
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: root.label
            color: root.mutedColor
            font.pixelSize: 7
            Layout.alignment: Qt.AlignHCenter
        }

    }

}
