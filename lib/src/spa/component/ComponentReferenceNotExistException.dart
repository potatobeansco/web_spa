part of '../../../spa.dart';

class ComponentReferenceNotExistException implements Exception {
  String id;

  ComponentReferenceNotExistException(this.id);

  @override
  String toString() {
    return 'Component #$id does not exist';
  }
}