import 'package:bits_n_bytes_ui/components/admin_controls_grid.dart';
import 'package:bits_n_bytes_ui/components/debug_action.dart';
import 'package:bits_n_bytes_ui/components/debug_log_overlay.dart';
import 'package:bits_n_bytes_ui/components/debug_option.dart';
import 'package:bits_n_bytes_ui/components/log_overlay.dart';
import 'package:bits_n_bytes_ui/components/shelf.dart';
import 'package:bits_n_bytes_ui/models/serial/esp_state.dart';
import 'package:bits_n_bytes_ui/theme.dart';
import 'package:bits_n_bytes_ui/viewmodel/admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

/// Thin View. Shelf state lives in [AdminViewModel] (route-scoped provider).
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final allShelves = vm.connectedShelves;

    // Stable A/B/C… label based on a shelf's position in the full list, so a
    // shelf keeps its letter regardless of which column it's moved to.
    String letterFor(ShelfData s) => String.fromCharCode(
      'A'.codeUnitAt(0) +
          allShelves.indexWhere((x) => x.macAddress == s.macAddress),
    );

    Widget shelfColumn(List<ShelfData> shelves) => ListView.builder(
      itemCount: shelves.length,
      itemBuilder: (context, index) {
        final s = shelves[index];
        return Shelf(
          key: ValueKey(s.macAddress),
          letter: letterFor(s),
          macAddr: s.macAddress,
          position: s.position,
          onMove: () => vm.moveShelf(s.macAddress),
        );
      },
    );

    return DefaultTabController(
      length: 4,
      child: MouseRegion(
        cursor: (dotenv.env['HIDE_CURSOR'] == 'true')
            ? SystemMouseCursors.none
            : SystemMouseCursors.basic,
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

                        // "Tare" tab — two columns split by shelf position; the
                        // per-shelf "Move" button flips a shelf between them.
                        allShelves.isEmpty
                            ? const Center(
                                child: Text("Waiting for shelf data..."),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: shelfColumn(vm.leftShelves)),
                                  Expanded(child: shelfColumn(vm.rightShelves)),
                                ],
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Flips the app-wide theme live. `system` resolves
                            // to the current platform brightness so the switch
                            // reflects what's actually on screen.
                            ValueListenableBuilder<ThemeMode>(
                              valueListenable: themeModeNotifier,
                              builder: (context, mode, _) {
                                final isDark =
                                    mode == ThemeMode.dark ||
                                    (mode == ThemeMode.system &&
                                        MediaQuery.platformBrightnessOf(
                                              context,
                                            ) ==
                                            Brightness.dark);
                                return DebugOption(
                                  title: 'Dark Mode',
                                  description:
                                      'Toggle between light and dark themes',
                                  value: isDark,
                                  onChanged: (v) => themeModeNotifier.value = v
                                      ? ThemeMode.dark
                                      : ThemeMode.light,
                                );
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ), // Use SizedBox for spacing in ListViews

                            Text(
                              "UI Overlays",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DebugOption(
                              title: 'Show Touch Targets',
                              description:
                                  'Display outlines on all clickable elements',
                            ),
                            const SizedBox(height: 10),
                            DebugOption(
                              title: 'Show Component Boundaries',
                              description:
                                  'Draw borders around screen sections',
                            ),
                            const SizedBox(height: 10),
                            // Real toggle: shows the floating debug + simulator
                            // sidebar over every screen (normally debug-only).
                            ValueListenableBuilder<bool>(
                              valueListenable: DebugLogOverlay.enabled,
                              builder: (context, on, _) => DebugOption(
                                title: 'Debug / Sim Sidebar',
                                description:
                                    'Show the floating debug + simulator panel over every screen',
                                value: on,
                                onChanged: (v) =>
                                    DebugLogOverlay.enabled.value = v,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              "Logging & Data",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                              description:
                                  "Display raw data from the weight sensors",
                            ),
                            const SizedBox(height: 10),
                            DebugAction(
                              title: 'Open System Log Feed',
                              description:
                                  'View real-time event, data, and hardware logs',
                              icon: Icons.terminal,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const SystemLogOverlay(),
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
