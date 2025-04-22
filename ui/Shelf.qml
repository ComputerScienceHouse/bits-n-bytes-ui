import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 12

    property int index
    required property var modelData  // dictionary with key "slots" -> list

    Repeater {
        model: modelData.slots

        delegate: TareButton {
            label: index + String.fromCharCode(65 + model.slot_index)  // e.g. 1A, 1B, etc.
            selected: model.selected
        }
    }
}