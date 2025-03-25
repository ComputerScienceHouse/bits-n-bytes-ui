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
        // currentIndex: 0 // Start with Name screen
        Welcome {
            id: welcome
            objectName: "welcome"
            onUnlockAdminScreen: controller.navigate("admin")
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
    //     // if (welcome.button) {
    //     //     welcome.button.onClicked.connect(() => controller.navigate("cart"));
    //     // }
    //     if(cart.button){
    //         cart.button.onClicked.connect(() => controller.navigate("reciept"));
    //     }
    //     if(admin.button){
    //         admin.button.onClicked.connect(() => controller.navigate("welcome"));
    //     }
    //     if(admin.tareButton){
    //         admin.tareButton.onClicked.connect(() => controller.navigate("tare"));
    //     }
    //     if(tare.button){
    //         tare.button.onClicked.connect(() => controller.navigate("admin"));
    //     }
    //     if(reciept.button){
    //         reciept.button.onClicked.connect(() => controller.navigate("welcome"));
    //     }
    // }
}

