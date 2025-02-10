import QtQuick
import QtQuick.Controls 2.15
import Constants
import QtQuick.Window 2.1

Window {
    id: root
    width: Constants.width
    height: Constants.height
    visible: true

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: "Welcome.qml"
    }
}
