import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Core
import qs.Services

Item {
    id: root

    required property var theme

    implicitWidth: 440
    implicitHeight: 420

    Flickable {
        anchors.fill: parent
        anchors.margins: 16
        contentWidth: width
        contentHeight: contentLayout.height
        clip: true
        interactive: true

        ColumnLayout {
            id: contentLayout

            width: parent.width
            spacing: 24

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                radius: 20
                clip: true
                border.width: 1
                border.color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.3)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    Item {
                        Layout.preferredWidth: 100
                        Layout.fillHeight: true

                        Text {
                            anchors.centerIn: parent
                            text: WeatherService.icon
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 84
                            color: theme.accent
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.3)
                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 0

                        Text {
                            text: WeatherService.temperature
                            color: theme.fg
                            font.pixelSize: 64
                            font.bold: true

                            Text {
                                text: WeatherService.conditionText
                                color: theme.fg
                                opacity: 0.7
                                font.pixelSize: 16
                                font.capitalization: Font.Capitalize
                                font.weight: Font.DemiBold
                                anchors.top: parent.bottom
                                anchors.left: parent.left
                                anchors.leftMargin: 4
                            }

                        }

                        Item {
                            Layout.preferredHeight: 24
                        }

                        RowLayout {
                            spacing: 8
                            opacity: 0.8

                            Text {
                                text: ""
                                font.family: "Symbols Nerd Font"
                                color: theme.blue
                                font.pixelSize: 14
                            }

                            Text {
                                text: WeatherService.city
                                color: theme.fg
                                font.pixelSize: 14
                                font.bold: true
                            }

                        }

                    }

                }

                gradient: Gradient {
                    orientation: Gradient.Horizontal

                    GradientStop {
                        position: 0
                        color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.25)
                    }

                    GradientStop {
                        position: 1
                        color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.25)
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.2)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.05)
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Text {
                        text: "24-Hour Temperature Trend"
                        Layout.margins: 12
                        font.bold: true
                        color: theme.subtext
                        font.pixelSize: 12
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 12

                        Shape {
                            id: tempGraph

                            property var points: WeatherService.hourlyForecast
                            property var minTemp: Math.min.apply(null, points) || 0
                            property var maxTemp: Math.max.apply(null, points) || 100
                            property var range: maxTemp - minTemp || 1

                            anchors.fill: parent

                            ShapePath {
                                strokeWidth: 3
                                strokeColor: theme.blue
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap
                                joinStyle: ShapePath.RoundJoin
                                startX: 0
                                startY: tempGraph.height / 2

                                PathPolyline {
                                    path: {
                                        var p = [];
                                        var data = tempGraph.points;
                                        if (!data || data.length < 2)
                                            return [];

                                        var w = tempGraph.width;
                                        var h = tempGraph.height;
                                        var step = w / (data.length - 1);
                                        var yPad = 10;
                                        var hAvail = h - (yPad * 2);
                                        for (var i = 0; i < data.length; i++) {
                                            var x = i * step;
                                            var val = data[i];
                                            var norm = (val - tempGraph.minTemp) / tempGraph.range;
                                            var y = h - (yPad + (norm * hAvail));
                                            p.push(Qt.point(x, y));
                                        }
                                        return p;
                                    }
                                }

                            }

                        }

                    }

                }

            }

            GridLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                columns: 3
                columnSpacing: 12
                rowSpacing: 12

                StatChip {
                    icon: "󰖎"
                    label: "Humidity"
                    value: WeatherService.humidity
                    tint: theme.blue
                }

                StatChip {
                    icon: "󰖝"
                    label: "Wind"
                    value: WeatherService.wind
                    tint: theme.cyan
                }

                StatChip {
                    icon: "󰖒"
                    label: "Pressure"
                    value: WeatherService.pressure
                    tint: theme.purple
                }

                StatChip {
                    icon: "󰖕"
                    label: "UV Index"
                    value: WeatherService.uvIndex
                    tint: theme.yellow
                }

                StatChip {
                    icon: ""
                    label: "Sunrise"
                    value: WeatherService.sunrise
                    tint: theme.orange
                }

                StatChip {
                    icon: ""
                    label: "Sunset"
                    value: WeatherService.sunset
                    tint: theme.red
                }

                component StatChip: Rectangle {
                    property string icon
                    property string label
                    property string value
                    property color tint: theme.blue

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.3)
                    radius: 16
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.05)

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: icon
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 24
                            color: tint
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: value
                            font.pixelSize: 14
                            font.bold: true
                            color: theme.fg
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: label
                            font.pixelSize: 11
                            color: theme.subtext
                        }

                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 240
                color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.2)
                radius: 16
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.05)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "5-Day Forecast"
                        font.bold: true
                        font.pixelSize: 14
                        color: theme.subtext
                        Layout.bottomMargin: 4
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: WeatherService.forecastModel
                        spacing: 8
                        interactive: false

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 40
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                spacing: 12

                                Text {
                                    Layout.preferredWidth: 40
                                    text: modelData.day
                                    color: theme.fg
                                    font.bold: true
                                    font.pixelSize: 14
                                }

                                Text {
                                    text: modelData.icon
                                    font.family: "Symbols Nerd Font"
                                    color: theme.accent
                                    font.pixelSize: 20
                                }

                                Text {
                                    text: modelData.condition
                                    color: theme.subtext
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.max + " / " + modelData.min
                                    color: theme.fg
                                    font.pixelSize: 14
                                    font.bold: true
                                    Layout.alignment: Qt.AlignRight
                                }

                            }

                        }

                    }

                }

            }

        }

        ScrollBar.vertical: ScrollBar {
            active: true
        }

    }

}
