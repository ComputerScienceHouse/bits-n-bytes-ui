import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart'; // Adjust path
import 'package:bits_n_bytes_ui/services/serial_service.dart'; // Adjust path

class HardwareStatusView extends StatefulWidget {
  const HardwareStatusView({super.key});

  @override
  State<HardwareStatusView> createState() => _HardwareStatusViewState();
}

class _HardwareStatusViewState extends State<HardwareStatusView> {
  bool _isReloading = false;

  // Primary Colors
  final Color brandRed = const Color(0xFFE11C52);
  final Color brandPurple = const Color(0xFFB0197E);

  Future<void> _handleReload() async {
    setState(() => _isReloading = true);
    
    LogService.logEvent("Manual Hardware Reset Triggered");
    
    await SerialService().startListeningAll();
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isReloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sectionHeader("COMMUNICATION PORTS"),
            _connectionRow("ESP32 (Atlus)", SerialService.portESP),
            _connectionRow("Jetson Nano (Vision)", SerialService.portJetson),
            _connectionRow("NFC Reader", SerialService.portNFC),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.black12),
            const SizedBox(height: 10),

            _sectionHeader("ACTIVE SHELVES"),
            
            ValueListenableBuilder<Map<String, dynamic>?>(  
              valueListenable: SerialService().espState, 
              builder: (context, data, _) {
                if (data == null || data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "WAITING FOR ESP32 DATA...", 
                        style: TextStyle(color: Colors.black26, fontSize: 12, fontStyle: FontStyle.italic)
                      ),
                    ),
                  );
                }

                final List<dynamic> shelfIds = data['shelf_ids'] ?? [];
                
                if (shelfIds.isEmpty) {
                  return const Text("No shelves reported by ESP32", 
                    style: TextStyle(color: Colors.black26, fontSize: 12));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Let the parent handle scrolling
                  itemCount: shelfIds.length,
                  itemBuilder: (context, index) {
                    return _shelfRow(shelfIds[index].toString());
                  },
                );
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandRed.withValues(alpha: 0.05),
                  elevation: 0,
                  side: BorderSide(color: brandRed, width: 1),
                ),
                onPressed: _isReloading ? null : _handleReload,
                icon: _isReloading 
                  ? SizedBox(
                      width: 18, 
                      height: 18, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: brandRed)
                    )
                  : Icon(Icons.refresh, color: brandRed),
                label: Text(
                  _isReloading ? "RESCANNING..." : "RELOAD ALL PORTS", 
                  style: TextStyle(color: brandRed, fontWeight: FontWeight.bold)
                ),
              ),
            ),
          ],
        ),
      )
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
              Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
              Text(port, style: const TextStyle(color: Colors.black45, fontSize: 12)),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green.withValues(alpha: 0.1) : brandRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isConnected ? Colors.green : brandRed),
            ),
            child: Text(
              isConnected ? "CONNECTED" : "DISCONNECTED",
              style: TextStyle(
                color: isConnected ? Colors.green : brandRed, 
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
      child: Text(title, style: TextStyle(color: brandPurple, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _shelfRow(String shelfId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.shelves, size: 16, color: Colors.black38),
          const SizedBox(width: 12),
          Text(shelfId, style: const TextStyle(color: Colors.black87, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: brandPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: brandPurple.withValues(alpha: 0.3)),
            ),
            child: Text("ACTIVE", style: TextStyle(color: brandPurple, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class SystemLogOverlay extends StatelessWidget {
  const SystemLogOverlay({super.key});

  final Color brandRed = const Color(0xFFE11C52);
  final Color brandPurple = const Color(0xFFB0197E);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.terminal, color: brandRed),
                      title: const Text("System Logs & Status", 
                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black38),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    TabBar(
                      indicatorColor: brandRed,
                      labelColor: brandRed,
                      unselectedLabelColor: Colors.black38,
                      tabs: const [
                        Tab(text: "Events", icon: Icon(Icons.event_note)),
                        Tab(text: "Data", icon: Icon(Icons.data_object)),
                        Tab(text: "Hardware", icon: Icon(Icons.settings_input_component)),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildLogList(LogService.eventLogs, brandPurple), 
                    _buildLogList(LogService.dataLogs, brandRed),  
                    const HardwareStatusView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogList(ValueListenable<List<String>> notifier, Color textColor) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: notifier,
      builder: (context, logs, _) {
        if (logs.isEmpty) {
          return const Center(child: Text("No logs available", style: TextStyle(color: Colors.black26)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.black12, height: 1),
          reverse: true, 
          itemBuilder: (context, index) {
            final log = logs[logs.length - 1 - index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                log,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8), 
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