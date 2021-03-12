part of '../../../spa.dart';

abstract class BaseRouter {
  Route? currentRoute;
  String routerElementBind;

  BaseRouter(this.routerElementBind);
}