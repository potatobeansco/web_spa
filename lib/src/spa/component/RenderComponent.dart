part of spa;

abstract class RenderComponent extends Component with MEventHandler {
  final List<StringComponent> _stringComponents = [];

  RenderComponent(String id, String baseInnerHtml): super(id, baseInnerHtml);

  RenderComponent.empty(String id): super.empty(id);

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
  Future<void> renderTo(String parentId) async {
    var parent = querySelector('#$parentId');
    if (parent == null) throw ComponentNoParentException(id);
    await preRender();
    parent.children.clear();
    parent.children.add(baseInnerElement!);
    this.parentId = parentId;
    await postRender();
  }

  /// Renders this component after an element with ID [elementId].
  /// This also checks whether the parent has a valid ID.
  @nonVirtual
  Future<void> renderAfter(String elementId) async {
    var element = querySelector('#$elementId');
    if (element == null) {
      throw ComponentReferenceNotExistException(elementId);
    }

    try {
      parentId = element.parent!.id;
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
  Future<void> renderAppend(String parentId) async {
    var parent = querySelector('#$parentId');
    if (parent == null) throw ComponentNoParentException(id);
    await preRender();
    parent.insertAdjacentElement('beforeEnd', baseInnerElement!);
    this.parentId = parentId;
    await postRender();
  }

  /// Renders this component inside the element with ID [parentId], prepended.
  /// This also checks whether the parent exists.
  @nonVirtual
  Future<void> renderPrepend(String parentId) async {
    var parent = querySelector('#$parentId');
    if (parent == null) throw ComponentNoParentException(id);
    await preRender();
    parent.insertAdjacentElement('afterBegin', baseInnerElement!);
    this.parentId = parentId;
    await postRender();
  }

  /// Removes this component from the DOM, setting [parentId] to null.
  /// Will throw [ComponentNotRenderedException] if it has not been rendered.
  @nonVirtual
  Future<void> unrender() async {
    if (parentId == null) {
      throw ComponentNotRenderedException(id);
    }

    await preUnrender();
    querySelector('#$id')?.remove();
    parentId = null;
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