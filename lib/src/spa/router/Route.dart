part of '../../../spa.dart';

class Route {
  /// The route ID for this route, must be unique, and needs
  /// to be unique just for the router where this [Route] is registered.
  /// It is used to check whether the currently rendered route is the same
  /// with newly rendered [Route]. If a new request to render a route is given,
  /// and the route has the same id as the currently rendered route, router is
  /// intended to do nothing.
  late String _id;
  late BeforeRenderFunc beforeRender;
  late AfterRenderFunc afterRender;
  late BeforeUnrenderFunc beforeUnrender;
  late AfterUnrenderFunc afterUnrender;
  FutureOr<RenderComponent> component;

  String get id => _id;

  Route(
      String id,
      this.component,
      {
        BeforeRenderFunc? beforeRender,
        AfterRenderFunc? afterRender,
        BeforeUnrenderFunc? beforeUnrender,
        AfterUnrenderFunc? afterUnrender,
      }) {


    _id = id;
    Future<bool> fillerFunctionBool() {
      return Future.value(true);
    }
    Future<void> fillerFunctionVoid() async {}

    this.beforeRender = beforeRender ?? fillerFunctionBool;
    this.afterRender = afterRender ?? fillerFunctionVoid;
    this.beforeUnrender = beforeUnrender ?? fillerFunctionBool;
    this.afterUnrender = afterUnrender ?? fillerFunctionVoid;
  }
}

typedef BeforeRenderFunc = Future<bool> Function();
typedef AfterRenderFunc = Future Function();
typedef BeforeUnrenderFunc = Future<bool> Function();
typedef AfterUnrenderFunc = Future Function();