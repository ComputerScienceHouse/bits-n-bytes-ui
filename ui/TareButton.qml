import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Controls.Material 6.8
import QtQuick.Layouts 6.8 // Needed for Layout attached property

Button {
    id: root

    // --- Properties received from Shelf.qml ---
    property string shelfId: "" // Unique ID of the parent shelf (e.g., MAC address)
    property int slotIndex: -1 // Index of this slot within the shelf (0, 1, 2, ...)
    property int tareState: 0 // Current state: 0=Normal, 1=Taring, 2=Completed
    property alias label: root.text // Keep the alias for convenience

    // --- Configuration ---
    property var colorList: [
        Material.background, // 0: Normal (use default Button background)
        Material.Orange,     // 1: Taring (use a distinct color)
        Material.Green       // 2: Completed (use a success color)
    ]
    property var textColorList: [
        Material.foreground, // 0: Normal
        Material.darkTheme ? Qt.color("black") : Qt.color("white"),     // 1: Taring Text Color
        Material.darkTheme ? Qt.color("black") : Qt.color("white")      // 2: Completed Text Color
    ]
    property real calibrationWeightG: 100.0 // Default weight, could be configurable

    // --- Visuals ---
    font.pointSize: 18 // Slightly smaller for potentially longer labels
    text: "N/A" // Default text if label isn't set
    Layout.preferredWidth: 90 // Adjusted size
    Layout.preferredHeight: 90 // Adjusted size

    // Bind background and text color directly to the tareState property
    Material.background: colorList[tareState]
    Material.foreground: textColorList[tareState] // Change text color for contrast

    // --- Actions ---
    onClicked: {
        console.log("Button clicked:", label, "Shelf:", shelfId, "Slot:", slotIndex, "Current State:", tareState);
        // Call the Python controller's slot method
        // The controller will handle the state logic and update the model
        controller.tare_slot(shelfId, slotIndex, calibrationWeightG);
    }

    // Optional: Add a tooltip to show the state
    ToolTip.visible: hovered
    ToolTip.text: {
        switch(tareState) {
            case 0: return "Click to tare (" + calibrationWeightG + "g)";
            case 1: return "Taring in progress...";
            case 2: return "Tare complete. Click to reset.";
            default: return "Unknown state";
        }
    }
}