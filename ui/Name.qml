import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import Constants

Rectangle {
    id: nameScreen
    width: Constants.width
    height: Constants.height
    Material.theme: Material.Dark
    color: "#292929"
    property alias text: nameText

    Text {
        id: nameText
        width: 828
        height: 101
        color: "#ffffff"
        text: "Welcome Joe Shmoe"
        textFormat: Text.RichText
        font.weight: Font.DemiBold
        font.pointSize: 80
        font.family: "IBM Plex Mono"
        anchors.verticalCenterOffset: -24
        anchors.horizontalCenterOffset: 1
        anchors.centerIn: parent
        opacity: 1
    }
}
