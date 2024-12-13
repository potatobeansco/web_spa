part of '../../../spa.dart';

/// The main component.
/// DocumentComponent has access to HtmlDocument.
abstract class DocumentComponent extends RenderComponent {
  DocumentComponent(super.id) : super.empty();

  Future<void> init() async {
    await preRender();
    document.body!.innerHTML = ''.toJS;
    document.body!.appendChild(baseInnerElement!);
    await postRender();
  }
}