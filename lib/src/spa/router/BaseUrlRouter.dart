part of '../../../spa.dart';

class BaseUrlRouter extends BaseRouter {
  late List<String> _patternSplit;
  late bool _patternIsExact;
  final Map<int, String> _paramPlaceholders = {};

  BaseUrlRouter(String pattern, String routerElementBind) : super(routerElementBind) {
    var normalized = path.normalize(pattern);
    _patternSplit = path.split(normalized);
    for (var i = 0; i < _patternSplit.length; i++) {
      var p = _patternSplit[i];
      if (p[0] == '[' && p.length >= 3 && p[p.length-1] == ']') {
        var paramName = p.substring(1, p.length-1);
        _paramPlaceholders[i] = paramName;
      }
    }

    _patternIsExact = pattern[pattern.length-1] != '/';
  }

  bool isMatch(Uri uri) {
    var splitPaths = path.split(path.normalize(uri.path));
    if (splitPaths.length < _patternSplit.length) return false;

    if (_patternIsExact && splitPaths.length != _patternSplit.length) return false;

    var match = true;
    for (var i = 0; i < _patternSplit.length; i++) {
      if (_paramPlaceholders[i] != null) continue;
      if (splitPaths[i] != _patternSplit[i]) match = false;
    }

    return match;
  }

  Map<String, String> extractParams(Uri uri) {
    if (!isMatch(uri)) throw RouterNoMatch();
    if (_paramPlaceholders.isEmpty) return {};

    var splitPaths = path.split(path.normalize(uri.path));
    var result = <String, String>{};
    for (var i = 0; i < _patternSplit.length; i++) {
      if (_paramPlaceholders[i] == null) continue;
      result[_paramPlaceholders[i]!] = splitPaths[i];
    }

    return result;
  }
}

class RouterNoMatch implements Exception {
  @override
  String toString() {
    return 'given URL does not match with the pattern';
  }
}