import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants

Rectangle {
    id: nameScreen
    width: Constants.width
    height: Constants.height
    Material.theme: Material.Dark
    color: "#292929"
    property alias text: nameText

    Text {
        id: nameText
        width: 828
        height: 101
        color: "#ffffff"
        text: `Welcome ${controller.getName()}`
        textFormat: Text.RichText
        font.weight: Font.DemiBold
        font.pointSize: 60
        font.family: "IBM Plex Mono"
        anchors.verticalCenterOffset: -24
        anchors.horizontalCenterOffset: 1
        anchors.centerIn: parent
        opacity: 1
    }

    Timer {
        id: navigationTimer
        interval: 1000  // 1 second
        running: false   // Start automatically when component is loaded
        repeat: false
        onTriggered: {
            stack.replace("Cart.qml")
            controller.device.open_doors()
        }
    }

    Component.onCompleted: {
        navigationTimer.start()
    }
}