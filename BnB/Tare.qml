import QtQuick
import Constants

Rectangle {
    width: Constants.width
    height: Constants.height
    property var stackView

    TareScreen{id: screen}

    property alias button: screen.backButton

}
