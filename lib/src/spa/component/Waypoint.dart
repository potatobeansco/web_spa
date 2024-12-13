part of '../../../spa.dart';

typedef WaypointHandler = void Function();

/// Waypoint is a new library implemented to detect if an element is displayed on
/// screen. Waypoint works by continuously checking whether an element is displayed
/// on screen by tracking its position relative to a viewport. The name `waypoint`
/// came from the same jQuery waypoint functionality.
///
/// To use waypoint, add your component and a handler function to the constructor,
/// and an optional offset value.
///
/// To initialize waypoint, call waypoint `loadEventHandler()` function to register
/// waypoint internal `onScroll` listener. You call it naturally in your component
/// `loadEventHandlers()`.
///
/// To dispose waypoint event listener, which
/// will release the memory that it uses to prevent memory leak, call `unloadEventHandler()`
/// method in your component `unloadEventHandlers()`.
///
/// Waypoint [offset]
///
/// If you do not supply **offset** value, then just immediately after the top
/// part of the element gets shown on the screen, the event is triggered. You may
/// not want this behavior especially when waypoint is used to play the element animation
/// to display it on screen because that will make the animation to fire too early,
/// even before the use can see the element completely on screen. The `offset`
/// value is used to add offset to this.
///
/// With `offset`, waypoint adds the `top` value of the element with `offset`, and
/// make sure the sum of them is <= the viewport height before firing the element.
/// (`top` + `offset` <= viewport height). There are cases, however, when you want
/// to wait for the element to be on screen completely before firing the event. This
/// basically means setting `offset` value to be the same as the element height.
/// However, this becomes problematic when you try to use media query and dynamically
/// resize elements depending on the viewport size, or if you simply do not know
/// the element height beforehand because it was set to `auto`. For this purpose,
/// Waypoint offers two different enum constants as a replacement of double values
/// it receives. You can use `Waypoint.offsetBottomInScreen` to wait for the element
/// to be fully shown on screen, and `Waypoint.offsetHalfBottomInScreen` to wait
/// for only half of the element height to be fully shown on screen. This is analogous
/// to the jQuery Waypoint `bottom-in-view` value. Using `offsetBottomInScreen`
/// or `offsetHalfBottomInScreen` tells waypoint to dynamically look at the
/// element height, *which may be 0 for element with `display: none`*.
class Waypoint {
  /// Fire the event when an element is completely in the viewport.
  static const offsetBottomInScreen = -1.0;
  /// Fire the event when half of the element height is in the viewport.
  static const offsetHalfBottomInScreen = -2.0;

  late Element _element;
  late WaypointHandler _handler;
  late num _offset;

  StreamSubscription<Event>? _onScrollSubs;

  Element get element => _element;

  num get offset => _offset;

  Waypoint(Element element, WaypointHandler handler, [num offset = 0]) {
    _element = element;
    _handler = handler;
    _offset = offset;
  }

  void loadEventHandler() {
    if (_offset == offsetBottomInScreen) {
      _offset = _element.getBoundingClientRect().height;
    } else if (_offset == offsetHalfBottomInScreen) {
      _offset = _element.getBoundingClientRect().height/2;
    }

    _onScrollSubs = document.documentElement!.onScroll.listen((event) {
      if ((_element.getBoundingClientRect().top + _offset) <= window.innerHeight) {
        _handler();
      }
    });
  }

  void unloadEventHandler() {
    _onScrollSubs?.cancel();
  }
}