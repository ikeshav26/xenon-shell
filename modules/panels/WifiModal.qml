import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    property bool isOpen: false
    property var theme
    property string connectedNetwork: ""
    property bool wifiEnabled: true
    property var globalState
    
    signal close()
    
    // Close wifi modal when side panel closes
    Connections {
        target: globalState
        function onSidePanelOpenChanged() {
            if (!globalState.sidePanelOpen) {
                root.isOpen = false
            }
        }
    }
    
    // List available networks
    ListModel {
        id: networksModel
    }
    
    function updateWifiStatus() {
        const result = Process.exec("nmcli", ["-t", "-f", "WIFI", "radio"])
        if (result.exitCode === 0) {
            root.wifiEnabled = result.stdout.trim() === "enabled"
        }
    }
    
    function updateConnectedNetwork() {
        const result = Process.exec("nmcli", ["-t", "-f", "active,ssid", "dev", "wifi"])
        if (result.exitCode === 0) {
            const lines = result.stdout.split('\n')
            root.connectedNetwork = ""
            for (const line of lines) {
                if (line.startsWith('yes:')) {
                    root.connectedNetwork = line.substring(4).trim()
                    break
                }
            }
        }
    }
    
    function scanNetworks() {
        const result = Process.exec("nmcli", ["-t", "-f", "SSID,SIGNAL,SECURITY", "dev", "wifi", "list"])
        if (result.exitCode === 0) {
            networksModel.clear()
            const lines = result.stdout.split('\n').filter(line => line.trim() !== '')
            const seen = new Set()
            
            for (const line of lines) {
                const parts = line.split(':')
                if (parts.length >= 2) {
                    const ssid = parts[0].trim()
                    const signal = parseInt(parts[1]) || 0
                    const security = parts[2] || ''
                    const secured = security !== '' && security !== '--'
                    
                    if (ssid && !seen.has(ssid)) {
                        seen.add(ssid)
                        networksModel.append({
                            ssid: ssid,
                            signal: signal,
                            secured: secured,
                            connected: ssid === root.connectedNetwork
                        })
                    }
                }
            }
        }
    }
    
    onIsOpenChanged: {
        if (isOpen) {
            updateWifiStatus()
            updateConnectedNetwork()
            scanNetworks()
        }
    }
    
    Timer {
        interval: 10000
        running: root.isOpen
        repeat: true
        onTriggered: {
            updateWifiStatus()
            updateConnectedNetwork()
            scanNetworks()
        }
    }
    
    visible: isOpen
    anchors.fill: parent
    
    Rectangle {
        anchors.fill: parent
        color: theme.bg
        radius: 16
        opacity: root.isOpen ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        
        transform: Translate {
            x: root.isOpen ? 0 : parent.width
            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Rectangle {
                    width: 40
                    height: 40
                    color: theme.tile
                    radius: 8
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰖩"
                        font.pixelSize: 20
                        font.family: "Symbols Nerd Font"
                        color: root.wifiEnabled ? theme.accent : theme.iconMuted
                    }
                }
                
                Text {
                    text: "Wi-Fi"
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    color: theme.text
                    Layout.fillWidth: true
                }
                
                // Toggle WiFi
                Rectangle {
                    width: 52
                    height: 30
                    radius: 15
                    color: root.wifiEnabled ? theme.accent : theme.tile
                    
                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: "white"
                        x: root.wifiEnabled ? parent.width - width - 2 : 2
                        y: 2
                        
                        Behavior on x {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const newState = root.wifiEnabled ? "off" : "on"
                            Process.exec("nmcli", ["radio", "wifi", newState])
                            root.wifiEnabled = !root.wifiEnabled
                        }
                    }
                }
                
                // Close button
                Rectangle {
                    width: 32
                    height: 32
                    color: "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.pixelSize: 18
                        font.family: "Symbols Nerd Font"
                        color: theme.secondary
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }
            
            // Connected network section
            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: theme.tile
                radius: 12
                visible: root.connectedNetwork !== ""
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    Rectangle {
                        width: 48
                        height: 48
                        color: theme.surface
                        radius: 8
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰖩"
                            font.pixelSize: 24
                            font.family: "Symbols Nerd Font"
                            color: theme.accent
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: root.connectedNetwork
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: theme.text
                        }
                        
                        Text {
                            text: "Connected"
                            font.pixelSize: 13
                            color: theme.secondary
                        }
                    }
                    
                    Text {
                        text: "󰅂"
                        font.pixelSize: 16
                        font.family: "Symbols Nerd Font"
                        color: theme.secondary
                    }
                }
            }
            
            // Available networks header
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                
                Text {
                    text: "Available networks"
                    font.pixelSize: 14
                    color: theme.secondary
                    Layout.fillWidth: true
                }
                
                // Refresh button
                Rectangle {
                    width: 80
                    height: 28
                    color: "transparent"
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            text: "󰑓"
                            font.pixelSize: 14
                            font.family: "Symbols Nerd Font"
                            color: theme.accent
                        }
                        
                        Text {
                            text: "Refresh"
                            font.pixelSize: 13
                            color: theme.accent
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: scanNetworks()
                    }
                }
            }
            
            // Networks list
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ListView {
                    model: networksModel
                    spacing: 8
                    
                    delegate: Rectangle {
                        required property string ssid
                        required property int signal
                        required property bool secured
                        required property bool connected
                        
                        width: ListView.view.width
                        height: 64
                        color: theme.tile
                        radius: 12
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            Text {
                                text: {
                                    if (signal > 75) return "󰤨"
                                    if (signal > 50) return "󰤥"
                                    if (signal > 25) return "󰤢"
                                    return "󰤟"
                                }
                                font.pixelSize: 20
                                font.family: "Symbols Nerd Font"
                                color: connected ? theme.accent : theme.text
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                
                                Text {
                                    text: ssid
                                    font.pixelSize: 14
                                    font.weight: connected ? Font.Medium : Font.Normal
                                    color: theme.text
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                Text {
                                    text: connected ? "Connected" : (secured ? "Secured" : "Open")
                                    font.pixelSize: 12
                                    color: theme.secondary
                                }
                            }
                            
                            Text {
                                text: secured ? "󰌾" : ""
                                font.pixelSize: 14
                                font.family: "Symbols Nerd Font"
                                color: theme.secondary
                                visible: secured
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!connected) {
                                    Process.exec("nmcli", ["dev", "wifi", "connect", ssid])
                                }
                            }
                        }
                    }
                }
            }
            
            // More settings button
            Rectangle {
                Layout.fillWidth: true
                height: 44
                color: "transparent"
                border.color: theme.accent
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "More settings"
                    font.pixelSize: 14
                    color: theme.accent
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Process.exec("nm-connection-editor", [])
                    }
                }
            }
        }
    }
}
