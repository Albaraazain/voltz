import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
      noBoxingByDefault: true,
    ),
    level: Level.debug,
    output: ConsoleOutput(),
  );

  static void debug(String message) {
    _logger.d('🔍 $message');
    if (kDebugMode) print('DEBUG: 🔍 $message');
  }

  static void info(String message) {
    _logger.i('ℹ️ $message');
    if (kDebugMode) print('INFO: ℹ️ $message');
  }

  static void warning(String message) {
    _logger.w('⚠️ $message');
    if (kDebugMode) print('WARNING: ⚠️ $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('❌ $message', error: error, stackTrace: stackTrace);
    if (kDebugMode) print('ERROR: ❌ $message');
    if (error != null && kDebugMode) print('Error details: $error');
    if (stackTrace != null && kDebugMode) print('Stack trace: $stackTrace');
  }

  static void testLogging() {
    debug('Test debug message');
    info('Test info message');
    warning('Test warning message');
    error('Test error message');
  }
}
