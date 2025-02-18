import QtQuick
import QtQuick.Controls 6.8
import Constants

Page {
    width: Constants.width
    height: Constants.height

    WelcomeScreen{
        id: welcomeScreen

    }
    tapButton.onClicked: {
        stackView.push("Cart.qml")  // Navigate to Cart screen
    }
    property var inputPattern: []  // Stores the user's button press sequence
    property var correctPattern: ["one", "two", "three", "four"] // Correct unlock sequence

    function checkStackRef() {
        if (stackView) {
           console.log("Navigating to Admin Screen...")
           stackView.push("AdminScreen.qml")  // Navigate to Admin screen
       } else {
           console.log("stackView is undefined.")
       }
    }

    function checkPattern() {
        if (JSON.stringify(inputPattern) === JSON.stringify(correctPattern)) {
            console.log("Correct pattern! Unlocking Admin Screen...")
            // backend.unlockAdminScreen()
            checkStackRef()
        } else if (inputPattern.length >= correctPattern.length) {
            console.log("Incorrect pattern. Resetting...")
            inputPattern = [] // Reset sequence if incorrect
        }
    }

    Button {
        id: one
        width: 100; height: 100
        opacity: 0
        anchors.top: parent.top
        anchors.right: parent.right
        onClicked: {
            console.log("stackView:", stackView)
            inputPattern.push("one")
            checkPattern()
        }
    }

    Button {
        id: two
        width: 100; height: 100
        opacity: 0
        anchors.top: parent.top
        anchors.left: parent.left
        onClicked: {
            inputPattern.push("two")
            checkPattern()
        }
    }

    Button {
        id: three
        width: 100; height: 100
        opacity: 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked: {
            inputPattern.push("three")
            checkPattern()
        }
    }

    Button {
        id: four
        width: 100; height: 100
        opacity: 0
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: {
            inputPattern.push("four")
            checkPattern()
        }
    }

}


// property var stackView

// Connections {
//     target: stackView
//     onCompleted: {
//         console.log("✅ stackView in Welcome.qml:", stackView); // This should now print the StackView
//     }
// }

// WelcomeScreen {
//     button.onClicked: {
//         console.log("Clicked")
//         if (stackView) {
//             stackView.push("Name.qml")
//         } else {
//             console.warn("⚠️ stackView is not defined!");
//         }
//     }
// }
