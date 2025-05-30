part of '../../graph.dart';

class BoxDataPoint {
  final double x;
  final double median;
  final double q1;
  final double q3;
  final double min;
  final double max;

  const BoxDataPoint({this.x = 0, this.median = 0, this.q1 = 0, this.q3 = 0, this.min = 0, this.max = 0});
}

class BoxChartComponent extends CanvasBaseGraphComponent {
  static const keyAllGraph = BaseGraphComponent.keyAllGraph;

  /// Width of a single bar.
  double singleBarWidth;
  /// Distance between one bar to another, NOT a distance between one set of
  /// bars to another set (distance between an X label to another).
  double barMargin;
  /// Distance between one set of bars to another, NOT a distance between one bar in a set of
  /// bars to another bar.
  double barSetMargin;
  /// Dot point fill style.
  Map<String, String> barFillStyle = const {};
  /// The minimum width of the graph.
  /// The minimum width of the graph cannot be lower than
  /// [getLabelCountX] * ([maxLabelWidthX] + 10). This is so there are no labels
  /// that are overlapping with each other because the width of the graph is
  /// too short. You can however override this behavior by setting [minWidthOverride]
  /// to true.
  double minWidth;
  /// See also [minWidth].
  bool minWidthOverride = false;

  /// A predefined sets of labels in X axis.
  /// If left empty, labels will be generated from the data points, and will keep
  /// on increasing if more X values are encountered. In bar chart, labels are
  /// stored as String, not in their numerical values. This is because it might
  /// be impossible to compare two double values for equality. And because
  /// the bar chart does not have any kind of sorting in X axis, it uses [LinkedHashSet].
  /// Data points are also store using [LinkedHashMap], therefore, you are
  /// the one in charge with ordering them.
  LinkedHashSet<String> labelsX = LinkedHashSet();

  Set<String> _userGraphKeys = {};
  final Set<String> _graphKeys = {};
  Map<String, String> graphAliases = {};
  /// (x, graph name => y).
  /// Each x value (a String, not a number) can have multiple y values from
  /// different graph name.
  final LinkedHashMap<String, Map<String, BoxDataPoint?>> _dataPoints = LinkedHashMap();

  /// The minimum Y point in [_dataPoints].
  /// Used to generate the minimum/maximum label value if label value range was not
  /// defined. See also [labelMinX] and others in constructor.
  double _dataPointMinY = 0;
  /// The maximum Y point in [_dataPoints].
  /// Used to generate the minimum/maximum label value if label value range was not
  /// defined. See also [labelMinX] and others in constructor.
  double _dataPointMaxY = 10;

  int? _initialLabelCountY;
  double? _initialLabelMinY;
  double? _initialLabelMaxY;

  StreamSubscription<MouseEvent>? _onMouseMoveSubs;
  StreamSubscription<MouseEvent>? _onMouseClickSubs;
  StreamSubscription<MouseEvent>? _onCaptionClickSubs;

  Function(String x, BoxDataPoint y)? onHover;
  Function(String x, BoxDataPoint y)? onClick;
  Function()? onHoverOut;

  final Map<String, Map<String, _BarHoverPath>> _hoverPaths = {};

  BoxChartComponent(super.parent, super.id, {
    Map<String, List<BoxDataPoint>> points = const {},
    LinkedHashSet<String>? labelsX,
    Set<String>? graphKeys,
    Map<String, String>? graphAliases,
    int? labelCountY,
    double? labelMinY,
    double? labelMaxY,
    super.maxLabelWidthX,
    super.maxLabelWidthY,
    super.textMargin,
    String Function(double)? labelFormatX,
    String Function(double)? labelFormatY,
    super.aspectRatio,
    super.gridLineWidth,
    super.gridLineStrokeStyle,
    super.labelFillStyle,
    super.labelFontStyle,
    super.captionBgColor,
    super.captionFgColor,
    super.captionFontFamily,
    super.drawGridY,
    this.barFillStyle = const {keyAllGraph: '#aaaaaa'},
    this.minWidth = 500,
    this.minWidthOverride = false,
    this.singleBarWidth = 15,
    this.barMargin = 5,
    this.barSetMargin = 45,
    this.onHover,
    this.onHoverOut,
    this.onClick,
  }) : super(labelFormatX: labelFormatX ?? _defaultLabelFormat,
    labelFormatY: labelFormatY ?? _defaultLabelFormat,
  ) {
    if (!barFillStyle.containsKey(keyAllGraph)) barFillStyle[keyAllGraph] = '#aaaaaa';
    _initialLabelCountY = labelCountY;
    _initialLabelMinY = labelMinY;
    _initialLabelMaxY = labelMaxY;
    _userGraphKeys = graphKeys ?? {};
    this.graphAliases = graphAliases ?? {};

    if (labelsX != null) this.labelsX = labelsX;

    var labelsXSet = labelsX != null && labelsX.isNotEmpty;

    // Add empty data point in some X point that is defined in labels, but
    // do not have any points.
    labelsX?.forEach((element) {
      if (_dataPoints[element] == null) {
        _dataPoints[element] = points.map((key, value) => MapEntry(key, BoxDataPoint()));
      }
    });

    _graphKeys.addAll(_userGraphKeys);

    points.forEach((key, value) {
      if (_userGraphKeys.isNotEmpty && !_userGraphKeys.contains(key)) return;

      _graphKeys.add(key);
      for (var dp in value) {
        // If the labelsX has predefined X labels, ignore those points that are outside of defined labels.
        if (labelsXSet && labelsX.contains(this.labelFormatX(dp.x))) continue;

        if (_dataPoints[this.labelFormatX(dp.x)] == null) {
          _dataPoints[this.labelFormatX(dp.x)] = {};
        }

        _dataPoints[this.labelFormatX(dp.x)]![key] = dp;
      }
    });
    _setMinMaxY();
  }

  set graphKeys(Set<String> graphNames) {
    _userGraphKeys = graphNames;
  }

  Set<String> get graphKeys => _userGraphKeys;

  Iterable<String> get keys {
    if (labelsX.isNotEmpty) return labelsX;
    return _dataPoints.keys;
  }

  /// The default label formatting function.
  /// It uses [NumberFormat.compact] to format label values. See also [labelFormatX]
  /// and [labelFormatY].
  static String _defaultLabelFormat(double label) {
    return NumberFormat.compact().format(label);
  }

  /// Searches for the minimum and maximum X and Y points throughout the entire
  /// point sets.
  void _setMinMaxY() {
    if (_dataPoints.isNotEmpty && _dataPoints.values.any((element) => element.isNotEmpty)) {
      var yMin = double.infinity;
      var yMax = double.negativeInfinity;
      for (var value in _dataPoints.values) {
        for (var p in value.values) {
          if (p == null) continue;

          if (p.max > yMax) {
            yMax = p.max;
          } else if (p.min > yMax) {
            yMax = p.min;
          } else if (p.median > yMax) {
            yMax = p.median;
          } else if (p.q1 > yMax) {
            yMax = p.q1;
          } else if (p.q3 > yMax) {
            yMax = p.q3;
          }

          if (p.max < yMin) {
            yMin = p.max;
          } else if (p.min < yMin) {
            yMin = p.min;
          } else if (p.median < yMin) {
            yMin = p.median;
          } else if (p.q1 < yMin) {
            yMin = p.q1;
          } else if (p.q3 < yMin) {
            yMin = p.q3;
          }
        }
      }
      _dataPointMinY = yMin == double.infinity ? 0 : yMin;
      _dataPointMaxY = yMax == double.negativeInfinity ? 0 : yMax;
    }
  }

  /// Sets the data points stored in this graph, and redraw the graph.
  /// See also [redraw].
  ///
  /// Because the graph does not really store any kind of ordering for X values,
  /// ordering is received from iterating the data point X values, as they
  /// are stored in [LinkedHashMap]. The chart stores X values in this map,
  /// and as new X values are encountered from new data points and graphs,
  /// they are added to the map. [LinkedHashMap] stores the ordering following
  /// the order in which X values are added to the map. If you want to guarantee
  /// the ordering in any way, set [labelsX] in the order you want.
  void setDataPoints(String key, List<BoxDataPoint> points) {
    if (_userGraphKeys.isNotEmpty && !_userGraphKeys.contains(key)) return;
    _graphKeys.add(key);

    var labelsXSet = labelsX.isNotEmpty;

    // Initialized _dataPoints in the same ordering as labelsX.
    if (labelsXSet) {
      // Add empty data point in some X point that is defined in labels
      for (var element in labelsX) {
        if (_dataPoints[element] == null) {
          _dataPoints[element] = {key: null};
        }
      }
    }

    for (var dp in points) {
      // If the labelsX has predefined X labels, ignore those points that are outside of defined labels.
      if (labelsXSet && !labelsX.contains(labelFormatX(dp.x))) continue;

      if (_dataPoints[labelFormatX(dp.x)] == null) {
        _dataPoints[labelFormatX(dp.x)] = {};
      }

      _dataPoints[labelFormatX(dp.x)]![key] = dp;
    }

    _setMinMaxY();
    clearDrawing();
    redraw();
  }

  @override
  void drawDataPoints() {
    var minY = getLabelMinY();
    var maxY = getLabelMaxY();
    var totalBarWidth = getBarWidth();

    var barMinPxX = gridMinPxX;
    var barMaxPxX = gridMaxPxX;
    if (maxLabelWidthX > getBarWidth()) {
      barMinPxX = gridMinPxX + max(0, (maxLabelWidthX - getBarWidth())/2);
      barMaxPxX = gridMaxPxX - max(0, (maxLabelWidthX - getBarWidth())/2);
    }

    var barSetIndex = 0;
    var spaceX = (barMaxPxX - totalBarWidth - barMinPxX) / (_dataPoints.length - 1);
    var alignmentOffsetX = 0.0;
    if (_dataPoints.length == 1) { // Start to draw from the center
      alignmentOffsetX = (barMaxPxX - barMinPxX - totalBarWidth)/2 - barMinPxX - totalBarWidth/2;
      spaceX = 0;
    }

    _hoverPaths.clear();

    for (var x in keys) {
      var mapPoints = _dataPoints[x];
      var barIndex = 0;
      for (var graphName in _graphKeys) {
        var y = mapPoints![graphName];
        if (y == null) {
          barIndex++;
          continue;
        }

        var offset = barIndex * singleBarWidth + barIndex * barMargin + spaceX * barSetIndex + alignmentOffsetX;

        // Clamp the value so it does not get drawn outside the graph.
        var clampedQ3Y = min(y.q3, maxY);
        var clampedQ1Y = max(y.q1, minY);
        var centerBarPxYStart = lerp(clampedQ3Y, minY, maxY, gridMaxPxY, gridMinPxY);
        var centerBarPxYEnd = lerp(clampedQ1Y, minY, maxY, gridMaxPxY, gridMinPxY);
        ctx.fillStyle = (barFillStyle[graphName] ?? barFillStyle[keyAllGraph])!.toJS;
        ctx.fillRect(barMinPxX + offset, centerBarPxYStart, singleBarWidth, max(centerBarPxYEnd - centerBarPxYStart, 1));

        var minLinePxY = centerBarPxYStart;
        var maxLinePxY = centerBarPxYEnd;

        // Draw the max point line
        if (y.max <= maxY) {
          ctx.strokeStyle = (barFillStyle[graphName] ?? barFillStyle[keyAllGraph])!.toJS;
          ctx.beginPath();
          maxLinePxY = lerp(y.max, minY, maxY, gridMaxPxY, gridMinPxY);
          ctx.moveTo(barMinPxX + offset, maxLinePxY);
          ctx.lineTo(barMinPxX + offset + singleBarWidth, maxLinePxY);
          ctx.stroke();
        }

        // Draw the min point line
        if (y.min >= minY) {
          ctx.strokeStyle = (barFillStyle[graphName] ?? barFillStyle[keyAllGraph])!.toJS;
          ctx.beginPath();
          minLinePxY = lerp(y.min, minY, maxY, gridMaxPxY, gridMinPxY);
          ctx.moveTo(barMinPxX + offset, minLinePxY);
          ctx.lineTo(barMinPxX + offset + singleBarWidth, minLinePxY);
          ctx.stroke();
        }

        // Draw the center line
        ctx.beginPath();
        ctx.moveTo(barMinPxX + offset + singleBarWidth/2, minLinePxY);
        ctx.lineTo(barMinPxX + offset + singleBarWidth/2, maxLinePxY);
        ctx.stroke();

        var hoverBar = Path2D();
        hoverBar.rect(barMinPxX + offset, maxLinePxY, singleBarWidth, max(minLinePxY - maxLinePxY, 1));
        var hoverPath = _BarHoverPath(hoverBar, barMinPxX + offset, maxLinePxY, max(minLinePxY - maxLinePxY, 1));
        if (_hoverPaths[x] == null) {
          _hoverPaths[x] = {graphName: hoverPath};
        } else {
          _hoverPaths[x]![graphName] = hoverPath;
        }

        barIndex++;
      }
      barSetIndex++;
    }
  }

  @override
  void drawLabels() {
    var labelCountX = getLabelCountX();
    var labelCountY = getLabelCountY();
    var labelMinPxX = gridMinPxX + max(getBarWidth(), maxLabelWidthX)/2;
    var labelMaxPxX = gridMaxPxX - max(getBarWidth(), maxLabelWidthX)/2;
    var rangeX  = labelMaxPxX - labelMinPxX;
    var rangeY = gridMaxPxY - gridMinPxY;

    var minY = getLabelMinY();
    var maxY = getLabelMaxY();

    var spaceX = rangeX/(labelCountX-1);
    var spaceY = rangeY/(labelCountY-1);
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
    if (labelCountX >= 2) {
      var i = 0;
      for (var x in keys) {
        ctx.fillText(x, labelMinPxX + spaceX*i, gridMaxPxY + textMargin, maxLabelWidthX);
        i++;
      }
    } else {
      for (var x in keys) {
        ctx.fillText(x, (labelMaxPxX - labelMinPxX)/2, gridMaxPxY + textMargin, maxLabelWidthX);
      }
    }
  }

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
      var labelMinPxX = gridMinPxX + max(getBarWidth(), maxLabelWidthX)/2;
      var labelMaxPxX = gridMaxPxX - max(getBarWidth(), maxLabelWidthX)/2;
      var rangeX  = labelMaxPxX - labelMinPxX;
      var spaceX = rangeX/(labelCountX-1);
      for (var i = 0; i < labelCountX; i++) {
        ctx.beginPath();
        ctx.moveTo(labelMinPxX + spaceX*i, gridMinPxY);
        ctx.lineTo(labelMinPxX + spaceX*i, gridMaxPxY);
        ctx.stroke();
      }
    }
  }

  double getBarWidth() {
    if (_dataPoints.isEmpty) {
      return 0;
    }
    var barCount = _dataPoints.values.first.length;
    for (var v in _dataPoints.values) {
      if (v.length > barCount) barCount = v.length;
    }
    return (singleBarWidth * barCount + barMargin * (barCount - 1)).toDouble();
  }

  @override
  int getLabelCountX() {
    return _dataPoints.keys.length;
  }

  /// Gets how many labels the graph should display in Y axis.
  /// If [_initialLabelCountY] is not supplied, which means [labelCountY] was
  /// not supplied in the constructor, the label counts is dynamic (depending
  /// on canvas height).
  @override
  int getLabelCountY() {
    if (_initialLabelCountY != null) return _initialLabelCountY!;

    var divider = 45;
    if (ctx.canvas.height.toDouble() < 600) {
      divider = 45;
    } else if (ctx.canvas.height.toDouble() < 1200) {
      divider = 80;
    } else {
      divider = 100;
    }

    return max((ctx.canvas.height.toDouble()/divider).truncate(), 2);
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
  void onComponentAttached() {}

  @override
  void clearPoints() {
    _dataPoints.clear();
    clearDrawing();
  }

  @override
  double calcGridMaxPxX() {
    if (maxLabelWidthX > getBarWidth()) {
      return (ctx.canvas.width.toDouble() - maxLabelWidthX/2).toDouble();
    }

    return ctx.canvas.width.toDouble();
  }

  @override
  double calcGridMaxPxY() {
    return (ctx.canvas.height.toDouble() - textMargin - _textHeight).toDouble();
  }

  @override
  double calcGridMinPxX() {
    return (max(maxLabelWidthY + textMargin, (maxLabelWidthX - getBarWidth()) / 2)).toDouble();
  }

  @override
  double calcGridMinPxY() {
    return _textHeight.toDouble();
  }

  @override
  double getCalculatedMinWidth() {
    if (minWidthOverride) {
      return minWidth;
    }

    return max(getLabelCountX() * (max(maxLabelWidthX, getBarWidth()) + barSetMargin), minWidth);
  }

  /// [x] and [y] defines the x,y of the data point that is being hovered.
  /// [coordX] and [coordY] defines the x,y coordinate of the dot, in canvas/SVG
  /// absolute coordinate space. It is the starting point of the bar, which is
  /// the top left corner of a bar.
  ///
  /// When a data point is hovered, a caption is shown near the data point.
  /// The value that is shown in the caption is formatted with [labelFormatX] and [labelFormatY].
  /// The way you do this currently cannot be changed, but can be overridden
  /// if you want to extend this [LineGraphComponent].
  ///
  /// [onHover] is executed also everytime this method is executed.
  @protected
  void onPointHover(String dataKey, String x, BoxDataPoint y, double coordX, double coordY, double height) {
    var dataName = graphAliases[dataKey];
    dataName ??= dataKey;
    _captionTextElem.text = '$dataName: ($x, Median: ${labelFormatY(y.median)}, Min: ${labelFormatY(y.min)}, Max: ${labelFormatY(y.max)}, Q1: ${labelFormatY(y.q1)}, Q3: ${labelFormatY(y.q3)})';
    // Increase the rectangle width to be 20 + text width.
    var textComputedWidth = _captionTextElem.getComputedTextLength();
    _captionTextElem.setAttribute('x', ((textComputedWidth + 20)/2).toStringAsFixed(3));
    _captionRectElem.setAttribute('width', (textComputedWidth + 20).toStringAsFixed(3));
    // Coordinate of the point, in SVG viewbox coord system.
    var viewBoxX = coordX + singleBarWidth/2;
    var viewBoxY = coordY + height/2;
    // How far to translate.
    var translateValueX = viewBoxX;
    var translateValueY = viewBoxY;
    var bb = _captionElem.getBBox();
    // Width, based on viewbox coordinate system.
    var widthViewBox = bb.width.toDouble();
    // Height, based on viewbox coordinate system.
    var heightViewBox = bb.height.toDouble();
    var rightestPointViewBox = viewBoxX + widthViewBox;
    var bottommostPointViewBox = viewBoxY + heightViewBox;
    // Outside range X, translate -width.
    if (rightestPointViewBox > ctx.canvas.width.toDouble()) {
      translateValueX -= widthViewBox;
    }
    // Outside range of Y too, translate -height.
    if (bottommostPointViewBox > ctx.canvas.height.toDouble()) {
      translateValueY -= heightViewBox;
    }

    _captionElem.setAttribute('transform', 'translate($translateValueX, $translateValueY)');
    _captionElem.setAttribute('visibility', 'visible');
    if (onHover != null) onHover!(x, y);
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
  
  @protected
  void onPointClick(String x, BoxDataPoint y) {
    if (onClick != null) onClick!(x, y);
  }

  void _onMouse(MouseEvent event) {
    for (var x in _hoverPaths.entries) {
      for (var bar in x.value.entries) {
        var graphName = bar.key;
        var path = bar.value;
        // TODO: ensure it is right to call isPointInPath this way
        if (ctx.isPointInPath(path.path, event.offsetX, event.offsetY.toJS)) {
          onPointHover(graphName,
            x.key,
            _dataPoints[x.key]![graphName]!,
            path.pxX,
            path.pxY,
            path.height,
          );
          return;
        }
      }
    }

    onPointHoverOut();
  }

  void _onClick(MouseEvent event) {
    for (var x in _hoverPaths.entries) {
      for (var bar in x.value.entries) {
        var graphName = bar.key;
        var path = bar.value;
        // TODO: ensure it is right to call isPointInPath this way
        if (ctx.isPointInPath(path.path, event.offsetX, event.offsetY.toJS)) {
          onPointClick(x.key, _dataPoints[x.key]![graphName]!);
          return;
        }
      }
    }
  }

  @override
  void loadEventHandlers() {
    super.loadEventHandlers();
    _onMouseMoveSubs = _svgElem.onMouseMove.listen(_onMouse);
    _onMouseClickSubs = _svgElem.onClick.listen((event) {
      _onMouse(event);
      _onClick(event);
    });
    _onCaptionClickSubs = _captionElem.onClick.listen((event) {
      hideCaption();
    });
  }

  @override
  void unloadEventHandlers() {
    super.unloadEventHandlers();
    _onMouseMoveSubs?.cancel();
    _onMouseClickSubs?.cancel();
    _onCaptionClickSubs?.cancel();
  }
}