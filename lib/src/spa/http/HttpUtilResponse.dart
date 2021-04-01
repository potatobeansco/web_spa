part of spa;

class HttpUtilResponse {
  int? statusCode;
  dynamic body;
  String? contentType;

  HttpUtilResponse(this.statusCode, this.body, this.contentType);

  Map<String, dynamic> asJson() {
    if (body is String) {
      return json.decode(body);
    }

    try {
      Map<dynamic, dynamic> temp = body;
      return { for (var e in temp.entries) e.key.toString() : e.value };
    } catch (e) {
      throw FormatException('body cannot be casted as Map<String, dynamic> (JSON map), type is: ${body.runtimeType}');
    }
  }

  List<dynamic> asJsonList() {
    if (body is String) {
      return json.decode(body);
    }

    try {
      List<dynamic> temp = body;
      return temp;
    } catch (e) {
      throw FormatException('body cannot be casted as List<dynamic> (JSON list), type is: ${body.runtimeType}');
    }
  }
}