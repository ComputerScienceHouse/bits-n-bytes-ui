import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts
import Constants

Rectangle {
    Material.theme: Material.Dark

    id: tareScreen
    width: Constants.width
    height: Constants.height
    color: "#292929"

    Text {
        id: _text
        x: 15
        y: 10
        width: 168
        height: 49
        color: "#ffffff"
        text: qsTr("Tare")
        font.pixelSize: 40
        horizontalAlignment: Text.AlignLeft
        font.family: "IBM Plex Mono"
        font.bold: true
    }

    GridLayout {
        columns: 8
        rows: 2
        columnSpacing: 20
        rowSpacing: 20
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: 66
        anchors.bottomMargin: 8

        Button {
            id: button1a
            x: 38
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("1A")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button1b
            x: 148
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("1B")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button1c
            x: 260
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("1C")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button1d
            x: 372
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("1D")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
            Layout.rightMargin: 10
        }

        Button {
            id: button2a
            x: 38
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("2A")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
            Layout.leftMargin: 10
        }

        Button {
            id: button2b
            x: 148
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("2B")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button2c
            x: 260
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("2C")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button2d
            x: 372
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("2D")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button3a
            x: 38
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("3A")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button3b
            x: 148
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("3B")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button3c
            x: 260
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("3C")
            font.family: "Roboto"
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button3d
            x: 372
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("3D")
            font.family: "Roboto"
            font.weight: Font.Normal
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
            Layout.rightMargin: 10
        }

        Button {
            id: button4a
            x: 38
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("4A")
            font.family: "Roboto"
            font.weight: Font.Normal
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
            Layout.leftMargin: 10
        }

        Button {
            id: button4b
            x: 148
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("4B")
            font.family: "Roboto"
            font.weight: Font.Normal
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button4c
            x: 260
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("4C")
            font.family: "Roboto"
            font.weight: Font.Normal
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }

        Button {
            id: button4d
            x: 372
            y: 84
            width: 91
            height: 211
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr("4D")
            font.family: "Roboto"
            font.weight: Font.Normal
            font.pointSize: 24
            Material.roundedScale: Material.NotRounded
        }
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
        onClicked: controller.navigate("admin")
    }
}
