part of '../../../spa.dart';

@Deprecated('This exception is too generic and is no longer thrown since using package:http')
class HttpUtilConnectionException implements Exception {
  final bool? lengthComputable;
  final int? loaded;
  final int? total;

  const HttpUtilConnectionException(this.lengthComputable, {this.loaded, this.total});

  @override
  String toString() {
    return 'Connection error (XHR threw onError event)';
  }
}