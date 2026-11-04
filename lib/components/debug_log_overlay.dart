import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';

// Status colors are semantic (RX/TX ok / warn), not part of the app palette.
const _green = Color(0xFF35C66B);
const _amber = Color(0xFFF2B53D);

/// Panel chrome colors pulled from the app theme (see theme.dart), so the
/// overlay tracks the same scheme as the rest of the app. Resolved per build
/// via [Theme.of]; each State stores it in `_c`.
class _DebugColors {
  final Color bg, bar, panel2, border, muted, accent, text;
  const _DebugColors._({
    required this.bg,
    required this.bar,
    required this.panel2,
    required this.border,
    required this.muted,
    required this.accent,
    required this.text,
  });

  factory _DebugColors.of(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _DebugColors._(
      bg: cs.surface,
      bar: cs.surfaceContainer,
      panel2: cs.surfaceContainerHigh,
      border: cs.outlineVariant,
      muted: cs.onSurfaceVariant,
      accent: cs.secondary,
      text: cs.onSurface,
    );
  }
}

/// A debug-only log + simulator sidebar that floats over every screen.
///
/// Wire it in via `MaterialApp.builder` so it sits above the Navigator and is
/// visible on any route. In non-debug builds it is a transparent passthrough,
/// so it is safe to leave wired in for release.
class DebugLogOverlay extends StatefulWidget {
  final Widget child;
  const DebugLogOverlay({super.key, required this.child});

  /// Global switch to show the overlay outside debug builds. Flipped from the
  /// admin Debug tab so an operator can pull up the sim/log sidebar on the
  /// deployed kiosk. In debug builds the overlay shows regardless of this flag.
  static final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);

  @override
  State<DebugLogOverlay> createState() => _DebugLogOverlayState();
}

class _DebugLogOverlayState extends State<DebugLogOverlay> {
  static const double _panelWidth = 360;

  bool _open = false;
  late _DebugColors _c;

  @override
  Widget build(BuildContext context) {
    // Rebuild when an operator flips the enable flag from the admin Debug tab.
    return ValueListenableBuilder<bool>(
      valueListenable: DebugLogOverlay.enabled,
      builder: (context, enabled, _) {
        // Debug builds always show the overlay; release/profile builds show it
        // only once enabled from the admin Debug tab. Otherwise pass through.
        if (!kDebugMode && !enabled) return widget.child;
        return _buildOverlay(context);
      },
    );
  }

  Widget _buildOverlay(BuildContext context) {
    _c = _DebugColors.of(context);
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
                builder: (_) =>
                    _DebugPanel(onClose: () => setState(() => _open = false)),
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
            color: _c.bar,
            border: Border.all(color: _c.border),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(10),
            ),
          ),
          child: Icon(
            _open ? Icons.chevron_right : Icons.bug_report_outlined,
            color: _open ? _c.muted : _c.accent,
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

  // Data-tab stream filter. Lines are tagged (RX ESP / TX NFC / …) so a simple
  // substring match isolates one stream from the ESP firehose.
  String _dataFilter = 'All';
  static const List<String> _dataFilters = ['All', 'ESP', 'JETSON', 'NFC'];
  late _DebugColors _c;

  // "Sim" injects fake inbound ESP/Jetson/NFC state via the state notifiers.
  // Available in both modes: on real hardware it's a way to push test state
  // (it holds until the next real packet overwrites the notifier).
  List<String> get _tabs => ['Sim', 'Send', 'Events', 'Data'];

  @override
  Widget build(BuildContext context) {
    _c = _DebugColors.of(context);
    final tabs = _tabs;
    final int tab = _tab.clamp(0, tabs.length - 1);
    final String label = tabs[tab];

    return Material(
      color: _c.bg,
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
      decoration: BoxDecoration(
        color: _c.bar,
        border: Border(bottom: BorderSide(color: _c.border)),
      ),
      child: Row(
        children: [
          Icon(Icons.terminal, size: 16, color: _c.muted),
          const SizedBox(width: 8),
          Text(
            'Debug',
            style: TextStyle(
              color: _c.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Mirrors the admin "Debug / Sim Sidebar" option: flipping this drives
          // DebugLogOverlay.enabled, so the sidebar and the admin toggle stay in
          // sync. (In debug builds the sidebar stays visible regardless.)
          ValueListenableBuilder<bool>(
            valueListenable: DebugLogOverlay.enabled,
            builder: (context, on, _) => Switch(
              value: on,
              activeThumbColor: _c.accent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => DebugLogOverlay.enabled.value = v,
            ),
          ),
          if (label == 'Events' || label == 'Data')
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: _c.muted),
              onPressed: () {
                (label == 'Events' ? LogService.eventLogs : LogService.dataLogs)
                        .value =
                    [];
              },
            ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: _c.muted),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(List<String> tabs, int selected) {
    return Container(
      color: _c.bar,
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
            color: isSelected
                ? _c.accent.withValues(alpha: 0.18)
                : Colors.transparent,
            border: Border.all(color: isSelected ? _c.accent : _c.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? _c.text : _c.muted,
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
      case 'Send':
        return const _SendControls();
      case 'Data':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStreamFilter(),
            Expanded(
              child: _buildLogList(
                LogService.dataLogs,
                _green,
                filter: _dataFilter,
              ),
            ),
          ],
        );
      case 'Events':
      default:
        return _buildLogList(LogService.eventLogs, _c.text);
    }
  }

  /// Per-stream filter chips for the Data tab (All / ESP / JETSON / NFC).
  Widget _buildStreamFilter() {
    return Container(
      color: _c.bar,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        children: [
          for (int i = 0; i < _dataFilters.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(child: _filterChip(_dataFilters[i])),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String name) {
    final bool isSelected = _dataFilter == name;
    return GestureDetector(
      onTap: () => setState(() => _dataFilter = name),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? _green.withValues(alpha: 0.18)
              : Colors.transparent,
          border: Border.all(color: isSelected ? _green : _c.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? _c.text : _c.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLogList(
    ValueNotifier<List<String>> notifier,
    Color lineColor, {
    String filter = 'All',
  }) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: notifier,
      builder: (context, allLogs, _) {
        final logs = filter == 'All'
            ? allLogs
            : allLogs.where((l) => l.contains(filter)).toList();
        if (logs.isEmpty) {
          return Center(
            child: Text(
              filter == 'All' ? 'No logs yet.' : 'No $filter logs yet.',
              style: TextStyle(
                color: _c.muted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
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
  late _DebugColors _c;

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
    // shelf_ids is a list of objects (see ShelfData); default each to the
    // right-hand position for sim purposes.
    'shelf_ids': _shelves.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((mac) => {'mac_address': mac, 'position': 'right'})
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
    ByteData.view(
      bytes.buffer,
    ).setUint32(0, uuid); // big-endian, matches welcome.dart
    SerialService().nfcState.value = bytes;
  }

  @override
  Widget build(BuildContext context) {
    _c = _DebugColors.of(context);
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
            SizedBox(
              width: 62,
              child: Text('Temp °C', style: _labelStyle),
            ),
            Expanded(
              child: Slider(
                min: 0,
                max: 90,
                value: _temp,
                activeColor: _c.accent,
                onChanged: (v) => setState(() => _temp = v),
              ),
            ),
            SizedBox(
              width: 30,
              child: Text(
                '${_temp.round()}',
                textAlign: TextAlign.right,
                style: _labelStyle,
              ),
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
        _button('Send ESP State', _c.accent, _sendEsp),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _button('Doors Open', _c.panel2, () => _quickDoors(false)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _button(
                'Close → Checkout',
                _amber,
                () => _quickDoors(true),
              ),
            ),
          ],
        ),
        const _Hint(
          'The app only reacts to doors closing, and only on the Cart '
          'page — Scan Card first, then Close → Checkout.',
        ),

        const SizedBox(height: 22),
        _sectionTitle('Jetson · Cart'),
        _field('Item ID', _itemId, number: true),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 62,
              child: Text('Quantity', style: _labelStyle),
            ),
            _stepButton(
              '−',
              () => setState(() => _qty = (_qty - 1).clamp(1, 999)),
            ),
            SizedBox(
              width: 42,
              child: Text(
                '$_qty',
                textAlign: TextAlign.center,
                style: _labelStyle,
              ),
            ),
            _stepButton(
              '+',
              () => setState(() => _qty = (_qty + 1).clamp(1, 999)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _button('Add Item', _green, () => _sendJetson(1))),
            const SizedBox(width: 8),
            Expanded(
              child: _button('Remove Item', _amber, () => _sendJetson(-1)),
            ),
          ],
        ),
        const _Hint(
          'Fetches the item from the API by ID — use a valid product ID.',
        ),

        const SizedBox(height: 22),
        _sectionTitle('NFC · Login'),
        Row(
          children: [
            Expanded(child: _field('UUID', _uuid, number: true)),
            const SizedBox(width: 8),
            _button('Scan Card', _c.accent, _scanCard),
          ],
        ),
        const _Hint('Simulates a card tap → welcome-page login for this UUID.'),
      ],
    );
  }

  // --- small styling helpers ---

  TextStyle get _labelStyle => TextStyle(color: _c.muted, fontSize: 12);

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      t.toUpperCase(),
      style: TextStyle(
        color: _c.muted,
        fontSize: 11,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w700,
      ),
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
            style: TextStyle(color: _c.text, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              filled: true,
              fillColor: _c.panel2,
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: _c.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: _c.accent),
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
            color: _c.panel2,
            border: Border.all(color: value ? _c.accent : _c.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: _c.text, fontSize: 13)),
              Icon(
                value ? Icons.toggle_on : Icons.toggle_off,
                color: value ? _c.accent : _c.muted,
                size: 26,
              ),
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
          color: _c.panel2,
          border: Border.all(color: _c.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: _c.text, fontSize: 18)),
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
    final c = _DebugColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(color: c.muted, fontSize: 11, height: 1.35),
      ),
    );
  }
}

/// Manual TX console — send JSON or raw hex to ESP / JETSON / NFC on demand.
/// Handy for poking a device (e.g. re-arming the NFC reader) without navigating.
class _SendControls extends StatefulWidget {
  const _SendControls();

  @override
  State<_SendControls> createState() => _SendControlsState();
}

class _SendControlsState extends State<_SendControls> {
  static const List<String> _targets = ['ESP', 'JETSON', 'NFC'];

  late _DebugColors _c;
  final SerialService _serial = SerialService();
  String _target = 'ESP';
  bool _asHex = false; // false = JSON object, true = raw hex bytes
  final TextEditingController _payload = TextEditingController(
    text: '{"doors": true, "hatch": false}',
  );
  String _result = '';
  bool _ok = true;

  String get _port {
    switch (_target) {
      case 'NFC':
        return SerialService.portNFC;
      case 'JETSON':
        return SerialService.portJetson;
      default:
        return SerialService.portESP;
    }
  }

  void _pickTarget(String t) {
    setState(() {
      _target = t;
      _asHex = t == 'NFC';
      _payload.text = _asHex
          ? 'ff 00 00 00 00 00 00 00'
          : '{"doors": true, "hatch": false}';
    });
  }

  void _setResult(bool ok, String msg) => setState(() {
    _ok = ok;
    _result = msg;
  });

  void _send() {
    final text = _payload.text.trim();
    try {
      if (_asHex) {
        final bytes = Uint8List.fromList(
          text
              .split(RegExp(r'[\s,]+'))
              .where((s) => s.isNotEmpty)
              .map((s) => int.parse(s, radix: 16))
              .toList(),
        );
        _serial.sendBinaryTo(_port, bytes);
        _setResult(true, 'Sent ${bytes.length} byte(s) to $_target');
      } else {
        final obj = jsonDecode(text);
        if (obj is! Map<String, dynamic>) {
          _setResult(false, 'JSON must be an object like {"key": value}');
          return;
        }
        _serial.sendJsonTo(_port, obj);
        _setResult(true, 'Sent JSON to $_target');
      }
    } catch (e) {
      _setResult(false, 'Error: $e');
    }
  }

  @override
  void dispose() {
    _payload.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _c = _DebugColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Target port',
            style: TextStyle(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (int i = 0; i < _targets.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _chip(
                    _targets[i],
                    _target == _targets[i],
                    () => _pickTarget(_targets[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Format',
                style: TextStyle(
                  color: _c.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              _chip('JSON', !_asHex, () => setState(() => _asHex = false)),
              const SizedBox(width: 6),
              _chip('HEX', _asHex, () => setState(() => _asHex = true)),
              const Spacer(),
              Text(
                _port,
                style: TextStyle(
                  color: _c.muted,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _payload,
            maxLines: 3,
            minLines: 1,
            style: TextStyle(
              color: _c.text,
              fontSize: 12.5,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: _asHex ? 'ff 00 1a 2b ...' : '{"doors": true}',
              hintStyle: TextStyle(color: _c.muted),
              filled: true,
              fillColor: _c.panel2,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _c.border),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: _c.accent),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _send,
              icon: const Icon(Icons.send, size: 16),
              label: Text('Send to $_target'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _c.accent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quick commands',
            style: TextStyle(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _preset('Open doors', () => _serial.openDoors()),
              _preset('Open hatch', () => _serial.openHatch()),
              _preset('Clear cart', () => _serial.clearCart()),
              _preset(
                'Arm NFC',
                () => _serial.sendBinaryTo(
                  SerialService.portNFC,
                  Uint8List.fromList([0xFF, 0, 0, 0, 0, 0, 0, 0]),
                ),
              ),
            ],
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              _result,
              style: TextStyle(color: _ok ? _green : _amber, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? _c.accent.withValues(alpha: 0.18)
              : Colors.transparent,
          border: Border.all(color: selected ? _c.accent : _c.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _c.text : _c.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _preset(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        _setResult(true, 'Sent: $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: _c.panel2,
          border: Border.all(color: _c.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(color: _c.text, fontSize: 11.5),
        ),
      ),
    );
  }
}
