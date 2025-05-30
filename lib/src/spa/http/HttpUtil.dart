part of '../../../spa.dart';

typedef OnProgressFunc = void Function(int? loaded, int? total);

class HttpUtil {
  static const headerAcceptJson = {'Accept': 'application/json'};
  @Deprecated('renamed to headerContentTypeJson')
  static const headerTypeJson = {'Content-Type': 'application/json'};
  static const headerContentTypeJson = {'Content-Type': 'application/json'};

  static Future<HttpUtilResponse> head(String url, {List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, http.Client? client}) async {
    var req = http.Request('HEAD', Uri.parse(url));
    req.headers.addAll(requestHeaders);

    var c = client ?? http.Client();
    var resp = await c.send(req);
    var total = int.tryParse(resp.headers['Content-Length'] ?? '');
    if (!expectedStatusCodes.contains(resp.statusCode)) {
      throw HttpUtilUnexpectedException(HttpUtilResponse(resp.statusCode, utf8.decode(await resp.stream.toBytes(), allowMalformed: true), resp.headers['Content-Type'], total));
    }

    return HttpUtilResponse(resp.statusCode, null, resp.headers['Content-Type'], total);
  }

  static Future<HttpUtilResponse> get(String url, {List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, bool returnResponseAsBytes = false, OnProgressFunc? onProgress, http.Client? client}) async {
    var req = http.Request('GET', Uri.parse(url));
    req.headers.addAll(requestHeaders);

    var c = client ?? http.Client();
    var resp = await c.send(req);
    var total = int.tryParse(resp.headers['Content-Length'] ?? '');
    if (!expectedStatusCodes.contains(resp.statusCode)) {
      throw HttpUtilUnexpectedException(HttpUtilResponse(resp.statusCode, utf8.decode(await resp.stream.toBytes(), allowMalformed: true), resp.headers['Content-Type'], total));
    }

    int loaded = 0;
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
    var subs = resp.stream.listen((chunk) {
        sink.add(chunk);
        if (onProgress != null) {
          loaded += chunk.length;
          onProgress(loaded, total);
        }
      },
      onError: completer.completeError,
      onDone: sink.close,
      cancelOnError: true
    );
    var bytes = await completer.future;
    await subs.cancel();
    
    if (returnResponseAsBytes) {
      return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total); 
    }
    
    return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
  }

  static Future<HttpUtilResponse> post(String url, {String? body, List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, bool returnResponseAsBytes = false, OnProgressFunc? onProgress, OnProgressFunc? uploadOnProgress, http.Client? client}) async {
    var req = http.Request('POST', Uri.parse(url));
    req.headers.addAll(requestHeaders);
    if (body != null) req.body = body;

    var c = client ?? http.Client();
    var resp = await c.send(req);
    var total = int.tryParse(resp.headers['Content-Length'] ?? '');
    if (!expectedStatusCodes.contains(resp.statusCode)) {
      throw HttpUtilUnexpectedException(HttpUtilResponse(resp.statusCode, utf8.decode(await resp.stream.toBytes(), allowMalformed: true), resp.headers['Content-Type'], total));
    }

    int loaded = 0;
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
    var subs = resp.stream.listen((chunk) {
      sink.add(chunk);
      if (onProgress != null) {
        loaded += chunk.length;
        onProgress(loaded, total);
      }
    },
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true
    );
    var bytes = await completer.future;
    await subs.cancel();

    if (returnResponseAsBytes) {
      return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total);
    }
    
    return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
  }

  static Future<HttpUtilResponse> patch(String url, {String? body, List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, bool returnResponseAsBytes = false, OnProgressFunc? onProgress, OnProgressFunc? uploadOnProgress, http.Client? client}) async {
    var req = http.Request('PATCH', Uri.parse(url));
    req.headers.addAll(requestHeaders);
    if (body != null) req.body = body;

    var c = client ?? http.Client();
    var resp = await c.send(req);
    var total = int.tryParse(resp.headers['Content-Length'] ?? '');
    if (!expectedStatusCodes.contains(resp.statusCode)) {
      throw HttpUtilUnexpectedException(HttpUtilResponse(resp.statusCode, utf8.decode(await resp.stream.toBytes(), allowMalformed: true), resp.headers['Content-Type'], total));
    }

    int loaded = 0;
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
    var subs = resp.stream.listen((chunk) {
      sink.add(chunk);
      if (onProgress != null) {
        loaded += chunk.length;
        onProgress(loaded, total);
      }
    },
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true
    );
    var bytes = await completer.future;
    await subs.cancel();

    if (returnResponseAsBytes) {
      return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total);
    }
    
    return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
  }

  static Future<HttpUtilResponse> postFormData(String url, Map<String, String> fields, Map<String, File> files, {List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, bool returnResponseAsBytes = false, OnProgressFunc? onProgress, OnProgressFunc? uploadOnProgress, http.Client? client}) async {
    var mFiles = <http.MultipartFile>[];

    for (var f in files.entries) {
      var k = f.key;
      var v = f.value;
      var data = (await f.value.arrayBuffer().toDart);
      var mf = http.MultipartFile.fromBytes(k, data.toDart.asUint8List(), filename: v.name, contentType: http_parser.MediaType.parse(v.type));
      mFiles.add(mf);
  }

    var req = http.MultipartRequest('POST', Uri.parse(url))
      ..fields.addAll(fields)
      ..files.addAll(mFiles)
      ..headers.addAll(requestHeaders);

    var c = client ?? http.Client();
    var resp = await c.send(req);
    var total = int.tryParse(resp.headers['Content-Length'] ?? '');
    if (!expectedStatusCodes.contains(resp.statusCode)) {
      throw HttpUtilUnexpectedException(HttpUtilResponse(resp.statusCode, utf8.decode(await resp.stream.toBytes(), allowMalformed: true), resp.headers['Content-Type'], total));
    }

    int loaded = 0;
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
    var subs = resp.stream.listen((chunk) {
      sink.add(chunk);
      if (onProgress != null) {
        loaded += chunk.length;
        onProgress(loaded, total);
      }
    },
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true
    );
    var bytes = await completer.future;
    await subs.cancel();

    if (returnResponseAsBytes) {
      return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total);
    }
    
    return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
  }

  static Future<HttpUtilResponse> put(String url, {String? body, List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, bool returnResponseAsBytes = false, OnProgressFunc? onProgress, OnProgressFunc? uploadOnProgress, http.Client? client}) async {
    var req = http.Request('PUT', Uri.parse(url));
    req.headers.addAll(requestHeaders);
    if (body != null) req.body = body;

    var c = client ?? http.Client();
    var resp = await c.send(req);
    var total = int.tryParse(resp.headers['Content-Length'] ?? '');
    if (!expectedStatusCodes.contains(resp.statusCode)) {
      throw HttpUtilUnexpectedException(HttpUtilResponse(resp.statusCode, utf8.decode(await resp.stream.toBytes(), allowMalformed: true), resp.headers['Content-Type'], total));
    }

    int loaded = 0;
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
    var subs = resp.stream.listen((chunk) {
      sink.add(chunk);
      if (onProgress != null) {
        loaded += chunk.length;
        onProgress(loaded, total);
      }
    },
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true
    );
    var bytes = await completer.future;
    await subs.cancel();

    if (returnResponseAsBytes) {
      return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total);
    }
    
    return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
  }

  static Future<HttpUtilResponse> delete(String url, {List<int> expectedStatusCodes = const [200], Map<String, String> requestHeaders = const {}, bool returnResponseAsBytes = false, OnProgressFunc? onProgress, http.Client? client}) async {
    var req = http.Request('DELETE', Uri.parse(url));
    req.headers.addAll(requestHeaders);

    var c = client ?? http.Client();
    var resp = await c.send(req);
    var total = int.tryParse(resp.headers['Content-Length'] ?? '');
    if (!expectedStatusCodes.contains(resp.statusCode)) {
      throw HttpUtilUnexpectedException(HttpUtilResponse(resp.statusCode, utf8.decode(await resp.stream.toBytes(), allowMalformed: true), resp.headers['Content-Type'], total));
    }

    int loaded = 0;
    var completer = Completer<Uint8List>();
    var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
    var subs = resp.stream.listen((chunk) {
      sink.add(chunk);
      if (onProgress != null) {
        loaded += chunk.length;
        onProgress(loaded, total);
      }
    },
        onError: completer.completeError,
        onDone: sink.close,
        cancelOnError: true
    );
    var bytes = await completer.future;
    await subs.cancel();

    if (returnResponseAsBytes) {
      return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total);
    }
    
    return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
  }
}