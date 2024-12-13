part of '../../../spa.dart';

/// Event handler capability for derivative of [Component].
mixin MEventHandler {
  final List<StreamSubscription> _eventSubscriptions = [];

  /// A generic method to add an event subscription which will also get
  /// cancelled when [unloadEventHandlers] is called.
  void addSubscription(StreamSubscription subs) {
    _eventSubscriptions.add(subs);
  }

  /// A generic method to add (bulk) event subscriptions which will also get
  /// cancelled when [unloadEventHandlers] is called.
  void addSubscriptions(Iterable<StreamSubscription> subs) {
    _eventSubscriptions.addAll(subs);
  }

  /// Creates an onClick event on [node] (has to be an [Element] or [Document] type).
  /// Call this in [loadEventHandlers].
  void addOnClickTo(Element node, void Function(Event) onClick) {
    _eventSubscriptions.add(node.onClick.listen(onClick));
  }

  /// Creates an onChange event on [node] (has to be an [Element] or [Document] type).
  /// Call this in [loadEventHandlers].
  void addOnChangeTo(Element node, void Function(Event) onChange) {
    _eventSubscriptions.add(node.onChange.listen(onChange));
  }

  /// Place all your event listener here.
  /// Use add event methods (like [addOnClickTo]).
  void loadEventHandlers();

  /// Unloads all event subscriptions previously added under loadEventHandlers.
  @mustCallSuper
  void unloadEventHandlers() {
    for (var subs in _eventSubscriptions) {
      subs.cancel();
    }
    _eventSubscriptions.clear();
  }
}