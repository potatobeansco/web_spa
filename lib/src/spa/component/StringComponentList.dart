part of '../../../spa.dart';

/// A list of [StringComponent].
/// The only difference with normal List is the toString function, which
/// will return all the components string representation concatenated together.
/// This is useful to create a list of HTML elements for example.
class StringComponentList<T extends StringComponent> extends ListBase<T> with MEventHandler {
  final List<T> _l = [];

  @override
  int get length => _l.length;

  @override
  set length(int newLength) { _l.length = newLength; }

  @override
  T operator [](int index) {
    return _l[index];
  }

  @override
  void operator []=(int index, T value) {
    _l[index] = value;
  }

  @override
  String toString() {
    var retval = '';
    _l.forEach((c) {
      retval += c.toString();
    });

    return retval;
  }

  @override
  void loadEventHandlers() {
    _l.forEach((element) {
      element.loadEventHandlers();
    });
  }

  @override
  void unloadEventHandlers() {
    super.unloadEventHandlers();
    _l.forEach((element) {
      element.unloadEventHandlers();
    });
  }
}