part of '../../../spa.dart';

/// A list of [StringComponent].
/// The only difference with normal List is the toString function, which
/// will return all the components string representation concatenated together.
/// This is useful to create a list of HTML elements for example.
class StringComponentList<T extends StringComponent> extends ListBase<T> with MEventHandler {
  final List<T> _l;

  StringComponentList() : _l = [];

  StringComponentList.from(Iterable elements, {bool growable = true}) : _l = List<T>.from(elements, growable: growable);

  StringComponentList.of(Iterable<T> elements, {bool growable = true}) : _l = List<T>.of(elements, growable: growable);

  StringComponentList.generate(int length, T Function(int index) generator, {bool growable = true}) : _l = List<T>.generate(length, generator, growable: growable);

  StringComponentList.unmodifiable(Iterable elements) : _l = List<T>.unmodifiable(elements);

  @override
  T operator [](int index) => _l[index];

  @override
  void operator []=(int index, T value) {
    _l[index] = value;
  }

  @override
  List<T> operator +(List<T> other) => _l + other;

  @override
  void add(T value) {
    _l.add(value);
  }

  @override
  void addAll(Iterable<T> iterable) {
    _l.addAll(iterable);
  }

  @override
  Map<int, T> asMap() => _l.asMap();

  @override
  List<E> cast<E>() => _l.cast<E>();

  @override
  void clear() {
    _l.clear();
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    _l.fillRange(start, end, fillValue);
  }

  @override
  set first(T value) {
    if (isEmpty) throw RangeError.index(0, this);
    this[0] = value;
  }

  @override
  Iterable<T> getRange(int start, int end) => _l.getRange(start, end);

  @override
  int indexWhere(bool Function(T) test, [int start = 0]) =>
      _l.indexWhere(test, start);

  @override
  void insert(int index, T element) {
    _l.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _l.insertAll(index, iterable);
  }

  @override
  set last(T value) {
    if (isEmpty) throw RangeError.index(0, this);
    this[length - 1] = value;
  }

  @override
  int lastIndexWhere(bool Function(T) test, [int? start]) =>
      _l.lastIndexWhere(test, start);

  @override
  set length(int newLength) {
    _l.length = newLength;
  }

  @override
  int get length => _l.length;

  @override
  bool remove(Object? value) => _l.remove(value);

  @override
  T removeAt(int index) => _l.removeAt(index);

  @override
  T removeLast() => _l.removeLast();

  @override
  void removeRange(int start, int end) {
    _l.removeRange(start, end);
  }

  @override
  void removeWhere(bool Function(T) test) {
    _l.removeWhere(test);
  }

  @override
  void replaceRange(int start, int end, Iterable<T> iterable) {
    _l.replaceRange(start, end, iterable);
  }

  @override
  void retainWhere(bool Function(T) test) {
    _l.retainWhere(test);
  }

  @override
  Iterable<T> get reversed => _l.reversed;

  @override
  void setAll(int index, Iterable<T> iterable) {
    _l.setAll(index, iterable);
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    _l.setRange(start, end, iterable, skipCount);
  }

  @override
  void shuffle([Random? random]) {
    _l.shuffle(random);
  }

  @override
  void sort([int Function(T, T)? compare]) {
    _l.sort(compare);
  }

  @override
  List<T> sublist(int start, [int? end]) => _l.sublist(start, end);

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