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

   Item {
        id: textContainer
        anchors.centerIn: parent
        width: parent.width * 0.75  // Use 90% of screen width
        height: parent.height * 0.75 // Use 90% of screen height

        Text {
            id: nameText
            color: "#ffffff"
            text: `Welcome ${controller.getName()}`
            textFormat: Text.RichText
            font.weight: Font.DemiBold
            font.family: "IBM Plex Mono"
            anchors.centerIn: parent
            opacity: 1
            
            // Make text as large as possible while fitting
            font.pixelSize: Math.min(
                textContainer.height * 0.8,  // Max 80% of container height
                textContainer.width / (text.length * 0.5)  // Scale based on text length
            )
            
            // Ensure minimum readable size
            minimumPixelSize: 20
            fontSizeMode: Text.VerticalFit
            
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.NoWrap
        }
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