part of spa;

/// A subclass of [Component] designed to be rendered through other [RenderComponent]
/// using string interpolation.
///
/// The component needs to be attached to its parent [RenderComponent] by
/// calling [_attachToRenderComponent]. Read ahead.
///
/// Because this component is not rendered independently, the parent component
/// is responsible for calling the [loadEventHandlers] and [unloadEventHandlers].
///
/// You use this component by calling [asString] to get the raw unfiltered string
/// representation of this component. The string is then used (typically using
/// string interpolation) in other [RenderComponent]'s [baseInnerHtml], so that
/// this component can be rendered through DOM through that element. As a result,
/// you need to attach the component to the [RenderComponent] manually, so that
/// the component can be controlled when the parent [RenderComponent] is
/// rendered to DOM. You do this by supplying the parent component to
/// [_attachToRenderComponent].
abstract class StringComponent extends Component with MEventHandler {
  String _rawBaseInnerHtml = '';
  late RenderComponent _parent;

  StringComponent(RenderComponent parent, String id, String baseInnerHtml): super(id, baseInnerHtml) {
    _parent = parent;
    _attachToRenderComponent(parent);
  }

  StringComponent.empty(RenderComponent parent, String id): super.empty(id) {
    _parent = parent;
    _attachToRenderComponent(parent);
  }
  
  RenderComponent get parent => _parent;

  /// Unlike [RenderComponent], setting the [baseInnerHtml] does not update
  /// [baseInnerElement], because this component is not designed +to be rendered
  /// independently. You need to reprint the component to the parent's component
  /// (update its [baseInnerHtml] with this component string [asString]), and
  /// re-attach it with [_attachToRenderComponent] again.
  @override
  @nonVirtual
  set baseInnerHtml(String baseInnerHtml) {
    _rawBaseInnerHtml = baseInnerHtml;
  }

  /// Updates the component [baseInnerElement] with the one rendered in the
  /// parent component.
  ///
  /// To attach this component to the parent, you need to really make sure that
  /// this component is printed as string somewhere in the parent
  /// [baseInnerHtml], otherwise it will throw [ComponentNotRenderedException].
  ///
  /// After calling this, you can be sure that this component is now attached
  /// to the parent component and will get rendered together with it. You can
  /// then control the rendered component with this class (any changes made to
  /// this component's [baseInnerElement] will change the component in the DOM).
  ///
  /// It is called typically after building the parent's [baseInnerHtml] (which
  /// usually happens in its constructor).
  @nonVirtual
  void _attachToRenderComponent(RenderComponent component) {
    component._stringComponents.add(this);
  }

  /// Called when this component has been attached to a parent [RenderComponent].
  void onComponentAttached();

  void assertElementAttached() {
    if (baseInnerElement == null) throw ComponentNotAttachedException(id);
  }

  @override
  Element? queryById(String id) {
    assertElementAttached();
    return super.queryById(id);
  }

  @override
  ElementList<Element> queryByClass(String elemClass) {
    assertElementAttached();
    return super.queryByClass(elemClass);
  }

  /// Loads this component event handlers.
  /// Call super to check whether this component has been attached. If it hasn't,
  /// it will throw [ComponentNotRenderedException].
  ///
  /// Because this is a [StringComponent], this method is not called as this
  /// component never gets rendered independently. The parent needs to call this
  /// typically during postRender.
  ///
  /// BUG: There might need a way for this to be called automatically after attached.
  @override
  @mustCallSuper
  @experimental
  void loadEventHandlers() {
    assertElementAttached();
  }

  /// Unloads this component event handlers.
  /// Call super to check whether this component has been attached. If it hasn't,
  /// it will throw [ComponentNotRenderedException].
  ///
  /// Because this is a [StringComponent], this method is not called as this
  /// component never gets rendered independently. The parent needs to call this
  /// typically during preUnrender.
  @override
  @mustCallSuper
  void unloadEventHandlers() {
    assertElementAttached();
    super.unloadEventHandlers();
  }

  /// Returns this component representation as HTML string that you can use
  /// inside other component's [baseInnerHtml].
  @override
  String toString() {
    return _rawBaseInnerHtml;
  }
}