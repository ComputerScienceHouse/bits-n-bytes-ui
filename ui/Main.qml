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

    StackLayout {
        id: stack
        objectName: "stack"
        anchors.fill: parent
        Welcome {
            id: welcome
            objectName: "welcome"
        }
        Name { 
            id: name
            objectName: "name"
        }
        Cart { 
            id: cart
            objectName: "cart"
        }
        Reciept { 
            id: reciept
            objectName: "reciept"
        }
        Admin { 
            id: admin
            objectName: "admin"
        }
        Tare { 
            id: tare
            objectName: "tare"
        }
    }

    Component.onCompleted: {
        controller.set_stack(stack)
    }
}

