part of '../../graph.dart';

/// [LineGraphComponent] is a canvas and SVG elements used to draw line graph.
/// The canvas is NOT responsive. Even if you use width 100% on this component,
/// you have to redraw the canvas in order for the canvas to resize. This can
/// be achieved by calling [redraw] under [Window.onResize].
///
/// The line graph itself and the data points are drawn on the canvas. On top
/// of that is an SVG element, used to display captions under data points
/// dynamically. Currently, the way it displays captions cannot be changed.
class LineGraphComponent extends CanvasBaseGraphComponent {
  static const keyAllGraph = BaseGraphComponent.keyAllGraph;

  /// Dot point size. Just to remind you, dot point is each point
  /// in the graph that represents a data point.
  Map<String, double> dotRadius = const {};
  /// Hover dot area radius offset. By default the hover dot area is equal to
  /// the dot point area size. Just to remind you, dot point is each point
  /// in the graph that represents a data point.
  ///
  /// You may want to increase the hover area if you feel that the dot point
  /// is too small to hover, but don't want to increase the dot point size.
  Map<String, double> hoverDotRadiusOffset = const {};
  /// Dot point fill style.
  Map<String, String> dotFillStyle = const {};
  /// Dot point stroke style.
  Map<String, String> dotStrokeStyle = const {};
  /// Dot point stroke width.
  Map<String, double> dotStrokeWidth = const {};
  /// Graph line stroke style.
  Map<String, String> dataLineStrokeStyle = const {};
  /// The graph line width.
  Map<String, double> dataLineWidth = const {};
  /// The fill style for the shading under graph line.
  Map<String, String> shadingFillStyle = const {};
  /// The minimum width of the graph.
  /// The minimum width of the graph cannot be lower than
  /// [getLabelCountX] * ([maxLabelWidthX] + 10). This is so there are no labels
  /// that are overlapping with each other because the width of the graph is
  /// too short. You can however override this behavior by setting [minWidthOverride]
  /// to true.
  double minWidth;
  /// See also [minWidth].
  bool minWidthOverride = false;

  late Map<String, SplayTreeMap<double, double>> _dataPoints;
  /// The minimum X point in [_dataPoints].
  /// Used to generate the minimum/maximum label value if label value range was not
  /// defined. See also [labelMinX] and others in constructor.
  double _dataPointMinX = 0;
  /// The maximum X point in [_dataPoints].
  /// Used to generate the minimum/maximum label value if label value range was not
  /// defined. See also [labelMinX] and others in constructor.
  double _dataPointMaxX = 100;
  /// The minimum Y point in [_dataPoints].
  /// Used to generate the minimum/maximum label value if label value range was not
  /// defined. See also [labelMinX] and others in constructor.
  double _dataPointMinY = 0;
  /// The maximum Y point in [_dataPoints].
  /// Used to generate the minimum/maximum label value if label value range was not
  /// defined. See also [labelMinX] and others in constructor.
  double _dataPointMaxY = 10;

  /// List of dots that are drawn on the graph.
  final Map<String, Map<MapEntry<double, double>, Path2D>> _hoverPaths = {};

  int? _initialLabelCountX;
  int? _initialLabelCountY;
  double? _initialLabelMinX;
  double? _initialLabelMinY;
  double? _initialLabelMaxX;
  double? _initialLabelMaxY;

  StreamSubscription<MouseEvent>? _onMouseMoveSubs;
  StreamSubscription<MouseEvent>? _onMouseClickSubs;
  StreamSubscription<MouseEvent>? _onCaptionClickSubs;

  Function(double x, double y, double coordX, double coordY)? onHover;
  Function()? onHoverOut;

  LineGraphComponent(super.parent, super.id,
      {Map<String, List<DataPoint>> points = const {},
        int? labelCountX,
        int? labelCountY,
        double? labelMinX,
        double? labelMinY,
        double? labelMaxX,
        double? labelMaxY,
        super.maxLabelWidthX,
        super.maxLabelWidthY,
        super.textMargin,
        super.labelFormatX = _defaultLabelFormat,
        super.labelFormatY = _defaultLabelFormat,
        super.aspectRatio,
        super.gridLineWidth,
        super.gridLineStrokeStyle,
        super.labelFillStyle,
        super.labelFontStyle,
        this.dotRadius = const {keyAllGraph: 6},
        this.hoverDotRadiusOffset = const {keyAllGraph: 0},
        this.dotFillStyle = const {keyAllGraph: 'white'},
        this.dotStrokeStyle = const {keyAllGraph: '#2d2d2d'},
        this.dotStrokeWidth = const {keyAllGraph: 1},
        this.dataLineStrokeStyle = const {keyAllGraph: '#aaaaaa'},
        this.dataLineWidth = const {keyAllGraph: 2},
        this.shadingFillStyle = const {keyAllGraph: 'rgba(0, 0, 0, 0.2)'},
        super.captionBgColor,
        super.captionFgColor,
        super.captionFontFamily,
        super.drawGridY,
        this.minWidth = 500,
        this.minWidthOverride = false,
        this.onHover,
        this.onHoverOut
      }) {
    _dataPoints = points.map(
            (key, value) =>
                MapEntry<String, SplayTreeMap<double, double>>(
                    key,
                    SplayTreeMap<double, double>.fromIterable(value, key: (e) => e.x, value: (e) => e.y)
                )
    );
    if (!dotRadius.containsKey(keyAllGraph)) dotRadius[keyAllGraph] = 6;
    if (!hoverDotRadiusOffset.containsKey(keyAllGraph)) hoverDotRadiusOffset[keyAllGraph] = 0;
    if (!dotFillStyle.containsKey(keyAllGraph)) dotFillStyle[keyAllGraph] = 'white';
    if (!dotStrokeStyle.containsKey(keyAllGraph)) dotStrokeStyle[keyAllGraph] = '#2d2d2d';
    if (!dotStrokeWidth.containsKey(keyAllGraph)) dotStrokeWidth[keyAllGraph] = 1;
    if (!dataLineStrokeStyle.containsKey(keyAllGraph)) dataLineStrokeStyle[keyAllGraph] = '#aaaaaa';
    if (!dataLineWidth.containsKey(keyAllGraph)) dataLineWidth[keyAllGraph] = 2;
    if (!shadingFillStyle.containsKey(keyAllGraph)) shadingFillStyle[keyAllGraph] = 'rgba(0, 0, 0, 0.2)';

    _initialLabelCountX = labelCountX;
    _initialLabelCountY = labelCountY;
    _initialLabelMinX = labelMinX;
    _initialLabelMinY = labelMinY;
    _initialLabelMaxX = labelMaxX;
    _initialLabelMaxY = labelMaxY;

    _setMinMaxXY();
  }

  set labelCountX(int labelCountX) {
    _initialLabelCountX = labelCountX;
  }

  set labelCountY(int labelCountY) {
    _initialLabelCountY = labelCountY;
  }

  set labelMinX(double labelMinX) {
    _initialLabelMinX = labelMinX;
  }

  set labelMinY(double labelMinY) {
    _initialLabelMinY = labelMinY;
  }

  set labelMaxX(double labelMaxX) {
    _initialLabelMaxX = labelMaxX;
  }

  set labelMaxY(double labelMaxY) {
    _initialLabelMaxY = labelMaxY;
  }

  /// The default label formatting function.
  /// It uses [NumberFormat.compact] to format label values. See also [labelFormatX]
  /// and [labelFormatY].
  static String _defaultLabelFormat(double label) {
    return NumberFormat.compact().format(label);
  }

  /// Searches for the minimum and maximum X and Y points throughout the entire
  /// point sets.
  void _setMinMaxXY() {
    if (_dataPoints.isNotEmpty && _dataPoints.values.every((element) => element.isNotEmpty)) {
      var xMin = double.infinity;
      var xMax = double.negativeInfinity;
      for (var dataPoint in _dataPoints.values) {
        if (dataPoint.firstKey()! < xMin) xMin = dataPoint.firstKey()!;
        if (dataPoint.lastKey()! > xMax) xMax = dataPoint.lastKey()!;
      }
      _dataPointMinX = xMin;
      _dataPointMaxX = xMax;

      var yMin = double.infinity;
      var yMax = double.negativeInfinity;
      for (var value in _dataPoints.values) {
        for (var y in value.values) {
          if (y > yMax) {
            yMax = y;
          }

          if (y < yMin) {
            yMin = y;
          }
        }
      }
      _dataPointMinY = yMin;
      _dataPointMaxY = yMax;
    }
  }

  /// Sets the data points stored in this graph, and redraw the graph.
  /// See also [redraw].
  void setDataPoints(String key, List<DataPoint> points) {
    _dataPoints[key] = SplayTreeMap<double, double>.fromIterable(points, key: (e) => e.x, value: (e) => e.y);
    _setMinMaxXY();
    clearDrawing();
    redraw();
  }

  /// Gets the calculated minimum width of the graph, depending on
  /// [minWidthOverride] and of course, [minWidth].
  @override
  double getCalculatedMinWidth() {
    if (minWidthOverride) {
      return minWidth;
    }

    return max((getLabelCountX() * (maxLabelWidthX + 10)), minWidth);
  }

  /// Hides the caption if it's already shown.
  void _hideCaption() {
    _captionElem.setAttribute('visibility', 'hidden');
  }

  /// Draw grid lines spanning left to right, lines that are parallel
  /// with the X axis. If `true` is supplied in [drawY], Y axis lines are drawn
  /// too.
  @override
  void drawGrid([bool drawY = false]) {
    var labelCountY = getLabelCountY();
    var rangeY = gridMaxPxY - gridMinPxY;
    var spaceY = rangeY/(labelCountY-1);

    ctx.strokeStyle = gridLineStrokeStyle.toJS;
    ctx.lineWidth = gridLineWidth;
    for (var i = 0; i < labelCountY; i++) {
      ctx.beginPath();
      ctx.moveTo(gridMinPxX, gridMinPxY + spaceY*i);
      ctx.lineTo(gridMaxPxX, gridMinPxY + spaceY*i);
      ctx.stroke();
    }

    if (drawY) {
      var labelCountX = getLabelCountX();
      var rangeX  = gridMaxPxX - gridMinPxX;
      var spaceX = rangeX/(labelCountX-1);
      for (var i = 0; i < labelCountX; i++) {
        ctx.beginPath();
        ctx.moveTo(gridMinPxX + spaceX*i, gridMinPxY);
        ctx.lineTo(gridMinPxX + spaceX*i, gridMaxPxY);
        ctx.stroke();
      }
    }
  }

  /// Draws text labels.
  /// Labels must be drawn only after drawing the data points.
  @override
  void drawLabels() {
    var labelCountX = getLabelCountX();
    var labelCountY = getLabelCountY();
    var rangeX  = gridMaxPxX - gridMinPxX;
    var rangeY = gridMaxPxY - gridMinPxY;

    var minX = getLabelMinX();
    var minY = getLabelMinY();
    var maxX = getLabelMaxX();
    var maxY = getLabelMaxY();

    var spaceX = rangeX/(labelCountX-1);
    var spaceY = rangeY/(labelCountY-1);
    var intervalX = (maxX - minX)/(labelCountX-1);
    var intervalY = (maxY - minY)/(labelCountY-1);

    ctx.font = labelFontStyle;
    ctx.shadowColor = '';
    ctx.shadowBlur = 0;
    ctx.shadowOffsetX = 0;
    ctx.shadowOffsetY = 0;
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'right';
    ctx.fillStyle = labelFillStyle.toJS;
    for (var i = 0; i < labelCountY; i++) {
      ctx.fillText(labelFormatY(maxY - intervalY*i), gridMinPxX - textMargin, gridMinPxY + spaceY*i, maxLabelWidthY);
    }

    ctx.textAlign = 'center';
    ctx.textBaseline = 'top';
    for (var i = 0; i < labelCountX; i++) {
      ctx.fillText(labelFormatX((minX + intervalX*i)), gridMinPxX + spaceX*i, gridMaxPxY + textMargin, maxLabelWidthX);
    }
  }

  /// Draws graph data points, clearing areas outside the grid.
  /// It is possible that some data points lie outside the graph grid, whether
  /// it lies outside of the X range or Y range or both. Those that are out
  /// of range will be removed, but a line will still be drawn towards the
  /// "invisible" data point.
  ///
  /// Because areas outside the grid will be cleared (to clear out those liens
  /// and shading that are caused by points that are out of range), text labels
  /// must be drawn only after drawing data points.
  @override
  void drawDataPoints() {
    var minX = getLabelMinX();
    var minY = getLabelMinY();
    var maxX = getLabelMaxX();
    var maxY = getLabelMaxY();
    var allMapPoints = { for (var e in _dataPoints.entries) e.key : SplayTreeMap<double, double>.from(e.value) };
    var allDotPoints = <String, SplayTreeMap<double, double>>{};
    var allLinePoints = <String, SplayTreeMap<double, double>>{};
    // ctx.globalCompositeOperation = 'source-over';
    allMapPoints.forEach((key, mapPoints) {
      var belowRange = <double>[];
      var aboveRange = <double>[];
      mapPoints.forEach((key, value) {
        if (key < minX) {
          belowRange.add(key);
        } else if (key > maxX) {
          aboveRange.add(key);
        }
      });

      // Remove all points but one that are below range.
      // The closest point that is below range is skipped.
      if (belowRange.length > 1) {
        for (var i = 0; i < belowRange.length - 1; i++) {
          mapPoints.remove(belowRange[i]);
        }
      }

      // Remove all points but one that are above range.
      // The closest point that is above range is skipped.
      if (aboveRange.length > 1) {
        aboveRange.removeAt(0);
        for (var i = 1; i < aboveRange.length; i++) {
          mapPoints.remove(aboveRange[i]);
        }
      }

      _hoverPaths.clear();
      // Points that need to be drawn as dots.
      allDotPoints[key] = SplayTreeMap<double, double>.from(mapPoints);
      var dotPoints = allDotPoints[key]!;
      // Points that the line graph has to go through, this includes interpolated
      // points.
      allLinePoints[key] = SplayTreeMap<double, double>.from(mapPoints);
      var linePoints = allLinePoints[key]!;

      // If the first point that is in range is == max, also remove
      // all points that are below range.
      if (belowRange.isNotEmpty) {
        dotPoints.remove(dotPoints.firstKey());
        linePoints.remove(linePoints.firstKey());
        if (mapPoints.firstKeyAfter(mapPoints.firstKey()!) == minX) {
          mapPoints.remove(mapPoints.firstKey());
        } else {
          var x1 = mapPoints.firstKey()!;
          var x2 = mapPoints.firstKeyAfter(mapPoints.firstKey()!)!;
          var y1 = mapPoints[x1]!;
          var y2 = mapPoints[x2]!;
          linePoints[minX] = lerp(minX, x1, x2, y1, y2);
        }
      }

      // If the last point that is in range is == max, also remove
      // all points that are above range.
      if (aboveRange.isNotEmpty) {
        dotPoints.remove(dotPoints.lastKey());
        linePoints.remove(linePoints.lastKey());
        if (mapPoints.lastKeyBefore(mapPoints.lastKey()!) == maxX) {
          mapPoints.remove(mapPoints.lastKey());
        } else {
          var x1 = mapPoints.lastKeyBefore(mapPoints.lastKey()!)!;
          var x2 = mapPoints.lastKey()!;
          var y1 = mapPoints[x1]!;
          var y2 = mapPoints[x2]!;
          linePoints[maxX] = lerp(maxX, x1, x2, y1, y2);
        }
      }

      // At this point, all points should be in range, with one point below
      // and one point outside range, if needed, however, this is only for x.
      // Dot points that are out of range of Y range will just be removed.
      // Line points are not removed, they are still drawn even when out of the grid,
      // but later will be masked with clearRect.
      var outsideRangeY = SplayTreeMap<double, double>();
      mapPoints.forEach((x, y) {
        if (y > maxY || y < minY) {
          outsideRangeY[x] = y;
        }
      });
      dotPoints.removeWhere((key, value) => outsideRangeY.containsKey(key));

      ctx.globalCompositeOperation = 'lighter';
      if (linePoints.isNotEmpty) {
        // Draw shading.
        ctx.beginPath();
        ctx.fillStyle = (shadingFillStyle[key] ?? shadingFillStyle[keyAllGraph])!.toJS;
        ctx.moveTo(lerp(linePoints.firstKey()!, minX, maxX, gridMinPxX, gridMaxPxX), gridMaxPxY);
        linePoints.forEach((x, y) {
          ctx.lineTo(lerp(x, minX, maxX, gridMinPxX, gridMaxPxX), lerp(y, minY, maxY, gridMaxPxY, gridMinPxY));
        });
        ctx.lineTo(lerp(linePoints.lastKey()!, minX, maxX, gridMinPxX, gridMaxPxX), gridMaxPxY);
        ctx.fill();
      }
    });

    ctx.globalCompositeOperation = 'source-over';

    allMapPoints.forEach((key, value) {
      var linePoints = allLinePoints[key]!;
      if (linePoints.isNotEmpty) {
        // Draw line.
        ctx.beginPath();
        ctx.moveTo(lerp(linePoints.firstKey()!, minX, maxX, gridMinPxX, gridMaxPxX), lerp(linePoints[linePoints.firstKey()!]!, minY, maxY, gridMaxPxY, gridMinPxY));
        ctx.lineWidth = dataLineWidth[key] ?? dataLineWidth[keyAllGraph]!;
        ctx.strokeStyle = (dataLineStrokeStyle[key] ?? dataLineStrokeStyle[keyAllGraph])!.toJS;
        linePoints.forEach((x, y) {
          ctx.lineTo(lerp(x, minX, maxX, gridMinPxX, gridMaxPxX), lerp(y, minY, maxY, gridMaxPxY, gridMinPxY));
        });
        ctx.stroke();
      }
    });

    // Mask all lines and shading that are outside of the grid.
    ctx.clearRect(0, gridMaxPxY, ctx.canvas.width, ctx.canvas.height - gridMaxPxY);
    ctx.clearRect(0, 0, gridMinPxX, ctx.canvas.height);
    ctx.clearRect(0, 0, ctx.canvas.width, gridMinPxY);
    ctx.clearRect(gridMaxPxX, 0, ctx.canvas.width - gridMaxPxX, ctx.canvas.height);

    _hoverPaths.clear();
    allMapPoints.forEach((key, value) {
      var dotPoints = allDotPoints[key]!;
      if (dotPoints.isNotEmpty) {
        // Draw dot points.
        ctx.fillStyle = (dotFillStyle[key] ?? dotFillStyle[keyAllGraph])!.toJS;
        ctx.shadowColor = 'rgba(0, 0, 0, 0.2)';
        ctx.shadowBlur = 4;
        ctx.shadowOffsetX = 1;
        ctx.shadowOffsetY = 1;
        ctx.lineWidth = dotStrokeWidth[key] ?? dotStrokeWidth[keyAllGraph]!;
        ctx.strokeStyle = (dotStrokeStyle[key] ?? dotStrokeStyle[keyAllGraph])!.toJS;
        dotPoints.forEach((x, y) {
          var dot = Path2D();
          var radius = dotRadius[key] ?? dotRadius[keyAllGraph]!;
          var radiusOffset = hoverDotRadiusOffset[key] ?? hoverDotRadiusOffset[keyAllGraph]!;
          dot.arc(lerp(x, minX, maxX, gridMinPxX, gridMaxPxX), lerp(y, minY, maxY, gridMaxPxY, gridMinPxY), radius, 0, 2 * pi, false);
          ctx.fill(dot);
          ctx.stroke(dot);
          var hoverDot = Path2D();
          hoverDot.arc(lerp(x, minX, maxX, gridMinPxX, gridMaxPxX), lerp(y, minY, maxY, gridMaxPxY, gridMinPxY), radius + radiusOffset, 0, 2 * pi, false);
          if (!_hoverPaths.containsKey(key)) {
            _hoverPaths[key] = <MapEntry<double, double>, Path2D>{MapEntry(x, y): hoverDot};
          } else {
            _hoverPaths[key]![MapEntry(x, y)] = hoverDot;
          }
        });
      }
    });
  }

  /// Gets how many labels the graph should display in X axis.
  /// If [_initialLabelCountX] is not supplied, which means [labelCountX] was
  /// not supplied in the constructor, the label counts is dynamic (depending
  /// on canvas width).
  @override
  int getLabelCountX() {
    if (_initialLabelCountX != null) return _initialLabelCountX!;

    var divider = 75;
    if (ctx.canvas.width < 600) {
      divider = 75;
    } else if (ctx.canvas.width < 1200) {
      divider = 100;
    } else {
      divider = 200;
    }

    return max((ctx.canvas.width/divider).truncate(), 2);
  }

  /// Gets how many labels the graph should display in Y axis.
  /// If [_initialLabelCountY] is not supplied, which means [labelCountY] was
  /// not supplied in the constructor, the label counts is dynamic (depending
  /// on canvas height).
  @override
  int getLabelCountY() {
    if (_initialLabelCountY != null) return _initialLabelCountY!;

    var divider = 45;
    if (ctx.canvas.height < 600) {
      divider = 45;
    } else if (ctx.canvas.height < 1200) {
      divider = 80;
    } else {
      divider = 100;
    }

    return max((ctx.canvas.height/divider).truncate(), 2);
  }

  /// Get the minimum (the first, the leftmost) X label value.
  /// If [_initialLabelMinX] is null, which means that [labelMinX] value from the constructor
  /// was not supplied, minimum X label value will be retrieved from
  /// floor(minimum X value in data points).
  double getLabelMinX() {
    if (_initialLabelMinX != null) return _initialLabelMinX!;
    return _dataPointMinX.floorToDouble();
  }

  /// Get the minimum (the first, the bottommost) Y label value.
  /// If [_initialLabelMinY] is null, which means that [labelMinY] value from the constructor
  /// was not supplied, minimum Y label value will be retrieved from
  /// floor(minimum Y value in data points).
  double getLabelMinY() {
    if (_initialLabelMinY != null) return _initialLabelMinY!;

    if (_dataPointMinY == _dataPointMaxY) {
      return (0.8 * _dataPointMaxY).roundToDouble();
    }

    return _dataPointMinY.roundToDouble();
  }

  /// Get the maximum (the last, the rightmost) X label value.
  /// If [_initialLabelMaxX] is null, which means that [labelMaxX] value from the constructor
  /// was not supplied, maximum X label value will be retrieved from
  /// ceil(maximum X value in data points).
  double getLabelMaxX() {
    if (_initialLabelMaxX != null) return _initialLabelMaxX!;
    return _dataPointMaxX.ceilToDouble();
  }

  /// Get the maximum (the last, the topmost) Y label value.
  /// If [_initialLabelMaxY] is null, which means that [labelMaxY] value from the constructor
  /// was not supplied, maximum Y label value will be retrieved from
  /// ceil(maximum Y value in data points). There is an exception to this, however.
  /// When the maximum point equals to the minimum point, which means that the
  /// data are flat, max Y label is calculated from ceil(1.2 * maximum Y value in data points).
  /// However, if the maximum data point is 0, multiplying it by 1.2 won't do anything,
  /// and so it will be set to constant 10 instead.
  double getLabelMaxY() {
    if (_initialLabelMaxY != null) return _initialLabelMaxY!;

    if (_dataPointMinY == _dataPointMaxY) {
      if (_dataPointMaxY == 0) {
        return 10;
      }

      return (1.2 * _dataPointMaxY).ceilToDouble();
    }

    return _dataPointMaxY.ceilToDouble();
  }

  @override
  void clearPoints() {
    _dataPoints.clear();
    clearDrawing();
  }

  @override
  double calcGridMaxPxX() {
    return (ctx.canvas.width - maxLabelWidthX/2).toDouble();
  }

  @override
  double calcGridMaxPxY() {
    return (ctx.canvas.height - textMargin - _textHeight).toDouble();
  }

  @override
  double calcGridMinPxX() {
    return (max(maxLabelWidthY + textMargin, maxLabelWidthX/2)).toDouble();
  }

  @override
  double calcGridMinPxY() {
    return _textHeight.toDouble();
  }

  /// [x] and [y] defines the x,y of the data point that is being hovered.
  /// [coordX] and [coordY] defines the x,y coordinate of the dot, in canvas/SVG
  /// absolute coordinate space.
  ///
  /// When a data point is hovered, a caption is shown near the data point.
  /// The value that is shown in the caption is formatted with [labelFormatX] and [labelFormatY].
  /// The way you do this currently cannot be changed, but can be overridden
  /// if you want to extend this [LineGraphComponent].
  ///
  /// [onHover] is executed also everytime this method is executed.
  @protected
  void onPointHover(String dataKey, double x, double y, double coordX, double coordY) {
    _captionTextElem.text = '$dataKey: (${labelFormatX(x)}, ${labelFormatY(y)})';
    // Increase the rectangle width to be 20 + text width.
    var textComputedWidth = _captionTextElem.getComputedTextLength();
    _captionTextElem.setAttribute('x', ((textComputedWidth + 20)/2).toStringAsFixed(3));
    _captionRectElem.setAttribute('width', (textComputedWidth + 20).toStringAsFixed(3));
    // Coordinate of the point, in SVG viewbox coord system.
    var viewBoxX = coordX;
    var viewBoxY = coordY;
    // How far to translate.
    var translateValueX = viewBoxX;
    var translateValueY = viewBoxY;
    var bb = _captionElem.getBBox();
    // Width, based on viewbox coordinate system.
    var widthViewBox = bb.width;
    // Height, based on viewbox coordinate system.
    var heightViewBox = bb.height;
    var rightestPointViewBox = viewBoxX + widthViewBox;
    var bottommostPointViewBox = viewBoxY + heightViewBox;
    // Outside range X, translate -width.
    if (rightestPointViewBox > ctx.canvas.width) {
      translateValueX -= widthViewBox;
    }
    // Outside range of Y too, translate -height.
    if (bottommostPointViewBox > ctx.canvas.height) {
      translateValueY -= heightViewBox;
    }

    _captionElem.setAttribute('transform', 'translate($translateValueX, $translateValueY)');
    _captionElem.setAttribute('visibility', 'visible');
    if (onHover != null) onHover!(x, y, coordX, coordY);
  }

  /// Called when the user is hovering over the canvas/SVG, but not above any
  /// data point.
  ///
  /// [onHoverOut] is executed also everytime this method is executed.
  @protected
  void onPointHoverOut() {
    _captionElem.setAttribute('visibility', 'hidden');
    if (onHoverOut != null) onHoverOut!();
  }

  @override
  void loadEventHandlers() {
    void onMouse(MouseEvent event) {
      var minX = getLabelMinX();
      var minY = getLabelMinY();
      var maxX = getLabelMaxX();
      var maxY = getLabelMaxY();
      for (var pointSet in _hoverPaths.entries) {
        for (var entry in pointSet.value.entries) {
          var point = entry.key;
          var dot = entry.value;
          // TODO: ensure it is right to call isPointInPath this way
          if (ctx.isPointInPath(dot, event.offsetX, event.offsetY.toJS)) {
            onPointHover(pointSet.key,
                point.key,
                point.value,
                lerp(point.key, minX, maxX, gridMinPxX, gridMaxPxX),
                lerp(point.value, minY, maxY, gridMaxPxY, gridMinPxY));
            return;
          }
        }
      }

      onPointHoverOut();
    }

    super.loadEventHandlers();
    _onMouseMoveSubs = _svgElem.onMouseMove.listen(onMouse);
    _onMouseClickSubs = _svgElem.onClick.listen(onMouse);
    _onCaptionClickSubs = _captionElem.onClick.listen((event) {
      _hideCaption();
    });
  }

  @override
  void unloadEventHandlers() {
    super.unloadEventHandlers();
    _onMouseMoveSubs?.cancel();
    _onMouseClickSubs?.cancel();
    _onCaptionClickSubs?.cancel();
  }

  @override
  void onComponentAttached() {}
}