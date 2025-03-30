import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    Material.theme: Material.Dark

    id: adminScreen
    width: Constants.width
    height: Constants.height
    color: "#292929"

    Button {
        id: powerOffButton
        x: 181
        y: 176
        width: 307
        height: 100
        text: qsTr("Power Off")
        font.family: "Roboto"
        font.weight: Font.Normal
        font.pointSize: 16
    }

    Button {
        id: openDoorButton
        x: 553
        y: 277
        width: 307
        height: 100
        text: qsTr("Open Doors")
        font.family: "Roboto"
        font.weight: Font.Normal
        font.pointSize: 16
    }

    Button {
        id: exitAppButton
        x: 181
        y: 277
        width: 307
        height: 100
        text: qsTr("Exit App")
        font.family: "Roboto"
        font.weight: Font.Normal
        font.pointSize: 16
    }

    Button {
        id: openHatchButton
        x: 553
        y: 176
        width: 307
        height: 100
        text: qsTr("Open Hatch")
        font.family: "Roboto"
        font.weight: Font.Normal
        font.pointSize: 16
    }

    Button {
        id: tareButton
        x: 553
        y: 377
        width: 307
        height: 100
        text: qsTr("Tare")
        font.family: "Roboto"
        font.weight: Font.Normal
        font.pointSize: 16
        onClicked: stack.push("Tare.qml")
    }

    Text {
        id: tare
        x: 251
        y: 121
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
        x: 642
        y: 121
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
        font.family: "Roboto"
        font.weight: Font.Normal
        font.pointSize: 30
        Material.background: "#F76902"
        onClicked: stack.pop()
    }

    Component.onCompleted: {
        exitAppButton.clicked.connect(() => {
            exitPopup.open();
        });
    }

    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "#000000"
        opacity: 0.35
        visible: exitPopup.opened
        z: 10  // Lower than popup and keyboard
    }

    Popup {
        id: exitPopup
        width: 450
        height: 300
        focus: true
        modal: true
        dim: false
        closePolicy: Popup.NoAutoClose  // Prevents closing when clicking outside
        x: parent.width / 2 - (width / 2)
        y: parent.height / 2 - (height / 2)
        z: 20
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        ColumnLayout {
            id: emailContainer
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: qsTr("Are you sure you want to exit?")
                color: "white"
                font.family: "Roboto"
                font.weight: Font.Normal
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                id: buttonLayout
                width: parent.width
                Button {
                    text: qsTr("Yes")
                    Layout.fillWidth: true
                    onClicked: {
                        controller.exit()
                    }
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    font.pixelSize: 24
                    Material.roundedScale: Material.MediumScale
                }

                Button {
                    text: qsTr("No")
                    Layout.fillWidth: true
                    onClicked: {
                        exitPopup.close()
                    }
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    font.pixelSize: 24
                    Material.roundedScale: Material.MediumScale
                }

            }
        }
    }
}

