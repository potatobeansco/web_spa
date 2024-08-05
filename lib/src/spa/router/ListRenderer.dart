part of '../../../spa.dart';

abstract class ListRenderer<T, C extends RenderComponent> extends DelegatingList<T> {
  final List<C> _modelToComponent = [];

  @protected
  final Element parentElement;

  RenderComponent? _emptyComponent;

  /// Retrieve the currently configured emptyComponent.
  /// The component can be modified as you see fit.
  RenderComponent? get emptyComponent => _emptyComponent;

  ListRenderer(this.parentElement) : super([]) {
    _emptyComponent = getEmptyComponent();
  }

  /// The returned components are immutable.
  /// Although you can make modification to the component itself directly still.
  List<C> get components => List.unmodifiable(_modelToComponent);

  FutureOr<C> getItemComponent(T state);

  /// Empty component is a component that is returned when there is no entry
  /// in the model. It is used for example to render empty notification on
  /// empty tables for example. By default, it returns null, which means
  /// no component is rendered.
  ///
  /// Unlike [getItemComponent], empty component is fetched once and then stored.
  RenderComponent? getEmptyComponent() {
    return null;
  }

  Future<void> refresh(int index) async {
    await _modelToComponent[index].unrender();
    _modelToComponent[index] = await getItemComponent(this[index]);
    if (index <= 0) {
      await _modelToComponent[index].renderPrepend(parentElement);
    } else {
      await _modelToComponent[index].renderAfter(_modelToComponent[index-1].elem);
    }
  }

  Future<void> setRefresh(int index, T value) async {
    this[index] = value;
    await refresh(index);
  }

  Future<void> addRefresh(T value) async {
    if (_emptyComponent != null && _emptyComponent!.isRendered()) await _emptyComponent?.unrender();
    add(value);
    _modelToComponent.add(await getItemComponent(last)) ;
    await _modelToComponent.last.renderAppend(parentElement);
  }

  Future<void> removeAtRefresh(int index) async {
    await _modelToComponent[index].unrender();
    _modelToComponent.removeAt(index);
    removeAt(index);
    if (length <= 0) {
      await _emptyComponent?.renderTo(parentElement);
    }
  }

  /// Replace all acts like clearRefresh + addAllRefresh, the only difference
  /// is replaceAllRefresh does not trigger rendering of empty component
  /// when the added content is not empty.
  ///
  /// For convenience, you can also put in empty list (but not null).
  /// Giving empty list will act like clearRefresh, and will render an empty
  /// component.
  Future<void> replaceAllRefresh(List<T> values) async {
    if (values.isEmpty) {
      await clearRefresh();
      return;
    }

    await clearRefresh(false);
    await addAllRefresh(values);
  }

  Future<void> clearRefresh([bool renderEmptyComponent = true]) async {
    for (var c in _modelToComponent) {
      await c.unrender();
    }
    clear();
    _modelToComponent.clear();

    if (renderEmptyComponent) {
      await _emptyComponent?.renderTo(parentElement);
    }
  }

  Future<void> addAllRefresh(List<T> values) async {
    for (var v in values) {
      await addRefresh(v);
    }
  }

  Future<void> insertRefresh(int index, T value) async {
    if (_emptyComponent != null && _emptyComponent!.isRendered()) await _emptyComponent?.unrender();
    insert(index, value);
    var c = await getItemComponent(value);
    _modelToComponent.insert(index, c);
    if (index > 0) {
      await c.renderAfter(_modelToComponent[index-1].elem);
    } else {
      await c.renderPrepend(parentElement);
    }
  }

  Future<void> insertAllRefresh(int index, Iterable<T> iterable) async {
    if (_emptyComponent != null && _emptyComponent!.isRendered()) await _emptyComponent?.unrender();
    insertAll(index, iterable);
    var i = 0;
    for (final v in iterable) {
      final c = await getItemComponent(v);
      if (index + i == 0) {
        await c.renderPrepend(parentElement);
      } else {
        await c.renderAfter(_modelToComponent[index+i-1].elem);
      }
      _modelToComponent.insert(index+i, c);
      i++;
    }
  }

  void forEachComponent(void Function(C component) action) async {
    var length = this.length;
    for (var i = 0; i < length; i++) {
      action(_modelToComponent[i]);
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
  }

  Future<void> forEachComponentAsync(Future<void> Function(C component) action) async {
    var length = this.length;
    for (var i = 0; i < length; i++) {
      await action(_modelToComponent[i]);
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
  }
}