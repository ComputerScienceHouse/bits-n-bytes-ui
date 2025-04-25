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

    Connections {
        target: controller.device
        function onDoorsClosed() {
            stack.replace("Receipt.qml")
        }
    }

     Item {
        id: textContainer
        anchors.centerIn: parent
        width: parent.width * 0.75  // Use 90% of screen width
        height: parent.height * 0.75 // Use 90% of screen height

        Text {
            id: nameText
            color: "#ffffff"
            text: `Close doors to end transaction`
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
}