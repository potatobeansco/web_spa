part of '../../../spa.dart';

class ComponentNotAttachedException implements Exception {
  String id;

  ComponentNotAttachedException(this.id);

  @override
  String toString() {
    return 'StringComponent #$id cannot be modified because it has not been attached to the parent';
  }
}