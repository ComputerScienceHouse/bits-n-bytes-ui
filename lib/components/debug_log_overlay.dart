import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';

// Self-contained dark palette so the panel is readable over any app screen.
const _bg = Color(0xF21A1D24);
const _bar = Color(0xFF21252E);
const _panel2 = Color(0xFF2A2F3A);
const _border = Color(0xFF2B303B);
const _muted = Color(0xFF8B93A7);
const _accent = Color(0xFF4F8CFF);
const _green = Color(0xFF35C66B);
const _amber = Color(0xFFF2B53D);
const _text = Color(0xFFE6E8EE);

/// A debug-only log + simulator sidebar that floats over every screen.
///
/// Wire it in via `MaterialApp.builder` so it sits above the Navigator and is
/// visible on any route. In non-debug builds it is a transparent passthrough,
/// so it is safe to leave wired in for release.
class DebugLogOverlay extends StatefulWidget {
  final Widget child;
  const DebugLogOverlay({super.key, required this.child});

  @override
  State<DebugLogOverlay> createState() => _DebugLogOverlayState();
}

class _DebugLogOverlayState extends State<DebugLogOverlay> {
  static const double _panelWidth = 360;

  bool _open = false;

  @override
  Widget build(BuildContext context) {
    // Debug-only. Release/profile builds get the app untouched.
    if (!kDebugMode) return widget.child;

    final double height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        widget.child,

        // Sliding panel, pinned to the right edge, full height.
        AnimatedPositioned(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          right: _open ? 0 : -_panelWidth,
          width: _panelWidth,
          // Host the panel in its own Overlay so the TextFields inside it can
          // resolve an Overlay ancestor. The app's Overlay lives in the
          // Navigator, which is a sibling of this panel — not an ancestor.
          child: Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => _DebugPanel(
                  onClose: () => setState(() => _open = false),
                ),
              ),
            ],
          ),
        ),

        // Toggle handle, follows the panel edge.
        AnimatedPositioned(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          right: _open ? _panelWidth : 0,
          top: height * 0.4,
          child: _buildHandle(),
        ),
      ],
    );
  }

  Widget _buildHandle() {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: Container(
          width: 34,
          height: 76,
          decoration: BoxDecoration(
            color: _bar,
            border: Border.all(color: _border),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
          ),
          child: Icon(
            _open ? Icons.chevron_right : Icons.bug_report_outlined,
            color: _open ? _muted : _accent,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// The panel body: header, tab bar, and the selected tab's content. Kept as a
/// self-contained stateful widget hosted inside an [Overlay] so its TextFields
/// (in the Sim section) resolve an Overlay ancestor.
class _DebugPanel extends StatefulWidget {
  final VoidCallback onClose;
  const _DebugPanel({required this.onClose});

  @override
  State<_DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends State<_DebugPanel> {
  int _tab = 0;

  // "Sim" only appears when the in-process simulator is active (desktop dev).
  List<String> get _tabs => [
        if (SerialService.useSimulator) 'Sim',
        'Events',
        'Data',
      ];

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    final int tab = _tab.clamp(0, tabs.length - 1);
    final String label = tabs[tab];

    return Material(
      color: _bg,
      elevation: 12,
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(label),
            _buildTabs(tabs, tab),
            Expanded(child: _buildContent(label)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String label) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 14, right: 6),
      decoration: const BoxDecoration(
        color: _bar,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.terminal, size: 16, color: _muted),
          const SizedBox(width: 8),
          const Text(
            'Debug',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (label != 'Sim')
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: _muted),
              onPressed: () {
                (label == 'Events' ? LogService.eventLogs : LogService.dataLogs).value = [];
              },
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: _muted),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(List<String> tabs, int selected) {
    return Container(
      color: _bar,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _tabButton(tabs[i], i, selected),
          ],
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index, int selected) {
    final bool isSelected = index == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _accent.withValues(alpha: 0.18) : Colors.transparent,
            border: Border.all(color: isSelected ? _accent : _border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : _muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(String label) {
    switch (label) {
      case 'Sim':
        return const _SimControls();
      case 'Data':
        return _buildLogList(LogService.dataLogs, _green);
      case 'Events':
      default:
        return _buildLogList(LogService.eventLogs, _text);
    }
  }

  Widget _buildLogList(ValueNotifier<List<String>> notifier, Color lineColor) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: notifier,
      builder: (context, logs, _) {
        if (logs.isEmpty) {
          return const Center(
            child: Text(
              'No logs yet.',
              style: TextStyle(color: _muted, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          );
        }
        return ListView.builder(
          reverse: true, // newest pinned to the bottom
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: logs.length,
          itemBuilder: (context, i) {
            final line = logs[logs.length - 1 - i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                line,
                style: TextStyle(
                  color: lineColor,
                  fontSize: 11.5,
                  height: 1.35,
                  fontFamily: 'monospace',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// In-app replacement for the old HTML control panel. Drives the simulator by
/// writing directly to the `SerialService` notifiers the app already listens to.
class _SimControls extends StatefulWidget {
  const _SimControls();

  @override
  State<_SimControls> createState() => _SimControlsState();
}

class _SimControlsState extends State<_SimControls> {
  bool _doors = false;
  bool _hatch = false;
  double _temp = 24;
  int _qty = 1;

  final _intake = TextEditingController(text: '1000');
  final _exhaust = TextEditingController(text: '1000');
  final _shelves = TextEditingController(text: 'MAC_1, MAC_2, MAC_3');
  final _itemId = TextEditingController(text: '1');
  final _uuid = TextEditingController(text: '12345');

  @override
  void dispose() {
    _intake.dispose();
    _exhaust.dispose();
    _shelves.dispose();
    _itemId.dispose();
    _uuid.dispose();
    super.dispose();
  }

  Map<String, dynamic> _espPayload() => {
        'doors': _doors,
        'hatch': _hatch,
        'temp_c': _temp.round(),
        'intake_rpm': int.tryParse(_intake.text) ?? 0,
        'exhaust_rmp': int.tryParse(_exhaust.text) ?? 0,
        'shelf_ids': _shelves.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      };

  // Each write is a fresh object so the ValueNotifier always fires, exactly
  // like a new inbound serial packet.
  void _sendEsp() => SerialService().espState.value = _espPayload();

  void _quickDoors(bool closed) {
    setState(() => _doors = closed);
    SerialService().espState.value = _espPayload();
  }

  void _sendJetson(int sign) {
    SerialService().jetsonState.value = {
      'id': int.tryParse(_itemId.text) ?? 0,
      'quantity': sign * _qty.abs(),
    };
  }

  void _scanCard() {
    final uuid = int.tryParse(_uuid.text) ?? 0;
    final bytes = Uint8List(8);
    ByteData.view(bytes.buffer).setUint32(0, uuid); // big-endian, matches welcome.dart
    SerialService().nfcState.value = bytes;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: [
        _sectionTitle('ESP · Enclosure'),
        Row(
          children: [
            _switchTile('Doors', _doors, (v) => setState(() => _doors = v)),
            const SizedBox(width: 12),
            _switchTile('Hatch', _hatch, (v) => setState(() => _hatch = v)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(width: 62, child: Text('Temp °C', style: _labelStyle)),
            Expanded(
              child: Slider(
                min: 0,
                max: 90,
                value: _temp,
                activeColor: _accent,
                onChanged: (v) => setState(() => _temp = v),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text('${_temp.round()}',
                  textAlign: TextAlign.right, style: _labelStyle),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _field('Intake', _intake, number: true)),
            const SizedBox(width: 10),
            Expanded(child: _field('Exhaust', _exhaust, number: true)),
          ],
        ),
        const SizedBox(height: 10),
        _field('Shelves', _shelves),
        const SizedBox(height: 12),
        _button('Send ESP State', _accent, _sendEsp),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _button('Doors Open', _panel2, () => _quickDoors(false))),
            const SizedBox(width: 8),
            Expanded(child: _button('Close → Checkout', _amber, () => _quickDoors(true))),
          ],
        ),
        const _Hint('The app only reacts to doors closing, and only on the Cart '
            'page — Scan Card first, then Close → Checkout.'),

        const SizedBox(height: 22),
        _sectionTitle('Jetson · Cart'),
        _field('Item ID', _itemId, number: true),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: 62, child: Text('Quantity', style: _labelStyle)),
            _stepButton('−', () => setState(() => _qty = (_qty - 1).clamp(1, 999))),
            SizedBox(
              width: 42,
              child: Text('$_qty', textAlign: TextAlign.center, style: _labelStyle),
            ),
            _stepButton('+', () => setState(() => _qty = (_qty + 1).clamp(1, 999))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _button('Add Item', _green, () => _sendJetson(1))),
            const SizedBox(width: 8),
            Expanded(child: _button('Remove Item', _amber, () => _sendJetson(-1))),
          ],
        ),
        const _Hint('Fetches the item from the API by ID — use a valid product ID.'),

        const SizedBox(height: 22),
        _sectionTitle('NFC · Login'),
        Row(
          children: [
            Expanded(child: _field('UUID', _uuid, number: true)),
            const SizedBox(width: 8),
            _button('Scan Card', _accent, _scanCard),
          ],
        ),
        const _Hint('Simulates a card tap → welcome-page login for this UUID.'),
      ],
    );
  }

  // --- small styling helpers ---

  static const _labelStyle = TextStyle(color: _muted, fontSize: 12);

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          t.toUpperCase(),
          style: const TextStyle(
              color: _muted, fontSize: 11, letterSpacing: 0.6, fontWeight: FontWeight.w700),
        ),
      );

  Widget _field(String label, TextEditingController c, {bool number = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: TextField(
            controller: c,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: _text, fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: _panel2,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: _accent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _panel2,
            border: Border.all(color: value ? _accent : _border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: _text, fontSize: 13)),
              Icon(value ? Icons.toggle_on : Icons.toggle_off,
                  color: value ? _accent : _muted, size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _panel2,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(color: _text, fontSize: 18)),
      ),
    );
  }

  Widget _button(String label, Color color, VoidCallback onTap) {
    final bool light = color == _amber || color == _green;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: light ? const Color(0xFF10130A) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: const TextStyle(color: _muted, fontSize: 11, height: 1.35),
      ),
    );
  }
}
