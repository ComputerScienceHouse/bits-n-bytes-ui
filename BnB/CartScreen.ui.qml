

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Qt5Compat.GraphicalEffects
import Constants

Rectangle {
    Material.theme: Material.Dark

    id: cartScreen
    width: Constants.width
    height: Constants.height
    color: "#292929"
    z: 0
    property alias button: button

    Text {
        id: _text
        x: 15
        y: 10
        width: 168
        height: 49
        color: "#ffffff"
        text: qsTr("Cart")
        font.pixelSize: 40
        horizontalAlignment: Text.AlignLeft
        font.family: "IBM Plex Mono"
        font.bold: true
    }

    Rectangle {
        id: sidebar
        x: 719
        y: 9
        width: 291
        height: 583
        color: "#646c0164" // Change frame color here
        border.color: "#646c0164"
        z: 1
        radius: 15

        Button {
            z: 2
            id: button
            x: 11
            y: 501
            width: 266
            height: 68
            text: qsTr("Finish Transaction")
            font.bold: false
            autoRepeat: true
            font.pointSize: 18
            font.family: "Roboto"
            font.weight: Font.Normal
            Material.roundedScale: Material.MediumScale
            Material.background: "#F76902"
            onClicked: controller.navigate("reciept")
        }

        Text {
            id: ingredients
            x: 13
            y: 262
            color: "#ffffff"
            text: "Ingredients"
            font.pixelSize: 24
            font.family: "IBM Plex Mono"
        }

        Text {
            id: nutrition
            x: 15
            y: 15
            color: "#ffffff"
            text: qsTr("Nutrition")
            font.pixelSize: 24
            font.family: "IBM Plex Mono"
        }
    }

    Text {
        id: _text1
        x: 153
        y: 232
        width: 405
        height: 137
        color: "#ffffff"
        text: qsTr("Welcome \nYour cart is empty, please grab your snacks\nfrom the cabinet to start. \nWe’ll do the rest")
        elide: Text.ElideNone
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
        font.family: "Roboto"
        font.weight: Font.Normal
    }

    Text {
        id: _text2
        x: 507
        y: 73
        width: 193
        height: 29
        color: "#ffffff"
        text: qsTr("Subtotal: $0.00")
        font.pixelSize: 20
        horizontalAlignment: Text.AlignLeft
        font.family: "IBM Plex Mono"
        font.bold: true
    }
}
