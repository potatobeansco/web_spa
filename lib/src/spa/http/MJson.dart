part of '../../../spa.dart';

mixin MJson {
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return json.encode(this);
  }
}