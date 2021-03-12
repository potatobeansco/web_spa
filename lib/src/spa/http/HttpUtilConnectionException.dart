part of spa;

class HttpUtilConnectionException implements Exception {
  @override
  String toString() {
    return 'Connection error (XHR threw onError event)';
  }
}