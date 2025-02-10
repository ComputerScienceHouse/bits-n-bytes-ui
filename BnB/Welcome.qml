import QtQuick
import QtQuick.Controls 2.15
import Constants

Item {
    width: Constants.width
    height: Constants.height
    WelcomeScr{
        button.onClicked: {
            let stack = root.findChild(StackView, "stack");
            if (stack) {
                stack.push("Name.qml");
            } else {
                console.warn("StackView not found!");
            }
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
