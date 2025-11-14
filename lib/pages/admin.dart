import 'package:bits_n_bytes_ui/components/debug_option.dart';
import 'package:bits_n_bytes_ui/components/shelf.dart';
import 'package:bits_n_bytes_ui/pages/welcome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/uart.dart';
import 'dart:async';
import 'dart:io';
import 'dart:developer';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<String> _connectedShelves = [];
  StreamSubscription<SerialDataPacket>? _serialSubscription;

  @override
  void initState() {
    _serialSubscription = SerialService().dataStream.listen((packet) {
      if (packet.protocol == SerialProtocol.json) {
        final Map<String, dynamic> jsonData =
            packet.data as Map<String, dynamic>;
        if (jsonData.containsKey('shelf_ids')) {
          final rawList = jsonData['shelf_ids'];

          if (rawList is List) {
            // Convert dynamic list to List<String> safely
            List<String> newShelves = rawList.map((e) => e.toString()).toList();

            // Simple check to avoid unnecessary rebuilds if data hasn't actually changed
            if (!_areListsEqual(_connectedShelves, newShelves)) {
              setState(() {
                _connectedShelves = newShelves;
              });
            }
          }
        }
      }
    });
    super.initState();
  }

  // Helper to compare lists quickly
  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _serialSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: MouseRegion(
        cursor: SystemMouseCursors.none,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                TabBar(
                  labelColor: Colors.black, // Or Theme.of(context)...
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: "Inventory"),
                    Tab(text: "Tare"),
                    Tab(text: "System"),
                    Tab(text: "Debug"),
                  ],
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    child: TabBarView(
                      children: [
                        // Your content for the "Inventory" tab
                        Center(child: Text('Inventory Content')),

                        // "Tare" tab
                        _connectedShelves.isEmpty
                            ? const Center(
                                child: Text("Waiting for shelf data..."),
                              )
                            : ListView.builder(
                                itemCount: _connectedShelves.length,
                                itemBuilder: (context, index) {
                                  // Generate a letter: index 0 = A, index 1 = B, etc.
                                  String letter = String.fromCharCode(
                                    'A'.codeUnitAt(0) + index,
                                  );

                                  return Shelf(
                                    // Use UniqueKey to ensure Flutter rebuilds correctly if order changes
                                    key: ValueKey(_connectedShelves[index]),
                                    letter: letter,
                                    macAddr: _connectedShelves[index],
                                  );
                                },
                              ),

                        // "System" tab
                        GridView.count(
                          padding: EdgeInsets.all(20),
                          crossAxisSpacing: 10.0, // Spacing between columns
                          mainAxisSpacing: 10.0,
                          crossAxisCount: 4,
                          children: [
                            Center(
                              child: TextButton.icon(
                                icon: SizedBox.square(
                                  dimension: 20,
                                  child: Icon(LucideIcons.doorOpen),
                                ),
                                onPressed: () => {
                                  SerialService().sendJsonTo('/dev/ttyAMA0', {
                                    "doors": true,
                                  }),
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                label: Text('Open Doors'),
                              ),
                            ),
                            Center(
                              child: TextButton.icon(
                                icon: SizedBox.square(
                                  dimension: 20,
                                  child: Icon(LucideIcons.lockOpen),
                                ),
                                onPressed: () => {
                                  SerialService().sendJsonTo('/dev/ttyAMA0', {
                                    "hatch": true,
                                  }),
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                label: Text('Open Hatch'),
                              ),
                            ),
                            Center(
                              child: TextButton.icon(
                                onPressed: () => {exit(0)},
                                icon: Icon(LucideIcons.logOut),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                label: Text('Exit App'),
                              ),
                            ),
                            Center(
                              child: TextButton.icon(
                                onPressed: () async {
                                  try {
                                    // Run the poweroff command
                                    final result = await Process.run('sudo', [
                                      'poweroff',
                                    ]);

                                    // Log the result for debugging
                                    if (result.exitCode == 0) {
                                      log("Power off command executed.");
                                    } else {
                                      log(
                                        "Power off command failed (this is expected if sudoers is not set up):",
                                      );
                                      log("STDOUT: ${result.stdout}");
                                      log("STDERR: ${result.stderr}");
                                    }
                                  } catch (e) {
                                    log("Error running power off command: $e");
                                  }
                                },
                                icon: Icon(LucideIcons.power),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                label: Text('Power Off'),
                              ),
                            ),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WelcomePage(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  LucideIcons.arrowLeft,
                                ), // Your back icon
                                label: Text('Back'), // Your label
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ), // 3. FIX: Corrected typo
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // "Debug" tab
                        ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          scrollDirection: Axis.vertical,
                          children: [
                            Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Appearance",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 24,
                                  ),
                                ),
                                DebugOption(
                                  title: 'Dark Mode',
                                  description:
                                      'Toggle between light and dark themes',
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "UI Overlays",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 24,
                                  ),
                                ),
                                DebugOption(
                                  title: 'Show Touch Targets',
                                  description:
                                      'Display outlines on all clickable elements',
                                ),
                                DebugOption(
                                  title: 'Show Component Boundaries',
                                  description:
                                      'Draw borders around screen sections',
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Logging & Data",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 24,
                                  ),
                                ),
                                DebugOption(
                                  title: 'Enable Verbose Logging',
                                  description:
                                      'Print detailed logs to the console',
                                ),
                                DebugOption(
                                  title: 'Show Real-time Log Feed',
                                  description:
                                      'Display a log overlay on the screen',
                                ),
                                DebugOption(
                                  title: "Show Raw Sensor Data",
                                  description:
                                      "Display raw data from the weight sensors",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
