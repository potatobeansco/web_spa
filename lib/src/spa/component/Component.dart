part of spa;

/// The basic building block of the whole application.
/// [Component], is a basic and abstract class, used to define a set of HTML
/// elements to be rendered on screen. For example, to create a button, with
/// image icon, you will create a <button> tag and <img> tag. [Component] class
/// wraps that and creates an object representing that particular component.
///
/// A [Component] is nothing more than just some HTML tags written in string
/// and grouped into an object, OOP-way. Therefore, [Component] always has
/// [baseInnerHtml] attribute, which is used to store the HTML representation
/// of this component as string.
///
/// To use this class, you need to subclass it and create a component based on
/// your need, and write the HTML into the [baseInnerHtml] attribute. Make sure
/// to read the documentation of that attribute before creating the class.
/// There are other methods that you need to override as well.
abstract class Component {
  /// The HTML ID of the parent where this component is rendered.
  /// The ID must refer to existent tag. This ID is used as reference to
  /// querySelector command, in order to render the component to DOM. In other
  /// words, the component will do querySelector('$parentId').setInnerHtml to
  /// render itself into the DOM, which means it will throw an error if there
  /// is no tag exist having the ID [parentId].
  String? _parentId;
  /// The HTML ID of the component itself. This must be rendered into DOM.
  /// HTML ID is the `id=""` attribute.
  late String _id;
  /// The HTML representation of this component, in the form of objects
  /// ([Element]s).
  Element? _baseInnerElement;

  @nonVirtual
  String get id => _id;

  /// Setting the component with new ID is basically not recommended. It will
  /// change the real HTML ID of this element rendered in DOM too, and will
  /// throw [ComponentDuplicateIdException] when the new ID already exists.
  @nonVirtual
  set id(String id) {
    assertDuplicateId(id);
    elem.id = id;
    baseInnerElement!.id = id;
    _id = id;
  }

  @nonVirtual
  String? get parentId => _parentId;

  @nonVirtual
  @protected
  set parentId(String? parentId) {
    _parentId = parentId;
  }

  @nonVirtual
  String get baseInnerHtml {
    var wrapper = Element.div();
    wrapper.children.add(_baseInnerElement!);
    return wrapper.innerHtml!;
  }

  /// Returns the DOM [Element] of this component by doing
  /// `querySelector('$id')`.
  @nonVirtual
  Element get elem => baseInnerElement!;

  @nonVirtual
  @protected
  Element? get baseInnerElement => _baseInnerElement;

  /// Sanitizes and sets the [baseInnerHtml] of this component.
  /// Will throw [ComponentNoIdException] if there is no `id=""` attribute
  /// with the same [id] value found inside the [baseInnerHtml] string. This
  /// ensures that the DOM is in sync with the object (meaning that the
  /// component with [id] test will really be rendered into DOM with `id="test"`
  /// in the tag.
  ///
  /// Setting this with new value also changes [baseInnerElement] attribute.
  ///
  /// It does not change the rendered looks. In other words, if this component
  /// has been rendered, changing [baseInnerHtml] won't change a thing in the
  /// browser. You need to re-render it again. This behavior will probably
  /// change in the future.
  @protected
  set baseInnerHtml(String baseInnerHtml) {
    var template = document.createElement('template');
    // ignore: unsafe_html
    template.setInnerHtml(baseInnerHtml.trim(), validator: TrustedNodeValidator(), treeSanitizer: null);
    _baseInnerElement = (template as TemplateElement).content!.nodes.single as Element;
    if (_baseInnerElement!.id != id) {
      throw ComponentNoIdException(id);
    }
  }

  /// Creates a [Component].
  /// The given [baseInnerHtml] string will be checked if it really has matching
  /// id="" tag or not. The given [id] should exist in [baseInnerHtml] as
  /// id="$id" attribute. This will keep this class in sync with the real DOM.
  Component(String id, String baseInnerHtml) {
    if (id == '') throw ArgumentError('Must not be empty', 'id');
    _id = id;
    this.baseInnerHtml = baseInnerHtml;
  }

  /// Creates empty [Component] with empty [baseInnerHtml].
  /// Useful for subclasses where you then create [baseInnerHtml] string inside
  /// the subclass constructor. The subclass constructor can call super.empty
  /// to build empty [Component].
  ///
  /// In dart, super constructor is always called first, before the subclass
  /// constructor. Therefore, creating component with non empty constructor
  /// can't be done because it needs you to supply [baseInnerHtml] string
  /// beforehand.
  Component.empty(String id) {
    if (id == '') throw ArgumentError('Must not be empty', 'id');
    _id = id;
  }

  /// Does elem.querySelector(#id) to select an element under this
  /// component.
  Element? queryById(String id) {
    return elem.querySelector('#$id');
  }

  /// Does elem.querySelectorAll(.elemClass) to select all
  /// element that have matched class.
  ElementList<Element> queryByClass(String elemClass) {
    return elem.querySelectorAll('.$elemClass');
  }

  @nonVirtual
  @protected
  void assertDuplicateId(String id) {
    if (querySelector('#$id') != null) {
      throw ComponentDuplicateIdException(id);
    }
  }

  /// Check if the component is rendered at DOM or not.
  @nonVirtual
  bool isRendered() {
    return parentId != null;
  }

  /// Contains checks whether a node is contained in this component.
  /// Can only be used by [StringComponent] if the component has been attached.
  @nonVirtual
  bool contains(Node node) {
    return elem.contains(node);
  }

  @override
  String toString() {
    return baseInnerHtml;
  }
}