part of spa;

abstract class AnimationElement {
  late Duration _duration;

  void init();
  void initFromEnd();
  Future<void> play();
  Future<void> rewind();
}