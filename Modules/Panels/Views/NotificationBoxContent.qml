import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Modules.Notifications
import qs.Widgets

ColumnLayout {
    id: root
    width: 320
    spacing: 0
    
    required property var notifManager
    required property var theme

    // --- Header ---
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 44
        color: "transparent"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 8
            
            Rectangle {
                width: 24
                height: 24
                radius: 8
                color: theme.accentActive
                Text {
                    anchors.centerIn: parent
                    text: "󰂚"
                    font.family: "Symbols Nerd Font"
                    color: theme.bg
                    font.pixelSize: 14
                }
            }

            Text {
                text: "Notifications"
                color: theme.text
                font.pixelSize: 14
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Clear All"
                color: root.notifManager.notifications.count > 0 ? theme.urgent : theme.muted
                font.pixelSize: 11
                font.bold: true
                visible: root.notifManager.notifications.count > 0
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.notifManager.clearHistory()
                }
            }
        }
    }
    
    // Separator
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: theme.border
        opacity: 0.5
        Layout.bottomMargin: 8
    }

    // List
    ListView {
        id: notifList
        Layout.fillWidth: true
        Layout.fillHeight: true
        // Allow the list to define the height of the layout, up to a point handled by the parent container
        implicitHeight: contentItem.childrenRect.height
        Layout.minimumHeight: 100 
        
        clip: true
        spacing: 10
        model: root.notifManager.notifications
        
        delegate: NotificationItem {
            width: ListView.view.width - 4
            notifId: model.id
            summary: model.summary || ""
            body: model.body || ""
            image: model.image || ""
            appIcon: model.appIcon || ""
            theme: root.theme
            onRemoveRequested: root.notifManager.removeById(notifId)
        }

        // Empty state
        Text {
            anchors.centerIn: parent
            visible: parent.count === 0
            text: "No new notifications"
            color: theme.muted
            font.pixelSize: 12
            font.italic: true
        }
    }
}
