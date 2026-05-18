import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Central logger for outbound API traffic.
///
/// Uses both [developer.log] (for IDE / DevTools panes) and [print] (for
/// `flutter run` stdout and `adb logcat`) so a request/response shows up
/// regardless of how the app is being observed. Silent in release.
class ApiLogger {
  static const _name = 'API';

  static bool get _on => kDebugMode;

  static void req(String method, Object url, {Object? body}) {
    if (!_on) return;
    final bodyPart = body == null ? '' : ' body=${_preview(body.toString(), 300)}';
    _emit('→ $method $url$bodyPart');
  }

  static void res(String method, Object url, int status, String body) {
    if (!_on) return;
    _emit('← $method $url status=$status body=${_preview(body, 500)}');
  }

  static void err(String method, Object url, Object error, [StackTrace? stack]) {
    if (!_on) return;
    final line = '✕ $method $url error=$error';
    developer.log(line, name: _name, error: error, stackTrace: stack);
    // ignore: avoid_print
    print('[API] $line');
    if (stack != null) {
      // ignore: avoid_print
      print(stack);
    }
  }

  static void info(String message) {
    if (!_on) return;
    _emit(message);
  }

  static void _emit(String line) {
    developer.log(line, name: _name);
    // ignore: avoid_print
    print('[API] $line');
  }

  static String _preview(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…(+${s.length - max} chars)';
  }
}
