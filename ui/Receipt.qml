import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.impl 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.VirtualKeyboard 2.15
import QtQuick.VirtualKeyboard.Styles 2.15
import Constants
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    Material.theme: Material.Dark
    id: recieptScreen
    visible: true
    width: Constants.width
    height: Constants.height
    color: "#292929"

    Notification{
        id: recieptNotification
    }
    Connections {
        target: controller.checkout
        function onNotifyPhoneInput() {
            recieptNotification.show("Text reciept sent!")
        }
        function onNotifyEmailInput() {
            recieptNotification.show("Email reciept sent!")
        }
    }
    
    Countdown {
        id: recieptCountdown
        onFinished: {
            if (stack) { // Ensure 'stack' is accessible here (e.g., id of StackView)
                stack.replace("Welcome.qml")
            } else {
                console.warn("StackView with id 'stack' not found for navigation.")
            }
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
        text: `Timeout: ${recieptCountdown.remainingTime}`
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
                    id: norecieptButton
                    x: 685
                    y: 354
                    Layout.preferredWidth: 235
                    Layout.preferredHeight: 75
                    visible: true
                    text: qsTr("No receipt")
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
            text: `<b>Subtotal:</b> $${controller.cart.getSubtotal().toFixed(2)}`
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
            text: `<b>Subtotal:</b> $${controller.cart.getSubtotal().toFixed(2)}`
        }
    }

    // Reciept items
    Item {
        id: reciept
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
        recieptCountdown.start()
        emailButton.clicked.connect(() => {
            emailPopup.open()
        })
        textButton.clicked.connect(() => {
            textPopup.open()
        })
    }
   
    // Email Popup
    Popup {
        id: emailPopup
        width: 400
        height: 250
        modal: true
        dim: true
        z: 30
        closePolicy: Popup.CloseOnPressOutside
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 - (keyboard.visible ? keyboard.height / 2 : 0)
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        Overlay.modal: Rectangle {
            z: 10
            color: "#464646"
            opacity: 0.4        
        }
        onOpened: {
            recieptCountdown.stop()
            forceActiveFocus()
        }
        onClosed: {
            recieptCountdown.resume()
            if (emailInput.text) {
                controller.checkout.send_email()
            }
            emailInput.focus = false
        }       
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
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    controller.checkout.setEmail(emailInput.text)
                    emailPopup.close()
                }
                font.pointSize: 18
                font.family: "Roboto"
                font.weight: Font.Normal
                Material.roundedScale: Material.MediumScale
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Phone Number Popup
    Popup {
        id: textPopup
        width: 400
        height: 250
        modal: true
        dim: true
        closePolicy: Popup.CloseOnPressOutside
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2 - (keyboard.visible ? keyboard.height / 2 : 0)
        z: 30
        background: Rectangle {
            color: "#333333"
            radius: 10
        }
        Overlay.modal: Rectangle {
            z: 10
            color: "#464646"
            opacity: 0.4        
        }
        onOpened: {
            recieptCountdown.stop()
            forceActiveFocus()
        }
        onClosed: {
            recieptCountdown.resume()
            if (textInput.text) {
                controller.checkout.send_sms()       
            }
            textInput.focus = false
        }
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
            }

            Button {
                text: qsTr("Submit")
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    controller.checkout.setPhoneNum(textInput.text)
                    textPopup.close()
                }
                font.pointSize: 18
                font.family: "Roboto"
                font.weight: Font.Normal
                Material.roundedScale: Material.MediumScale
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    // Keyboard
    InputPanel {
        parent: Overlay.overlay
        id: keyboard
        anchors.bottom: parent.bottom
        width: parent.width
        height: 300
        z: 25 
        y: visible ? parent.height - height : parent.height
        visible: emailInput.activeFocus || textInput.activeFocus
        
        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}