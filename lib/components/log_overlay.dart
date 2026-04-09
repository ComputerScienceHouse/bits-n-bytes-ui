import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart'; // Adjust path
import 'package:bits_n_bytes_ui/services/uart.dart'; // Adjust path

class HardwareStatusView extends StatefulWidget {
  const HardwareStatusView({super.key});

  @override
  State<HardwareStatusView> createState() => _HardwareStatusViewState();
}

class _HardwareStatusViewState extends State<HardwareStatusView> {
  bool _isReloading = false;

  Future<void> _handleReload() async {
    setState(() => _isReloading = true);
    
    LogService.logEvent("Manual Hardware Reset Triggered");
    
    // Call your parallel start function
    await SerialService().startListeningAll();
    
    // Brief delay so the user sees the "Reloading" state
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isReloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Port Status Section
          _sectionHeader("COMMUNICATION PORTS"),
          _connectionRow("ESP32 (Main Controller)", SerialService.portESP),
          _connectionRow("Jetson Nano (Vision)", SerialService.portJetson),
          _connectionRow("NFC Reader", SerialService.portNFC),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),

          // New Shelf Status Section
          _sectionHeader("ACTIVE SHELVES"),
          Expanded(
            child: ValueListenableBuilder<Map<String, dynamic>?>(
              // Note the nullable type <Map<String, dynamic>?>
              valueListenable: SerialService().espState, 
              builder: (context, data, _) {
                // 1. Handle Null or Empty Data
                if (data == null || data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "WAITING FOR ESP32 DATA...", 
                        style: TextStyle(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic)
                      ),
                    ),
                  );
                }

                // 2. Safely extract the list
                final List<dynamic> shelfIds = data['shelf_ids'] ?? [];
                
                if (shelfIds.isEmpty) {
                  return const Text("No shelves reported by ESP32", 
                    style: TextStyle(color: Colors.white24, fontSize: 12));
                }

                // 3. Build the list if data is valid
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: shelfIds.length,
                  itemBuilder: (context, index) {
                    return _shelfRow(shelfIds[index].toString());
                  },
                );
              },
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.withOpacity(0.1),
                side: const BorderSide(color: Colors.greenAccent, width: 1),
              ),
              onPressed: _isReloading ? null : _handleReload,
              icon: _isReloading 
                ? const SizedBox(
                    width: 18, 
                    height: 18, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent)
                  )
                : const Icon(Icons.refresh, color: Colors.greenAccent),
              label: Text(
                _isReloading ? "RESCANNING..." : "RELOAD ALL PORTS", 
                style: const TextStyle(color: Colors.greenAccent)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectionRow(String label, String port) {
    final bool isConnected = SerialService().isListening(port);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              Text(port, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isConnected ? Colors.green : Colors.red),
            ),
            child: Text(
              isConnected ? "CONNECTED" : "DISCONNECTED",
              style: TextStyle(
                color: isConnected ? Colors.greenAccent : Colors.redAccent, 
                fontSize: 10, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _shelfRow(String shelfId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.shelves, size: 16, color: Colors.white54),
          const SizedBox(width: 12),
          Text(shelfId, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const Spacer(),
          // Reusing your visual style for consistency
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
            ),
            child: const Text("ACTIVE", style: TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class SystemLogOverlay extends StatelessWidget {
  const SystemLogOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Dialog(
        backgroundColor: Colors.grey[900],
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              // --- Header & Tabs ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.terminal, color: Colors.greenAccent),
                      title: const Text("System Logs & Status", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const TabBar(
                      indicatorColor: Colors.greenAccent,
                      labelColor: Colors.greenAccent,
                      unselectedLabelColor: Colors.white54,
                      tabs: [
                        Tab(text: "Events", icon: Icon(Icons.event_note)),
                        Tab(text: "Data", icon: Icon(Icons.data_object)),
                        Tab(text: "Hardware", icon: Icon(Icons.settings_input_component)),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Body ---
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLogList(LogService.eventLogs), // Event Tab
                    _buildLogList(LogService.dataLogs),  // Data Tab
                    const HardwareStatusView(),          // Hardware Tab
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generic Reusable Log List
  Widget _buildLogList(ValueListenable<List<String>> notifier) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: notifier,
      builder: (context, logs, _) {
        if (logs.isEmpty) {
          return const Center(child: Text("No logs available", style: TextStyle(color: Colors.white24)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
          reverse: true, // Show newest at the top (or bottom depending on preference)
          itemBuilder: (context, index) {
            final log = logs[logs.length - 1 - index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                log,
                style: const TextStyle(
                  color: Colors.greenAccent, 
                  fontFamily: 'monospace', 
                  fontSize: 13
                ),
              ),
            );
          },
        );
      },
    );
  }
}