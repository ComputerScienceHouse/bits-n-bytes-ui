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
        id: tareGrid
        columns: 2
        rows: 3
        columnSpacing: 20
        rowSpacing: 20
        anchors.fill: parent
        anchors.margins: 18
        anchors.topMargin: 66
        anchors.bottomMargin: 8

        property var buttonLabels: [
            "1A", "1B", "1C", "1D", "2A", "2B", "2C", "2D",
            "3A", "3B", "3C", "3D", "4A", "4B", "4C", "4D",
            "5A", "5B", "5C", "5D", "6A", "6B", "6C", "6D"
        ]   
        
        Repeater {
            model: tareGrid.buttonLabels.length
            delegate: TareButton {
                label: tareGrid.buttonLabels[index]
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

