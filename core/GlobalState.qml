import QtQuick

QtObject {
    id: root

    // --- State Properties ---
    property bool launcherOpen: false
    property bool clipboardOpen: false

    // --- Actions ---
    function toggleLauncher() {
        if (launcherOpen) {
            launcherOpen = false;
        } else {
            // Close others when opening launcher (Exclusive mode)
            closeAll();
            launcherOpen = true;
        }
    }

    function toggleClipboard() {
        if (clipboardOpen) {
            clipboardOpen = false;
        } else {
            closeAll();
            clipboardOpen = true;
        }
    }

    function closeAll() {
        launcherOpen = false;
        clipboardOpen = false;
    }
}
