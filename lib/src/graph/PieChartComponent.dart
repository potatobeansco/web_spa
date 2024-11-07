part of '../../graph.dart';

class PieChartComponent extends BaseGraphComponent {
  static final NumberFormat _nf = NumberFormat.percentPattern();

  static const keyAllGraph = BaseGraphComponent.keyAllGraph;

  /// The maximum width for label texts in X axis.
  final double maxLabelWidth;
  /// The width interval (radius) for each grid.
  double pointIntervalRadiusWidth;
  /// Chart fill style.
  Map<String, Color> chartFillStyle = {
    keyAllGraph: Color.css('#2d2d2d')
  };

  Map<String, double> _dataPoints = {};
  final Set<String> _activeGraphs = {};

  late final ResizeObserver _resizeObserver = ResizeObserver((entries, observer) {
    redraw();
  });

  SvgSvgElement get _svgElem => queryById('$id-svg') as SvgSvgElement;
  GElement get _labelElem => queryById('$id-svg-label') as GElement;
  GElement get _pointsElem => queryById('$id-svg-points') as GElement;

  PieChartComponent(super.parent, super.id, {
    this.maxLabelWidth = 50,
    this.pointIntervalRadiusWidth = 20,
    String css = 'pie',
    super.gridLineWidth,
    super.aspectRatio,
    super.textMargin,
    super.gridLineStrokeStyle,
    super.labelFillStyle = '#ffffff',
    super.labelFontStyle,
    super.captionBgColor,
    super.captionFgColor,
    super.captionFontFamily,
  }) {
    baseInnerHtml = '''
    <div id="$id" class="$css" style="aspect-ratio: $aspectRatio;position: relative;overflow-x: auto;width: 100%;">
        <svg id="$id-svg" xmlns="http://www.w3.org/2000/svg" class="$css-svg" width="100%" height="100%" style="display: block;">
            <g id="$id-svg-points"></g>
            <g id="$id-svg-label"></g>
        </svg>
    </div>
    ''';
  }

  @override
  void onComponentAttached() {}

  Map<String, double> get dataPoints => _dataPoints;

  set dataPoints(Map<String, double> value) {
    _dataPoints = _scale(value);
    drawDataPoints();
    drawLabels();
  }

  void hideGraph(String graphId) {
    _activeGraphs.remove(graphId);
    drawDataPoints();
  }

  void showGraph(String graphId) {
    _activeGraphs.add(graphId);
    drawDataPoints();
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

  Map<String, double> _scale(Map<String, double> orig) {
    var data = Map<String, double>.from(orig);

    double total = orig.values.fold(0, (pv, v) => pv + v);
    total = total == 0 ? 1 : total;
    for (var d in orig.entries) {
      var v = d.value;
      data[d.key] = v/total;
    }

    return data;
  }

  @override
  void drawDataPoints() {
    _pointsElem.children.clear();
    if (_dataPoints.isEmpty) return;

    final centerX = _svgElem.clientWidth/2;
    final centerY = _svgElem.clientHeight/2;

    final r = min(_svgElem.clientWidth, _svgElem.clientHeight)/2;
    final dx = max(_svgElem.clientWidth/2 - r, 0);
    final dy = max(_svgElem.clientHeight/2 - r, 0);
    var gridR = r - gridLineWidth - textMargin/4 - maxLabelWidth;

    double totalRadii = 0;
    for (var dpe in _dataPoints.entries) {
      var value = dpe.value;
      var dataRadii = 2*pi*dpe.value;
      var pointStart = [gridR*sin(totalRadii) + r + dx, gridR*cos(totalRadii) + r + dy];
      var pointEnd = [gridR*sin(totalRadii+dataRadii) + r + dx, gridR*cos(totalRadii + dataRadii) + r + dy];

      var largeArc = value > 0.5 ? 1 : 0;
      var fill = chartFillStyle[dpe.key] ?? chartFillStyle[keyAllGraph]!;
      if (_activeGraphs.isNotEmpty && !_activeGraphs.contains(dpe.key)) {
        fill = Color.createRgba(0, 0, 0, 0.2);
      }

      _pointsElem.children.add(SvgElement.svg('<path d="M$centerX,$centerY L${pointStart[0]},${pointStart[1]} A$gridR $gridR ${360*value} $largeArc 0 ${pointEnd[0]},${pointEnd[1]} Z" fill="$fill" stroke="rgba(255, 255, 255, 0.1)" stroke-width="1" />'));
      totalRadii += dataRadii;
    }
  }

  @override
  void drawGrid([bool drawY = true]) {}

  @override
  void drawLabels() {
    _labelElem.children.clear();

    final r = min(_svgElem.clientWidth, _svgElem.clientHeight)/2;
    final dx = max(_svgElem.clientWidth/2 - r, 0);
    final dy = max(_svgElem.clientHeight/2 - r, 0);
    var gridR = (r - gridLineWidth - textMargin/4 - maxLabelWidth)*0.6;

    double totalRadii = 0;
    for (var dpe in _dataPoints.entries) {
      var dataRadii = 2*pi*dpe.value;
      var area = 2*pi*r*r*dpe.value;
      // Only draw label if area is enough
      if (area > 5000) {
        var labelRadii = dataRadii/2;
        var p = [gridR*sin(totalRadii + labelRadii) + r + dx, gridR*cos(totalRadii + labelRadii) + r + dy];

        _labelElem.children.add(SvgElement.svg('<text x="${p[0]}" y="${p[1]}" style="font: $labelFontStyle;fill: $labelFillStyle;text-anchor: middle;dominant-baseline: middle;">${_nf.format(dpe.value)}</text>'));
      }

      totalRadii += dataRadii;
    }
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