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

        // Define custom push transition (swipe down when entering)
        pushEnter: Transition {
            PropertyAnimation {
                property: "y"
                from: -stack.height
                to: 0
                duration: 300
                easing.type: Easing.OutQuad
            }
            // PropertyAnimation {
            //     property: "opacity"
            //     from: 0.0
            //     to: 1.0
            //     duration: 300
            // }
        }

        // Define animation for view being covered during push (current view exits downward)
        pushExit: Transition {
            PropertyAnimation {
                property: "y"
                from: 0
                to: stack.height
                duration: 300
                easing.type: Easing.OutQuad
            }
            // PropertyAnimation {
            //     property: "opacity"
            //     from: 1.0
            //     to: 0.0
            //     duration: 300
            // }
        }

        // Define animation for popping (returning) to previous view (swipe up)
        popEnter: Transition {
            PropertyAnimation {
                property: "y"
                from: stack.height
                to: 0
                duration: 300
                easing.type: Easing.OutQuad
            }
            // PropertyAnimation {
            //     property: "opacity"
            //     from: 0.0
            //     to: 1.0
            //     duration: 300
            // }
        }

        // Define animation for view being removed during pop (current view exits upward)
        popExit: Transition {
            PropertyAnimation {
                property: "y"
                from: 0
                to: -stack.height
                duration: 300
                easing.type: Easing.OutQuad
            }
            // PropertyAnimation {
            //     property: "opacity"
            //     from: 1.0
            //     to: 0.0
            //     duration: 300
            // }
        }
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
