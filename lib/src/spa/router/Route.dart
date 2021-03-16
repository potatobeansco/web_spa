part of spa;

class Route {
  /// The route ID for this route, must be unique, and needs
  /// to be unique just for the router where this [Route] is registered.
  /// It is used to check whether the currently rendered route is the same
  /// with newly rendered [Route]. If a new request to render a route is given,
  /// and the route has the same id as the currently rendered route, router is
  /// intended to do nothing.
  late String _id;
  late beforeRenderFunc beforeRender;
  late afterRenderFunc afterRender;
  late beforeUnrenderFunc beforeUnrender;
  late afterUnrenderFunc afterUnrender;
  FutureOr<RenderComponent> component;

  String get id => _id;

  Route(
      String id,
      this.component,
      {
        beforeRenderFunc? beforeRender,
        afterRenderFunc? afterRender,
        beforeUnrenderFunc? beforeUnrender,
        afterUnrenderFunc? afterUnrender,
      }) {


    _id = id;
    var fillerFunctionBool = () {
      return Future.value(true);
    };
    var fillerFunctionVoid = () async {};

    this.beforeRender = beforeRender ?? fillerFunctionBool;
    this.afterRender = afterRender ?? fillerFunctionVoid;
    this.beforeUnrender = beforeUnrender ?? fillerFunctionBool;
    this.afterUnrender = afterUnrender ?? fillerFunctionVoid;
  }
}

typedef beforeRenderFunc = Future<bool> Function();
typedef afterRenderFunc = Future Function();
typedef beforeUnrenderFunc = Future<bool> Function();
typedef afterUnrenderFunc = Future Function();