part of '../../../spa.dart';

class ComponentNotRenderedException implements Exception {
  String id;

  ComponentNotRenderedException(this.id);

  @override
  String toString() {
    return 'Component #$id is not rendered yet';
  }
}