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
    property string nfc_id: ""

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
        text:  welcomeScreen.nfc_id // qsTr("Tap Card to Continue")
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
            controller.admin.pushInput(1)
            controller.admin.checkSeq()
        }
    }

    Button {
        id: two
        width: 100; height: 100
        opacity: 0
        anchors.top: parent.top
        anchors.left: parent.left
        onClicked: {
            controller.admin.pushInput(2)
            controller.admin.checkSeq()
        }
    }

    Button {
        id: three
        width: 100; height: 100
        opacity: 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked: {
            controller.admin.pushInput(3)
            controller.admin.checkSeq()
        }
    }

    Button {
        id: four
        width: 100; height: 100
        opacity: 0
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: {
            controller.admin.pushInput(4)
            controller.admin.checkSeq()
        }
    }

    Component.onCompleted: {
        controller.wait_for_nfc()
    }

    Connections {
        target: controller
        function on_Nfc_signal(msg) {
            if(msg == "") {
                userNotFoundNotification.show("User not Found!", "#D91E1E")
            } else {
                stack.replace("Name.qml")
            }
        }
    }

    Notification{
        id: userNotFoundNotification

    }

}


