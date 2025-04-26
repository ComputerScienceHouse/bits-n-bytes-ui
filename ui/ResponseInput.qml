import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts


Item {

    
    id: responseInput
    width: parent ? parent.width: 0
    height: parent ? parent.width/6: 0

    property string inputType: "email"
    property alias label: responseLabel.text
    property alias placeholderText: internalTextField.placeholderText
    property alias textField: internalTextField

    signal submitRequested(string text)
    signal pauseCountdown(bool pause)

    Component.onCompleted: {
    internalTextField.text = 
        inputType === "email" 
            ? controller.checkout.getEmail() 
            : controller.checkout.getPhoneNum()
    }

    MouseArea {
        anchors.fill: parent
        enabled: textField.activeFocus
        onClicked: {
            textField.focus = false
            Qt.inputMethod.hide()
        }
    }

    ColumnLayout{
        spacing: 10
        Label {
            id: responseLabel
            Layout.alignment: Qt.AlignLeft
            font.pointSize: 15
            font.family: "Roboto"
            color: "white"
        }
        RowLayout {
            id: textFieldRow
            spacing: 10
            TextField {
                id: internalTextField
                Layout.preferredWidth: responseInput.width * 0.65
                placeholderText: qsTr("Email Address")
                color: "white"
                font.family: "Roboto"
                font.weight: Font.Normal
                font.pointSize: 12
                Material.accent: "#F76902"
                // text: {
                //     if (inputType === "email") 
                //         return controller.checkout.getEmail()
                //     else 
                //         return controller.checkout.getPhoneNum()
                //     }
                inputMethodHints: inputType === "email" ? 
                    Qt.ImhEmailCharactersOnly | Qt.ImhNoPredictiveText :
                    Qt.ImhDialableCharactersOnly | Qt.ImhPreferNumbers

                onActiveFocusChanged: {
                    if (activeFocus) {
                        pauseCountdown(true)                        
                        Qt.inputMethod.show()
                    }
                    else {
                        pauseCountdown(false)                        
                        Qt.inputMethod.hide()
                    }
                }

            }
            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: responseInput.width * 0.35
                onClicked: {
                    console.log("Clicked Submit Button")
                    if (internalTextField.text.length > 0) {
                        submitRequested(internalTextField.text)
                        internalTextField.focus = false
                        pauseCountdown(false)                        
                        Qt.inputMethod.hide()
                    }
                }
                font.pointSize: 12
                font.family: "Roboto"
                font.weight: Font.Normal
                Material.roundedScale: Material.MediumScale
            }
        }
    }
}