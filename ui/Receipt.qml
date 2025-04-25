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
    
    Component.onCompleted: {
        receiptCountdown.start()
    }

    Countdown {
        id: receiptCountdown
        onFinished: {
            if (stack) { // Ensure 'stack' is accessible here (e.g., id of StackView)
                stack.replace("Welcome.qml")
                textResponseInput.textField.text = ""
                emailResponseInput.textField.text = ""
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
        text: `Timeout: ${receiptCountdown.remainingTime}`
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
        y: 65
        width: 341
        height: 449
        spacing: 20

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

        ColumnLayout {
            id: responseOptions
            width: parent.width * 0.9
            Layout.alignment: Qt.AlignCenter
            spacing: 50
            ResponseInput {
                id: textResponseInput
                inputType: "phone"
                label: "Text"
                placeholderText: "Phone Number"
                onPauseCountdown: (pause) => {
                    if (pause) receiptCountdown.stop()
                    else receiptCountdown.resume()
                }
                onSubmitRequested: (text) => {
                    controller.checkout.setPhoneNum(text)
                    controller.checkout.send_sms()
                }
            }

            ResponseInput {
                id: emailResponseInput
                inputType: "email"
                label: "Email"
                placeholderText: "Email Address"
                onPauseCountdown: (pause) => {
                    if (pause) receiptCountdown.stop()
                    else receiptCountdown.resume()
                }
                onSubmitRequested: (text) => {
                    controller.checkout.setEmail(text)
                    controller.checkout.send_email()
                }
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

    MouseArea {
        anchors.fill: parent
        enabled: keyboard.visible
        onClicked: {
            textResponseInput.textField.focus = false
            emailResponseInput.textField.focus = false
            receiptCountdown.resume()
            Qt.inputMethod.hide()
        }
    }

    // Keyboard
    InputPanel {
        parent: Overlay.overlay
        id: keyboard
        anchors.bottom: parent.bottom
        width: parent.width
        height: 200
        z: 20
        y: visible ? parent.height - height : parent.height
        visible: Qt.inputMethod.visible

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}