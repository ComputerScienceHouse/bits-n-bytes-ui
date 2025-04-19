import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts

Button {
    id: root
    property alias label: root.text
    highlighted: modelData.selected

    font.family: "Roboto"
    font.pointSize: 24
    Material.roundedScale: Material.NotRounded
    Layout.preferredWidth: 80
    Layout.preferredHeight: 80

    // Color cycling logic
    property int colorIndex: 0
    property var colorList: ["#424242", "#FFDE21", "#4CAF50"]

    Material.background: colorList[colorIndex]

    onClicked: {
        modelData.selected = !modelData.selected
        colorIndex = (colorIndex + 1) % colorList.length
        Material.background = colorList[colorIndex]
    }
}
