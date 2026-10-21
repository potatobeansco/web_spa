part of '../../../spa.dart';

typedef OnProgressFunc = void Function(int? loaded, int? total);

class HttpUtil {
  static const headerAcceptJson = {'Accept': 'application/json'};
  static const headerContentTypeJson = {'Content-Type': 'application/json'};

  static CancelableOperation<HttpUtilResponse> cancelableHead(
    String url, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    http.Client? client,
  }) {
    var cpl = Completer<void>();
    var req = http.AbortableRequest('HEAD', Uri.parse(url), abortTrigger: cpl.future);
    req.headers.addAll(requestHeaders);

    var c = client ?? http.Client();
    return CancelableOperation.fromFuture(
      () async {
        var resp = await c.send(req);
        var total = int.tryParse(resp.headers['Content-Length'] ?? '');
        if (!expectedStatusCodes.contains(resp.statusCode)) {
          throw HttpUtilUnexpectedException(
            HttpUtilResponse(
              resp.statusCode,
              utf8.decode(await resp.stream.toBytes(), allowMalformed: true),
              resp.headers['Content-Type'],
              total,
            ),
          );
        }

        return HttpUtilResponse(resp.statusCode, null, resp.headers['Content-Type'], total);
      }(),
      onCancel: () {
        cpl.complete();
        throw http.RequestAbortedException(req.url);
      },
    );
  }

  static Future<HttpUtilResponse> head(
    String url, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    http.Client? client,
  }) {
    return cancelableHead(
      url,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      client: client,
    ).value;
  }

  static CancelableOperation<HttpUtilResponse> _requestNoBody(
    String method,
    String url, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    http.Client? client,
  }) {
    var cpl = Completer<void>();
    var req = http.AbortableRequest(method, Uri.parse(url), abortTrigger: cpl.future);
    req.headers.addAll(requestHeaders);

    var c = client ?? http.Client();
    return CancelableOperation.fromFuture(
      () async {
        var resp = await c.send(req);
        var total = int.tryParse(resp.headers['Content-Length'] ?? '');
        if (!expectedStatusCodes.contains(resp.statusCode)) {
          throw HttpUtilUnexpectedException(
            HttpUtilResponse(
              resp.statusCode,
              utf8.decode(await resp.stream.toBytes(), allowMalformed: true),
              resp.headers['Content-Type'],
              total,
            ),
          );
        }

        int loaded = 0;
        var completer = Completer<Uint8List>();
        var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
        var subs = resp.stream.listen(
          (chunk) {
            sink.add(chunk);
            if (onProgress != null) {
              loaded += chunk.length;
              onProgress(loaded, total);
            }
          },
          onError: completer.completeError,
          onDone: sink.close,
          cancelOnError: true,
        );
        var bytes = await completer.future;
        await subs.cancel();

        if (returnResponseAsBytes) {
          return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total);
        }

        return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
      }(),
      onCancel: () {
        cpl.complete();
        throw http.RequestAbortedException(req.url);
      },
    );
  }

  static CancelableOperation<HttpUtilResponse> cancelableGet(
    String url, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    http.Client? client,
  }) {
    return _requestNoBody(
      'GET',
      url,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      client: client,
    );
  }

  static Future<HttpUtilResponse> get(
    String url, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    http.Client? client,
  }) {
    return cancelableGet(
      url,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      onProgress: onProgress,
      client: client,
    ).value;
  }

  // TODO: implement upload on progress
  static CancelableOperation<HttpUtilResponse> _requestWithBody(
    String method,
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    var cpl = Completer<void>();
    var req = http.AbortableRequest(method, Uri.parse(url), abortTrigger: cpl.future);
    req.headers.addAll(requestHeaders);
    if (body != null) req.body = body;

    var c = client ?? http.Client();
    return CancelableOperation.fromFuture(
      () async {
        var resp = await c.send(req);
        var total = int.tryParse(resp.headers['Content-Length'] ?? '');
        if (!expectedStatusCodes.contains(resp.statusCode)) {
          throw HttpUtilUnexpectedException(
            HttpUtilResponse(
              resp.statusCode,
              utf8.decode(await resp.stream.toBytes(), allowMalformed: true),
              resp.headers['Content-Type'],
              total,
            ),
          );
        }

        int loaded = 0;
        var completer = Completer<Uint8List>();
        var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
        var subs = resp.stream.listen(
          (chunk) {
            sink.add(chunk);
            if (onProgress != null) {
              loaded += chunk.length;
              onProgress(loaded, total);
            }
          },
          onError: completer.completeError,
          onDone: sink.close,
          cancelOnError: true,
        );
        var bytes = await completer.future;
        await subs.cancel();

        if (returnResponseAsBytes) {
          return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total);
        }

        return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
      }(),
      onCancel: () {
        cpl.complete();
        throw http.RequestAbortedException(req.url);
      },
    );
  }

  static CancelableOperation<HttpUtilResponse> cancelablePost(
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return _requestWithBody(
      'POST',
      url,
      body: body,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    );
  }

  static Future<HttpUtilResponse> post(
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return cancelablePost(
      url,
      body: body,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    ).value;
  }

  static CancelableOperation<HttpUtilResponse> cancelableQuery(
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return _requestWithBody(
      'QUERY',
      url,
      body: body,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    );
  }

  static Future<HttpUtilResponse> query(
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return cancelableQuery(
      url,
      body: body,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    ).value;
  }

  static CancelableOperation<HttpUtilResponse> cancelablePatch(
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return _requestWithBody(
      'PATCH',
      url,
      body: body,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    );
  }

  static Future<HttpUtilResponse> patch(
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return cancelablePatch(
      url,
      body: body,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    ).value;
  }

  static CancelableOperation<HttpUtilResponse> _requestWithFormData(
    String method,
    String url,
    Map<String, String> fields,
    Map<String, File> files, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    var cpl = Completer();
    var c = client ?? http.Client();
    return CancelableOperation.fromFuture(
      () async {
        var mFiles = <http.MultipartFile>[];

        for (var f in files.entries) {
          var k = f.key;
          var v = f.value;
          var data = (await f.value.arrayBuffer().toDart);
          var mf = http.MultipartFile.fromBytes(
            k,
            data.toDart.asUint8List(),
            filename: v.name,
            contentType: http_parser.MediaType.parse(v.type),
          );
          mFiles.add(mf);
        }

        var req =
            http.AbortableMultipartRequest('POST', Uri.parse(url), abortTrigger: cpl.future)
              ..fields.addAll(fields)
              ..files.addAll(mFiles)
              ..headers.addAll(requestHeaders);

        var resp = await c.send(req);
        var total = int.tryParse(resp.headers['Content-Length'] ?? '');
        if (!expectedStatusCodes.contains(resp.statusCode)) {
          throw HttpUtilUnexpectedException(
            HttpUtilResponse(
              resp.statusCode,
              utf8.decode(await resp.stream.toBytes(), allowMalformed: true),
              resp.headers['Content-Type'],
              total,
            ),
          );
        }

        int loaded = 0;
        var completer = Completer<Uint8List>();
        var sink = ByteConversionSink.withCallback((bytes) => completer.complete(Uint8List.fromList(bytes)));
        var subs = resp.stream.listen(
          (chunk) {
            sink.add(chunk);
            if (onProgress != null) {
              loaded += chunk.length;
              onProgress(loaded, total);
            }
          },
          onError: completer.completeError,
          onDone: sink.close,
          cancelOnError: true,
        );
        var bytes = await completer.future;
        await subs.cancel();

        if (returnResponseAsBytes) {
          return HttpUtilResponse(resp.statusCode, bytes, resp.headers['Content-Type'], total);
        }

        return HttpUtilResponse(resp.statusCode, utf8.decode(bytes), resp.headers['Content-Type'], total);
      }(),
      onCancel: () {
        cpl.complete();
        throw http.RequestAbortedException(Uri.parse(url));
      },
    );
  }

  static CancelableOperation<HttpUtilResponse> cancelablePostFormData(
    String url,
    Map<String, String> fields,
    Map<String, File> files, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return _requestWithFormData(
      'POST',
      url,
      fields,
      files,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    );
  }

  static Future<HttpUtilResponse> postFormData(
    String url,
    Map<String, String> fields,
    Map<String, File> files, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return cancelablePostFormData(
      url,
      fields,
      files,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    ).value;
  }

  static CancelableOperation<HttpUtilResponse> cancelablePut(
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return _requestWithBody(
      'PUT',
      url,
      body: body,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    );
  }

  static Future<HttpUtilResponse> put(
    String url, {
    String? body,
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    OnProgressFunc? uploadOnProgress,
    http.Client? client,
  }) {
    return cancelablePut(
      url,
      body: body,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      uploadOnProgress: uploadOnProgress,
      client: client,
    ).value;
  }

  static CancelableOperation<HttpUtilResponse> cancelableDelete(
    String url, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    http.Client? client,
  }) {
    return _requestNoBody(
      'DELETE',
      url,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      onProgress: onProgress,
      client: client,
    );
  }

  static Future<HttpUtilResponse> delete(
    String url, {
    List<int> expectedStatusCodes = const [200],
    Map<String, String> requestHeaders = const {},
    bool returnResponseAsBytes = false,
    OnProgressFunc? onProgress,
    http.Client? client,
  }) {
    return cancelableDelete(
      url,
      expectedStatusCodes: expectedStatusCodes,
      requestHeaders: requestHeaders,
      returnResponseAsBytes: returnResponseAsBytes,
      onProgress: onProgress,
      client: client,
    ).value;
  }
}
