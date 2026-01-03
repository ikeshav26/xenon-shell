import "../Components"
import QtQuick
import QtQuick.Layouts
import qs.Services

BentoCard {
    id: root

    required property var colors

    cardColor: colors.surface
    borderColor: colors.border

    CpuService {
        id: cpuService
    }

    MemService {
        id: memService
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                width: 22
                height: 22
                radius: 6
                color: Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.2)

                Text {
                    anchors.centerIn: parent
                    text: "󰒋"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 12
                    color: root.colors.accent
                }

            }

            Text {
                text: "System"
                color: root.colors.fg
                font.pixelSize: 12
                font.bold: true
            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Canvas {
                    id: cpuCanvas

                    property real progress: cpuService.usage / 100

                    anchors.centerIn: parent
                    width: 70
                    height: 70
                    onProgressChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        var cx = width / 2, cy = height / 2, r = 28, lw = 6;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                        ctx.strokeStyle = Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.15);
                        ctx.lineWidth = lw;
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress));
                        ctx.strokeStyle = root.colors.accent;
                        ctx.lineCap = "round";
                        ctx.lineWidth = lw;
                        ctx.stroke();
                    }
                    Component.onCompleted: requestPaint()
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        text: cpuService.usage + "%"
                        color: root.colors.fg
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "CPU"
                        color: root.colors.accent
                        font.pixelSize: 9
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Canvas {
                    id: ramCanvas

                    property real progress: memService.usage / 100

                    anchors.centerIn: parent
                    width: 70
                    height: 70
                    onProgressChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        var cx = width / 2, cy = height / 2, r = 28, lw = 6;
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                        ctx.strokeStyle = Qt.rgba(root.colors.muted.r, root.colors.muted.g, root.colors.muted.b, 0.15);
                        ctx.lineWidth = lw;
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress));
                        ctx.strokeStyle = root.colors.secondary;
                        ctx.lineCap = "round";
                        ctx.lineWidth = lw;
                        ctx.stroke();
                    }
                    Component.onCompleted: requestPaint()
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        text: memService.usage + "%"
                        color: root.colors.fg
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "RAM"
                        color: root.colors.secondary
                        font.pixelSize: 9
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                }

            }

        }

    }

}
