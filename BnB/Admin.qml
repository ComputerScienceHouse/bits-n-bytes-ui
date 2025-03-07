import QtQuick
import Constants

Rectangle {
    width: Constants.width
    height: Constants.height
    property var stackView

    AdminScreen{id: screen}

    property alias button: screen.backButton
    property alias tareButton: screen.tareButton

}
