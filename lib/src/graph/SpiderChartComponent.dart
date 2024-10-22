part of '../../graph.dart';

class SpiderChartComponent extends BaseGraphComponent {
  static const keyAllGraph = BaseGraphComponent.keyAllGraph;

  /// The maximum width for label texts in X axis.
  final double maxLabelWidth;
  /// The number of points of the spider chart.
  int get points => labels.length;
  /// The width interval (radius) for each grid.
  double pointIntervalRadiusWidth;
  /// The list of labels currently present in the chart.
  Set<String> labels;
  /// Chart fill style.
  Map<String, Color> chartFillStyle = {
    keyAllGraph: Color.css('rgba(0, 0, 0, 0.2)')
  };

  Map<String, Map<String, double>> _dataPoints = {};
  late final ResizeObserver _resizeObserver = ResizeObserver((entries, observer) {
    redraw();
  });

  SvgSvgElement get _svgElem => queryById('$id-svg') as SvgSvgElement;
  GElement get _gridElem => queryById('$id-svg-grid') as GElement;
  GElement get _labelElem => queryById('$id-svg-label') as GElement;
  GElement get _pointsElem => queryById('$id-svg-points') as GElement;

  SpiderChartComponent(super.parent, super.id, {
    this.maxLabelWidth = 50,
    this.pointIntervalRadiusWidth = 20,
    Set<String>? labels,
    super.gridLineWidth,
    super.aspectRatio,
    super.textMargin,
    super.gridLineStrokeStyle,
    super.labelFillStyle,
    super.labelFontStyle,
    super.captionBgColor,
    super.captionFgColor,
    super.captionFontFamily,
  }) : labels = labels ?? {} {
    baseInnerHtml = '''
    <div id="$id" style="aspect-ratio: $aspectRatio;position: relative;overflow-x: auto;width: 100%;">
        <svg id="$id-svg" xmlns="http://www.w3.org/2000/svg" class="$id" width="100%" height="100%" style="display: block;">
            <g id="$id-svg-grid"></g>
            <g id="$id-svg-label"></g>
            <g id="$id-svg-points"></g>
        </svg>
    </div>
    ''';
  }

  @override
  void onComponentAttached() {}

  Map<String, Map<String, double>> get dataPoints => _dataPoints;

  set dataPoints(Map<String, Map<String, double>> value) {
    _dataPoints = value;
    drawDataPoints();
  }

  void hideGraph(String graphId) {
    (queryById('$id-$graphId') as GElement?)?.style.opacity = '0';
  }

  void showGraph(String graphId) {
    (queryById('$id-$graphId') as GElement?)?.style.removeProperty('opacity');
  }

  void redraw() {
    drawGrid();
    drawLabels();
    drawDataPoints();
  }

  @override
  void clearPoints() {
    _pointsElem.children.clear();
  }

  @override
  void drawDataPoints() {
    _pointsElem.children.clear();
    if (points == 0 || _dataPoints.isEmpty) return;

    for (var dpe in dataPoints.entries) {
      var g = GElement();
      g.id = '$id-${dpe.key}';
      g.style.transition = 'opacity 0.2s ease';

      final radians = 2*pi/points.toDouble();
      final r = min(_svgElem.clientWidth, _svgElem.clientHeight)/2;
      final dx = max(_svgElem.clientWidth/2 - r, 0);
      final dy = max(_svgElem.clientHeight/2 - r, 0);

      var gridR = r - gridLineWidth - textMargin/4 - maxLabelWidth;
      var polygons = <List<double>>[];
      var i = 0;
      for (var label in labels) {
        var x = dpe.value[label] ?? 0;

        var dataR = gridR*max(min(x, 1), 0);
        polygons.add([
          dataR*sin((radians*i)+pi) + r + dx,
          dataR*cos((radians*i)+pi) + r + dy,
        ]);
        i++;
      }

      var pointStr = polygons.map((e) => e.join(' ')).join(', ');
      var fill = chartFillStyle[dpe.key] ?? chartFillStyle[keyAllGraph]!;
      g.children.add(SvgElement.svg('<polygon points="$pointStr" fill="$fill" stroke-width="1" stroke="$fill" />'));

      var fillRgba = fill.rgba;
      for (var p in polygons) {
        var dotFill = Color.createRgba(fillRgba.r, fillRgba.g, fillRgba.b);
        g.children.add(SvgElement.svg('<circle cx="${p[0]}" cy="${p[1]}" r="3" fill="$dotFill" />'));
      }

      _pointsElem.children.add(g);
    }
  }

  @override
  void drawGrid([bool drawY = true]) {
    _gridElem.children.clear();
    if (points == 0) return;

    final radians = 2*pi/points.toDouble();
    final r = min(_svgElem.clientWidth, _svgElem.clientHeight)/2;
    final dx = max(_svgElem.clientWidth/2 - r, 0);
    final dy = max(_svgElem.clientHeight/2 - r, 0);

    var gridR = r - gridLineWidth - textMargin/4 - maxLabelWidth;
    List<List<double>>? outerPolygons;
    while (gridR > 10) {
      var polygons = <List<double>>[];

      for (var i = 0; i < points; i++) {
        polygons.add([
          gridR*sin((radians*i)+pi) + r + dx,
          gridR*cos((radians*i)+pi) + r + dy,
        ]);
      }

      outerPolygons ??= polygons;

      var pointStr = polygons.map((e) => e.join(' ')).join(', ');
      _gridElem.children.add(SvgElement.svg('<polygon points="$pointStr" stroke="$gridLineStrokeStyle" fill="none" stroke-width="$gridLineWidth" />'));
      gridR = gridR - pointIntervalRadiusWidth;
      if (gridR <= 10) break;
    }

    if (outerPolygons != null) {
      for (var p in outerPolygons) {
        _gridElem.children.add(SvgElement.svg('<line x1="${r+dx}" y1="${r+dy}" x2="${p[0]}" y2="${p[1]}" stroke-width="$gridLineWidth" stroke="$gridLineStrokeStyle" />'));
      }
    }

  }

  @override
  void drawLabels() {
    _labelElem.children.clear();
    if (points == 0) return;

    final radians = 2*pi/points.toDouble();
    var polygons = <List<double>>[];

    final r = min(_svgElem.clientWidth, _svgElem.clientHeight)/2;
    final dx = max(_svgElem.clientWidth/2 - r, 0);
    final dy = max(_svgElem.clientHeight/2 - r, 0);

    var labelR = r - textMargin/2 - maxLabelWidth/4;
    for (var i = 0; i < points; i++) {
      if (i == 0) {
        polygons.add([
          labelR*sin((radians*i)+pi) + r + dx,
          labelR*cos((radians*i)+pi) + r + dy + 10, // This brings the first top label closer to the chart, for optical correctness
        ]);
      } else {
        polygons.add([
          labelR*sin((radians*i)+pi) + r + dx,
          labelR*cos((radians*i)+pi) + r + dy,
        ]);
      }

    }

    var textElems = <SvgElement>[];
    var i = 0;
    for (var label in labels) {
      var p = polygons[i];
      textElems.add(SvgElement.svg('<text x="${p[0]}" y="${p[1]}" style="font: $labelFontStyle;fill: $labelFillStyle;text-anchor: middle;dominant-baseline: middle;">$label</text>'));
      i++;
    }

    _gridElem.children.addAll(textElems);
  }

  @override
  void loadEventHandlers() {
    super.loadEventHandlers();
    _resizeObserver.observe(_svgElem);
  }

  @override
  void unloadEventHandlers() {
    super.unloadEventHandlers();
    _resizeObserver.unobserve(_svgElem);
  }
}