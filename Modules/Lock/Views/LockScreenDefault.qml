import "../Cards"
import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Services

Item {
    id: root

    required property var colors
    required property var pam
    required property var notifications
    property bool expanded: Config.disableLockAnimation
    property real expandedWidth: Math.min(width - 60, 920)
    property real expandedHeight: Math.min(height - 80, 480)
    property real collapsedSize: 120
    property alias inputField: passwordCard.inputField

    Item {
        anchors.fill: parent

        Loader {
            anchors.fill: parent
            sourceComponent: Config.lockScreenCustomBackground ? wallpaperComponent : screencopyComponent
        }

        Component {
            id: screencopyComponent

            ScreencopyView {
                anchors.fill: parent
                captureSource: Quickshell.screens[0]
                layer.enabled: true

                layer.effect: FastBlur {
                    radius: Config.disableLockBlur ? 0 : 48
                }

            }

        }

        Component {
            id: wallpaperComponent

            Image {
                anchors.fill: parent
                source: "file://" + WallpaperService.getWallpaper(Quickshell.screens[0].name)
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true

                layer.effect: FastBlur {
                    radius: Config.disableLockBlur ? 0 : 64
                    transparentBorder: false
                }

            }

        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: Config.disableLockAnimation ? 0.45 : 0

            NumberAnimation on opacity {
                from: 0
                to: 0.45
                duration: 400
                easing.type: Easing.OutQuad
                running: !Config.disableLockAnimation
            }

        }

    }

    Rectangle {
        id: morphContainer

        anchors.centerIn: parent
        width: root.expanded ? root.expandedWidth : root.collapsedSize
        height: root.expanded ? root.expandedHeight : root.collapsedSize
        color: Qt.rgba(root.colors.surface.r, root.colors.surface.g, root.colors.surface.b, 0.9)
        radius: root.expanded ? 20 : 30
        border.width: root.expanded ? 0 : 2
        border.color: root.colors.accent
        scale: Config.disableLockAnimation ? 1 : 0
        rotation: Config.disableLockAnimation ? 0 : -180

        SequentialAnimation {
            running: !Config.disableLockAnimation

            ParallelAnimation {
                NumberAnimation {
                    target: morphContainer
                    property: "scale"
                    from: 0
                    to: 1
                    duration: 450
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.3
                }

                NumberAnimation {
                    target: morphContainer
                    property: "rotation"
                    from: -180
                    to: 0
                    duration: 450
                    easing.type: Easing.OutBack
                }

            }

            PauseAnimation {
                duration: 250
            }

            ScriptAction {
                script: root.expanded = true
            }

        }

        Text {
            anchors.centerIn: parent
            text: "󰌾"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 48
            color: root.colors.accent
            opacity: root.expanded ? 0 : 1
            scale: root.expanded ? 0.5 : 1

            Behavior on opacity {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 300
                }

            }

            Behavior on scale {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 300
                }

            }

        }

        Item {
            anchors.fill: parent
            anchors.margins: 12
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : 0.8

            RowLayout {
                anchors.fill: parent
                spacing: 12
                visible: root.expanded

                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.3
                    Layout.fillHeight: true
                    spacing: 12

                    ClockCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colors: root.colors
                    }

                    MusicCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 130
                        colors: root.colors
                    }

                }

                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.4
                    Layout.fillHeight: true
                    spacing: 12

                    SystemInfoCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colors: root.colors
                    }

                    PasswordCard {
                        id: passwordCard

                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        colors: root.colors
                        pam: root.pam
                    }

                }

                ColumnLayout {
                    Layout.preferredWidth: (parent.width - 24) * 0.3
                    Layout.fillHeight: true
                    spacing: 12

                    SystemStatsCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        colors: root.colors
                    }

                    NotificationsCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        colors: root.colors
                        notifications: root.notifications
                    }

                }

            }

            Behavior on opacity {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 400
                }

            }

            Behavior on scale {
                enabled: !Config.disableLockAnimation

                NumberAnimation {
                    duration: 400
                }

            }

        }

        Behavior on width {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 1.02
            }

        }

        Behavior on height {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 1.02
            }

        }

        Behavior on radius {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 400
            }

        }

        Behavior on border.width {
            enabled: !Config.disableLockAnimation

            NumberAnimation {
                duration: 200
            }

        }

    }

}
