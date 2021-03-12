part of spa;

/// Attaches a CSS transition property to an [Element], along with the set
/// properties. Animation can then be played freely by calling [play()] or [rewind()].
@deprecated
class CustomAnimationMultiple extends AnimationElement {
  late ElementList _elementList;
  late Map<String, String> _from;
  late Map<String, String> _to;
  late Map<String, String> _prePlay;
  late Map<String, String> _postPlay;
  late Map<String, String> _preRewind;
  late Map<String, String> _postRewind;

  /// The element attached to this [CustomAnimation].
  /// In other words, the element that is controlled.
  ElementList get elementList => _elementList;

  /// The properties that are set as the initial state of the [element].
  Map<String, String> get from => _from;

  /// The properties that are set when animation is started using [play], which
  /// in return triggers the CSS transition. This is the end state of the [element].
  Map<String, String> get to => _to;

  /// The properties that are set just before [play] is called.
  /// This is useful for triggering fade in for example while also changing the CSS
  /// display value also from 'none' to anything. For example if you want to show
  /// hidden elements (elements that were hidden by setting display to 'none'),
  /// you may want to set the display value to other than 'none' first. Otherwise,
  /// animating the opacity from 0 to 1 will do nothing.
  Map<String, String> get prePlay => _prePlay;

  /// The properties that are set after [play] has been completed.
  Map<String, String> get postPlay => _postPlay;

  /// The properties that are set just before [rewind] is called.
  Map<String, String> get preRewind => _preRewind;

  /// The properties that are set after [rewind] has been completed.
  /// This is useful when triggering fade out by rewinding fade in animation.
  /// For example, if you want to hide an element you will animate its opacity
  /// from 1 to 0, but also setting the display CSS property to 'none' afterwards
  /// to really hide it from the DOM.
  Map<String, String> get postRewind => _postRewind;

  /// The duration of the animation.
  /// Animation duration is not exact/real-time due to some delays introduced
  /// during some parts of playing/rewinding the animation. These delays are
  /// introduced programmatically to make sure animation can run. You don't have
  /// to worry about this but remember that the time set 300ms is not exactly
  /// 300ms, it is longer. You should not rely on the exact duration.
  Duration get duration => _duration;

  /// Sets the [elementList] CSS property with the properties supplied by [from].
  /// Also sets the transition property for the [elementList].
  CustomAnimationMultiple(ElementList elementList, Map<String, String> from,
      Map<String, String> to, Duration duration, {Map<String, String>? prePlay, Map<String, String>? postPlay, Map<String, String>? preRewind, Map<String, String>? postRewind}) {
    _elementList = elementList;
    _from = from;
    _to = to;
    _assertProperties();

    _duration = duration;
    _prePlay = (prePlay == null) ? {} : prePlay;
    _postPlay = (postPlay == null) ? {} : postPlay;
    _preRewind = (preRewind == null) ? {} : preRewind;
    _postRewind = (postRewind == null) ? {} : postRewind;
  }

  /// Standard animation for fading in the [elementList] (changing its opacity from 0 to
  /// 1).
  CustomAnimationMultiple.fadeIn(ElementList elementList, Duration duration) {
    _elementList = elementList;
    _from = {'opacity': '0'};
    _to = {'opacity': '1'};
    _duration = duration;

    _prePlay = {};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {};
  }

  /// Standard animation for fading in the [elementList] (changing its opacity from 0 to
  /// 1), while also sliding it to a direction set by 20px.
  CustomAnimationMultiple.fadeInSlide(ElementList elementList, Duration duration, String direction) {
    _elementList = elementList;
    _from = {'opacity': '0', 'position': 'relative', direction: '20px'};
    _to = {'opacity': '1', 'position': 'relative', direction: '0'};
    _duration = duration;

    _prePlay = {};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {};
  }

  /// Standard animation for fading in the [elementList] (changing its opacity from 0 to
  /// 1), but also setting the display to the value set by [displayProperty]
  /// first before triggering animation.
  CustomAnimationMultiple.displayFadeIn(ElementList elementList, Duration duration, String displayProperty) {
    _elementList = elementList;
    _from = {'opacity': '0'};
    _to = {'opacity': '1'};
    _duration = duration;

    _prePlay = {'display': displayProperty};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {'display': 'none'};
  }

  /// Standard animation for changing [elementList]'s color from [startColor] to [endColor].
  CustomAnimationMultiple.color(ElementList elementList, Duration duration, String startColor, String endColor) {
    _elementList = elementList;
    _from = {'color': startColor};
    _to = {'color': endColor};
    _duration = duration;

    _prePlay = {};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {};
  }

  /// Standard animation for changing [elementList]'s stroke-dashoffset from
  /// [startOffset] to [endOffset].
  CustomAnimationMultiple.strokeDashOffset(ElementList elementList, Duration duration, int startOffset, int endOffset) {
    _elementList = elementList;
    _from = {'stroke-dashoffset': startOffset.toString()};
    _to = {'stroke-dashoffset': endOffset.toString()};
    _duration = duration;

    _prePlay = {};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {};
  }

  void _assertProperties() {
    if (_from == null || _from.isEmpty) throw AnimationPropertyInvalidException(_from);
    if (_to == null || _to.isEmpty) throw AnimationPropertyInvalidException(_to);
  }

  /// Initializes animation to the [elementList].
  /// This will add transition CSS property and other properties that you set in
  /// [from] and [postRewind] attributes.
  @override
  void init() {
    _setProperties(_elementList, _postRewind);
    _setInitialState(_elementList, _from, _duration);
  }

  /// Initializes animation to the [elementList], from the end.
  /// This will add transition CSS property and other properties that you set in
  /// [to] and [prePlay] attributes.
  @override
  void initFromEnd() {
    _setProperties(_elementList, _prePlay);
    _setInitialState(_elementList, _to, _duration);
  }

  /// Plays the transition from initial state to end state.
  @override
  Future<void> play() async {
    await _setPropertiesWithDelay(_elementList, _prePlay);
    _setEndState(_elementList, _to);
    await Future.delayed(_duration, () {
      _setProperties(_elementList, _postPlay);
    });
  }

  /// Plays the transition from the end state to initial state.
  @override
  Future<void> rewind() async {
    await _setPropertiesWithDelay(_elementList, _preRewind);
    _setEndState(_elementList, _from);
    await Future.delayed(_duration, () {
      _setProperties(_elementList, _postRewind);
    });
  }

  /// Removes the transition and initial state properties from the [elementList].
  void removeAnimation() {
    _from.forEach((property, value) {
      _elementList.forEach((element) {
        element.style.removeProperty(property);
      });
    });
    _elementList.forEach((element) {
      element.style.removeProperty('transition');
    });
  }

  /// Sets the element initial state defined by the [from] map.
  ///
  /// Also sets the transition property of the element to activate CSS animation.
  void _setInitialState(ElementList elementList, Map<String, String> from, Duration duration) {
    var transitionValue = '';
    from.forEach((property, value) {
      transitionValue += property + ' ' + duration.inMilliseconds.toString() + 'ms, ';
      elementList.style.setProperty(property, value);
    });

    transitionValue = transitionValue.substring(0, transitionValue.length - 2);
    elementList.style.transition = transitionValue;
  }

  /// Sets the element end state, effectively triggering the animation.
  void _setEndState(ElementList elementList, Map<String, String> to) {
    _setProperties(elementList, to);
  }

  Future<void> _setPropertiesWithDelay(ElementList elementList, Map<String, String> properties) async {
    _setProperties(elementList, properties);
    if (properties.isNotEmpty) await Future.delayed(Duration(milliseconds: 200));
  }
  
  void _setProperties(ElementList elementList, Map<String, String> properties) {
    properties.forEach((property, value) {
      elementList.style.setProperty(property, value);
    });
  }
}
