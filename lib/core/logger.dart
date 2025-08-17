import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final Logger log = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.dateAndTime,
  ),
  level: kDebugMode ? Level.debug : Level.warning,
);

class AppLogger {
  static void debug(String message) {
    log.d(message);
  }

  static void info(String message) {
    log.i(message);
  }

  static void warning(String message) {
    log.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    log.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    log.f(message, error: error, stackTrace: stackTrace);
  }
}
