
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants

Rectangle {
    Material.theme: Material.Dark

    /* Exposing components to be used in respective .qml file*/
    property alias button: tapButton

    id: welcomeScreen
    width: Constants.width
    height: Constants.height
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
        Material.background: "#6C0164"
        // onClicked: controller.navigate("cart")
    }
}
