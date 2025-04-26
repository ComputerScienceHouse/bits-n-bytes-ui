import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts 6.8 // Needed for Layout attached property

ColumnLayout {
    id: root
    property string shelfId // Unique ID of the parent shelf (e.g., MAC address)
    property int slotIndex // Index of this slot within the shelf (0, 1, 2, ...)
    property int tareState // Current state: 0=Normal, 1=Taring, 2=Completed
    property alias label: button.text // Keep the alias for convenience
    property real calibrationWeightG: 100.0 // Default weight, could be configurable
    property string toolTipText: {
        switch(tareState) {
            case 0: return qsTr("Click to tare (%1g)").arg(calibrationWeightG);
            case 1: return qsTr("Taring in progress...");
            case 2: return qsTr("Tare complete. Click to re-tare.");
            default: return qsTr("Unknown state");
        }
    }
    spacing: 10
    Layout.alignment: Qt.AlignHCenter
    Label {
        id: label
        text: shelfId
    }
    Button {
        id: button
        font.family: "Roboto"
        font.weight: Font.Normal
        
        // --- Visuals ---
        font.pointSize: 18 // Slightly smaller for potentially longer labels
        text: "N/A" // Default text if label isn't set
        Layout.preferredWidth: 90 // Adjusted size
        Layout.preferredHeight: 90 // Adjusted size

        // Bind background and text color directly to the tareState property
        Material.background: {
            if (tareState === 0) return "#454545"
            if (tareState === 1) return "#E2DF00"
            if (tareState === 2) return "#4CAF50"
            return Material.background
        }
        // --- Actions ---
        onClicked: {
            console.log("Button clicked:", label, "Shelf:", shelfId, "Slot:", slotIndex, "Current State:", tareState);
            // Call the Python controller's slot method
            // The controller will handle the state logic and update the model
            controller.tare.tare_slot(shelfId, slotIndex, calibrationWeightG);
        }

        Connections {
            target: controller.tare
            function onShelvesChanged() {
                // This forces the button to re-evaluate its tareState
                tareState = Qt.binding(function() {
                    return controller.tare.get_tare_state(shelfId, slotIndex);
                });
            }
        }

        // Optional: Add a tooltip to show the state
        ToolTip {
            id: toolTip
            visible: parent.hovered
            background: Rectangle {
                color: Material.dialogColor // Semi-transparent dark
                opacity: 0.9
                radius: 4
            }
            
            contentItem: Text {
                text: toolTipText
                font: toolTip.font
                color: Material.foreground
                wrapMode: Text.Wrap
            }
            y: -30
        }

    }
}
