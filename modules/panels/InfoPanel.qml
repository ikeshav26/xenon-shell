import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../core"

PanelWindow {
    id: root
    
    required property var globalState
    
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    visible: globalState.infoPanelOpen
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "info-panel"
    WlrLayershell.exclusiveZone: -1
    
    color: "transparent"
    
    Colors { id: theme }
    
    // Animated background with blur effect
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, globalState.infoPanelOpen ? 0.5 : 0)
        opacity: globalState.infoPanelOpen ? 1 : 0
        
        Behavior on color {
            ColorAnimation { duration: 350; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }
    }
    
    // Click outside to close
    MouseArea {
        anchors.fill: parent
        enabled: globalState.infoPanelOpen
        onClicked: {
            globalState.infoPanelOpen = false
        }
        z: 0
    }
    
    // Main panel with modern glassmorphism
    Rectangle {
        id: panelContent
        z: 1
        
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 12
        anchors.topMargin: 52
        
        width: 420
        height: 720
        
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.97)
        radius: 24
        border.color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.25)
        border.width: 2
        
        clip: true
        
        opacity: globalState.infoPanelOpen ? 1 : 0
        scale: globalState.infoPanelOpen ? 1 : 0.92
        
        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 1.15
            }
        }
        
        // Prevent clicks from propagating
        MouseArea {
            anchors.fill: parent
            onClicked: {}
            z: -1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10
            
            // --- Compact Header with GIFs ---
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                spacing: 10
                
                // Left GIF - Bongo Cat
                Rectangle {
                    Layout.preferredWidth: 52
                    Layout.preferredHeight: 52
                    radius: 16
                    color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.12)
                    border.color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.25)
                    border.width: 1.5
                    clip: true
                    
                    AnimatedImage {
                        anchors.centerIn: parent
                        width: 44
                        height: 44
                        fillMode: Image.PreserveAspectFit
                        source: "../../public/bongo-cat-transparent.gif"
                        playing: globalState.infoPanelOpen
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🎀"
                            font.pixelSize: 36
                            visible: parent.status === Image.Error
                            
                            SequentialAnimation on scale {
                                running: true
                                loops: Animation.Infinite
                                NumberAnimation { from: 1.0; to: 1.1; duration: 900; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 1.1; to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
                            }
                        }
                    }
                }
                
                // Greeting Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    Text {
                        text: "Hello, User! 👋"
                        color: theme.fg
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        font.letterSpacing: -0.5
                    }
                    
                    Text {
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.65)
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    RowLayout {
                        spacing: 5
                        
                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: theme.green
                            
                            SequentialAnimation on opacity {
                                running: true
                                loops: Animation.Infinite
                                NumberAnimation { from: 1.0; to: 0.3; duration: 1100 }
                                NumberAnimation { from: 0.3; to: 1.0; duration: 1100 }
                            }
                        }
                        
                        Text {
                            text: Qt.formatTime(new Date(), "hh:mm AP")
                            color: theme.green
                            font.pixelSize: 11
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                        }
                    }
                }
                
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
                radius: 0.5
            }
            
            // --- Compact Tabs ---
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                spacing: 6
                
                Repeater {
                    model: [
                        { icon: "󰃰", name: "Calendar" },
                        { icon: "󰝚", name: "Music" },
                        { icon: "󰖐", name: "Weather" },
                        { icon: "󰍛", name: "System" }
                    ]
                    
                    Rectangle {
                        required property int index
                        required property var modelData
                        
                        property bool isActive: contentStack.currentIndex === index
                        
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        Layout.maximumHeight: 34
                        radius: 11
                        
                        color: isActive ? 
                               Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.18) : 
                               tabArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.05) :
                               "transparent"
                        
                        border.color: isActive ? 
                                      Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.4) : 
                                      Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                        border.width: isActive ? 1.5 : 1
                        
                        scale: tabArea.pressed ? 0.95 : 1.0
                        
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                text: modelData.icon
                                color: isActive ? theme.purple : theme.fg
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 14
                                
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            
                            Text {
                                text: modelData.name
                                color: isActive ? theme.purple : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.7)
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9
                                font.bold: isActive
                                
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                        
                        MouseArea {
                            id: tabArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: contentStack.currentIndex = index
                        }
                    }
                }
            }
            
            // --- Content Stack ---
            StackLayout {
                id: contentStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0
                
                CalendarTab { theme: theme }
                MusicTab { theme: theme }
                WeatherTab { theme: theme }
                SystemTab { theme: theme }
            }
        }
    }
    
    // --- Calendar Tab ---
    component CalendarTab: Item {
        required property var theme
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 12
            
            // Current Date Display
            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.15) }
                    GradientStop { position: 1.0; color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.1) }
                }
                border.color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.22)
                border.width: 1.5
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 3
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "dddd")
                        color: theme.purple
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 1
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(), "MMMM d, yyyy")
                        color: theme.fg
                        font.pixelSize: 16
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }
            
            // Calendar Grid Container
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.03)
                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10
                    
                    // Month Navigation
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            Layout.fillWidth: true
                            text: Qt.formatDate(new Date(), "MMMM yyyy")
                            color: theme.fg
                            font.pixelSize: 15
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 8
                            color: prevArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08) : "transparent"
                            border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.15)
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰍞"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 14
                                color: theme.fg
                            }
                            
                            MouseArea {
                                id: prevArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                        
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 8
                            color: nextArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08) : "transparent"
                            border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.15)
                            border.width: 1
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰍟"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 14
                                color: theme.fg
                            }
                            
                            MouseArea {
                                id: nextArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                    
                    // Day Headers
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 7
                        rowSpacing: 5
                        columnSpacing: 5
                        
                        Repeater {
                            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                            
                            Text {
                                required property string modelData
                                Layout.fillWidth: true
                                text: modelData
                                font.pixelSize: 10
                                font.bold: true
                                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.5)
                                horizontalAlignment: Text.AlignHCenter
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }
                    
                    // Calendar Days
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        rowSpacing: 4
                        columnSpacing: 4
                        
                        Repeater {
                            model: 35
                            
                            Rectangle {
                                required property int index
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 9
                                
                                property int dayNumber: {
                                    var today = new Date()
                                    var firstDay = new Date(today.getFullYear(), today.getMonth(), 1)
                                    var startDay = firstDay.getDay()
                                    return index - startDay + 1
                                }
                                
                                property bool isCurrentMonth: dayNumber > 0 && dayNumber <= new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).getDate()
                                property bool isToday: isCurrentMonth && dayNumber === new Date().getDate()
                                
                                color: isToday ? theme.purple : 
                                       dayArea.containsMouse && isCurrentMonth ? Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.12) : 
                                       "transparent"
                                
                                scale: dayArea.pressed && isCurrentMonth ? 0.92 : 1.0
                                
                                Behavior on color { ColorAnimation { duration: 180 } }
                                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: isCurrentMonth ? dayNumber : ""
                                    font.pixelSize: 12
                                    font.bold: isToday
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: isToday ? theme.bg : 
                                           isCurrentMonth ? theme.fg : 
                                           Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.3)
                                }
                                
                                MouseArea {
                                    id: dayArea
                                    anchors.fill: parent
                                    hoverEnabled: isCurrentMonth
                                    cursorShape: isCurrentMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // --- Music Tab ---
    component MusicTab: Item {
        required property var theme
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 14
            
            // Album Art
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 160
                Layout.preferredHeight: 160
                radius: 18
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.04)
                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                border.width: 1
                
                Rectangle {
                    anchors.centerIn: parent
                    width: 130
                    height: 130
                    radius: 14
                    color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.15)
                    border.color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.3)
                    border.width: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰝚"
                        font.pixelSize: 45
                        font.family: "Symbols Nerd Font"
                        color: theme.purple
                        opacity: 0.6
                        
                        SequentialAnimation on scale {
                            running: true
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 1.08; duration: 1100; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.08; to: 1.0; duration: 1100; easing.type: Easing.InOutQuad }
                        }
                    }
                }
            }
            
            // Song Info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: "No Music Playing"
                    color: theme.fg
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: "Connect your music player"
                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.65)
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // Progress Bar
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 5
                    radius: 2.5
                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                    
                    Rectangle {
                        width: parent.width * 0
                        height: parent.height
                        radius: parent.radius
                        color: theme.purple
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "0:00"
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "0:00"
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                    }
                }
            }
            
            // Controls
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 16
                
                Repeater {
                    model: [
                        { icon: "󰒮", size: 22 },
                        { icon: "󰒭", size: 26 },
                        { icon: "󰐊", size: 34 },
                        { icon: "󰒬", size: 26 },
                        { icon: "󰒯", size: 22 }
                    ]
                    
                    Rectangle {
                        required property int index
                        required property var modelData
                        
                        width: modelData.size + 18
                        height: modelData.size + 18
                        radius: (modelData.size + 18) / 2
                        color: index === 2 ? theme.purple : 
                               controlArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08) : 
                               "transparent"
                        border.color: index === 2 ? "transparent" : Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.2)
                        border.width: 1.5
                        
                        scale: controlArea.pressed ? 0.92 : 1.0
                        
                        Behavior on color { ColorAnimation { duration: 180 } }
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: modelData.size
                            color: index === 2 ? theme.bg : theme.fg
                        }
                        
                        MouseArea {
                            id: controlArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
    
    // --- Weather Tab ---
    component WeatherTab: Item {
        required property var theme
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 12
            
            // Current Weather Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 115
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.2) }
                    GradientStop { position: 1.0; color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.15) }
                }
                border.color: Qt.rgba(theme.blue.r, theme.blue.g, theme.blue.b, 0.3)
                border.width: 1.5
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 14
                    
                    Text {
                        text: "󰖐"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 52
                        color: theme.fg
                        
                        SequentialAnimation on rotation {
                            running: true
                            loops: Animation.Infinite
                            NumberAnimation { from: -6; to: 6; duration: 2200; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 6; to: -6; duration: 2200; easing.type: Easing.InOutQuad }
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "24°C"
                            color: theme.fg
                            font.pixelSize: 28
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        
                        Text {
                            text: "Partly Cloudy"
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.8)
                            font.pixelSize: 13
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        
                        Text {
                            text: "📍 Your Location"
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                            font.pixelSize: 11
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                }
            }
            
            // Weather Details Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 8
                
                Repeater {
                    model: [
                        { icon: "󰖎", label: "Humidity", value: "45%" },
                        { icon: "󰖝", label: "Wind", value: "12 km/h" },
                        { icon: "󰖒", label: "Pressure", value: "1012 hPa" },
                        { icon: "󰖕", label: "UV Index", value: "Moderate" }
                    ]
                    
                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 62
                        radius: 12
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.04)
                        border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10
                            
                            Text {
                                text: modelData.icon
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 24
                                color: theme.purple
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                
                                Text {
                                    text: modelData.label
                                    font.pixelSize: 10
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                                }
                                
                                Text {
                                    text: modelData.value
                                    font.pixelSize: 13
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: theme.fg
                                }
                            }
                        }
                    }
                }
            }
            
            // 5-Day Forecast
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.03)
                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: "5-Day Forecast"
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        color: theme.fg
                    }
                    
                    Repeater {
                        model: [
                            { day: "Mon", icon: "󰖐", low: "18°", high: "24°" },
                            { day: "Tue", icon: "󰖕", low: "19°", high: "25°" },
                            { day: "Wed", icon: "󰖑", low: "17°", high: "22°" },
                            { day: "Thu", icon: "󰖐", low: "20°", high: "26°" },
                            { day: "Fri", icon: "󰖎", low: "18°", high: "23°" }
                        ]
                        
                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            height: 32
                            radius: 8
                            color: forecastArea.containsMouse ? Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.05) : "transparent"
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 10
                                
                                Text {
                                    Layout.preferredWidth: 35
                                    text: modelData.day
                                    font.pixelSize: 12
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: theme.fg
                                }
                                
                                Text {
                                    text: modelData.icon
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 16
                                    color: theme.purple
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: modelData.low
                                    font.pixelSize: 11
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.6)
                                }
                                
                                Text {
                                    text: modelData.high
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: theme.fg
                                }
                            }
                            
                            MouseArea {
                                id: forecastArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }
    
    // --- System Tab ---
    component SystemTab: Item {
        required property var theme
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 12
            
            // System Status Card with Bongo Cat
            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.15) }
                    GradientStop { position: 1.0; color: Qt.rgba(theme.green.r, theme.green.g, theme.green.b, 0.1) }
                }
                border.color: Qt.rgba(theme.purple.r, theme.purple.g, theme.purple.b, 0.22)
                border.width: 1.5
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14
                    
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "System Status"
                            font.pixelSize: 14
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            color: theme.fg
                        }
                        
                        Text {
                            text: "Everything running smoothly!"
                            font.pixelSize: 12
                            font.family: "JetBrainsMono Nerd Font"
                            color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.7)
                        }
                        
                        RowLayout {
                            spacing: 6
                            
                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: theme.green
                                
                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 1000 }
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 1000 }
                                }
                            }
                            
                            Text {
                                text: "All systems operational"
                                font.pixelSize: 10
                                font.family: "JetBrainsMono Nerd Font"
                                color: theme.green
                                font.bold: true
                            }
                        }
                    }
                }
            }
            
            // System Stats Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 8
                
                Repeater {
                    model: [
                        { icon: "󰻠", label: "CPU Usage", value: "45%", progress: 0.45, color: theme.blue },
                        { icon: "󰍛", label: "Memory", value: "8.2 GB", progress: 0.62, color: theme.purple },
                        { icon: "󰋊", label: "Disk", value: "234 GB", progress: 0.78, color: theme.green },
                        { icon: "󰓅", label: "Network", value: "12 MB/s", progress: 0.35, color: theme.yellow }
                    ]
                    
                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 58
                        radius: 12
                        color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.04)
                        border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                        border.width: 1
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                Text {
                                    text: modelData.icon
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 20
                                    color: modelData.color
                                }
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.family: "JetBrainsMono Nerd Font"
                                    color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.7)
                                }
                            }
                            
                            Text {
                                text: modelData.value
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "JetBrainsMono Nerd Font"
                                color: theme.fg
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 4
                                radius: 2
                                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.1)
                                
                                Rectangle {
                                    width: parent.width * modelData.progress
                                    height: parent.height
                                    radius: parent.radius
                                    color: modelData.color
                                    
                                    Behavior on width {
                                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Quick Actions
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.03)
                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.08)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: "Quick Actions"
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        color: theme.fg
                    }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 6
                        columnSpacing: 6
                        
                        Repeater {
                            model: [
                                { icon: "󰐥", label: "Lock", color: theme.red },
                                { icon: "󰜉", label: "Power", color: theme.blue },
                                { icon: "󰁯", label: "Settings", color: theme.purple },
                                { icon: "󰌍", label: "Terminal", color: theme.green }
                            ]
                            
                            Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                height: 42
                                radius: 10
                                color: actionArea.containsMouse ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.12) : "transparent"
                                border.color: Qt.rgba(theme.fg.r, theme.fg.g, theme.fg.b, 0.12)
                                border.width: 1
                                
                                scale: actionArea.pressed ? 0.96 : 1.0
                                
                                Behavior on color { ColorAnimation { duration: 170 } }
                                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8
                                    
                                    Text {
                                        text: modelData.icon
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 18
                                        color: modelData.color
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.label
                                        font.pixelSize: 11
                                        font.family: "JetBrainsMono Nerd Font"
                                        color: theme.fg
                                    }
                                }
                                
                                MouseArea {
                                    id: actionArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}