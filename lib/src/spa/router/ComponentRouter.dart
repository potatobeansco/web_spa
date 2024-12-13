part of '../../../spa.dart';

typedef ComponentRouterHandleFunc = Route Function(Map<String, String> urlParams, Map<String, String> queryParams);

class _ComponentRoute {
  final ComponentRouterHandleFunc handleFunc;
  final bool? prefixMatch;

  const _ComponentRoute(this.handleFunc, {this.prefixMatch});
}

class ComponentRouter with MLogging {
  @override
  String get className => 'ComponentRouter';

  late String currentPath;
  Route? currentRoute;
  final Element parentElement;
  final LinkedHashMap<String, _ComponentRoute> _matchMap = LinkedHashMap<String, _ComponentRoute>();
  final bool doNotRenderSameRoute;

  StreamSubscription<PopStateEvent>? _onPopStateSubscription;

  ComponentRouter(this.parentElement, {this.doNotRenderSameRoute = true});

  static StreamSubscription<MouseEvent> attachOnPopStateEmitter(HTMLAnchorElement onClickElem) {
    return onClickElem.onClick.listen((event) {
      event.preventDefault();
      emitPopState(onClickElem.href);
    });
  }

  static void emitPopState(String uri) {
    window.history.pushState(null, uri, uri);
    window.dispatchEvent(PopStateEvent('popstate'));
  }

  void _loadOnPopStateListener() {
    _onPopStateSubscription?.cancel();
    _onPopStateSubscription = window.onPopState.listen((PopStateEvent event) async {
      try {
        var newUrl = Uri.parse(window.location.href);
        if (currentPath == newUrl.path) return;

        await render();
      } catch (e) {
        logError(e.toString());
      }
    });
  }

  void handleRoute(String pattern, ComponentRouterHandleFunc matcherFunc, {bool? prefixMatch}) {
    _matchMap[pattern] = _ComponentRoute(matcherFunc, prefixMatch: prefixMatch);
  }

  @Deprecated('Automatic extraction will be replaced with explicit match prefix/not')
  Map<String, String>? _extractParamsAuto(String pattern, String currentPath) {
    var cp = path.normalize(currentPath);
    var matchSubpaths = pattern.endsWith('/');
    var patternUri = Uri(path: path.normalize(pattern));
    var currentUri = Uri(path: cp);

    // Current path is shorter.
    if (currentUri.pathSegments.length < patternUri.pathSegments.length) return null;

    // Current path is longer, but match subpaths is false.
    if (!matchSubpaths && patternUri.pathSegments.length != currentUri.pathSegments.length) return null;

    final minLength = patternUri.pathSegments.length;
    final patternSegments = patternUri.pathSegments;
    final currentPathSegments = currentUri.pathSegments;
    var params = <String, String>{};
    var isMatch = true;
    for (var i = 0; i < minLength; i++) {
      final patternSegment = patternSegments[i];
      final currentSegment = currentPathSegments[i];

      // we extract the param
      if (patternSegment.startsWith('[') && patternSegment.endsWith(']')) {
        var key = patternSegment.replaceFirst('[', '');
        key = key.substring(0, key.length-1);
        params[key] = currentSegment;
        continue;
      }

      // Exact segment match
      if (currentSegment != patternSegment) {
        isMatch = false;
        break;
      }
    }

    if (!isMatch) return null;

    return params;
  }

  Map<String, String>? _extractParams(String pattern, String currentPath, {bool prefixMatch = false}) {
    var cp = path.normalize(currentPath);
    var matchSubpaths = prefixMatch;
    var patternUri = Uri(path: path.normalize(pattern));
    var currentUri = Uri(path: cp);

    // Current path is shorter.
    if (currentUri.pathSegments.length < patternUri.pathSegments.length) return null;

    // Current path is longer, but match subpaths is false.
    if (!matchSubpaths && patternUri.pathSegments.length != currentUri.pathSegments.length) return null;

    final minLength = patternUri.pathSegments.length;
    final patternSegments = patternUri.pathSegments;
    final currentPathSegments = currentUri.pathSegments;
    var params = <String, String>{};
    var isMatch = true;
    for (var i = 0; i < minLength; i++) {
      final patternSegment = patternSegments[i];
      final currentSegment = currentPathSegments[i];

      // we extract the param
      if (patternSegment.startsWith('[') && patternSegment.endsWith(']')) {
        var key = patternSegment.replaceFirst('[', '');
        key = key.substring(0, key.length-1);
        params[key] = currentSegment;
        continue;
      }

      // Exact segment match
      if (currentSegment != patternSegment) {
        isMatch = false;
        break;
      }
    }

    if (!isMatch) return null;

    return params;
  }

  /// Make sure to unrender current route first before rendering new route.
  Future<void> _renderRoute(Route route) async {
    var allowContinue = await route.beforeRender();
    var newComponent = await route.component;
    if (allowContinue) {
      logDebug('[${parentElement.id}] rendering ${route.id}');
      currentRoute = route;
      await newComponent.renderTo(parentElement);
      await route.afterRender();
    } else {
      logDebug('[${parentElement.id}] rendering ${route.id} is disallowed to continue');
    }
  }

  /// Unrenders the current route, assuming it is not null.
  Future<void> _unrenderCurrent() async {
    var r = currentRoute;
    currentRoute = null;
    var allowContinue = await r!.beforeUnrender();
    var component = await r.component;
    if (allowContinue) {
      logDebug('[${parentElement.id}] unrendering ${r.id}');
      await component.unrender();
      await r.afterUnrender();
    } else {
      logDebug('[${parentElement.id}] unrendering ${r.id} is disallowed to continue');
    }
  }

  Future<void> init() async {
    _loadOnPopStateListener();
    await render();
  }

  /// Starts rendering current route.
  Future<void> render() async {
    var currentUrl = Uri.parse(window.location.href);
    // TODO: currentPath and currentRoute should be set both at the same time
    currentPath = currentUrl.path;
    var isMatch = false;
    for (var i in _matchMap.entries) {
      var pattern = i.key;
      var entry = i.value;
      Map<String, String>? params;
      if (entry.prefixMatch == null) {
        params = _extractParamsAuto(pattern, currentUrl.path);
      } else {
        params = _extractParams(pattern, currentPath, prefixMatch: entry.prefixMatch!);
      }

      if (params == null) continue; // Does not match pattern, continue to the next

      isMatch = true;
      var route = entry.handleFunc(params, currentUrl.queryParameters);
      if (currentRoute != null) {
        if (doNotRenderSameRoute && currentRoute!.id == route.id) {
          break;
        } else {
          await _unrenderCurrent();
        }
      }

      currentRoute = route;
      await _renderRoute(route);
      break;
    }

    if (!isMatch) {
      throw ComponentRouterNoMatchException(currentUrl.path, parentElement.id);
    }
  }

  Future<void> dispose() async {
    _onPopStateSubscription?.cancel();
    if (currentRoute != null) await _unrenderCurrent();
  }
}

class ComponentRouterNoMatchException implements Exception {
  final String currentPath;
  /// The ID in which the router is bound to (render to).
  final String? routerElementBind;

  const ComponentRouterNoMatchException(this.currentPath, [this.routerElementBind]);

  @override
  String toString() {
    return '${routerElementBind != null ? '[$routerElementBind] ' : ''}$currentPath does not match any registered patterns';
  }
}