import 'package:flutter/material.dart';
import '../services/serial_service.dart';
import 'dart:developer';

class Shelf extends StatefulWidget {
  final String letter;
  final String macAddr;

  /// Which column this shelf sits in ('left' or 'right').
  final String position;

  /// Invoked when the "Move" button is tapped (flips columns).
  final VoidCallback onMove;

  const Shelf({
    super.key,
    required this.letter,
    required this.macAddr,
    required this.position,
    required this.onMove,
  });

  @override
  State<Shelf> createState() => _ShelfState();
}

class _ShelfState extends State<Shelf> {
  final List<String> items = List.generate(
    4,
    (index) => 'Item ${index + 1}',
  ); // Sample data
  String get letter => widget.letter;

  void _showTareDialog(int slotIndex) {
    // List of options for the dropdown
    final List<String> weightOptions = [
      '100g',
      '50g',
      '20g',
      '10g',
      '5g',
      '2g',
      '1g',
    ];
    // Variable to hold the selected value in the dialog
    String? selectedValue = weightOptions.first; // Default to 100g

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Tare Slot $letter$slotIndex'),
              content: DropdownButton<String>(
                value: selectedValue,
                isExpanded: true,
                items: weightOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setDialogState(() {
                    selectedValue = newValue;
                  });
                },
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Tare'),
                  onPressed: () {
                    final int weightInt = int.parse(
                      selectedValue!.replaceAll('g', ''),
                    );
                    log(weightInt.toString());
                    log(
                      'Taring slot $letter$slotIndex with weight $selectedValue',
                    );
                    SerialService().sendJsonTo('/dev/ttyAMA0', {
                      "calibration": {
                        widget.macAddr: [
                          {"slot_id": slotIndex, "weight_g": weightInt},
                        ],
                      },
                    });
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Where tapping "Move" sends this shelf.
    final String moveTarget = widget.position == 'left' ? 'Right' : 'Left';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Card margin (16*2) + inner padding (16*2) eat into the column width.
        final double availableWidth = constraints.maxWidth - 32 - 32;
        final double buttonWidth = (availableWidth / 4) - 8;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            // Flat border instead of a blurred BoxShadow (avoids the
            // offscreen saveLayer that blur forces on the Pi GPU).
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shelf $letter",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.onMove,
                      icon: Icon(
                        widget.position == 'left'
                            ? Icons.arrow_forward
                            : Icons.arrow_back,
                        size: 18,
                      ),
                      label: Text('Move $moveTarget'),
                    ),
                  ],
                ),
                Text(
                  widget.macAddr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => {_showTareDialog(index)},
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(10),
                              ),
                              fixedSize: Size(buttonWidth, 50),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                            ),
                            child: Text("Slot $letter$index"),
                          ),
                          SizedBox(width: 10),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
