part of '../../../spa.dart';

/// Event handler capability for derivative of [Component].
mixin MEventHandler {
  final List<StreamSubscription> _eventSubscriptions = [];

  /// Creates an onClick event on [node].
  /// Call this in [loadEventHandlers].
  void addOnClickTo(dynamic node, void Function(Event) onClick) {
    if (!(node is Element) && !(node is Document)) throw ArgumentError('node must be a subtype of Element or Document');
    _eventSubscriptions.add(node.onClick.listen(onClick));
  }

  /// Place all your event listener here.
  /// Use add event methods (like [addOnClickTo]).
  void loadEventHandlers();

  /// Unloads all event subscriptions previously added under loadEventHandlers.
  @mustCallSuper
  void unloadEventHandlers() {
    _eventSubscriptions.forEach((subs) {
      subs.cancel();
    });
    _eventSubscriptions.clear();
  }
}