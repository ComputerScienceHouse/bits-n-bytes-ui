import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.VirtualKeyboard 2.8

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Virtual Keyboard Test")

    // Input field
    TextField {
        id: inputField
        width: 300
        height: 40
        placeholderText: "Tap to type..."
        focus: true
    }

        // Input Panel
        InputPanel {
            anchors.bottom: parent.bottom
            width: parent.width
        }
    }

