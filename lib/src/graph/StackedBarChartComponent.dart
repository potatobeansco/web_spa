part of '../../graph.dart';

class StackedBarChartComponent extends BaseGraphComponent {
  static const keyAllGraph = BaseGraphComponent.keyAllGraph;

  /// The maximum width for label texts in X axis.
  final double maxLabelWidthX;
  /// The maximum width for label texts in Y axis.
  final double maxLabelWidthY;
  /// The number of points of the spider chart.
  int get points => barLabels.length;
  /// The list of labels currently present in the chart.
  Set<String> barLabels;
  /// Width of a single bar.
  double barWidth;
  /// Distance between one bar to another, NOT a distance between one set of
  /// bars to another set (distance between an X label to another).
  double barMargin;
  /// Chart fill style.
  Map<String, Color> chartFillStyle = {
    keyAllGraph: Color.css('#2d2d2d')
  };

  /// A predefined sets of labels in X axis.
  /// If left empty, labels will be generated from the data points, and will keep
  /// on increasing if more X values are encountered. In bar chart, labels are
  /// stored as String, not in their numerical values. This is because it might
  /// be impossible to compare two double values for equality. And because
  /// the bar chart does not have any kind of sorting in X axis, it uses [LinkedHashSet].
  /// Data points are also store using [LinkedHashMap], therefore, you are
  /// the one in charge with ordering them.
  LinkedHashSet<String> labelsX = LinkedHashSet();

  /// The formatting function used to display the labels in Y axis.
  /// If none is specified, it by default uses [NumberFormat.compact] to format
  /// label values into string. You might want to override this for example
  /// if you want the label to be a date.
  ///
  /// Label values are calculated arithmetically, so the produced value is double.
  /// If you want custom label formatting, for example to include units or converts
  /// seconds into human-readable date, you should supply this function.
  final String Function(double label) labelFormatY;

  final int? _initialLabelCountY;
  final double? _initialLabelMinY;
  final double? _initialLabelMaxY;

  /// The minimum Y point in [_dataPoints].
  /// Used to generate the minimum/maximum label value if label value range was not
  /// defined. See also [labelMinX] and others in constructor.
  double _dataPointMinY = 0;
  /// The maximum Y point in [_dataPoints].
  /// Used to generate the minimum/maximum label value if label value range was not
  /// defined. See also [labelMinX] and others in constructor.
  double _dataPointMaxY = 10;

  /// (x, graph name => y).
  /// Each x value (a String, not a number) can have multiple y values from
  /// different graph name.
  final LinkedHashMap<String, Map<String, double?>> _dataPoints = LinkedHashMap();
  final Set<String> _activeGraphs = {};

  SvgSvgElement get _svgElem => queryById('$id-svg') as SvgSvgElement;
  GElement get _gridElem => queryById('$id-svg-grid') as GElement;
  GElement get _labelElem => queryById('$id-svg-label') as GElement;
  GElement get _pointsElem => queryById('$id-svg-points') as GElement;

  StackedBarChartComponent(super.parent, super.id, {
    this.maxLabelWidthX = 50,
    this.maxLabelWidthY = 50,
    Set<String>? barLabels,
    this.barWidth = 15,
    this.barMargin = 45,
    Set<String>? labelsX,
    int? labelCountY,
    double? labelMinY,
    double? labelMaxY,
    String Function(double)? labelFormatY,
    String? css = 'stackedbar',
    super.gridLineWidth,
    super.aspectRatio,
    super.textMargin,
    super.gridLineStrokeStyle,
    super.labelFillStyle,
    super.labelFontStyle,
    super.captionBgColor,
    super.captionFgColor,
    super.captionFontFamily,
  }) :
      barLabels = barLabels ?? {},
      _initialLabelCountY = labelCountY,
      _initialLabelMinY = labelMinY,
      _initialLabelMaxY = labelMaxY,
      labelFormatY = labelFormatY ?? _defaultLabelFormat {
    // Add empty data point in some X point that is defined in labels, but
    // do not have any points.
    labelsX?.forEach((element) {
      if (_dataPoints[element] == null) {
        _dataPoints[element] = {};
      }
    });

    if (labelsX != null) this.labelsX = LinkedHashSet.from(labelsX);

    baseInnerHtml = '''
    <div id="$id" class="$css" style="aspect-ratio: $aspectRatio;position: relative;overflow-x: auto;width: 100%;">
        <svg id="$id-svg" xmlns="http://www.w3.org/2000/svg" class="$css-svg" width="100%" height="100%" style="display: block;">
            <g id="$id-svg-grid"></g>
            <g id="$id-svg-label"></g>
            <g id="$id-svg-points"></g>
        </svg>
    </div>
    ''';
  }

  /// The default label formatting function.
  /// It uses [NumberFormat.compact] to format label values. See also [labelFormatX]
  /// and [labelFormatY].
  static String _defaultLabelFormat(double label) {
    return NumberFormat.compact().format(label);
  }

  /// The minimum coordinate of the grid, in pixel.
  /// The grid starts at ([gridMinPxX],[gridMinPxY]) and ends in
  /// ([gridMaxPxX], [gridMaxPxY]).
  @protected
  double get gridMinPxX => (max(maxLabelWidthY + textMargin, (maxLabelWidthX - barWidth) / 2)).toDouble();

  /// The minimum coordinate of the grid, in pixel.
  /// The grid starts at ([gridMinPxX],[gridMinPxY]) and ends in
  /// ([gridMaxPxX], [gridMaxPxY]).
  @protected
  double get gridMinPxY => _textHeight;

  /// The maximum coordinate of the grid, in pixel.
  /// The grid starts at ([gridMinPxX],[gridMinPxY]) and ends in
  /// ([gridMaxPxX], [gridMaxPxY]).
  @protected
  double get gridMaxPxX {
    if (maxLabelWidthY + max(maxLabelWidthX, barWidth)*keys.length > elem.clientWidth) {
      // SVG is overflowing
      return maxLabelWidthY + max(maxLabelWidthX, barWidth)*keys.length;
    }

    if (maxLabelWidthX > barWidth) {
      return (elem.clientWidth - maxLabelWidthX/2).toDouble();
    }

    return elem.clientWidth.toDouble();
  }

  /// The maximum coordinate of the grid, in pixel.
  /// The grid starts at ([gridMinPxX],[gridMinPxY]) and ends in
  /// ([gridMaxPxX], [gridMaxPxY]).
  @protected
  double get gridMaxPxY {
    return (_svgElem.clientHeight - textMargin - _textHeight).toDouble();
  }

  Iterable<String> get keys {
    if (labelsX.isNotEmpty) return labelsX;
    return _dataPoints.keys;
  }

  /// Searches for the minimum and maximum X and Y points throughout the entire
  /// point sets.
  void _setMinMaxY() {
    if (_dataPoints.isNotEmpty && _dataPoints.values.any((element) => element.isNotEmpty)) {
      var yMin = double.infinity;
      var yMax = double.negativeInfinity;
      for (var value in _dataPoints.values) {
        for (var y in value.values) {
          if (y == null) continue;

          if (y > yMax) {
            yMax = y;
          }

          if (y < yMin) {
            yMin = y;
          }
        }
      }
      _dataPointMinY = yMin == double.infinity ? 0 : yMin;
      _dataPointMaxY = yMax == double.negativeInfinity ? 0 : yMax;
    }
  }

  /// Gets how many labels the graph should display in Y axis.
  /// If [_initialLabelCountY] is not supplied, which means [labelCountY] was
  /// not supplied in the constructor, the label counts is dynamic (depending
  /// on canvas height).
  int getLabelCountY() {
    if (_initialLabelCountY != null) return _initialLabelCountY!;

    var divider = 45;
    if (_svgElem.clientHeight < 600) {
      divider = 45;
    } else if (_svgElem.clientHeight < 1200) {
      divider = 80;
    } else {
      divider = 100;
    }

    return max((_svgElem.clientHeight/divider).truncate(), 2);
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

  void hideGraph(String graphId) {
    _activeGraphs.remove(graphId);
    drawDataPoints();
  }

  void showGraph(String graphId) {
    _activeGraphs.add(graphId);
    drawDataPoints();
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
  void setDataPoints(String key, List<TextDataPoint> points) {
    if (barLabels.isEmpty) return;
    if (barLabels.isNotEmpty && !barLabels.contains(key)) return;

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
      if (labelsXSet && !labelsX.contains(dp.x)) continue;

      if (_dataPoints[dp.x] == null) {
        _dataPoints[dp.x] = {};
      }

      _dataPoints[dp.x]![key] = dp.y;
    }

    _setMinMaxY();
  }

  void redraw() {
    drawGrid(true);
    drawLabels();
    drawDataPoints();
  }

  @override
  void clearPoints() {
    _pointsElem.children.clear();
  }

  @override
  void drawDataPoints() {
    clearPoints();

    var minY = getLabelMinY();
    var maxY = getLabelMaxY();
    var totalBarWidth = barWidth;

    var barMinPxX = gridMinPxX;
    var barMaxPxX = gridMaxPxX;
    if (maxLabelWidthX > barWidth) {
      barMinPxX = gridMinPxX + max(0, (maxLabelWidthX - barWidth)/2);
      barMaxPxX = gridMaxPxX - max(0, (maxLabelWidthX - barWidth)/2);
    }

    var barIndex = 0;
    var spaceX = (barMaxPxX - (barWidth * _dataPoints.length) - barMinPxX) / (_dataPoints.length - 1);
    var alignmentOffsetX = 0.0;
    if (_dataPoints.length == 1) { // Start to draw from the center
      alignmentOffsetX = (barMaxPxX - barMinPxX - totalBarWidth)/2 - barMinPxX - totalBarWidth/2;
      spaceX = 0;
    }

    List<Element> rects = [];
    for (var x in keys) {
      if (_dataPoints[x] == null) continue;
      var mapPoints = Map<String, double?>.from(_dataPoints[x]!);

      // Clamp all values to avoid charts going overly high
      double total = minY;
      for (var graphName in barLabels) {
        if (_activeGraphs.isNotEmpty && !_activeGraphs.contains(graphName)) {
          mapPoints.remove(graphName);
          continue;
        }

        var y = mapPoints[graphName];
        if (y == null) continue;

        if (y < minY) mapPoints[graphName] = minY;
        if (y > maxY) mapPoints[graphName] = maxY;

        // chart is overflowing
        if (total + y > maxY) {
          if (total < maxY) {
            mapPoints[graphName] = maxY - total;
          } else {
            mapPoints.remove(graphName);
          }
        }

        total = total + y;
      }

      double? startY;
      for (var graphName in mapPoints.keys) {
        var y = mapPoints[graphName];
        if (y == null) {
          continue;
        }

        var offset = barWidth * barIndex + spaceX * barIndex + alignmentOffsetX;
        var pxY = lerp(y, minY, maxY, gridMaxPxY, gridMinPxY);
        var heightY = gridMaxPxY - pxY;
        if (startY == null) {
          startY = pxY;
          heightY = gridMaxPxY - pxY;
        } else {
          heightY = gridMaxPxY - pxY;
          startY = startY - heightY;
        }

        var fill = chartFillStyle[graphName] ?? chartFillStyle[keyAllGraph]!;
        var rect = SvgElement.svg('<rect x="${barMinPxX + offset}" y="$startY" width="$barWidth" height="$heightY" fill="$fill" />');
        rects.add(rect);
      }
      barIndex++;
    }

    _pointsElem.children.addAll(rects);
  }

  @override
  void drawGrid([bool drawY = false]) {
    _gridElem.children.clear();

    _svgElem.style.minWidth = '$gridMaxPxX';

    var labelCountY = getLabelCountY();
    var rangeY = gridMaxPxY - gridMinPxY;
    var spaceY = rangeY/(labelCountY-1);

    List<Element> lines = [];
    for (var i = 0; i < labelCountY; i++) {
      lines.add(SvgElement.svg('<line x1="$gridMinPxX" y1="${gridMinPxY + spaceY*i}" x2="$gridMaxPxX" y2="${gridMinPxY + spaceY*i}" stroke-width="$gridLineWidth" stroke="$gridLineStrokeStyle" />'));
    }

    if (drawY) {
      var labelCountX = _dataPoints.length;
      var labelMinPxX = gridMinPxX + max(barWidth, maxLabelWidthX)/2;
      var labelMaxPxX = gridMaxPxX - max(barWidth, maxLabelWidthX)/2;
      var rangeX  = labelMaxPxX - labelMinPxX;
      var spaceX = rangeX/(labelCountX-1);
      for (var i = 0; i < labelCountX; i++) {
        lines.add(SvgElement.svg('<line x1="${labelMinPxX + spaceX*i}" y1="$gridMinPxY" x2="${labelMinPxX + spaceX*i}" y2="$gridMaxPxY" stroke-width="$gridLineWidth" stroke="$gridLineStrokeStyle" />'));
      }
    }

    _gridElem.children.addAll(lines);
  }

  @override
  void drawLabels() {
    _labelElem.children.clear();

    var labelCountX = keys.length;
    var labelCountY = getLabelCountY();
    var labelMinPxX = gridMinPxX + max(barWidth, maxLabelWidthX)/2;
    var labelMaxPxX = gridMaxPxX - max(barWidth, maxLabelWidthX)/2;
    var rangeX  = labelMaxPxX - labelMinPxX;
    var rangeY = gridMaxPxY - gridMinPxY;

    var minY = getLabelMinY();
    var maxY = getLabelMaxY();

    var spaceX = rangeX/(labelCountX-1);
    var spaceY = rangeY/(labelCountY-1);
    var intervalY = (maxY - minY)/(labelCountY-1);

    List<Element> texts = [];
    for (var i = 0; i < labelCountY; i++) {
      texts.add(SvgElement.svg('<text x="${gridMinPxX - textMargin}" y="${gridMinPxY + spaceY*i}" style="font: $labelFontStyle;fill: $labelFillStyle;text-anchor: end;dominant-baseline: middle;">${labelFormatY(maxY - intervalY*i)}</text>'));
    }

    if (labelCountX >= 2) {
      var i = 0;
      for (var x in keys) {
        texts.add(SvgElement.svg('<text x="${labelMinPxX + spaceX*i}" y="${gridMaxPxY + textMargin}" style="font: $labelFontStyle;fill: $labelFillStyle;text-anchor: middle;dominant-baseline: text-top;">$x</text>'));
        i++;
      }
    } else {
      for (var x in keys) {
        texts.add(SvgElement.svg('<text x="${(labelMaxPxX - labelMinPxX)/2}" y="${gridMaxPxY + textMargin}" style="font: $labelFontStyle;fill: $labelFillStyle;text-anchor: middle;dominant-baseline: hanging;">$x</text>'));
      }
    }

    _labelElem.children.addAll(texts);
  }

  @override
  void onComponentAttached() {}
}