import 'dart:async' show Zone;
import 'dart:developer' as dev;
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Drop-in replacement for dart:developer's log().
/// Writes every entry both to the debug console and to a daily log file
/// in the app's documents directory (checkme_YYYY-MM-DD.log).
class AppLogger {
  static File? _logFile;

  /// Call once in main() before runApp().
  static Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      _logFile = File('${dir.path}/checkme_$date.log');
    } catch (e) {
      dev.log('AppLogger.initialize failed: $e', name: 'AppLogger');
    }
  }

  static void log(
    String message, {
    DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String name = '',
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
    _writeToFile(message, name: name, error: error, stackTrace: stackTrace);
  }

  static void _writeToFile(
    String message, {
    String name = '',
    Object? error,
    StackTrace? stackTrace,
  }) {
    final file = _logFile;
    if (file == null) return;
    try {
      final ts = DateTime.now().toIso8601String();
      final tag = name.isNotEmpty ? '[$name] ' : '';
      final buf = StringBuffer('$ts $tag$message\n');
      if (error != null) buf.write('  ERROR: $error\n');
      if (stackTrace != null) buf.write('  STACK: $stackTrace\n');
      file.writeAsStringSync(buf.toString(), mode: FileMode.append);
    } catch (_) {
      // Never let logging crash the app.
    }
  }
}

/// Top-level function – identical signature to dart:developer log().
/// Import this file instead of dart:developer to get file logging for free.
void log(
  String message, {
  DateTime? time,
  int? sequenceNumber,
  int level = 0,
  String name = '',
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
}) =>
    AppLogger.log(
      message,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: name,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
