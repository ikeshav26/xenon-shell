import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    property ListModel notifications
    property var currentPopup: null
    property bool popupVisible: false
    property int notificationCounter: 0
    property ListModel activeNotifications

    activeNotifications: ListModel {
    }

    function closePopup() {
        popupVisible = false;
    }

    function clearHistory() {
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.ref)
                item.ref.dismiss();

        }
        notifications.clear();
        popupVisible = false;
    }

    function removeAtIndex(index) {
        var item = notifications.get(index);
        if (item && item.ref)
            item.ref.dismiss();

        notifications.remove(index);
    }

    function removeById(notifId) {
        Logger.d("NotifMan", "Removing notification with ID:", notifId);
        // Remove from active list (popup)
        for (var i = 0; i < activeNotifications.count; i++) {
            if (activeNotifications.get(i).id === notifId) {
                activeNotifications.remove(i);
                break;
            }
        }
        // Remove from history
        for (var i = 0; i < notifications.count; i++) {
            var item = notifications.get(i);
            if (item.id === notifId) {
                Logger.d("NotifMan", "  Found! Dismissing and removing...");
                if (item.ref) {
                    try {
                        item.ref.dismiss();
                    } catch (e) {
                        Logger.w("NotifMan", "Failed to dismiss notification (already destroyed?): " + e);
                    }
                }
                notifications.remove(i);
                return ;
            }
        }
        Logger.d("NotifMan", "  Not found!");
    }

    function removeSilent(notifId) {
        // Remove from active list
        for (var i = 0; i < activeNotifications.count; i++) {
            if (activeNotifications.get(i).id === notifId) {
                activeNotifications.remove(i);
                break;
            }
        }
        // Remove from history
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).id === notifId) {
                notifications.remove(i);
                return ;
            }
        }
    }

    function removeByRef(notificationRef) {
        // Remove from active list
        for (var i = 0; i < activeNotifications.count; i++) {
            if (activeNotifications.get(i).ref === notificationRef) {
                activeNotifications.remove(i);
                break;
            }
        }
        for (var i = 0; i < notifications.count; i++) {
            if (notifications.get(i).ref === notificationRef) {
                notifications.remove(i);
                break;
            }
        }
    }

    NotificationServer {
        id: server

        bodySupported: true
        imageSupported: true
        actionsSupported: true
        onNotification: (notification) => {
            // 5 seconds display time

            notification.tracked = true;
            var uniqueId = root.notificationCounter++;
            var entry = {
                "id": uniqueId,
                "ref": notification,
                "appName": notification.appName,
                "summary": notification.summary,
                "body": notification.body,
                "appIcon": notification.appIcon,
                "image": notification.image,
                "urgency": notification.urgency,
                "time": Qt.formatTime(new Date(), "hh:mm"),
                "expireTime": Date.now() + 5000
            };
            // Add to history
            root.notifications.insert(0, entry);
            // Add to active notifications (stack)
            root.activeNotifications.insert(0, entry);
            Logger.d("NotifMan", "Notification added:", notification.summary, "ID:", uniqueId, "Stack count:", root.activeNotifications.count);
            root.popupVisible = true;
            popupTimer.restart(); // Ensure timer is running
            notification.closed.connect(() => {
                Logger.d("NotifMan", "Notification closed signal received for ID:", uniqueId);
                root.removeSilent(uniqueId);
            });
        }
    }

    Timer {
        id: popupTimer

        interval: 1000
        repeat: true
        running: root.activeNotifications.count > 0
        onTriggered: {
            var now = Date.now();
            var kept = false;
            // Iterate backwards to safe remove
            for (var i = root.activeNotifications.count - 1; i >= 0; i--) {
                var item = root.activeNotifications.get(i);
                if (now >= item.expireTime)
                    root.activeNotifications.remove(i);
                else
                    kept = true;
            }
            if (!kept)
                root.popupVisible = false;

        }
    }

    notifications: ListModel {
    }

}
