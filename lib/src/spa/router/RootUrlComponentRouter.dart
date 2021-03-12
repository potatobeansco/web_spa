part of '../../../spa.dart';

class RootUrlComponentRouter extends UrlComponentRouter {
  RootUrlComponentRouter(String urlPattern, String routerElementBind) : super(urlPattern, routerElementBind);

  @override
  Future<void> init() {
    var newUrl = Uri.parse(window.location.href);
    logDebug('[$routerElementBind] initializing "${newUrl.path}"');
    _loadOnPopStateListener();
    if (!isMatch(newUrl)) return Future.value();
    var route = routeTableMatcher(extractParams(newUrl), newUrl.queryParameters);
    if (route == null) return Future.value();
    return _renderRoute(route, newUrl);
  }

  @override
  bool isMatch(Uri uri) {
    if (uri.path == '/') return true;
    return super.isMatch(uri);
  }

  @override
  Map<String, String> extractParams(Uri uri) {
    if (uri.path == '/') return {};

    return super.extractParams(uri);
  }
}