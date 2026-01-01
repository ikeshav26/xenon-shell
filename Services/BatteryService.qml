import QtQuick
pragma Singleton

QtObject {
    id: root

    // Helper function to get battery icon based on percentage and charging state
    function getIcon(percent, charging, isReady) {
        if (!isReady) return "󰂎"
        if (charging) return "󰂄"
        
        const p = Math.round(percent)
        if (p >= 90) return "󰁹"
        if (p >= 80) return "󰂂"
        if (p >= 70) return "󰂁"
        if (p >= 60) return "󰂀"
        if (p >= 50) return "󰁿"
        if (p >= 40) return "󰁾"
        if (p >= 30) return "󰁽"
        if (p >= 20) return "󰁼"
        if (p >= 10) return "󰁻"
        return "󰁺"
    }

    // Helper function to get state color
    function getStateColor(percent, charging, full) {
        if (charging) return "#a6e3a1"  // Green
        if (full) return "#89b4fa"       // Blue
        if (percent <= 20) return "#f38ba8"  // Red
        if (percent <= 40) return "#fab387"  // Orange
        return "#cdd6f4"                 // Normal
    }

    // Helper function to format time remaining
    function formatTime(seconds) {
        if (seconds <= 0) return ""
        
        const hours = Math.floor(seconds / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        
        if (hours > 0) {
            return hours + "h " + minutes + "m"
        }
        return minutes + "m"
    }
}