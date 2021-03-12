part of spa;

class ComponentNoIdException implements Exception {
  String id;

  ComponentNoIdException(this.id);

  @override
  String toString() {
    return 'Component #$id does not contain id="$id" declaration in baseInnerHtml';
  }
}