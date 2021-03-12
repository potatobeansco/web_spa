part of '../../../spa.dart';

typedef RouteTableMatcher = Route? Function(Map<String, String> urlParams, Map<String, String> queryParams);

class UrlComponentRouter extends BaseUrlRouter with MLogging {
  Uri? currentUrl;
  late RouteTableMatcher routeTableMatcher;

  StreamSubscription<PopStateEvent>? _onPopStateSubscription;

  @override
  String get className => 'UrlComponentRouter';

  UrlComponentRouter(String urlPattern, String routerElementBind): super(urlPattern, routerElementBind) {
    ArgumentError.checkNotNull(routerElementBind);
  }

  static StreamSubscription<MouseEvent> attachOnPopStateEmitter(AnchorElement onClickElem) {
    return onClickElem.onClick.listen((event) {
      event.preventDefault();
      emitPopState(onClickElem.href!);
    });
  }

  static void emitPopState(String uri) {
    window.history.pushState(null, uri, uri);
    window.dispatchEvent(PopStateEvent('popstate'));
  }

  /// Checks the current window.location.pathname and initializes the router.
  /// If the pathname does not exist in the routingTable, it will do nothing
  /// but will still listen to PopStateEvent. But if the pathname does exist
  /// in the routing table, it will render the component.
  Future<void> init() {
    var newUrl = Uri.parse(window.location.href);
    logDebug('[$routerElementBind] initializing "${newUrl.path}"');
    _loadOnPopStateListener();
    if (!isMatch(newUrl)) return Future.value();
    var route = routeTableMatcher(extractParams(newUrl), newUrl.queryParameters);
    if (route == null) return Future.value();
    return _renderRoute(route, newUrl);
  }

  void _loadOnPopStateListener() {
    _onPopStateSubscription = window.onPopState.listen((PopStateEvent event) async {
      var newUrl = Uri.parse(window.location.href);
      if (currentUrl == newUrl || !isMatch(newUrl)) return;

      var route = routeTableMatcher(extractParams(newUrl), newUrl.queryParameters);
      if (route == null) return;

      if (currentRoute != null) {
        if (route.id == currentRoute!.id) return;
        await _unrenderCurrent();
      }

      await _renderRoute(route, newUrl);
    })..onError((error, stackTrace) {
      logError(error);
    });
  }

  /// Make sure to unrender current route first before rendering new route.
  Future _renderRoute(Route route, Uri newUrl) async {
    var allowContinue = await route.beforeRender();
    var newComponent = await route.component;
    if (allowContinue) {
      logDebug('[$routerElementBind] rendering ${route.id}');
      currentUrl = newUrl;
      currentRoute = route;
      await newComponent.renderTo(routerElementBind);
      await route.afterRender();
    } else {
      logDebug('[$routerElementBind] rendering ${route.id} is disallowed to continue');
    }
  }

  Future _unrenderCurrent() async {
    var allowContinue = await currentRoute!.beforeUnrender();
    var component = await currentRoute!.component;
    if (allowContinue) {
      logDebug('[$routerElementBind] unrendering ${currentRoute!.id}');
      await component.unrender();
      await currentRoute!.afterUnrender();
    } else {
      logDebug('[$routerElementBind] unrendering ${currentRoute!.id} is disallowed to continue');
    }
  }

  /// Unrenders the component that is currently rendered.
  /// If the router has not rendered anything, it will just cancel the event
  /// handler that listens to PopStateEvent, meaning that this router will no
  /// longer do anything.
  ///
  /// It can be reinitialized by [init]. Will throw [RouterUninitializedException]
  /// if router has not been initialized.
  Future dispose() async {
    if (currentUrl == null) {
      throw RouterUninitializedException();
    }

    logDebug('[$routerElementBind] disposing "${currentUrl!.path}"');
    await _onPopStateSubscription?.cancel();
    if (currentRoute != null) return _unrenderCurrent();
    return Future.value();
  }
}

class RouterUninitializedException implements Exception {
  RouterUninitializedException();

  @override
  String toString() {
    return 'Router has not been initialized';
  }
}