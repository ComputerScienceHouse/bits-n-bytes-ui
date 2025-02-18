import QtQuick
import QtQuick.Controls 2.15
import Constants
import QtQuick.Window 2.1

Window {
    id: root
    width: Constants.width
    height: Constants.height
    visible: true

    property alias stackView: stackView

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "Welcome.qml"
    }

    Component.onCompleted: {
            // Example: push the Cart screen after initial load
        stackView.push("Cart.qml")
    }
}
