part of spa;

class TrustedNodeValidator implements NodeValidator {
  @override
  bool allowsAttribute(Element element, String attributeName, String value) => true;

  @override
  bool allowsElement(Element element) => true;
}