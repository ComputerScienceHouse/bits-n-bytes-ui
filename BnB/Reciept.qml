import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants
import QtQuick.VirtualKeyboard 2.8
import QtQuick.VirtualKeyboard.Styles
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: window
    visible: true
    width: Constants.width
    height: Constants.height

    RecieptScreen {id: screen}

    property alias button: screen.noRecieptButton

    Component.onCompleted: {
        screen.emailButton.clicked.connect(() => {
            emailPopup.open();
        });
        screen.textButton.clicked.connect(() => {
            textPopup.open();
        });
    }

    // Email Popup
    Popup {
        id: emailPopup
        width: 300
        height: 200
        focus: true
        closePolicy: Popup.CloseOnEscape
        x: parent.width / 2 - (width / 2)
        y: parent.height / 6 - (height / 6)
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        onOpened: emailInput.forceActiveFocus()
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
                inputMethodHints: Qt.ImhEmailCharactersOnly
                focus: true
                onAccepted: {
                    console.log("Email entered:", text)
                    emailPopup.close()
                    recieptScreenLoader.item.emailButton.checked = false
                }
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    console.log("Email entered:", emailInput.text)
                    emailPopup.close()
                    recieptScreenLoader.item.emailButton.checked = false
                }
                font.pointSize: 12
                font.family: "Roboto"
                Material.roundedScale: Material.MediumScale
            }
        }
    }

    // Phone Number Popup
    Popup {
        id: textPopup
        width: 300
        height: 200
        focus: true
        closePolicy: Popup.CloseOnEscape
        x: parent.width / 2 - (width / 2)
        y: parent.height / 6 - (height / 6)
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        onOpened: textInput.forceActiveFocus()
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
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    console.log("Phone Number entered:", text)
                    textPopup.close()
                    recieptScreenLoader.item.textButton.checked = false
                }
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    console.log("Phone Number entered:", textInput.text)
                    textPopup.close()
                    recieptScreenLoader.item.emailButton.checked = false
                }
                font.pointSize: 12
                font.family: "Roboto"
                Material.roundedScale: Material.MediumScale
            }
        }
    }

    InputPanel {
        id: keyboard
        anchors.bottom: parent.bottom
        width: parent.width
        height: 200
        visible: (emailPopup.opened && emailInput.activeFocus) || (textPopup.opened && textInput.activeFocus)
        

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        onVisibleChanged: {
            if (visible) {
                y = parent.height - height  // Slide up
            } else {
                y = parent.height  // Slide down
            }
        }

        states: State {
            name: "visible"
            when: keyboard.active
            PropertyChanges {
                target: keyboard
                y: window.height - keyboard.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
