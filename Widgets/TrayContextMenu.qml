import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property var menuHandle: null
    property real menuX: 0
    property real menuY: 0

    function open(handle, x, y) {
        menuHandle = handle;
        menuX = x;
        menuY = y;
        visible = true;
    }

    color: "transparent"
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    }

    Item {
        id: animationContainer

        property int targetHeight: menuBox.height

        x: Math.min(root.menuX, Screen.width - width)
        y: Math.min(root.menuY, Screen.height - targetHeight)
        width: 200
        height: visible ? targetHeight : 0 // Start closed
        clip: true

        Rectangle {
            id: menuBox

            width: parent.width
            height: column.implicitHeight + 10
            color: "#1e1e2e" // Dark background
            radius: 8
            border.color: "#313244"
            border.width: 1
            anchors.top: parent.top // Stick to top so it reveals downward

            QsMenuOpener {
                id: opener

                menu: root.menuHandle
            }

            ColumnLayout {
                id: column

                anchors.fill: parent
                anchors.margins: 5
                spacing: 2

                Repeater {
                    model: opener.children

                    Item {
                        id: menuItem

                        Layout.fillWidth: true
                        Layout.preferredHeight: modelData.isSeparator ? 1 : 30
                        visible: true

                        Rectangle {
                            visible: modelData.isSeparator
                            anchors.centerIn: parent
                            width: parent.width
                            height: 1
                            color: "#313244"
                        }

                        Rectangle {
                            visible: !modelData.isSeparator
                            anchors.fill: parent
                            color: hover.containsMouse ? "#313244" : "transparent"
                            radius: 4

                            MouseArea {
                                id: hover

                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    modelData.triggered();
                                    root.visible = false;
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Text {
                                    text: modelData.text
                                    color: "#cdd6f4"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                }

                            }

                        }

                    }

                }

            }

        }

        Behavior on height {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuart
            }

        }

    }

}
