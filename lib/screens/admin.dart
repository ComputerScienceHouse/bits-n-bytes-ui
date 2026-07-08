import 'package:bits_n_bytes_ui/components/admin_controls_grid.dart';
import 'package:bits_n_bytes_ui/components/debug_action.dart';
import 'package:bits_n_bytes_ui/components/debug_option.dart';
import 'package:bits_n_bytes_ui/components/log_overlay.dart';
import 'package:bits_n_bytes_ui/components/shelf.dart';
import 'package:bits_n_bytes_ui/viewmodel/admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

/// Thin View. Shelf state lives in [AdminViewModel] (route-scoped provider).
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final connectedShelves = context.watch<AdminViewModel>().connectedShelves;
    return DefaultTabController(
      length: 4,
      child: MouseRegion(
        cursor: (dotenv.env['HIDE_CURSOR'] == 'true') ? SystemMouseCursors.none : SystemMouseCursors.basic,
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
                        connectedShelves.isEmpty
                            ? const Center(
                                child: Text("Waiting for shelf data..."),
                              )
                            : ListView.builder(
                                itemCount: connectedShelves.length,
                                itemBuilder: (context, index) {
                                  // Generate a letter: index 0 = A, index 1 = B, etc.
                                  String letter = String.fromCharCode(
                                    'A'.codeUnitAt(0) + index,
                                  );

                                  return Shelf(
                                    // Use UniqueKey to ensure Flutter rebuilds correctly if order changes
                                    key: ValueKey(connectedShelves[index]),
                                    letter: letter,
                                    macAddr: connectedShelves[index],
                                  );
                                },
                              ),

                        // "System" tab
                        AdminControlsGrid(),
                        // "Debug" tab
                        ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          // Removed the nested Columns with 'spacing' to prevent infinite layout loops
                          children: [
                            Text(
                              "Appearance",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DebugOption(
                              title: 'Dark Mode',
                              description: 'Toggle between light and dark themes',
                            ),
                            const SizedBox(height: 20), // Use SizedBox for spacing in ListViews
                            
                            Text(
                              "UI Overlays",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DebugOption(
                              title: 'Show Touch Targets',
                              description: 'Display outlines on all clickable elements',
                            ),
                            const SizedBox(height: 10),
                            DebugOption(
                              title: 'Show Component Boundaries',
                              description: 'Draw borders around screen sections',
                            ),
                            const SizedBox(height: 20),

                            Text(
                              "Logging & Data",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DebugOption(
                              title: 'Enable Verbose Logging',
                              description: 'Print detailed logs to the console',
                            ),
                            const SizedBox(height: 10),
                            DebugOption(
                              title: "Show Raw Sensor Data",
                              description: "Display raw data from the weight sensors",
                            ),
                            const SizedBox(height: 10),
                            DebugAction(
                              title: 'Open System Log Feed',
                              description: 'View real-time event, data, and hardware logs',
                              icon: Icons.terminal,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const SystemLogOverlay(),
                                );
                              },
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
