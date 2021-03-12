part of '../../../spa.dart';

/// An interface for components that have values that can be added or removed.
@deprecated
mixin MTwoWayValue<T> on Component {
  set value(T value);
  T get value;

  /// Get the <input> value pointed by [id].
  /// It is guaranteed to never be null, as null value will be converted to
  /// empty string.
  @protected
  String getValueFromInput(String id) => (queryById(id) as InputElement).value ?? '';

  /// Get the <textarea> value pointed by [id].
  /// It is guaranteed to never be null, as null value will be converted to
  /// empty string.
  @protected
  String getValueFromTextarea(String id) => (queryById(id) as TextAreaElement).value ?? '';

  /// Get the <select> value pointed by [id].
  /// It is guaranteed to never be null, as null value will be converted to
  /// empty string.
  @protected
  String getValueFromSelect(String id) => (queryById(id) as SelectElement).value ?? '';

  @protected
  void setValueInput(String id, String value) {
    (queryById(id) as InputElement).value = value;
  }

  @protected
  void setValueTextarea(String id, String value) {
    (queryById(id) as TextAreaElement).value = value;
  }

  @protected
  void setValueSelect(String id, String value) {
    for (var option in (queryById(id) as SelectElement).children) {
      if ((option as OptionElement).value == value) {
        (queryById(id) as SelectElement).value = value;
        return;
      }
    }

    throw ArgumentError('value $value is not among the select options');
  }
}