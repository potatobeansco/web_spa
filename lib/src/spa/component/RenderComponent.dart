part of '../../../spa.dart';

abstract class RenderComponent extends Component with MEventHandler {
  final List<StringComponent> _stringComponents = [];

  RenderComponent(super.id, super.baseInnerHtml);

  RenderComponent.empty(super.id): super.empty();

  @override
  set baseInnerHtml(String baseInnerHtml) {
    super.baseInnerHtml = baseInnerHtml;
    _attachAllStringComponents();
  }

  @protected
  Future<void> preRender() async {}

  @mustCallSuper
  @protected
  Future<void> postRender() async {
    loadEventHandlers();
  }

  @mustCallSuper
  @protected
  Future<void> preUnrender() async {
    unloadEventHandlers();
  }

  @protected
  Future<void> postUnrender() async {}

  /// Renders this component on an element with ID [parentId].
  /// You can override this method for example to add animations and other things. Just make sure to call
  /// super.renderTo to really render the component to the DOM.
  /// Will throw [ComponentNoParentException] if [parentId] cannot be found in the DOM.
  @nonVirtual
  Future<void> renderTo(Element parentNode) async {
    var parent = parentNode;
    await preRender();
    parent.innerHTML = ''.toJS;
    parent.appendChild(baseInnerElement!);
    await postRender();
  }

  /// Renders this component after an element with ID [elementId].
  /// This also checks whether the parent has a valid ID.
  @nonVirtual
  Future<void> renderAfter(Element element) async {
    try {
      await preRender();
      element.insertAdjacentElement('afterEnd', baseInnerElement!);
      await postRender();
    } catch (e) {
      throw ComponentNoParentException(id);
    }
  }

  /// Renders this component inside the element with ID [parentId], appended.
  /// This also checks whether the parent exists.
  @nonVirtual
  Future<void> renderAppend(Element parentElement) async {
    await preRender();
    parentElement.insertAdjacentElement('beforeEnd', baseInnerElement!);
    await postRender();
  }

  /// Renders this component inside the element with ID [parentId], prepended.
  /// This also checks whether the parent exists.
  @nonVirtual
  Future<void> renderPrepend(Element parentElement) async {
    await preRender();
    parentElement.insertAdjacentElement('afterBegin', baseInnerElement!);
    await postRender();
  }

  /// Removes this component from the DOM, setting [parentId] to null.
  /// Will throw [ComponentNotRenderedException] if it has not been rendered.
  @nonVirtual
  Future<void> unrender() async {
    await preUnrender();
    elem.remove();
    await postUnrender();
  }

  /// Components that are in lower level are attached first by traversing
  /// [_stringComponents] in reverse. This is done so that a higher (parent)
  /// [StringComponent] does not have problem interacting with the children
  /// [StringComponent], because the children has been attached first.
  @nonVirtual
  @protected
  void _attachAllStringComponents() {
    for (var c in _stringComponents) {
      var element = elem.querySelector('#${c.id}');
      if (element == null) throw ComponentNotRenderedException(c.id);
      c._baseInnerElement = element;
    }
    for (var c in _stringComponents.reversed) {
      c.onComponentAttached();
    }
  }
}