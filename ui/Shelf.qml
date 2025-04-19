import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts

RowLayout {
    id: root

    Repeater {
        model: modelData.slots
        delegate: TareButton {
            label: modelData.shelfIndex + String.fromCharCode(65 + modelData.slotIndex)
        }
    }

}