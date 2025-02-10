
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
import QtQuick.Layouts

Rectangle {
    Material.theme: Material.Dark
    id: recieptScreen
    width: Constants.width
    height: Constants.height
    color: "#292929"
    property alias emailButton: emailButton
    property alias textButton: textButton

    Text {
        id: _text
        x: 15
        y: 10
        width: 168
        height: 49
        color: "#ffffff"
        text: qsTr("Reciept")
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        font.weight: Font.DemiBold
        font.family: "IBM Plex Mono"
        font.bold: true
    }

    Text {
        id: timeout
        x: 844
        y: 10
        width: 172
        height: 49
        color: "#ffffff"
        text: qsTr("Timeout: 10")
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.weight: Font.DemiBold
        font.family: "Roboto"
        font.bold: true
    }

    ColumnLayout {
        id: container
        x: 662
        y: 131
        width: 341
        height: 449
        Text {
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: 20
            x: 668
            y: 177
            width: 269
            height: 65
            color: "#ffffff"
            text: qsTr("Would you like your reciept?")
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.DemiBold
            font.family: "Roboto"
            font.bold: true
        }

        Item {
            id: buttonContainer
            // The container's size will be driven by the ColumnLayout's children.
            // (Assuming the ColumnLayout’s children are added as normal QML children.)
            width: buttons.childrenRect.width
            height: buttons.childrenRect.height
            Layout.alignment: Qt.AlignCenter
            ColumnLayout {
                id: buttons
                spacing: 5
                Button {
                    Layout.alignment: Qt.AlignCenter
                    id: textButton
                    Layout.preferredWidth: 234
                    Layout.preferredHeight: 52
                    x: 685
                    y: 238
                    text: qsTr("Text")
                }

                Button {
                    checked: false
                    Layout.alignment: Qt.AlignCenter
                    id: emailButton
                    x: 685
                    y: 296
                    Layout.preferredWidth: 234
                    Layout.preferredHeight: 52
                    visible: true
                    text: qsTr("Email")
                }

                Button {
                    Layout.alignment: Qt.AlignCenter
                    id: noRecieptButton
                    x: 685
                    y: 354
                    Layout.preferredWidth: 234
                    Layout.preferredHeight: 52
                    visible: true
                    text: qsTr("No Reciept")
                }
            }
        }

        Text {

            id: subtotal
            x: 685
            y: 441
            width: 234
            height: 49
            color: "#ffffff"
            text: qsTr("Subtotal:")
            font.pixelSize: 16
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.DemiBold
            font.family: "Roboto"
            font.bold: true
        }

        Text {
            id: tax
            x: 685
            y: 476
            width: 234
            height: 49
            color: "#ffffff"
            text: qsTr("Tax:")
            font.pixelSize: 16
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.DemiBold
            font.family: "Roboto"
            font.bold: true
        }

        Text {
            id: total
            x: 685
            y: 511
            width: 234
            height: 49
            color: "#ffffff"
            text: qsTr("Total:")
            font.pixelSize: 16
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.weight: Font.DemiBold
            font.family: "Roboto"
            font.bold: true
        }
    }

    ColumnLayout {
        id: columnLayout
        x: 20
        y: 65
        z: 1
        width: 607
        height: 509
        Rectangle {
            id: rectangle
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#646c0164"
            radius: 15
        }
    }
}
