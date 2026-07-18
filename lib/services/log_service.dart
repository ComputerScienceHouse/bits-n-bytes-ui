import 'dart:developer';

import 'package:bits_n_bytes_ui/services/serial_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Log Service
/// Handles the logging of the current state of the Machine from the point of the PI.
class LogService {
  static final int logsLength = 100;

  /// Log Events (Connections, Fails, Page Transitions)
  static final ValueNotifier<List<String>> eventLogs = ValueNotifier([]);

  /// Logs CHANGES to Data in Receives and all Sends (UART, NFC).
  /// handled by this service
  static final ValueNotifier<List<String>> dataLogs = ValueNotifier([]);

  static Map<String, dynamic>? previousESPData;
  static Map<String, dynamic>? previousJetsonData;
  // static Map<String, dynamic>? previousNFCData;

  static void logToNotifier(ValueNotifier<List<String>> vn, String message) {
    final timestamp = DateTime.now().toString().split(' ').last.substring(0, 8);

    void apply() {
      final next = [...vn.value, "[$timestamp] $message"];
      if (next.length > logsLength) next.removeAt(0);
      vn.value = next;
    }

    // Logging often happens synchronously during a build (e.g. a ViewModel
    // constructor / initState side effect that sends serial + logs). Mutating
    // the notifier then wakes a listening ValueListenableBuilder (the debug
    // overlay) mid-build, causing setState-during-build and re-entrant rebuilds
    // (which surface as unrelated cast errors). Defer to after the frame.
    // In a pure-Dart context (e.g. unit tests) there is no binding, so
    // SchedulerBinding.instance throws. Treat "no binding" as "not mid-build"
    // and apply synchronously.
    SchedulerBinding? binding;
    try {
      binding = SchedulerBinding.instance;
    } catch (_) {
      binding = null;
    }
    if (binding != null &&
        binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }

    // Flutter Web Log
    log(message);
  }

  /// Logs Message to Event List
  static void logEvent(String message) {
    logToNotifier(eventLogs, message);
  }

  /// Logs Message to Data List
  static void logData(String message) {
    logToNotifier(dataLogs, message);
  }

  /// Parse the Previous and Current Json
  /// returning a list of messages for each change in key,value pairs
  static List<String> parseJsonChanges(Map<String, dynamic>? previous, Map<String, dynamic>? current) {
   List<String> changes = [];

    // If there is no new data, there are no changes
    if (current == null) return changes;

    // If previous is null, treat everything in current as a new change
    final prev = previous ?? {};

    current.forEach((key, newValue) {
      final oldValue = prev[key];

      // Compare by value, not identity: Lists/Maps from jsonDecode are new
      // instances every packet, so `oldValue != newValue` reports "[] -> []"
      // on every frame. Comparing their string form treats equal contents as
      // unchanged and kills the spam.
      if ('$oldValue' != '$newValue') {
        changes.add('"$key": "$oldValue" -> "$newValue"');
      }
    });

    return changes; 
  }

  static bool _initialized = false;

  static void _onEspState() {
    final Map<String, dynamic>? currentJson = SerialService().espState.value;
    final List<String> messages = parseJsonChanges(previousESPData, currentJson);
    for (String message in messages) {
      if (message.contains("shelves")) continue; // Fix Annoying spam
      logData("ESP change: $message");
    }
    previousESPData = currentJson;
  }

  static void _onJetsonState() {
    final Map<String, dynamic>? currentJson = SerialService().jetsonState.value;
    final List<String> messages = parseJsonChanges(
      previousJetsonData,
      currentJson,
    );
    for (String message in messages) {
      logData("JETSON change: $message");
    }
    previousJetsonData = currentJson;
  }

  static void init() {
    // Idempotent: guard against re-registering the listeners (named handlers
    // mean a duplicate add would otherwise stack and double-log every packet).
    if (_initialized) return;
    _initialized = true;

    // Setup listeners for data updates from ESP and Jetson
    SerialService().espState.addListener(_onEspState);
    SerialService().jetsonState.addListener(_onJetsonState);
  }
}