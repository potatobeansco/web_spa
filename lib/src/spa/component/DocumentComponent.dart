part of '../../../spa.dart';

/// The main component.
/// DocumentComponent has access to HtmlDocument.
abstract class DocumentComponent extends RenderComponent {
  DocumentComponent(String id) : super.empty(id);

  BodyElement get body => document.body!;

  Future<void> init() async {
    await preRender();
    body.children.clear();
    body.children.add(baseInnerElement!);
    parentId = 'body';
    await postRender();
  }
}