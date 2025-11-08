import 'package:flutter/material.dart';

class Shelf extends StatefulWidget {
  final String letter;
  final String macAddr;
  
  const Shelf({
    super.key,
    required this.letter,
    required this.macAddr,
  });

  @override
  State<Shelf> createState() => _ShelfState();
}

class _ShelfState extends State<Shelf> {
  final List<String> items = List.generate(4, (index) => 'Item ${index + 1}'); // Sample data
  String get letter => widget.letter;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    
    // 2. Calculate the available width INSIDE your container
    //    (Screen Width - 32 for margin - 32 for padding)
    final double availableWidth = screenWidth - 32 - 32;

    // 3. Calculate the width for one button
    //    (Available width / 4) - 8px for its own right-padding
    final double buttonWidth = (availableWidth / 4) - 8;

    return Row(
        children: [
          Container(
            width: screenWidth-32,
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              // border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(30), 
                  spreadRadius: 2, 
                  blurRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shelf $letter",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.macAddr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant
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
                          spacing: 20,
                          children: [
                            ElevatedButton(
                              onPressed: () => {},
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(10)
                                ),
                                fixedSize: Size(buttonWidth, 50)
                              ),
                              child: Text("Slot $letter$index"),
                            ),
                          ],
                        );
                      }
                    ),
                  )
                ]
              ),
            ),
          ),
        ],
      );
  }
}