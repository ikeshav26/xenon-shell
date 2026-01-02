import QtQuick
pragma Singleton

QtObject {
    id: root

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


    function getStateColor(percent, charging, full) {
        if (charging) return "#a6e3a1"
        if (full) return "#89b4fa"      
        if (percent <= 20) return "#f38ba8"  
        if (percent <= 40) return "#fab387"  
        return "#cdd6f4"
    }

    
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