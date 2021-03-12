part of spa;

/// Attaches a CSS transition property to an [Element], along with the set
/// properties. Animation can then be played freely by calling [play] or [rewind].
///
/// Note on animating display: because display is not really a visual CSS property
/// like opacity, height, and so on, it cannot be animated. You often want to use
/// the displayFadeIn, which will change the element display to none when it is
/// invisible and vice versa. When changing the element display, it will introduce a delay of
/// 200ms to let the browser change the display and re-render the element
/// properly. For example when fading in an element with display: none, it will
/// have the display property changed to the intended property (flex, block, and so on)
/// and then it will wait 200ms before the opacity can be animated. This needs
/// to happen as when the display property is changed, the browser needs to
/// re-render the element, which takes time depending on the capability of the
/// CPU. For this reason also, you cannot put display property on CSS3 transition.
/// You can however, have fadeIn only instead, if you do not care about the element
/// taking up space when it's still invisible. fadeIn will not change the display,
/// but only the opacity and so the element will always be rendered but invisible.
class CustomAnimation extends AnimationElement {
  static const SLIDE_DIRECTION_UP = 'top';
  static const SLIDE_DIRECTION_DOWN = 'bottom';
  static const SLIDE_DIRECTION_LEFT = 'left';
  static const SLIDE_DIRECTION_RIGHT = 'right';

  late Element _element;
  late Map<String, String> _from;
  late Map<String, String> _to;
  late Map<String, String> _prePlay;
  late Map<String, String> _postPlay;
  late Map<String, String> _preRewind;
  late Map<String, String> _postRewind;

  Timer? _playTimer;
  Timer? _rewindTimer;
  Completer<void>? _playCompleter;
  Completer<void>? _rewindCompleter;

  /// True if approaching end, false if approaching start.
  bool _state = false;

  /// The element attached to this [CustomAnimation].
  /// In other words, the element that is controlled.
  Element get element => _element;

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

  /// Sets the [element] CSS property with the properties supplied by [from].
  /// Also sets the transition property for the [element].
  ///
  /// Adding properties to prePlay or preRewind will introduce 200ms of delay
  /// before transition, so that the browser can process the properties first
  /// before playing/rewinding. An example of this is [CustomAnimation.displayFadeIn].
  CustomAnimation(Element element,
      Map<String, String> from,
      Map<String, String> to,
      Duration duration,
      {Map<String, String>? prePlay,
        Map<String, String>? postPlay,
        Map<String, String>? preRewind,
        Map<String, String>? postRewind}) {
    _element = element;
    _from = from;
    _to = to;
    _assertProperties();

    _duration = duration;
    _prePlay = (prePlay == null) ? {} : prePlay;
    _postPlay = (postPlay == null) ? {} : postPlay;
    _preRewind = (preRewind == null) ? {} : preRewind;
    _postRewind = (postRewind == null) ? {} : postRewind;
  }

  /// Standard animation for fading in an element (changing its opacity from 0 to
  /// 1).
  CustomAnimation.fadeIn(Element element, Duration duration) {
    _element = element;
    _from = {'opacity': '0'};
    _to = {'opacity': '1'};
    _duration = duration;

    _prePlay = {};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {};
  }

  /// Standard animation for fading in an element (changing its opacity from 0 to
  /// 1), while also sliding it to a direction set by [distance] (by default: 20px).
  CustomAnimation.fadeInSlide(Element element, Duration duration, String direction, {double opacity = 1, double distance = 20.0}) {
    _element = element;
    _from = {'opacity': '0', 'position': 'relative', direction: '${distance.toStringAsFixed(2)}px'};
    _to = {'opacity': opacity.toString(), 'position': 'relative', direction: '0'};
    _duration = duration;

    _prePlay = {};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {};
  }

  /// Standard animation for fading in an element (changing its opacity from 0 to
  /// 1), but also setting the display to the value set by [displayProperty]
  /// first before triggering animation.
  ///
  /// Remember that changing the display of an element adds 200ms of delay before
  /// transition. See also the documentation of [CustomAnimation].
  CustomAnimation.displayFadeIn(Element element, Duration duration, String displayProperty) {
    _element = element;
    _from = {'opacity': '0'};
    _to = {'opacity': '1'};
    _duration = duration;

    _prePlay = {'display': displayProperty};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {'display': 'none'};
  }

  /// Standard animation for changing element's color from [startColor] to [endColor].
  CustomAnimation.color(Element element, Duration duration, String startColor, String endColor) {
    _element = element;
    _from = {'color': startColor};
    _to = {'color': endColor};
    _duration = duration;

    _prePlay = {};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {};
  }

  /// Standard animation for changing element's stroke-dashoffset from
  /// [startOffset] to [endOffset].
  CustomAnimation.strokeDashOffset(Element element, Duration duration, double startOffset, int endOffset) {
    _element = element;
    _from = {'stroke-dashoffset': startOffset.toString()};
    _to = {'stroke-dashoffset': endOffset.toString()};
    _duration = duration;

    _prePlay = {};
    _postPlay = {};
    _preRewind = {};
    _postRewind = {};
  }

  void _assertProperties() {
    if (_from.isEmpty) throw AnimationPropertyInvalidException(_from);
    if (_to == null || _to.isEmpty) throw AnimationPropertyInvalidException(_to);
  }

  /// Initializes animation to the [element].
  /// This will add transition CSS property and other properties that you set in
  /// [from] and [postRewind] attributes.
  @override
  void init() {
    _setProperties(_element, _postRewind);
    _setInitialState(_element, _from, _duration);
    _state = false;
  }

  /// Initializes animation to the [element], from the end.
  /// This will add transition CSS property and other properties that you set in
  /// [to] and [prePlay] attributes.
  @override
  void initFromEnd() {
    _setProperties(_element, _prePlay);
    _setInitialState(_element, _to, _duration);
    _state = true;
  }

  /// Plays the transition from initial state to end state.
  @override
  Future<void> play() async {
    _rewindTimer?.cancel();
    try {
      if (_rewindCompleter != null && !_rewindCompleter!.isCompleted) _rewindCompleter!.complete();
    } catch (e) {
      print('Completer already completed in play()');
    }
    if (_state) return Future.value();

    _state = true;
    await _setPropertiesWithDelay(_element, _prePlay);
    _setEndState(_element, _to);

    _playCompleter = Completer<void>.sync();
    _playTimer = Timer(_duration, () {
      _setProperties(_element, _postPlay);
      _playCompleter!.complete();
    });

    return _playCompleter!.future;
  }

  /// Plays the transition from the end state to initial state.
  @override
  Future<void> rewind() async {
    _playTimer?.cancel();
    try {
      if (_playCompleter != null && !_playCompleter!.isCompleted) _playCompleter!.complete();
    } catch (e) {
      print('Completer already completed in rewind()');
    }
    if (!_state) return Future.value();

    _state = false;
    await _setPropertiesWithDelay(_element, _preRewind);
    _setEndState(_element, _from);

    _rewindCompleter = Completer<void>.sync();
    _rewindTimer = Timer(_duration, () {
      _setProperties(_element, _postRewind);
      _rewindCompleter!.complete();
    });

    return _rewindCompleter!.future;
  }

  /// Rewind animation if it's already played, play the animation if it's already rewound.
  Future<void> toggle() async {
    if (_state) {
      await rewind();
    } else {
      await play();
    }
  }

  /// Removes the transition and initial state properties from the [element].
  void removeAnimation() {
    _from.forEach((property, value) {
      _element.style.removeProperty(property);
    });
    _element.style.removeProperty('transition');
  }

  /// Sets the element initial state defined by the [from] map.
  ///
  /// Also sets the transition property of the element to activate CSS animation.
  void _setInitialState(Element element, Map<String, String> from, Duration duration) {
    var transitionValue = '';
    from.forEach((property, value) {
      transitionValue += property + ' ' + duration.inMilliseconds.toString() + 'ms, ';
      element.style.setProperty(property, value);
    });

    transitionValue = transitionValue.substring(0, transitionValue.length - 2);
    element.style.transition = transitionValue;
  }

  /// Sets the element end state, effectively triggering the animation.
  void _setEndState(Element element, Map<String, String> to) {
    _setProperties(element, to);
  }

  /// Sets the element properties defined by [properties], but introduces
  /// 200ms of delay.
  ///
  /// The delay introduced here is to wait until the element really is processed
  /// completely by the browser. This is useful if you want to set the property
  /// and immediately trigger and animation afterwards. In slow browsers, even
  /// 200ms of delay probably is not enough. In that case, the animation will
  /// not run but the element will change to its end state immediately anyway.
  Future<void> _setPropertiesWithDelay(Element element, Map<String, String> properties) async {
    _setProperties(element, properties);
    if (properties.isNotEmpty) await Future.delayed(Duration(milliseconds: 200));
  }

  /// Sets the element properties defined by [properties].
  void _setProperties(Element element, Map<String, String> properties) {
    properties.forEach((property, value) {
      element.style.setProperty(property, value);
    });
  }
}
