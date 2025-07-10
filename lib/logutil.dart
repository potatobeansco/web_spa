library;

import 'dart:js_interop';
import 'package:web/web.dart';

class Log {
  static void debug(Object? arg) {
    console.debug(arg?.toString().toJS);
  }

  static void info(Object? arg) {
    console.info(arg?.toString().toJS);
  }

  static void warn(Object? arg) {
    console.warn(arg?.toString().toJS);
  }

  static void error(Object? arg) {
    console.error(arg?.toString().toJS);
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