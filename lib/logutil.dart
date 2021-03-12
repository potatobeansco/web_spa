import 'dart:html';

class Log {
  static void debug(Object? arg) {
    window.console.debug(arg);
  }

  static void info(Object? arg) {
    window.console.info(arg);
  }

  static void warn(Object? arg) {
    window.console.warn(arg);
  }

  static void error(Object? arg) {
    window.console.error(arg);
  }
}

mixin MLogging {
  String get className;

  void logDebug(Object? arg) {
    Log.debug('[$className] $arg');
  }

  void logInfo(Object? arg) {
    Log.info('[$className] $arg');
  }

  void logWarn(Object? arg) {
    Log.warn('[$className] $arg');
  }

  void logError(Object? arg) {
    Log.error('[$className] $arg');
  }
}