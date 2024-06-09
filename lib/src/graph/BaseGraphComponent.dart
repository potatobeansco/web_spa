part of '../../graph.dart';

abstract class BaseGraphComponent extends StringComponent  {
  /// The default SVG viewbox width.
  /// The SVG height will be calculated by width/[aspectRatio].
  static const svgViewBoxWidth = 300;

  static const keyAllGraph = '';

  /// The calculated height of label fonts.
  /// It is calculated by measuring the baseline to the top part of the text
  /// bounding box. See also [TextMetrics.fontBoundingBoxAscent].
  double _textHeight = 10;
  /// The minimum coordinate of the grid, in pixel.
  /// The grid starts at ([gridMinPxX],[gridMinPxY]) and ends in
  /// ([gridMaxPxX], [gridMaxPxY]).
  @protected
  late double gridMinPxX;
  /// The minimum coordinate of the grid, in pixel.
  /// The grid starts at ([gridMinPxX],[gridMinPxY]) and ends in
  /// ([gridMaxPxX], [gridMaxPxY]).
  @protected
  late double gridMinPxY;
  /// The maximum coordinate of the grid, in pixel.
  /// The grid starts at ([gridMinPxX],[gridMinPxY]) and ends in
  /// ([gridMaxPxX], [gridMaxPxY]).
  @protected
  late double gridMaxPxX;
  /// The maximum coordinate of the grid, in pixel.
  /// The grid starts at ([gridMinPxX],[gridMinPxY]) and ends in
  /// ([gridMaxPxX], [gridMaxPxY]).
  @protected
  late double gridMaxPxY;

  /// The maximum width for label texts in X axis.
  final double maxLabelWidthX;
  /// The maximum width for label texts in Y axis.
  final double maxLabelWidthY;
  /// The distance between label text to the grid.
  final double textMargin;
  /// The formatting function used to display the labels in X axis.
  /// If none is specified, it by default uses [NumberFormat.compact] to format
  /// label values into string. You might want to override this for example
  /// if you want the label to be a date.
  ///
  /// Label values are calculated arithmetically, so the produced value is double.
  /// If you want custom label formatting, for example to include units or converts
  /// seconds into human-readable date, you should supply this function.
  final String Function(double label) labelFormatX;
  /// The formatting function used to display the labels in Y axis.
  /// If none is specified, it by default uses [NumberFormat.compact] to format
  /// label values into string. You might want to override this for example
  /// if you want the label to be a date.
  ///
  /// Label values are calculated arithmetically, so the produced value is double.
  /// If you want custom label formatting, for example to include units or converts
  /// seconds into human-readable date, you should supply this function.
  final String Function(double label) labelFormatY;

  /// The width/height ratio of this canvas. The canvas height, everytime it
  /// is redrawn, changes based on the canvas clientWidth. The height follows
  /// the width depending on the ratio: height = width/aspectRatio.
  final double aspectRatio;

  /// The line width used to draw canvas grid.
  final double gridLineWidth;
  /// The line stroke style for the canvas grid.
  final String gridLineStrokeStyle;
  /// The label texts color style.
  final String labelFillStyle;
  /// The labels font style.
  final String labelFontStyle;
  /// The caption background color.
  final String captionBgColor;
  /// The caption foreground color (the text color).
  final String captionFgColor;
  /// The caption font family.
  final String captionFontFamily;
  /// Whether to draw Y grid lines.
  final bool drawGridY;

  CanvasRenderingContext2D get ctx {
    return _canvasElem.context2D;
  }

  CanvasElement get _canvasElem => queryById('$id-canvas') as CanvasElement;
  SvgElement get _svgElem => queryById('$id-caption') as SvgElement;
  GElement get _captionElem => queryById('$id-caption-g') as GElement;
  RectElement get _captionRectElem => queryById('$id-caption-g-rect') as RectElement;
  TextElement get _captionTextElem => queryById('$id-caption-g-text') as TextElement;

  BaseGraphComponent(RenderComponent parent, String id,
      {
        this.maxLabelWidthX = 50,
        this.maxLabelWidthY = 20,
        this.textMargin = 15,
        this.labelFormatX = _defaultLabelFormat,
        this.labelFormatY = _defaultLabelFormat,
        this.aspectRatio = 1.5,
        this.gridLineWidth = 1,
        this.gridLineStrokeStyle = '#d7d7d7',
        this.labelFillStyle = '#aaaaaa',
        this.labelFontStyle = '14px sans-serif',
        this.captionBgColor = '#2d2d2d',
        this.captionFgColor = 'white',
        this.captionFontFamily = 'sans-serif',
        this.drawGridY = false,
      }) : super.empty(parent, id) {

    baseInnerHtml = '''
    <div id="$id" style="position: relative;overflow-x: auto;">
        <canvas id="$id-canvas" style="width: 100%;"></canvas>
        <svg xmlns="http://www.w3.org/2000/svg" id="$id-caption" class="$id-caption" width="300" preserveAspectRatio="xMinYMin meet"
            style="width: 100%; position: absolute;top: 0;left: 0;">
         <defs>
          <filter id="$id-dropshadow" color-interpolation-filters="sRGB" x="-40%" y="-40%" width="180%" height="180%">
            <feGaussianBlur in="SourceAlpha" stdDeviation="4"/> <!-- stdDeviation is how much to blur -->
            <feOffset dx="3" dy="3" result="offsetblur"/> <!-- how much to offset -->
            <feComponentTransfer>
                <feFuncA type="linear" slope="0.3"/> <!-- slope is the opacity of the shadow -->
            </feComponentTransfer>
            <feMerge> 
                <feMergeNode/> <!-- this contains the offset blurred image -->
                <feMergeNode in="SourceGraphic"/> <!-- this contains the element that the filter is applied to -->
            </feMerge>
          </filter>
         </defs>
         <g visibility="hidden" id="$id-caption-g">
            <rect id="$id-caption-g-rect" width="88" height="33" ry="3" fill="$captionBgColor" filter="url(#$id-dropshadow)" />
            <text id="$id-caption-g-text" x="44" y="16.5" text-anchor="middle" dominant-baseline="middle" fill="$captionFgColor" font-family="$captionFontFamily" font-size="16px" letter-spacing="0px" xml:space="preserve">Text</text>
         </g>
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

  /// The exact font height is retrieved from [TextMetrics.fontBoundingBoxAscent].
  /// However, not all browsers support this property, and if this property returns
  /// null, the height can be approximated by getting the width of character
  /// 'M'. This is no magic, see also: https://stackoverflow.com/a/13318387/9113939.
  double getApproxTextHeight() {
    ctx.font = labelFontStyle;
    var metric = ctx.measureText('100'); // 100 is a test text. It does not matter what is put here.
    if (metric.fontBoundingBoxAscent != null) return metric.fontBoundingBoxAscent!.toDouble();
    return ctx.measureText('M').width!.toDouble();
  }

  /// Gets the calculated minimum width of the graph.
  double getCalculatedMinWidth();

  @protected
  void calculateMinMaxGrid() {
    gridMaxPxX = calcGridMaxPxX();
    gridMaxPxY = calcGridMaxPxY();
    gridMinPxX = calcGridMinPxX();
    gridMinPxY = calcGridMinPxY();
  }

  void redraw() {
    _canvasElem.style.minWidth = '${getCalculatedMinWidth()}px';
    _canvasElem.style.aspectRatio = aspectRatio.toStringAsPrecision(5);
    ctx.canvas.width = _canvasElem.parent!.clientWidth;
    ctx.canvas.height = (elem.clientWidth/aspectRatio).truncate();
    _textHeight = getApproxTextHeight();
    calculateMinMaxGrid();
    drawGrid(drawGridY);
    drawDataPoints();
    drawLabels();
    _svgElem.setAttribute('viewBox', '0 0 ${ctx.canvas.width} ${ctx.canvas.height}');
    _svgElem.style.aspectRatio = aspectRatio.toStringAsPrecision(5);
  }

  void clearDrawing() {
    ctx.clearRect(0, 0, ctx.canvas.width!.toDouble(), ctx.canvas.height!.toDouble());
    hideCaption();
  }

  /// Hides the caption if it's already shown.
  @protected
  void hideCaption() {
    _captionElem.setAttribute('visibility', 'hidden');
  }

  @protected
  void drawGrid([bool drawY = false]);

  @protected
  void drawLabels();

  @protected
  void drawDataPoints();

  void clearPoints();

  double calcGridMaxPxX();

  double calcGridMaxPxY();

  double calcGridMinPxX();

  double calcGridMinPxY();

  /// Gets how many labels the graph should display in X axis.
  int getLabelCountX();

  /// Gets how many labels the graph should display in Y axis.
  int getLabelCountY();

  /// Linear interpolate x between two points (x1, y1) and (x2, y2).
  @protected
  double lerp(num x, num x1, num x2, num y1, num y2) {
    var m = (y2 - y1)/(x2 - x1);
    var y = y1 + (x - x1) * m;
    return y.toDouble();
  }
}

class DataPoint {
  double x;
  double y;

  DataPoint(this.x, this.y);
}