part of spa;

/// Useful class for building animation queue.
/// This class, like [CustomAnimation], has [play] and [rewind] methods, which
/// actually only triggers the delay.
class CustomAnimationDelay extends AnimationElement {
  /// Updates the duration of the delay.
  set duration(Duration duration) {
    _duration = duration;
  }

  /// Straightforward, the duration of the delay.
  Duration get duration => _duration;

  /// Creates a delay with duration of [duration].
  CustomAnimationDelay(Duration duration) {
    _duration = duration;
  }

  /// Does nothing, for now.
  @override
  @experimental
  void init() {}

  /// DOes nothing, for now.
  @override
  @experimental
  void initFromEnd() {}

  /// Triggers the delay specified by duration.
  @override
  Future<void> play() async {
    return Future.delayed(_duration, () {});
  }

  /// Does exactly the same as [play].
  @override
  Future<void> rewind() async {
    return play();
  }
}