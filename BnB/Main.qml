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

    // Property to track current screen
    property string currentScreen: "welcome"

    // Function to navigate between screens
    function navigateTo(screenName) {
        currentScreen = screenName

        // Update stack layout index based on screen name
        if (screenName === "welcome") {
            stack.currentIndex = 0
        } else if (screenName === "name") {
            stack.currentIndex = 1
        } else if (screenName === "cart") {
            stack.currentIndex = 2
        } else if (screenName === "reciept") {
            stack.currentIndex = 3
        } else if (screenName === "admin") {
            stack.currentIndex = 4
        } else if (screenName === "tare") {
            stack.currentIndex = 5
        }
    }

    StackLayout {
        id: stack
        objectName: stack
        anchors.fill: parent
        currentIndex: 0 // Start with Name screen
        Welcome {
            id: welcome
            onUnlockAdminScreen: navigateTo("admin")
        }
        Name { id: name}
        Cart { id: cart }
        Reciept { id: reciept }
        Admin {id: admin}
        Tare {id: tare}

    }

    Component.onCompleted: {
        if (welcome.button) {
            welcome.button.onClicked.connect(() => navigateTo("cart"));
        }
        if(cart.button){
            cart.button.onClicked.connect(() => navigateTo("reciept"));
        }
        if(admin.button){
            admin.button.onClicked.connect(() => navigateTo("welcome"));
        }
        if(admin.tareButton){
            admin.tareButton.onClicked.connect(() => navigateTo("tare"));
        }
        if(tare.button){
            tare.button.onClicked.connect(() => navigateTo("admin"));
        }
        if(reciept.button){
            reciept.button.onClicked.connect(() => navigateTo("welcome"));
        }
    }
}

