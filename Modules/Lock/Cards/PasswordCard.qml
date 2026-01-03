import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell

BentoCard {
    id: root

    required property var colors
    required property var pam
    property alias inputField: inputField

    cardColor: colors.surface
    borderColor: inputField.activeFocus ? colors.accent : colors.border

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        width: parent.width - 32

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: root.colors.surface
                border.width: 2
                border.color: root.colors.accent

                Image {
                    id: avatarImg

                    anchors.fill: parent
                    anchors.margins: 2
                    source: "file://" + Quickshell.env("HOME") + "/.face"
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: status === Image.Ready

                    layer.effect: OpacityMask {

                        maskSource: Rectangle {
                            width: avatarImg.width
                            height: avatarImg.height
                            radius: width / 2
                        }

                    }

                }

                Text {
                    anchors.centerIn: parent
                    text: "󰀄"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 20
                    color: root.colors.muted
                    visible: avatarImg.status !== Image.Ready
                }

            }

            Text {
                text: Quickshell.env("USER") || "User"
                color: root.colors.fg
                font.pixelSize: 13
                font.bold: true
            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 18
            color: Qt.rgba(0, 0, 0, 0.35)
            border.width: 1
            border.color: inputField.activeFocus ? root.colors.accent : "transparent"

            TextInput {
                id: inputField

                property int shakeOffset: 0

                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                color: root.colors.fg
                font.pixelSize: 13
                font.letterSpacing: 3
                echoMode: TextInput.Password
                passwordCharacter: "●"
                focus: true
                Component.onCompleted: forceActiveFocus()
                onAccepted: {
                    if (text.length > 0) {
                        root.pam.submit(text);
                        text = "";
                    }
                }
                x: anchors.leftMargin + shakeOffset

                Text {
                    anchors.centerIn: parent
                    text: "Enter password"
                    color: root.colors.muted
                    font.pixelSize: 11
                    visible: !parent.text && !parent.activeFocus
                }

                SequentialAnimation {
                    id: shakeAnim

                    loops: 2

                    PropertyAnimation {
                        target: inputField
                        property: "shakeOffset"
                        to: 8
                        duration: 40
                    }

                    PropertyAnimation {
                        target: inputField
                        property: "shakeOffset"
                        to: -8
                        duration: 40
                    }

                    PropertyAnimation {
                        target: inputField
                        property: "shakeOffset"
                        to: 0
                        duration: 40
                    }

                }

                Connections {
                    function onFailure() {
                        shakeAnim.start();
                        inputField.color = root.colors.urgent;
                        errorLabel.visible = true;
                        failTimer.start();
                    }

                    function onError() {
                        shakeAnim.start();
                        inputField.color = root.colors.urgent;
                        errorLabel.visible = true;
                        failTimer.start();
                    }

                    target: root.pam
                }

                Timer {
                    id: failTimer

                    interval: 2000
                    onTriggered: {
                        inputField.color = root.colors.fg;
                        errorLabel.visible = false;
                    }
                }

            }

        }

        Text {
            id: errorLabel

            text: "Incorrect Password"
            color: root.colors.urgent
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            visible: false
            opacity: visible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }

            }

        }

    }

}
