import QtQuick
import Constants

NameScreen {
    width: Constants.width
    height: Constants.height
    property var stackView

    Loader{
        id: nameScreenLoader
        source: "NameScreen.ui.qml"
    }
}
