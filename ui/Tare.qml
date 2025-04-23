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
        controller.tare.sort_shelves()
    }

    Connections {
        target: controller.tare
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
            controller.tare.sort_shelves()
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

    GridLayout {
        id: grid
        anchors.fill: parent
        columns: 2
        rowSpacing: 50
        columnSpacing: 100

        Repeater {
            model: controller.tare.shelves
            delegate: Shelf {
                shelfData: modelData
                Layout.row: Math.floor(index / 2)
                Layout.column: index % 2
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

