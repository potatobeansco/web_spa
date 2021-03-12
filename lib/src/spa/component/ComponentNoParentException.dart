part of spa;

class ComponentNoParentException implements Exception {
  String id;

  ComponentNoParentException(this.id);

  @override
  String toString() {
    return 'Component #$id cannot be rendered because the parent does not exist';
  }
}