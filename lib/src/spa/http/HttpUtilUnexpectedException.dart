part of '../../../spa.dart';

class HttpUtilUnexpectedException implements Exception {
  HttpUtilResponse response;

  HttpUtilUnexpectedException(this.response);

  @override
  String toString() {
    return 'Unexpected response, received status code ${response.statusCode}';
  }
}