part of spa;

/// Animation queue capability for a [Component].
/// It comes with a default animation queue, that can be filled and then played
/// sequentially, or simultaneously.
///
/// To use this mixin, add this mixin to your newly made [Component] subclass.
/// Then, starts adding [CustomAnimation], [CustomAnimationMultiple], or
/// [CustomAnimationDelay] to the queue with some add methods defined here.
/// As said before, it contains an animation queue, which merely is just a list.
/// Every element in the list will be played sequentially. Every element in the
/// list is not just a single animation, but can be multiple simultaneous
/// animations which can be added with [addSimultaneousAnimations] method.
///
/// For example, if you do:
/// * addSingleAnimation for component A
/// * addSimultaneousAnimations for component B, C, D
/// * addSingleAnimation for component E
/// When played sequentially, it will play animation for component A, then B, C,
/// and D simultaneously, and finally E. If played simultaneously, all
/// animations will be played simultaneously anyway. The same behavior applies
/// to rewind.
///
/// P.S. Simultaneous playing/rewinding skips any [CustomAnimationDelay].
mixin MAnimationQueue {
  final AnimationQueue _defaultQueue = AnimationQueue();

  AnimationQueue createQueue() => AnimationQueue();

  /// This should be called when you want to animate all animations in the queue
  /// immediately after the component is rendered. It adds 100ms of delay.
  ///
  /// This ensures that the browser has finished rendering the component to DOM.
  /// If animation is started without this delay, the animation usually fails
  /// to start, but will go to the end state anyway.
  Future<void> animationRenderDelay() async {
    await _defaultQueue.animationRenderDelay();
  }

  /// Adds delay to the queue.
  void addAnimationDelay(Duration duration) {
    _defaultQueue.addAnimationDelay(duration);
  }

  /// Adds a single animation to the queue.
  void addSingleAnimation(CustomAnimation customAnimation) {
    _defaultQueue.addSingleAnimation(customAnimation);
  }

  /// Adds multiple animations that will be played at once to the queue.
  void addSimultaneousAnimations(List<CustomAnimation> customAnimations) {
    _defaultQueue.addSimultaneousAnimations(customAnimations);
  }

  /// Initializes all animations in the queue.
  void initAnimations() {
    _defaultQueue.initAnimations();
  }

  /// Plays all animations sequentially.
  /// If you add simultaneous animations at once to the queue with
  /// [addSimultaneousAnimations], these will still be played simultaneously.
  ///
  /// See also this class documentation.
  Future<void> playAnimationSequential() async {
    await _defaultQueue.playAnimationSequential();
  }

  /// Plays all animations simultaneously.
  ///
  /// See also this class documentation.
  Future<void> playAnimationSimultaneous() async {
    await _defaultQueue.playAnimationSimultaneous();
  }

  /// Rewinds all animations sequentially.
  /// If you add simultaneous animations at once to the queue with
  /// [addSimultaneousAnimations], these will still be rewind simultaneously.
  ///
  /// See also this class documentation.
  Future<void> rewindAnimationSequential() async {
    await _defaultQueue.rewindAnimationSequential();
  }

  /// Rewinds all animations simultaneously.
  ///
  /// See also this class documentation.
  Future rewindAnimationSimultaneous() async {
    await _defaultQueue.rewindAnimationSimultaneous();
  }
}

/// A custom [AnimationQueue].
/// Create a custom queue to avoid breaking with other animation queue in the
/// same component, or even with the default queue that is usually used for
/// the component rendering/closing animations.
class AnimationQueue {
  final List<List<AnimationElement>> _animations = [];

  /// This should be called when you want to animate all animations in the queue
  /// immediately after the component is rendered. It adds 100ms of delay.
  ///
  /// This ensures that the browser has finished rendering the component to DOM.
  /// If animation is started without this delay, the animation usually fails
  /// to start, but will go to the end state anyway.
  Future<void> animationRenderDelay() async {
    await Future.delayed(Duration(milliseconds: 100));
  }

  /// Adds delay to the queue.
  void addAnimationDelay(Duration duration) {
    _animations.add([CustomAnimationDelay(duration)]);
  }

  /// Adds a single animation to the queue.
  void addSingleAnimation(CustomAnimation customAnimation) {
    _animations.add([customAnimation]);
  }

  /// Adds multiple animations that will be played at once to the queue.
  void addSimultaneousAnimations(List<CustomAnimation> customAnimations) {
    _animations.add(customAnimations);
  }

  /// Initializes all animations in the queue.
  void initAnimations() {
    _animations.forEach((animationPack) {
      animationPack.forEach((animation) {
        animation.init();
      });
    });
  }

  /// Plays all animations sequentially.
  /// If you add simultaneous animations at once to the queue with
  /// [addSimultaneousAnimations], these will still be played simultaneously.
  ///
  /// See also MAnimationQueue documentation.
  Future<void> playAnimationSequential() async {
    for (var i = 0; i < _animations.length; i++) {
      var animationFutures = <Future>[];
      for (var j = 0; j < _animations[i].length; j++) {
        animationFutures.add(_animations[i][j].play());
      }

      await Future.wait(animationFutures);
    }
  }

  /// Plays all animations simultaneously.
  ///
  /// See also MAnimationQueue documentation.
  Future<void> playAnimationSimultaneous() async {
    var animationFutures = <Future>[];
    for (var i = 0; i < _animations.length; i++) {
      for (var j = 0; j < _animations[i].length; j++) {
        if (!(_animations[i][j] is CustomAnimationDelay)) animationFutures.add(_animations[i][j].play());
      }
    }

    await Future.wait(animationFutures);
  }

  /// Rewinds all animations sequentially.
  /// If you add simultaneous animations at once to the queue with
  /// [addSimultaneousAnimations], these will still be rewind simultaneously.
  ///
  /// See also MAnimationQueue documentation.
  Future<void> rewindAnimationSequential() async {
    for (var i = _animations.length - 1; i >= 0; i--) {
      var animationFutures = <Future>[];
      for (var j = 0; j < _animations[i].length; j++) {
        animationFutures.add(_animations[i][j].rewind());
      }

      await Future.wait(animationFutures);
    }
  }

  /// Rewinds all animations simultaneously.
  ///
  /// See also MAnimationQueue documentation.
  Future<void> rewindAnimationSimultaneous() async {
    List<Future> animationFutures = []; // ignore: omit_local_variable_types
    for (var i = _animations.length - 1; i >= 0; i--) {
      for (var j = 0; j < _animations[i].length; j++) {
        if (!(_animations[i][j] is CustomAnimationDelay)) animationFutures.add(_animations[i][j].rewind());
      }
    }

    await Future.wait(animationFutures);
  }
}