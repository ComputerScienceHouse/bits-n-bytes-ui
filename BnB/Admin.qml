import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    width: Constants.width
    height: Constants.height
    property var stackView

    AdminScreen{id: screen}

    property alias button: screen.backButton
    property alias tareButton: screen.tareButton

    Component.onCompleted: {
        screen.exitAppButton.clicked.connect(() => {
            emailPopup.open();
        });
    }

    Popup {
        id: emailPopup
        width: 450
        height: 300
        focus: true
        modal: true
        dim: true
        closePolicy: Popup.NoAutoClose  // Prevents closing when clicking outside
        x: parent.width / 2 - (width / 2)
        y: parent.height / 2 - (height / 2)
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
                        emailPopup.close()
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
