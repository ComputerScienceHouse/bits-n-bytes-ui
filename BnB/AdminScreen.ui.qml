

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

    id: adminScreen
    width: Constants.width
    height: Constants.height
    color: "#292929"

    property alias backButton: backButton
    property alias tareButton: tareButton

    Button {
        id: powerOffButton
        x: 279
        y: 190
        width: 184
        height: 69
        text: qsTr("Power Off")
    }

    Button {
        id: openDoorButton
        x: 543
        y: 266
        width: 212
        height: 69
        text: qsTr("Open Doors")
    }

    Button {
        id: exitAppButton
        x: 279
        y: 266
        width: 184
        height: 69
        text: qsTr("Exit App")
    }

    Button {
        id: openHatchButton
        x: 543
        y: 190
        width: 212
        height: 69
        text: qsTr("Open Hatch")
    }

    Button {
        id: tareButton
        x: 543
        y: 341
        width: 212
        height: 69
        text: qsTr("Tare")
        onClicked: controller.navigate("tare")
    }

    Text {
        id: tare
        x: 287
        y: 135
        width: 168
        height: 49
        text: qsTr("System")
        font.pixelSize: 36
        horizontalAlignment: Text.AlignHCenter
        font.family: "IBM Plex Mono"
        color: "#FFFFFF"
    }

    Text {
        id: app
        x: 585
        y: 135
        width: 129
        height: 49
        color: "#ffffff"
        text: qsTr("App")
        font.pixelSize: 36
        horizontalAlignment: Text.AlignHCenter
        font.family: "IBM Plex Mono"
    }

    Text {
        id: admin
        x: 15
        y: 10
        width: 168
        height: 49
        color: "#ffffff"
        text: qsTr("Admin")
        font.pixelSize: 40
        horizontalAlignment: Text.AlignLeft
        font.bold: true
        font.family: "IBM Plex Mono"
    }

    Button {
        id: backButton
        x: 958
        y: 0
        width: 58
        height: 68
        text: qsTr("⬅")
        font.pointSize: 30
        Material.background: "#F76902"
    }
}
