library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:web_spa/logutil.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:web/web.dart';

part 'src/spa/component/Component.dart';
part 'src/spa/component/ComponentDuplicateIdException.dart';
part 'src/spa/component/ComponentNotAttachedException.dart';
part 'src/spa/component/ComponentNotRenderedException.dart';
part 'src/spa/component/ComponentNoParentException.dart';
part 'src/spa/component/ComponentNoIdException.dart';
part 'src/spa/component/ComponentReferenceNotExistException.dart';
part 'src/spa/component/DocumentComponent.dart';
part 'src/spa/component/MEventHandler.dart';
part 'src/spa/component/RenderComponent.dart';
part 'src/spa/component/StringComponent.dart';
part 'src/spa/component/StringComponentList.dart';
part 'src/spa/component/Waypoint.dart';

part 'src/spa/http/HttpUtil.dart';
part 'src/spa/http/HttpUtilConnectionException.dart';
part 'src/spa/http/HttpUtilResponse.dart';
part 'src/spa/http/HttpUtilUnexpectedException.dart';
part 'src/spa/http/MJson.dart';

part 'src/spa/router/ComponentRouter.dart';
part 'src/spa/router/Route.dart';
part 'src/spa/router/BaseRenderer.dart';
part 'src/spa/router/ListRenderer.dart';

typedef OnClickFunc = void Function(MouseEvent event);
