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
        width: 400
        height: 250
        focus: true
        modal: false
        dim: false
        closePolicy: Popup.NoAutoClose  // Prevents closing when clicking outside
        x: parent.width / 2 - (width / 2)
        y: parent.height / 14 - (height / 14)
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        onOpened: emailInput.forceActiveFocus()
        ColumnLayout {
            id: emailContainer
            anchors.centerIn: parent
            spacing: 15

            Text {
                text: qsTr("Enter your email:")
                font.family: "Roboto"
                font.weight: Font.Normal
                color: "white"
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: emailInput
                Layout.preferredWidth: emailPopup.width - (emailPopup.width/4)
                placeholderText: qsTr("Email Address")
                color: "white"
                font.family: "Roboto"
                font.weight: Font.Normal
                font.pointSize: 18
                Material.accent: "#F76902"
                inputMethodHints: Qt.ImhEmailCharactersOnly
                focus: true
                onAccepted: {
                    console.log("Email entered:", text)
                    emailPopup.close()
                }
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    console.log("Email entered:", emailInput.text)
                    emailPopup.close()
                }
                font.pointSize: 18
                font.family: "Roboto"
                font.weight: Font.Normal
                Material.roundedScale: Material.MediumScale
            }
        }
    }

    // Phone Number Popup
    Popup {
        id: textPopup
        width: 400
        height: 250
        focus: true
        modal: false
        dim: false
        closePolicy: Popup.NoAutoClose  // Prevents closing when clicking outside
        x: parent.width / 2 - (width / 2)
        y: parent.height / 14 - (height / 14)
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        onOpened: textInput.forceActiveFocus()
        ColumnLayout {
            id: textContainer
            anchors.centerIn: parent
            spacing: 15
            Text {
                text: qsTr("Enter your phone number:")
                color: "white"
                font.pixelSize: 24
                font.family: "Roboto"
                font.weight: Font.Normal
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: textInput
                Layout.preferredWidth: textPopup.width - (textPopup.width/4)
                placeholderText: qsTr("Phone Number")
                color: "white"
                font.family: "Roboto"
                font.weight: Font.Normal
                font.pointSize: 18
                Material.accent: "#F76902"
                inputMethodHints: Qt.ImhDigitsOnly
                onAccepted: {
                    console.log("Phone Number entered:", text)
                    textPopup.close()
                }
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    console.log("Phone Number entered:", textInput.text)
                    textPopup.close()
                }
                font.pointSize: 18
                font.family: "Roboto"
                font.weight: Font.Normal
                Material.roundedScale: Material.MediumScale
            }
        }
    }

    InputPanel {
        id: keyboard
        anchors.bottom: parent.bottom
        width: parent.width
        height: 200
        z: 9999
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
