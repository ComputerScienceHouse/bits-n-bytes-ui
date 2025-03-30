import QtQuick
import QtQuick.Controls 6.8
import Constants
import QtQuick.Window 2.1
import QtQuick.Layouts

Window {
    id: root
    width: Constants.width
    height: Constants.height
    visible: true
    flags: Qt.Window | Qt.FramelessWindowHint

    StackView {
        id: stack
        objectName: "stack"
        anchors.fill: parent
        initialItem: Welcome {}  // Set the initial item as the Component    
    }

    Component.onCompleted: {
            controller.stackView = stack
    }

    Connections {
        target: controller
        
        function onOpenAdmin() {
            stack.push("Admin.qml")
        }
    }
}
