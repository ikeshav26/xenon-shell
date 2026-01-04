import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Core
import qs.Services
import qs.Widgets

Rectangle {
    id: root

    required property var colors
    required property string fontFamily
    required property int fontSize
    required property var globalState
    required property var networkService
    required property var volumeService
    required property int volumeLevel
    default property alias content: innerLayout.data
    property var battery: UPower.displayDevice
    property real batteryPercent: battery && battery.percentage !== undefined ? battery.percentage * 100 : 0
    property bool batteryCharging: battery && battery.state === UPowerDeviceState.Charging
    property bool batteryFull: battery && battery.state === UPowerDeviceState.FullyCharged
    property bool batteryReady: battery && battery.ready && battery.percentage !== undefined && battery.isPresent

    Layout.preferredHeight: 26
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: innerLayout.implicitWidth + 20
    radius: height / 2
    color: "transparent"
    border.color: colors.muted
    border.width: 1

    RowLayout {
        id: innerLayout

        anchors.centerIn: parent
        spacing: 8

        RowLayout {
            visible: networkService
            spacing: 6

            Icon {
                icon: networkService.ethernetConnected ? Icons.networkEthernet : (networkService.wifiEnabled ? Icons.networkWifiConnected : Icons.networkWifiDisconnected)
                color: (networkService.ethernetConnected || networkService.wifiEnabled) ? colors.purple : colors.muted
                font.pixelSize: fontSize + 2
            }

            Text {
                id: tNet

                text: {
                    if (networkService.active)
                        return networkService.active.ssid;

                    if (networkService.ethernetConnected)
                        return "Ethernet";

                    return networkService.wifiEnabled ? "Disconnected" : "Off";
                }
                color: colors.fg
                font.pixelSize: fontSize - 1
                font.family: fontFamily
                font.bold: true
                Layout.maximumWidth: 150
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignBaseline
            }

            TapHandler {
                onTapped: globalState.requestSidePanelMenu("wifi")
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

        }

        VerticalDivider {
            visible: networkService
            Layout.preferredHeight: 12
            colors: root.colors
        }

        Item {
            Layout.preferredHeight: volumeLayout.implicitHeight
            Layout.preferredWidth: volumeLayout.implicitWidth

            RowLayout {
                id: volumeLayout

                anchors.centerIn: parent
                spacing: 6

                Icon {
                    icon: volumeService ? volumeService.icon : Icons.volumeHigh
                    color: colors.yellow
                    font.pixelSize: fontSize + 2

                    Behavior on text {
                        enabled: false
                    }

                }

                Text {
                    id: tVol

                    text: (volumeService && volumeService.muted) ? "MUT" : (volumeLevel + "%")
                    color: (volumeService && volumeService.muted) ? colors.red : colors.fg
                    font.pixelSize: fontSize - 1
                    font.family: fontFamily
                    font.bold: true
                    Layout.alignment: Qt.AlignBaseline
                }

            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                onClicked: {
                    if (volumeService)
                        volumeService.toggleMute();

                }
                onWheel: (wheel) => {
                    if (!volumeService)
                        return ;

                    if (wheel.angleDelta.y > 0)
                        volumeService.increaseVolume();
                    else
                        volumeService.decreaseVolume();
                }
            }

        }

        VerticalDivider {
            visible: root.batteryReady
            Layout.preferredHeight: 12
            colors: root.colors
        }

        RowLayout {
            visible: root.batteryReady
            spacing: 6

            Icon {
                icon: BatteryService.getIcon(root.batteryPercent, root.batteryCharging, root.batteryReady)
                color: BatteryService.getStateColor(root.batteryPercent, root.batteryCharging, root.batteryFull)
                font.pixelSize: fontSize + 2
            }

            Text {
                text: Math.round(root.batteryPercent) + "%"
                color: colors.fg
                font.pixelSize: fontSize - 1
                font.family: fontFamily
                font.bold: true
                Layout.alignment: Qt.AlignBaseline
            }

        }

    }

}
