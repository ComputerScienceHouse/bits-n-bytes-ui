import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts

Button {
    id: root
    property alias label: root.text
    property bool selected: false

    font.pointSize: 20
    Layout.preferredWidth: 80
    Layout.preferredHeight: 80

    property int colorIndex: selected ? 1 : 0
    property var colorList: ["#424242", "#FFDE21", "#4CAF50"]

    Material.background: colorList[colorIndex]

    onClicked: {
        selected = !selected
        colorIndex = (colorIndex + 1) % colorList.length
        Material.background = colorList[colorIndex]
    }
}
