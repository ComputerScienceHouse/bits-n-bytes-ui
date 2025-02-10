
/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
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
