part of spa;

/// Thrown when you supply null or empty from or to parameters to [CustomAnimation]
/// or [CustomAnimationMultiple].
class AnimationPropertyInvalidException implements Exception {
  Map<String, String> properties;

  AnimationPropertyInvalidException(this.properties);

  @override
  String toString() {
    return 'AnimationPropertyInvalidException: $properties is not a valid animation property';
  }
}