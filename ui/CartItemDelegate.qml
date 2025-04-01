import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts

// CartItemDelegate.qml
ItemDelegate {
    id: root
    width: ListView.view ? ListView.view.width : parent.width
    height: 80  // Increased height for image
    padding: 0

    property string itemName: ""
    property int itemQuantity: 0
    property real itemPrice: 0.00
    property string itemImage: ""

    // background: Rectangle {
    //     radius: 12
    //     color: root.highlighted ? "#7a7c01a4" : "#646c0164"
    //     border.color: Qt.lighter(color, 1.2)
    // }

    contentItem: RowLayout {
        anchors.fill: parent
        spacing: 15
        Item { Layout.preferredWidth: 15 }
        // Product image
        Row {
            spacing: 15
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            // Image {
            //     id: productImage
            //     source: "file://" + root.itemImage // Now becomes "file:///Users/.../placeholder.png"
            //     fillMode: Image.PreserveAspectFit

            //     // Add error handling
            //     onStatusChanged: {
            //         if (status === Image.Error) {
            //             console.error("Failed to load image:", source)
            //             source = "file://" + Qt.resolvedUrl("../images/placeholder.png")
            //         }
            //     }
            // }

            // Product name (left-aligned)
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.Wrap
                font { family: "Roboto"; pixelSize: 20 }
                text: root.itemName
                color: "white"
            }
        }

        // Right-aligned group
        Row {
            spacing: 15
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            // Quantity
            Text {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                font { family: "Roboto"; pixelSize: 20 }
                text: `x${root.itemQuantity}`
                color: "#a0a0a0"
            }

            // Price
            Text {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                font { family: "Roboto"; pixelSize: 20; bold: true }
                text: `$${root.itemPrice.toFixed(2)}`
                color: "#F76902"
            }
        }
        Item { Layout.preferredWidth: 15 }
    }
}