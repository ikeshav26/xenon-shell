import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Services

Item {
    // Logger.d("Wallpaper", "Transition complete!");

    id: root

    property string source: ""
    property Image currentImage: img1
    property int transitionType: 0
    property string screenName: screen ? screen.name : ""

    function applyTransition(newImage, oldImage) {
        // Logger.d("Wallpaper", "Starting transition type", transitionType);
        var w = root.width;
        var h = root.height;
        oldImage.opacity = 1;
        oldImage.scale = 1;
        oldImage.rotation = 0;
        switch (transitionType) {
        case 0:
            // Smooth Fade - Classic crossfade
            // Logger.d("Wallpaper", "Applying FADE transition");
            newImage.x = 0;
            newImage.y = 0;
            newImage.scale = 1;
            newImage.rotation = 0;
            newImage.opacity = 0;
            break;
        case 1:
            // Slide Left - Push from right
            Logger.d("Wallpaper", "Applying SLIDE LEFT transition");
            newImage.x = w * 1.2; // Start further off-screen
            newImage.y = 0;
            newImage.scale = 1;
            newImage.rotation = 0;
            newImage.opacity = 1;
            oldImage.x = -w * 1.2; // Slide out further
            break;
        case 2:
            // Slide Up - Push from bottom
            Logger.d("Wallpaper", "Applying SLIDE UP transition");
            newImage.x = 0;
            newImage.y = h * 1.2; // Start further off-screen
            newImage.scale = 1;
            newImage.rotation = 0;
            newImage.opacity = 1;
            oldImage.y = -h * 1.2; // Slide out further
            break;
        case 3:
            // Zoom In - Scale up fade
            Logger.d("Wallpaper", "Applying ZOOM IN transition");
            newImage.x = 0;
            newImage.y = 0;
            newImage.scale = 1.6;
            newImage.rotation = 0;
            newImage.opacity = 0;
            oldImage.scale = 0.75;
            break;
        case 4:
            // Cube Effect - Compiz style
            Logger.d("Wallpaper", "Applying CUBE transition");
            newImage.x = w * 1.1;
            newImage.y = 0;
            newImage.scale = 0.85;
            newImage.rotation = 0;
            newImage.opacity = 1;
            oldImage.x = -w * 0.4;
            oldImage.scale = 0.85;
            break;
        case 5:
            // Glide - Diagonal movement
            Logger.d("Wallpaper", "Applying GLIDE transition");
            newImage.x = 0;
            newImage.y = -h * 0.3;
            newImage.scale = 1.15;
            newImage.rotation = 0;
            newImage.opacity = 0;
            oldImage.y = h * 0.3;
            oldImage.scale = 0.9;
            break;
        case 6:
            // Rotate & Scale - Dynamic spin
            Logger.d("Wallpaper", "Applying ROTATE transition");
            newImage.x = 0;
            newImage.y = 0;
            newImage.scale = 0.5;
            newImage.rotation = -25;
            newImage.opacity = 0;
            oldImage.rotation = 15;
            oldImage.scale = 1.2;
            break;
        case 7:
            // Flip - Card flip effect (horizontal flip simulation)
            Logger.d("Wallpaper", "Applying FLIP transition");
            newImage.x = 0;
            newImage.y = 0;
            newImage.scale = 0.05; // Very small to simulate flip
            newImage.rotation = 90; // Rotate to enhance flip effect
            newImage.opacity = 0;
            oldImage.scale = 0.05;
            oldImage.rotation = -90;
            break;
        case 8:
            // Slide Right - Reverse push
            Logger.d("Wallpaper", "Applying SLIDE RIGHT transition");
            newImage.x = -w * 1.2;
            newImage.y = 0;
            newImage.scale = 1;
            newImage.rotation = 0;
            newImage.opacity = 1;
            oldImage.x = w * 1.2;
            break;
        case 9:
            // Zoom & Slide - Combined effect
            Logger.d("Wallpaper", "Applying ZOOM & SLIDE transition");
            newImage.x = w * 0.3;
            newImage.y = 0;
            newImage.scale = 0.7;
            newImage.rotation = 0;
            newImage.opacity = 0;
            oldImage.x = -w * 0.3;
            oldImage.scale = 1.3;
            break;
        case 10:
            // Diagonal Slide - Corner movement
            Logger.d("Wallpaper", "Applying DIAGONAL transition");
            newImage.x = w * 0.5;
            newImage.y = h * 1.1;
            newImage.scale = 0.9;
            newImage.rotation = 0;
            newImage.opacity = 1;
            oldImage.x = -w * 0.5;
            oldImage.y = -h * 1.1;
            oldImage.scale = 0.9;
            break;
        case 11:
            // Expand - Center to full
            Logger.d("Wallpaper", "Applying EXPAND transition");
            newImage.x = 0;
            newImage.y = 0;
            newImage.scale = 0.4;
            newImage.rotation = 0;
            newImage.opacity = 0;
            oldImage.scale = 1.2;
            break;
        case 12:
            // Spin Out - Rotating exit
            Logger.d("Wallpaper", "Applying SPIN transition");
            newImage.x = 0;
            newImage.y = 0;
            newImage.scale = 0.3;
            newImage.rotation = -45;
            newImage.opacity = 0;
            oldImage.rotation = 45;
            oldImage.scale = 1.5;
            break;
        case 13:
            // Slide Down - Top to bottom
            Logger.d("Wallpaper", "Applying SLIDE DOWN transition");
            newImage.x = 0;
            newImage.y = -h * 1.2;
            newImage.scale = 1;
            newImage.rotation = 0;
            newImage.opacity = 1;
            oldImage.y = h * 1.2;
            break;
        case 14:
            // Cinematic Zoom - Movie-style
            Logger.d("Wallpaper", "Applying CINEMATIC transition");
            newImage.x = 0;
            newImage.y = 0;
            newImage.scale = 1.3;
            newImage.rotation = 0;
            newImage.opacity = 0;
            oldImage.scale = 0.8;
            oldImage.opacity = 0.5;
            break;
        }
        img1Container.z = (newImage === img1) ? 2 : 1;
        img2Container.z = (newImage === img2) ? 2 : 1;
        root.currentImage = newImage;
        // Logger.d("Wallpaper", "Animating to final state...");
        newImage.opacity = 1;
        newImage.scale = 1;
        newImage.x = 0;
        newImage.y = 0;
        newImage.rotation = 0;
        oldImage.opacity = 0;
        transitionTimer.callback = function() {
            oldImage.scale = 1;
            oldImage.x = 0;
            oldImage.y = 0;
            oldImage.rotation = 0;
        };
        transitionTimer.start();
    }

    anchors.fill: parent
    Component.onCompleted: {
        if (WallpaperService.isInitialized) {
            // Logger.d("Wallpaper", "Loading wallpaper for", screenName, ":", wallpaper);

            var wallpaper = WallpaperService.getWallpaper(screenName);
            if (wallpaper && wallpaper !== "")
                root.source = "file://" + wallpaper;

        }
    }
    onSourceChanged: {
        // Logger.d("Wallpaper", "Source changed to:", source);
        if (source === "") {
            currentImage = null;
        } else {
            var nextImage = (currentImage === img1) ? img2 : img1;
            // Logger.d("Wallpaper", "Loading into", (nextImage === img1 ? "img1" : "img2"));
            nextImage.opacity = 0;
            nextImage.scale = 1;
            nextImage.x = 0;
            nextImage.y = 0;
            nextImage.rotation = 0;
            nextImage.source = root.source;
        }
    }

    Timer {
        id: transitionTimer

        property var callback

        interval: 1000
        repeat: false
        onTriggered: {
            if (callback)
                callback();

        }
    }

    Connections {
        function onWallpaperChanged(changedScreenName, path) {
            if (changedScreenName === screenName) {
                Logger.d("Wallpaper", "Wallpaper changed for", screenName, "to", path);
                root.source = "file://" + path;
                transitionType = Math.floor(Math.random() * 15);
                Logger.d("Wallpaper", "Selected transition type:", transitionType);
            }
        }

        target: WallpaperService
    }

    Connections {
        function onIsInitializedChanged() {
            if (WallpaperService.isInitialized && !root.source) {
                var wallpaper = WallpaperService.getWallpaper(screenName);
                if (wallpaper && wallpaper !== "") {
                    Logger.d("Wallpaper", "Loading initial wallpaper for", screenName, ":", wallpaper);
                    root.source = "file://" + wallpaper;
                }
            }
        }

        target: WallpaperService
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        visible: root.source === ""
        z: 10

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "󰸉"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 64
                color: "#f38ba8"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "No wallpaper set"
                color: "#cdd6f4"
                font.bold: true
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Open the wallpaper panel to select one"
                color: "#a6adc8"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

        }

    }

    Item {
        id: img1Container

        anchors.fill: parent

        Image {
            id: img1

            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            opacity: (root.currentImage === img1) ? 1 : 0
            onStatusChanged: {
                // Logger.d("Wallpaper", "img1 ready, will apply transition type:", root.transitionType);

                // Logger.d("Wallpaper", "img1 status:", status === Image.Ready ? "Ready" : status === Image.Loading ? "Loading" : "Error");
                if (status === Image.Ready && root.currentImage !== img1 && source == root.source)
                    Qt.callLater(function() {
                    applyTransition(img1, img2);
                });

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on y {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on rotation {
                NumberAnimation {
                    duration: 900
                    easing.type: Easing.InOutCubic
                }

            }

        }

    }

    Item {
        id: img2Container

        anchors.fill: parent

        Image {
            id: img2

            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            opacity: (root.currentImage === img2) ? 1 : 0
            onStatusChanged: {
                // Logger.d("Wallpaper", "img2 ready, will apply transition type:", root.transitionType);

                // Logger.d("Wallpaper", "img2 status:", status === Image.Ready ? "Ready" : status === Image.Loading ? "Loading" : "Error");
                if (status === Image.Ready && root.currentImage !== img2 && source == root.source)
                    Qt.callLater(function() {
                    applyTransition(img2, img1);
                });

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on x {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on y {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }

            }

            Behavior on rotation {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutCubic
                }

            }

        }

    }

}
