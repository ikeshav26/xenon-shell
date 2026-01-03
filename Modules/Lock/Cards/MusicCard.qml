import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import qs.Services

BentoCard {
    id: root

    required property var colors

    cardColor: colors.surface
    borderColor: colors.border
    layer.enabled: true

    Image {
        anchors.fill: parent
        source: MprisService.artUrl
        fillMode: Image.PreserveAspectCrop
        visible: MprisService.artUrl !== ""
        opacity: 0.2
        layer.enabled: visible

        layer.effect: FastBlur {
            radius: 32
        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item {
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: Qt.rgba(0, 0, 0, 0.3)
                    visible: MprisService.artUrl === ""
                }

                Image {
                    anchors.fill: parent
                    source: MprisService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: MprisService.artUrl !== ""
                    layer.enabled: true

                    layer.effect: OpacityMask {

                        maskSource: Rectangle {
                            x: 0
                            y: 0
                            width: 64
                            height: 64
                            radius: 12
                        }

                    }

                }

                Text {
                    anchors.centerIn: parent
                    text: "󰎈"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 28
                    color: root.colors.muted
                    visible: MprisService.artUrl === ""
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    text: MprisService.title || "No Media Playing"
                    color: root.colors.fg
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: MprisService.artist || "Unknown Artist"
                    color: root.colors.muted
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Item {
                    Layout.fillHeight: true
                }

            }

        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            Text {
                text: "󰒮"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 18
                color: root.colors.fg
                opacity: 0.8

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    onClicked: MprisService.previous()
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.8
                }

            }

            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: root.colors.accent

                Text {
                    anchors.centerIn: parent
                    text: MprisService.isPlaying ? "󰏤" : "󰐊"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 18
                    color: root.colors.bg
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: MprisService.playPause()
                    cursorShape: Qt.PointingHandCursor
                }

            }

            Text {
                text: "󰒭"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 18
                color: root.colors.fg
                opacity: 0.8

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    onClicked: MprisService.next()
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: parent.opacity = 1
                    onExited: parent.opacity = 0.8
                }

            }

        }

    }

    layer.effect: OpacityMask {

        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: 16
        }

    }

}
