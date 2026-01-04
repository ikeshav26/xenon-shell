import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Core
import qs.Widgets

Rectangle {
    id: wsContainer

    required property var colors
    required property string fontFamily
    required property int fontSize
    property int activeWs: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    property int pageIndex: Math.floor((activeWs - 1) / 5)
    property int pageStart: pageIndex * 5 + 1
    property bool isSpecialOpen: Hyprland.focusedMonitor && Hyprland.focusedMonitor.lastIpcObject.specialWorkspace.name !== ""

    Layout.preferredWidth: 150
    Layout.preferredHeight: 26
    color: Qt.rgba(0, 0, 0, 0.2)
    radius: height / 2
    clip: true

    Connections {
        function onRawEvent(event) {
            const n = event.name;
            if (["activespecial", "focusedmon", "workspace", "moveworkspace"].includes(n))
                Hyprland.refreshMonitors();

        }

        target: Hyprland
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0)
                Hyprland.dispatch("workspace -1");
            else
                Hyprland.dispatch("workspace +1");
        }
    }

    Item {
        id: wsContent

        anchors.fill: parent
        opacity: parent.isSpecialOpen ? 0 : 1

        Rectangle {
            id: highlight

            property int relIndex: (wsContainer.activeWs - 1) % 5
            property real itemWidth: 26
            property real spacing: 4
            property real targetX1: relIndex * (itemWidth + spacing) + 2
            property real targetX2: targetX1
            property real animatedX1: targetX1
            property real animatedX2: targetX2

            onTargetX1Changed: animatedX1 = targetX1
            onTargetX2Changed: animatedX2 = targetX2
            x: Math.min(animatedX1, animatedX2)
            width: Math.abs(animatedX2 - animatedX1) + itemWidth
            height: 26
            radius: 13
            color: colors.accent

            Behavior on animatedX1 {
                NumberAnimation {
                    duration: Animations.fast
                    easing.type: Animations.standardEasing
                }

            }

            Behavior on animatedX2 {
                NumberAnimation {
                    duration: Animations.slow
                    easing.type: Animations.standardEasing
                }

            }

        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            spacing: 4

            Repeater {
                model: 5

                delegate: Item {
                    property int wsId: wsContainer.pageStart + index
                    property bool isActive: wsId === wsContainer.activeWs
                    property var workspace: Hyprland.workspaces.values.find((w) => {
                        return w.id === wsId;
                    })
                    property bool hasWindows: workspace !== undefined && workspace !== null

                    width: 26
                    height: 26

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: (parent.hasWindows && !parent.isActive) ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                        visible: true
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: (parent.isActive || parent.hasWindows) ? 6 : 4
                        height: width
                        radius: width / 2
                        color: parent.isActive ? colors.bg : (parent.hasWindows ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.2))
                        visible: Config.hideWorkspaceNumbers
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("workspace " + wsId)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: wsId
                        font.family: fontFamily
                        font.pixelSize: fontSize
                        font.bold: isActive
                        color: isActive ? colors.bg : (hasWindows ? colors.accent : colors.subtext)
                        visible: !Config.hideWorkspaceNumbers

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.fast
                            }

                        }

                    }

                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.fast
            }

        }

    }

    Rectangle {
        anchors.centerIn: parent
        width: 26
        height: 26
        radius: 13
        color: colors.accent
        scale: parent.isSpecialOpen ? 1 : 0.5
        opacity: parent.isSpecialOpen ? 1 : 0

        Icon {
            anchors.centerIn: parent
            icon: Icons.star
            font.pixelSize: 18
            color: colors.bg
            font.bold: true
        }

        Behavior on scale {
            NumberAnimation {
                duration: Animations.medium
                easing.type: Animations.enterEasing
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.medium
            }

        }

    }

}
