import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants
import QtQuick.VirtualKeyboard 2.8
import QtQuick.VirtualKeyboard.Styles
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    Material.theme: Material.Dark
    id: receiptScreen
    visible: true
    width: Constants.width
    height: Constants.height
    color: "#292929"

    Notification{
        id: recieptNotification
    }
    Connections {
        target: controller
        function onNotifyPhoneInput() {
            recieptNotification.show("Text receipt sent!")
        }
        function onNotifyEmailInput() {
            recieptNotification.show("Email receipt sent!")
        }
    }

    Text {
        id: _text
        x: 15
        y: 10
        width: 168
        height: 49
        color: "#ffffff"
        text: qsTr("Receipt")
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        font.weight: Font.DemiBold
        font.family: "IBM Plex Mono"
        font.bold: true
    }

    Text {
        id: timeout
        x: 844
        y: 10
        width: 172
        height: 49
        color: "#ffffff"
        text: `Timeout: ${controller.countdown.remainingTime}`
        font.pixelSize: 24
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.weight: Font.DemiBold
        font.family: "Roboto"
        font.bold: true
    }

    ColumnLayout {
        id: contact
        x: 662
        y: 95
        width: 341
        height: 449
        Text {
            Layout.alignment: Qt.AlignCenter
            x: 668
            y: 177
            width: 269
            height: 65
            color: "#ffffff"
            text: qsTr("Would you like your receipt?")
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Normal
            font.family: "Roboto"
            font.bold: true
        }

        Item {
            id: buttonContainer
            // The container's size will be driven by the ColumnLayout's children.
            // (Assuming the ColumnLayout’s children are added as normal QML children.)
            width: buttons.childrenRect.width
            height: buttons.childrenRect.height
            Layout.alignment: Qt.AlignCenter
            ColumnLayout {
                id: buttons
                spacing: 5
                Button {
                    Layout.alignment: Qt.AlignCenter
                    id: textButton
                    Layout.preferredWidth: 235
                    Layout.preferredHeight: 75
                    x: 685
                    y: 238
                    text: qsTr("Text")
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    font.pointSize: 20
                }

                Button {
                    checked: false
                    Layout.alignment: Qt.AlignCenter
                    id: emailButton
                    x: 685
                    y: 296
                    Layout.preferredWidth: 235
                    Layout.preferredHeight: 75
                    visible: true
                    text: qsTr("Email")
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    font.pointSize: 20
                }

                Button {
                    Layout.alignment: Qt.AlignCenter
                    id: noReceiptButton
                    x: 685
                    y: 354
                    Layout.preferredWidth: 235
                    Layout.preferredHeight: 75
                    visible: true
                    text: qsTr("No Receipt")
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    font.pointSize: 20
                    onClicked: stack.replace("Welcome.qml")
                }
            }
        }

        Text {
            id: subtotal
            x: 685
            y: 441
            width: 234
            height: 49
            color: "#ffffff"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Normal
            font.family: "Roboto"

            textFormat: Text.RichText
            text: `<b>Subtotal:</b> $${controller.getSubtotal().toFixed(2)}`
        }

        Text {
            id: tax
            x: 685
            y: 476
            width: 234
            height: 49
            color: "#ffffff"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Normal
            font.family: "Roboto"

            textFormat: Text.RichText
            text: `<b>Tax:</b> $0.00`
        }

        Text {
            id: total
            x: 685
            y: 511
            width: 234
            height: 49
            color: "#ffffff"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.Normal
            font.family: "Roboto"

            textFormat: Text.RichText
            text: `<b>Subtotal:</b> $${controller.getSubtotal().toFixed(2)}`
        }
    }

    // Reciept items
    Item {
        id: receipt
        x: 20
        y: 65
        width: 607
        height: 509

        Rectangle {
            id: background
            width: parent.width
            height: parent.height
            color: "#646c0164"
            radius: 8
            z: 0 // Background at the lowest layer
        }

        ListView {
            id: cart
            anchors.fill: parent
            x: background.x
            y: background.y
            highlightFollowsCurrentItem: true
            clip: true
            model: controller.cart
            z: 1 // Ensures ListView is on top of the Rectangle

            delegate: CartItemDelegate {
                itemName: model.name
                itemQuantity: model.quantity
                itemPrice: model.price
                itemImage: {
                    if (root.itemImage && root.itemImage.toString().length > 0) {
                        return "file://" + root.itemImage
                    }
                    return "file://" + Qt.resolvedUrl("../images/placeholder.png")
                }
            }
        }
    }

    Component.onCompleted: {
        controller.countdown.startCountdown()
        controller.countdown.finished.connect(() => {
            if (stack) { 
                stack.replace("Welcome.qml")
            }
        })
        emailButton.clicked.connect(() => {
            emailPopup.open()
        })
        textButton.clicked.connect(() => {
            textPopup.open()
        })
    }
    // Shadow Overlay for Popups
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "#000000"
        opacity: 0.35
        visible: emailPopup.opened || textPopup.opened
        z: 10  // Lower than popup and keyboard

        // Block interaction with background while popup is open
        MouseArea {
            anchors.fill: parent
            onClicked: {}  // Prevent clicks from reaching background
        }
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
        z: 20
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        onOpened: {
            emailInput.forceActiveFocus()
            controller.countdown.stopTime()
        }
        onClosed: controller.countdown.resumeTime()
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
                // onAccepted: {
                //     controller.getEmail(text)
                //     emailPopup.close()
                // }
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    controller.getEmail(emailInput.text)
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
        z: 20
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        onOpened: {
            textInput.forceActiveFocus()
            controller.countdown.stopTime()
        }
        onClosed: controller.countdown.resumeTime()       
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
                // onAccepted: {
                //     controller.getPhoneNum(text)
                //     textPopup.close()
                // }
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    controller.getPhoneNum(textInput.text)
                    textPopup.close()
                }
                font.pointSize: 18
                font.family: "Roboto"
                font.weight: Font.Normal
                Material.roundedScale: Material.MediumScale
            }
        }
    }

    // Keyboard
    InputPanel {
        id: keyboard
        anchors.bottom: parent.bottom
        width: parent.width
        height: 200
        z: 30
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
                y: receiptScreen.height - receiptScreen.height
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

