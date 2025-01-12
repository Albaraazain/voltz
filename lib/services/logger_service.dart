import 'package:flutter/foundation.dart';

class LoggerService {
  static void debug(String message) {
    if (kDebugMode) {
      print('DEBUG: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('INFO: $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('ERROR: $message');
      if (error != null) {
        print('Error details: $error');
      }
      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    }
  }
}
