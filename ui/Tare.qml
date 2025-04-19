import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts
import Constants

Rectangle {
    Material.theme: Material.Dark

    id: tareScreen
    width: Constants.width
    height: Constants.height
    color: "#292929"
    property color bgColor: "#454545"

    Component.onCompleted: {
        controller.sort_shelves()
    }

    Connections {
        target: controller
        function onShelvesChanged(){
            if(!debounceTimer.running){
                debounceTimer.start();
            }
        }
    }

    Timer {
        id: debounceTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            controller.sort_shelves()
        }
    }

    Text {
        id: _text
        x: 15
        y: 10
        width: 168
        height: 49
        color: "#ffffff"
        text: qsTr("Tare")
        font.pixelSize: 40
        horizontalAlignment: Text.AlignLeft
        font.family: "IBM Plex Mono"
        font.bold: true
    }

    RowLayout{ 
        anchors.fill: parent
        anchors.margins: 18
        spacing: 100  // adjust spacing between columns as needed
        
        ColumnLayout {
        id: leftColumn
        spacing: 50
        Layout.fillWidth: true
        Layout.fillHeight: true

            Repeater {
                model: controller.left_shelves
                delegate: Shelf {
                    required property int index
                    required property var modelData
                }
            }
        }

        ColumnLayout{
            id: rightColumn
            spacing: 50
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: controller.right_shelves
                delegate: Shelf {
                    required property int index
                    required property var modelData
                }
            }
        }
    }
    

    Button {
        id: backButton
        x: 958
        y: 0
        width: 58
        height: 68
        text: qsTr("⬅")
        font.pointSize: 30
        Material.background: "#F76902"
        onClicked: stack.pop()
    }
}

