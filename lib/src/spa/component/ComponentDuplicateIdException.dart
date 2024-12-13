part of '../../../spa.dart';

class ComponentDuplicateIdException implements Exception {
  String id;

  ComponentDuplicateIdException(this.id);

  @override
  String toString() {
    return '#$id already exists in DOM';
  }
}