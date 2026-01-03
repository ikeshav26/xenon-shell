import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import qs.Services

Item {
    id: root

    required property var theme

    function formatTime(seconds) {
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    implicitWidth: 400
    implicitHeight: 480
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: cardBackground

        anchors.fill: parent
        radius: 16
        color: "#1a1a1a"
        border.width: 1
        border.color: theme.border
        layer.enabled: true

        Image {
            id: albumArt

            anchors.fill: parent
            source: MprisService.artUrl
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
        }

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(0, parent.height)

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#40000000"
                }

                GradientStop {
                    position: 0.4
                    color: "#80000000"
                }

                GradientStop {
                    position: 1
                    color: "#e6000000"
                }

            }

        }

        Item {
            property var cavaValues: CavaService.values

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 0
            width: parent.width
            height: parent.height * 0.5 // Cover bottom half
            z: 0

            Binding {
                target: CavaService
                property: "running"
                value: MprisService.isPlaying && root.visible
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 10
                spacing: 6

                Repeater {
                    id: visualizerRepeater

                    model: 32 // Increase bars for better look

                    Rectangle {
                        property var val: CavaService.values[index] || 0

                        width: 6
                        height: 10 + (val * 50)
                        anchors.bottom: parent.bottom
                        color: theme.accent
                        opacity: 0.6
                        radius: 3

                        Behavior on height {
                            NumberAnimation {
                                duration: 60
                            }

                        }

                    }

                }

            }

        }

        ColumnLayout {
            id: contentColumn

            z: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 60 // Move down a bit
            width: parent.width
            anchors.margins: 24
            spacing: 16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: MprisService.title || "No Media"
                    font.bold: true
                    font.pixelSize: 20
                    color: "white"
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: MprisService.artist || "Unknown Artist"
                    font.pixelSize: 14
                    color: "#cccccc" // Light gray for subtext
                    elide: Text.ElideRight
                }

            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 32

                Item {
                    width: 32
                    height: 32

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮" // Previous icon
                        font.family: "Symbols Nerd Font"
                        color: "white"
                        font.pixelSize: 24
                        opacity: prevMouse.containsMouse ? 1 : 0.8
                    }

                    MouseArea {
                        id: prevMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.previous()
                    }

                }

                Rectangle {
                    width: 64
                    height: 64
                    radius: 20 // Rounded as user requested
                    color: theme.accent

                    Text {
                        anchors.centerIn: parent
                        text: MprisService.isPlaying ? "󰏤" : "󰐊"
                        font.family: "Symbols Nerd Font"
                        color: theme.bg // Contrast with accent
                        font.pixelSize: 28
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.playPause()
                        onPressed: parent.scale = 0.95
                        onReleased: parent.scale = 1
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }

                    }

                }

                Item {
                    width: 32
                    height: 32

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭" // Next icon
                        font.family: "Symbols Nerd Font"
                        color: "white"
                        font.pixelSize: 24
                        opacity: nextMouse.containsMouse ? 1 : 0.8
                    }

                    MouseArea {
                        id: nextMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisService.next()
                    }

                }

            }

            RowLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width * 0.9
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Text {
                    text: root.formatTime(MprisService.position)
                    color: "white"
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                }

                Item {
                    id: progressContainer

                    property bool seeking: false
                    property real seekValue: 0
                    property bool seekingCooldown: false

                    function seekTo(mouseX) {
                        var pos = Math.max(0, Math.min(mouseX / width, 1));
                        seekValue = pos * MprisService.length;
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: 24

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: 6
                        radius: 3
                        color: "#40ffffff"

                        Rectangle {
                            width: {
                                var len = MprisService.length > 0 ? MprisService.length : 1;
                                var pos = (progressContainer.seeking || progressContainer.seekingCooldown) ? progressContainer.seekValue : MprisService.position;
                                return (pos / len) * parent.width;
                            }
                            height: parent.height
                            radius: 3
                            color: theme.accent
                        }

                    }

                    Rectangle {
                        id: progressHandle

                        x: {
                            var len = MprisService.length > 0 ? MprisService.length : 1;
                            var pos = (progressContainer.seeking || progressContainer.seekingCooldown) ? progressContainer.seekValue : MprisService.position;
                            return (pos / len) * (parent.width - width);
                        }
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12
                        height: 24
                        radius: 6
                        color: theme.accent
                    }

                    Timer {
                        id: seekCooldownTimer

                        interval: 1000 // 1 second grace period for player to update
                        repeat: false
                        onTriggered: {
                            progressContainer.seekingCooldown = false;
                        }
                    }

                    Binding {
                        target: progressContainer
                        property: "seekValue"
                        value: MprisService.position
                        when: !progressContainer.seeking && !progressContainer.seekingCooldown
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => {
                            seekCooldownTimer.stop();
                            progressContainer.seekingCooldown = false;
                            progressContainer.seekTo(mouse.x);
                            progressContainer.seeking = true;
                        }
                        onPositionChanged: (mouse) => {
                            if (progressContainer.seeking)
                                progressContainer.seekTo(mouse.x);

                        }
                        onReleased: {
                            if (progressContainer.seeking) {
                                MprisService.setPosition(progressContainer.seekValue);
                                progressContainer.seeking = false;
                                progressContainer.seekingCooldown = true;
                                seekCooldownTimer.restart();
                            }
                        }
                    }

                }

                Text {
                    text: root.formatTime(MprisService.length)
                    color: "white"
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                }

            }

        }

        layer.effect: OpacityMask {

            maskSource: Rectangle {
                width: cardBackground.width
                height: cardBackground.height
                radius: cardBackground.radius
                visible: false // Only used as mask source
            }

        }

    }

}
