import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 10

    RowLayout {
        id: buttonRow
        spacing: 12
        Layout.alignment: Qt.AlignHCenter

        Repeater {
            model: modelData.slots // Use the slots property

            delegate: TareButton {
                // Access slot properties from the model
                required property var modelData

                shelfId: root.modelData.mac_addr
                slotIndex: modelData.slot_index
                tareState: modelData.tare_state
                label: root.modelData.index + String.fromCharCode(65 + modelData.slot_index) // e.g., 1A, 1B
            }
        }
    }
}