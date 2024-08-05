library spa;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:spa/logutil.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

part 'src/spa/animation/AnimationElement.dart';
part 'src/spa/animation/AnimationPropertyInvalidException.dart';
part 'src/spa/animation/CustomAnimation.dart';
part 'src/spa/animation/CustomAnimationDelay.dart';
part 'src/spa/animation/CustomAnimationMultiple.dart';
part 'src/spa/animation/MAnimationQueue.dart';

part 'src/spa/component/Component.dart';
part 'src/spa/component/ComponentDuplicateIdException.dart';
part 'src/spa/component/ComponentNotAttachedException.dart';
part 'src/spa/component/ComponentNotRenderedException.dart';
part 'src/spa/component/ComponentNoParentException.dart';
part 'src/spa/component/ComponentNoIdException.dart';
part 'src/spa/component/ComponentReferenceNotExistException.dart';
part 'src/spa/component/DocumentComponent.dart';
part 'src/spa/component/MTwoWayValue.dart';
part 'src/spa/component/MEventHandler.dart';
part 'src/spa/component/RenderComponent.dart';
part 'src/spa/component/StdNodeValidator.dart';
part 'src/spa/component/StringComponent.dart';
part 'src/spa/component/StringComponentList.dart';
part 'src/spa/component/TrustedNodeValidator.dart';
part 'src/spa/component/Waypoint.dart';

part 'src/spa/http/HttpUtil.dart';
part 'src/spa/http/HttpUtilResponse.dart';
part 'src/spa/http/HttpUtilConnectionException.dart';
part 'src/spa/http/HttpUtilUnexpectedException.dart';
part 'src/spa/http/MJson.dart';

part 'src/spa/router/ComponentRouter.dart';
part 'src/spa/router/Route.dart';
part 'src/spa/router/BaseRenderer.dart';
part 'src/spa/router/ListRenderer.dart';

typedef OnClickFunc = void Function(MouseEvent event);
