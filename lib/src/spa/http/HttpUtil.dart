part of spa;

typedef OnProgressFunc = void Function(int? loaded, int? total);

class HttpUtil {
  static const HEADER_ACCEPT_JSON = {'Accept': 'application/json'};
  static const headerTypeJson = {'Content-Type': 'application/json'};

  static Future<HttpUtilResponse> get(String url, {List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, String responseType = '', OnProgressFunc? onProgress}) {
    var completer = Completer<HttpUtilResponse>();

    var req = HttpRequest();
    req.open('GET', url);
    req.responseType = responseType;

    requestHeaders.forEach((key, value) {
      req.setRequestHeader(key, value);
    });

    if (onProgress != null) {
      req.onProgress.listen((event) {
        onProgress(event.loaded, event.total);
      });
    }

    req.onLoad.listen((event) {
      var response = HttpUtilResponse(req.status, req.response, req.getResponseHeader('Content-Type'));
      if (expectedStatusCodes.contains(req.status)) {
        completer.complete(response);
      } else {
        completer.completeError(HttpUtilUnexpectedException(response));
      }
    });

    req.onError.listen((event) {
      completer.completeError(HttpUtilConnectionException());
    });

    req.send();
    return completer.future;
  }

  static Future<HttpUtilResponse> post(String url, {String? body, List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, String responseType = '', OnProgressFunc? onProgress, OnProgressFunc? uploadOnProgress}) {
    var completer = Completer<HttpUtilResponse>();

    var req = HttpRequest();
    req.open('POST', url);
    req.responseType = responseType;

    requestHeaders.forEach((key, value) {
      req.setRequestHeader(key, value);
    });

    if (onProgress != null) {
      req.onProgress.listen((event) {
        onProgress(event.loaded, event.total);
      });
    }

    if (uploadOnProgress != null) {
      req.upload.onProgress.listen((event) {
        uploadOnProgress(event.loaded, event.total);
      });
    }

    req.onLoad.listen((event) {
      var response = HttpUtilResponse(req.status, req.response, req.getResponseHeader('Content-Type'));
      if (expectedStatusCodes.contains(req.status)) {
        completer.complete(response);
      } else {
        completer.completeError(HttpUtilUnexpectedException(response));
      }
    });

    req.onError.listen((event) {
      completer.completeError(HttpUtilConnectionException());
    });

    req.send(body);
    return completer.future;
  }

  static Future<HttpUtilResponse> patch(String url, {String? body, List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, String responseType = '', OnProgressFunc? onProgress, OnProgressFunc? uploadOnProgress}) {
    var completer = Completer<HttpUtilResponse>();

    var req = HttpRequest();
    req.open('PATCH', url);
    req.responseType = responseType;

    requestHeaders.forEach((key, value) {
      req.setRequestHeader(key, value);
    });

    if (onProgress != null) {
      req.onProgress.listen((event) {
        onProgress(event.loaded, event.total);
      });
    }

    if (uploadOnProgress != null) {
      req.upload.onProgress.listen((event) {
        uploadOnProgress(event.loaded, event.total);
      });
    }

    req.onLoad.listen((event) {
      var response = HttpUtilResponse(req.status, req.response, req.getResponseHeader('Content-Type'));
      if (expectedStatusCodes.contains(req.status)) {
        completer.complete(response);
      } else {
        completer.completeError(HttpUtilUnexpectedException(response));
      }
    });

    req.onError.listen((event) {
      completer.completeError(HttpUtilConnectionException());
    });

    req.send(body);
    return completer.future;
  }

  static Future<HttpUtilResponse> postFormData(String url, FormData body, {List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, String responseType = '', OnProgressFunc? onProgress, OnProgressFunc? uploadOnProgress}) {
    var completer = Completer<HttpUtilResponse>();

    var req = HttpRequest();
    req.open('POST', url);
    req.responseType = responseType;

    requestHeaders.forEach((key, value) {
      req.setRequestHeader(key, value);
    });

    if (onProgress != null) {
      req.upload.onProgress.listen((event) {
        onProgress(event.loaded, event.total);
      });
    }

    if (uploadOnProgress != null) {
      req.upload.onProgress.listen((event) {
        uploadOnProgress(event.loaded, event.total);
      });
    }

    req.onLoad.listen((event) {
      var response = HttpUtilResponse(req.status, req.response, req.getResponseHeader('Content-Type'));
      if (expectedStatusCodes.contains(req.status)) {
        completer.complete(response);
      } else {
        completer.completeError(HttpUtilUnexpectedException(response));
      }
    });

    req.onError.listen((event) {
      completer.completeError(HttpUtilConnectionException());
    });

    req.send(body);
    return completer.future;
  }

  static Future<HttpUtilResponse> put(String url, {String? body, List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, String responseType = '', OnProgressFunc? onProgress, OnProgressFunc? uploadOnProgress}) {
    var completer = Completer<HttpUtilResponse>();

    var req = HttpRequest();
    req.open('PUT', url);
    req.responseType = responseType;

    requestHeaders.forEach((key, value) {
      req.setRequestHeader(key, value);
    });

    if (onProgress != null) {
      req.upload.onProgress.listen((event) {
        onProgress(event.loaded, event.total);
      });
    }

    if (uploadOnProgress != null) {
      req.upload.onProgress.listen((event) {
        uploadOnProgress(event.loaded, event.total);
      });
    }

    req.onLoad.listen((event) {
      var response = HttpUtilResponse(req.status, req.response, req.getResponseHeader('Content-Type'));
      if (expectedStatusCodes.contains(req.status)) {
        completer.complete(response);
      } else {
        completer.completeError(HttpUtilUnexpectedException(response));
      }
    });

    req.onError.listen((event) {
      completer.completeError(HttpUtilConnectionException());
    });

    req.send(body);
    return completer.future;
  }

  static Future<HttpUtilResponse> delete(String url, {List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, String responseType = '', OnProgressFunc? onProgress}) {
    var completer = Completer<HttpUtilResponse>();

    var req = HttpRequest();
    req.open('DELETE', url);
    req.responseType = responseType;

    requestHeaders.forEach((key, value) {
      req.setRequestHeader(key, value);
    });

    if (onProgress != null) {
      req.onProgress.listen((event) {
        onProgress(event.loaded, event.total);
      });
    }

    req.onLoad.listen((event) {
      var response = HttpUtilResponse(req.status, req.response, req.getResponseHeader('Content-Type'));
      if (expectedStatusCodes.contains(req.status)) {
        completer.complete(response);
      } else {
        completer.completeError(HttpUtilUnexpectedException(response));
      }
    });

    req.onError.listen((event) {
      completer.completeError(HttpUtilConnectionException());
    });

    req.send();
    return completer.future;
  }
}