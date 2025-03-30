import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants

Rectangle {
    width: Constants.width
    height: Constants.height
    Material.theme: Material.Dark
    id: welcomeScreen
    color: "#292929"

    Text {
        id: welcome
        x: 15
        y: 10
        width: 168
        height: 49
        color: "#ffffff"
        text: qsTr("Welcome")
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        font.weight: Font.DemiBold
        font.bold: true
        font.family: "IBM Plex Mono"
    }

    Image {
        id: logo
        x: 329
        y: 93
        width: 390
        height: 345
        source: "images/bitsnbyteslogo.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        id: info
        x: 951
        y: 10
        width: 60
        height: 61
        source: "images/info-light.png"
        fillMode: Image.PreserveAspectFit
    }

    Button {
        id: tapButton
        x: 292
        y: 461
        width: 441
        height: 75
        icon.source: "images/tap.png"
        text: qsTr("Tap Card to Continue")
        font.bold: false
        font.pointSize: 20
        font.family: "Roboto"
        font.weight: Font.Normal
        Material.background: "#6C0164"
        onClicked: {
            stack.replace("Name.qml")
        }
    }

    Button {
        id: one
        width: 100; height: 100
        opacity: 0
        anchors.top: parent.top
        anchors.right: parent.right
        onClicked: {
            controller.pushInput(1)
            controller.checkSeq()
        }
    }

    Button {
        id: two
        width: 100; height: 100
        opacity: 0
        anchors.top: parent.top
        anchors.left: parent.left
        onClicked: {
            controller.pushInput(2)
            controller.checkSeq()
        }
    }

    Button {
        id: three
        width: 100; height: 100
        opacity: 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked: {
            controller.pushInput(3)
            controller.checkSeq()
        }
    }

    Button {
        id: four
        width: 100; height: 100
        opacity: 0
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: {
            controller.pushInput(4)
            controller.checkSeq()
        }
    }

    // Component.onCompleted: {
    //     controller.runNFC()
    // }
    // Component.onDestruction: {
    //     controller.stopNFC()
    // }
}


