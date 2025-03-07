import QtQuick
import Constants

Rectangle {
    width: Constants.width
    height: Constants.height
    property var stackView

    CartScreen{
        id: screen
    }
    property alias button: screen.button
}
