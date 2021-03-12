part of spa;

class StdNodeValidator implements NodeValidator {
  late NodeValidatorBuilder _nodeValidator;

  StdNodeValidator() {
    _nodeValidator = NodeValidatorBuilder.common();
    _nodeValidator.allowSvg();
    _nodeValidator.allowImages(_AllowAllUriPolicy());
  }

  @override
  bool allowsAttribute(Element element, String attributeName, String value) {
    return _nodeValidator.allowsAttribute(element, attributeName, value);
  }

  @override
  bool allowsElement(Element element) {
    return _nodeValidator.allowsElement(element);
  }
}

class _AllowAllUriPolicy implements UriPolicy {
  @override
  bool allowsUri(String uri) {
    return true;
  }
}