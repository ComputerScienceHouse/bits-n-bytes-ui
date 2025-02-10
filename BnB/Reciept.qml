import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants
import QtQuick.Layouts

Window {

    RecieptScreen {
        id: recieptScreen
        anchors.fill: parent
    }

    width: Constants.width
    height: Constants.height
    property var stackView

    Popup {
        id: emailPopup
        width: 300
        height: 200
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            color: "#333333"
            radius: 10
        }

        ColumnLayout {
            id: emailContainer
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: qsTr("Enter your email:")
                color: "white"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: emailInput
                Layout.preferredWidth: 200
                placeholderText: qsTr("Email Address")
                color: "white"
                Material.accent: "#F76902"
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    console.log("Email entered:", emailInput.text)
                    emailPopup.close()
                    // Reset the emailButton's state when done.
                    emailButton.checked = false
                }
                font.pointSize: 12
                font.family: "Roboto"
                Material.roundedScale: Material.MediumScale
            }
        }
    }

    Popup {
        id: textPopup
        width: 300
        height: 200
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        background: Rectangle {
            color: "#333333"
            radius: 10
        }

        ColumnLayout {
            id: textContainer
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: qsTr("Enter your phone number:")
                color: "white"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: textInput
                Layout.preferredWidth: 200
                placeholderText: qsTr("Phone Number")
                color: "white"
                Material.accent: "#F76902"
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    console.log("Phone Number entered:", textInput.text)
                    textPopup.close()
                    // Reset the emailButton's state when done.
                    emailButton.checked = false
                }
                font.pointSize: 12
                font.family: "Roboto"
                Material.roundedScale: Material.MediumScale
            }
        }
    }


    Connections {
        target: recieptScreen.emailButton
        function onClicked() {
            emailPopup.open()
        }
    }
    Connections {
        target: recieptScreen.textButton
        function onClicked() {
            textPopup.open()
        }
    }
}
