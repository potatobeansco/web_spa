# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2.0.0-alpha.7] - 2025-04-16

### Added

- returnResponseAsBytes boolean parameter, replacing responseType in HttpUtil methods, to return HttpUtilResponse with body set as Uint8List.

## [2.0.0-alpha.6] - 2025-04-09

### Fixed

- Now _resizeObserverCallback use specified parameter type instead of dynamic.

## [2.0.0-alpha.5] - 2025-03-08

Previous versions were unreleased. The current version 2 of `spa` now depends
on `package:web` instead of the deprecated `dart:html` and mostly depends on
the new Dart JS interop.

### Added

- This repository in pub.dev and github.

### Changed

- Now using `package:web`
- Now using `package:http`
- Now using `dart:js_interop`