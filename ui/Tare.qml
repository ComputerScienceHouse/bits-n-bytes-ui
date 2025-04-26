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

    Connections {
        target: controller.tare
        function onShelvesChanged() {
            controller.tare.update_shelves
        }
    }

    Component.onCompleted: {
        controller.tare.get_new_shelves()
        controller.tare.start_real_time_updates()
        console.log("Real-time updates enabled")
    }

    Component.onDestruction: {
        controller.tare.stop_real_time_updates()
        console.log("Real-time updates disabled")
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

    Rectangle {
        id: contentArea
        anchors {
            top: _text.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 30  // Uniform margin around all edges
            topMargin: 20  // Smaller top margin
        }
        color: "transparent"
    GridLayout {
        id: grid
        anchors.fill: parent
        columns: 2
        rowSpacing: 15
        columnSpacing: 15

        Text {
            visible: controller.tare.shelves.length === 0
            text: "No shelves connected"
            color: Material.foreground
            font.pointSize: 30
            font.family: "Roboto"
            font.weight: Font.Normal
            Layout.row: 0
            Layout.column: 0
            Layout.columnSpan: 2  // Span both columns
            Layout.rowSpan: 1
            Layout.alignment: Qt.AlignCenter
        }

        Repeater {
            model: controller.tare.shelves.length > 0 ? controller.tare.shelves : null
            delegate: Shelf {
                // Bind model properties explicitly
                // Pass the properties to the Shelf component
                required property int index
                required property var modelData
                Layout.row: index
                Layout.column: index % 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: grid.width / 2 - grid.columnSpacing / 2
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

