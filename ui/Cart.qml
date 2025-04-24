import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    Material.theme: Material.Dark

    id: cartScreen
    width: Constants.width
    height: Constants.height
    color: "#292929"
    z: 0
    property alias button: button

    Connections {
        target: controller.device
        function onNotifyDoorsClosed() {
            stack.push("Receipt.qml")
        }
    }

    Text {
        id: _text
        x: 15
        y: 10
        width: 168
        height: 49
        color: "#ffffff"
        text: qsTr("Cart")
        font.pixelSize: 40
        horizontalAlignment: Text.AlignLeft
        font.family: "IBM Plex Mono"
        font.bold: true
    }

    ListView {
        id: cart
        x: 10; y: 120
        width: 700; height: 470
        spacing: 8
        clip: true
        focus: true
        highlightFollowsCurrentItem: true
        model: controller.cart

        delegate: CartItemDelegate {
            itemName: model.name
            itemQuantity: model.quantity
            itemPrice: model.price
            itemImage: {
                if (root.itemImage && root.itemImage.toString().length > 0) {
                    return "file://" + root.itemImage
                }
                return "file://" + Qt.resolvedUrl("../images/placeholder.png")
            } // Using resource system
        }
    }

    Rectangle {
        id: sidebar
        x: 719
        y: 9
        width: 291
        height: 583
        color: "#646c0164" // Change frame color here
        border.color: "#646c0164"
        z: 1
        radius: 15

        Button {
            z: 2
            id: button
            x: 11
            y: 501
            width: 266
            height: 68
            text: qsTr("Finish Transaction")
            font.bold: false
            autoRepeat: true
            font.pointSize: 18
            font.family: "Roboto"
            font.weight: Font.Normal
            Material.roundedScale: Material.MediumScale
            Material.background: "#F76902"
            onClicked: stack.replace("Receipt.qml")
        }

        Text {
            id: ingredients
            x: 13
            y: 262
            color: "#ffffff"
            text: "Ingredients"
            font.pixelSize: 24
            font.family: "IBM Plex Mono"
        }

        Text {
            id: nutrition
            x: 15
            y: 15
            color: "#ffffff"
            text: qsTr("Nutrition")
            font.pixelSize: 24
            font.family: "IBM Plex Mono"
        }
    }

    Text {
        id: _text1
        x: 153
        y: 232
        width: 405
        height: 137
        color: "#ffffff"
        visible: controller.cart.rowCount === 0
        text: qsTr("Welcome \nYour cart is empty, please grab your snacks\nfrom the cabinet to start. \nWe’ll do the rest")
        elide: Text.ElideNone
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
        font.family: "Roboto"
        font.weight: Font.Normal
    }

    Text {
        id: _text2
        x: 490
        y: 73
        width: 193
        height: 29
        color: "#ffffff"
        text: `Subtotal: $${controller.cart.getSubtotal().toFixed(2)}`
        font.pixelSize: 20
        horizontalAlignment: Text.AlignLeft
        font.family: "IBM Plex Mono"
        font.bold: true
    }
}



