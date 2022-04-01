part of spa;

class HttpUtilResponse {
  int? statusCode;
  Object? body;
  String? contentType;
  int? contentLength;

  HttpUtilResponse(this.statusCode, this.body, this.contentType, this.contentLength);

  Map<String, Object?> asJson() {
    if (body is String) {
      return json.decode(body as String);
    }

    try {
      var temp = body as Map<dynamic, dynamic>;
      return Map<String, Object?>.from(temp);
    } catch (e) {
      throw FormatException('body cannot be casted as Map<String, Object?> (JSON map), type is: ${body.runtimeType}');
    }
  }

  /// Returns a JSON array representation from response body.
  List<Object?> asJsonList() {
    if (body is String) {
      return json.decode(body as String);
    }

    try {
      var temp = body as List<dynamic>;
      return List<Object?>.from(temp);
    } catch (e) {
      throw FormatException('body cannot be casted as List<Object?> (JSON list), type is: ${body.runtimeType}');
    }
  }
}