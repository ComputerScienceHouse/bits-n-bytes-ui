import QtQuick
import QtQuick.Controls 6.8
import Constants

Rectangle {
    width: Constants.width
    height: Constants.height

    WelcomeScreen{
        id: screen
    }

    property alias button: screen.button
    property var inputPattern: []  // Stores the user's button press sequence
    property var correctPattern: ["one", "two", "three", "four"] // Correct unlock sequence
    signal unlockAdminScreen()

    function checkPattern() {
        if (JSON.stringify(inputPattern) === JSON.stringify(correctPattern)) {
            console.log("Correct pattern! Unlocking Admin Screen...")
            unlockAdminScreen()
            inputPattern = []
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
