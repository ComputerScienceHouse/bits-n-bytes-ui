import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: 10

    property int index
    required property var modelData  // dictionary with key "slots" -> list
    
    Label {
        text: "Shelf " + shelfData.display_index + " (" + shelfData.id + ")" // Show index and ID
        font.bold: true
        font.pointSize: 16
        Layout.alignment: Qt.AlignHCenter
    }

    RowLayout {
        id: buttonRow
        spacing: 12
        Layout.alignment: Qt.AlignHCenter // Center the row of buttons if needed

        Repeater {
            // model: shelfData.slots.length // Use the list directly
            model: shelfData.slots // Bind to the list of slot data dictionaries

            delegate: TareButton {
                // Pass necessary info down to the button
                shelfId: shelfData.id // Pass the shelf's unique ID (MAC address)
                slotIndex: modelData.slot_index // Pass the slot's index (0-3)
                tareState: modelData.tare_state // Pass the current tare state (0, 1, 2)

                // Create the label dynamically
                // modelData here is the slot data dictionary
                label: shelfData.display_index + String.fromCharCode(65 + modelData.slot_index) // e.g., 1A, 1B
            }
        }
    }
}