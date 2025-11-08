import 'package:bits_n_bytes_ui/components/debug_option.dart';
import 'package:bits_n_bytes_ui/components/shelf.dart';
import 'package:bits_n_bytes_ui/pages/welcome.dart';
import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
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
                  Tab(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(LucideIcons.arrowLeft),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => const WelcomePage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ]
                    ),
                  )
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
                      ListView(
                        children: [
                          Shelf(
                            letter: 'A', 
                            macAddr: '5C:DF:28:AC:BE:1B', 
                          )
                        ]
                      ),
                      
                      // "System" tab
                      GridView.count(
                        crossAxisSpacing: 10.0, // Spacing between columns
                        mainAxisSpacing: 10.0,
                        crossAxisCount: 4,
                        children: [
                          Center(
                            child: TextButton.icon(
                              icon: SizedBox.square(
                                dimension: 20,
                                child: Icon(LucideIcons.doorOpen)
                              ),
                              onPressed: () => {}, 
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(10)
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text('Open Doors'),
                            ),
                          ),
                          Center(
                            child: TextButton.icon(
                              icon: SizedBox.square(
                                dimension: 20,
                                child: Icon(LucideIcons.lockOpen)
                              ),
                              onPressed: () => {}, 
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(10)
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text('Open Hatch'),
                            ),
                          ),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => {},
                              icon: Icon(
                                LucideIcons.logOut
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(10)
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text('Exit App')
                            ),
                          ),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => {},
                              icon: Icon(
                                LucideIcons.power
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(10)
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text('Power Off')
                            ),
                          )
                        ]
                      ),
                      // "Debug" tab
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        scrollDirection: Axis.vertical,
                        children: [
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Appearance", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 24),),
                              DebugOption(
                                title: 'Dark Mode', 
                                description: 'Toggle between light and dark themes'
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("UI Overlays", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 24),),
                              DebugOption(
                                title: 'Show Touch Targets', 
                                description: 'Display outlines on all clickable elements'
                              ),
                              DebugOption(
                                title: 'Show Component Boundaries', 
                                description: 'Draw borders around screen sections'
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Logging & Data", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 24),),
                              DebugOption(
                                title: 'Enable Verbose Logging', 
                                description: 'Print detailed logs to the console'
                              ),
                              DebugOption(
                                title: 'Show Real-time Log Feed', 
                                description: 'Display a log overlay on the screen'
                              ),
                              DebugOption(
                                title: "Show Raw Sensor Data", 
                                description: "Display raw data from the weight sensors")
                            ],
                          ),
                        ],
                      )
                    ]
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}