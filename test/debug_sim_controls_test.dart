import 'dart:typed_data';

import 'package:bits_n_bytes_ui/components/debug_log_overlay.dart';
import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // SerialService reads dotenv at construction (SIM_CONNECTIONS), and
  // `useSimulator` below touches it — so dotenv must be loaded first or the
  // whole file fails to load with NotInitializedError. Force the simulator on
  // so the Sim controls exist to test.
  dotenv.loadFromString(envString: 'SIM_CONNECTIONS=true');

  // The Sim section only exists when the simulator backend is active.
  final bool sim = SerialService.useSimulator;

  Future<void> openPanel(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DebugLogOverlay(child: const Scaffold(body: SizedBox.expand())),
      ),
    );
    await tester.tap(find.byIcon(Icons.bug_report_outlined));
    await tester.pumpAndSettle();
  }

  testWidgets('Sim tab and controls render when the simulator is active',
      (tester) async {
    if (!sim) return;
    await openPanel(tester);

    expect(find.text('Sim'), findsOneWidget);
    expect(find.text('Send ESP State'), findsOneWidget);
  });

  testWidgets('Close → Checkout pushes doors:true onto espState',
      (tester) async {
    if (!sim) return;
    await openPanel(tester);

    await tester.tap(find.text('Close → Checkout'));
    await tester.pump();

    expect(SerialService().espState.value?['doors'], true);
  });

  testWidgets('Scan Card writes a decodable UUID packet to nfcState',
      (tester) async {
    if (!sim) return;
    await openPanel(tester);

    await tester.dragUntilVisible(
      find.text('Scan Card'),
      find.byType(ListView),
      const Offset(0, -150),
    );
    await tester.tap(find.text('Scan Card'));
    await tester.pump();

    final Uint8List? packet = SerialService().nfcState.value;
    expect(packet, isNotNull);
    expect(ByteData.view(packet!.buffer).getUint32(0), 12345);
  });
}
