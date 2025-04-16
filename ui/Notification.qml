import QtQuick 6.8
import QtQuick.Controls 6.8

Rectangle {
    id: banner
    width: 300
    height: 50
    color: "#4CAF50" // default: green success
    opacity: 0
    visible: opacity > 0
    z: 999

    property alias message: bannerText.text
    property alias bannerColor: banner.color
    property int duration: 2000

    anchors.top: parent ? parent.top : undefined
    radius: 20 
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: 20

    Text {
        id: bannerText
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 18
    }

    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    Timer {
        id: hideTimer
        interval: duration
        running: false
        repeat: false
        onTriggered: banner.opacity = 0
    }

    function show(msg, color) {
        if (msg) message = msg
        if (color) bannerColor = color
        opacity = 1
        hideTimer.restart()
    }
}