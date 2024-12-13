library;

import 'dart:js_interop';
import 'package:web/web.dart';

class Log {
  static void debug(Object? arg) {
    console.debug(arg?.toJSBox);
  }

  static void info(Object? arg) {
    console.info(arg?.toJSBox);
  }

  static void warn(Object? arg) {
    console.warn(arg?.toJSBox);
  }

  static void error(Object? arg) {
    console.error(arg?.toJSBox);
  }
}

mixin MLogging {
  String get className;

  void logDebug(Object? arg) {
    Log.debug('[$className] $arg'.toJS);
  }

  void logInfo(Object? arg) {
    Log.info('[$className] $arg'.toJS);
  }

  void logWarn(Object? arg) {
    Log.warn('[$className] $arg'.toJS);
  }

  void logError(Object? arg) {
    Log.error('[$className] $arg'.toJS);
  }
}