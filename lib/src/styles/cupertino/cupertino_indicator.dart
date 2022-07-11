part of easy_refresh;

const double _kDefaultCupertinoIndicatorRadius = 14.0;
const double _kDefaultWaterDropCupertinoIndicatorRadius = 10.0;

const _maxCircleRadius = 20.0;
const _minCircleRadius = _maxCircleRadius / 5;

/// Cupertino indicator.
/// Base widget for [CupertinoHeader] and [CupertinoFooter].
class _CupertinoIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  /// Indicator foreground color.
  final Color? foregroundColor;

  /// Use WaterDrop style.
  final bool userWaterDrop;

  /// WaterDrop background color.
  final Color? backgroundColor;

  const _CupertinoIndicator({
    Key? key,
    required this.state,
    required this.reverse,
    this.foregroundColor,
    this.userWaterDrop = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<_CupertinoIndicator> createState() => _CupertinoIndicatorState();
}

class _CupertinoIndicatorState extends State<_CupertinoIndicator>
    with SingleTickerProviderStateMixin {
  IndicatorMode get _mode => widget.state.mode;
  double get _offset => widget.state.offset;
  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  double get _radius => widget.userWaterDrop
      ? _kDefaultWaterDropCupertinoIndicatorRadius
      : _kDefaultCupertinoIndicatorRadius;

  late AnimationController _waterDropHiddenController;

  @override
  void initState() {
    super.initState();
    _waterDropHiddenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    widget.state.notifier.addModeChangeListener(_onModeChange);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _waterDropHiddenController.dispose();
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.ready) {
      if (!_waterDropHiddenController.isAnimating) {
        _waterDropHiddenController.forward(from: 0);
      }
    }
  }

  Widget _buildIndicator() {
    final scale = (_offset / _actualTriggerOffset).clamp(0.0, 1.0);
    switch (_mode) {
      case IndicatorMode.drag:
      case IndicatorMode.armed:
        const Curve opacityCurve = Interval(
          0.0,
          0.8,
          curve: Curves.easeInOut,
        );
        return Opacity(
          opacity: opacityCurve.transform(scale),
          child: CupertinoActivityIndicator.partiallyRevealed(
            radius: _radius,
            progress: math.min(scale, 0.99),
            color: widget.foregroundColor,
          ),
        );
      case IndicatorMode.ready:
      case IndicatorMode.processing:
      case IndicatorMode.processed:
        return CupertinoActivityIndicator(
          radius: _radius,
          color: widget.foregroundColor,
        );
      case IndicatorMode.done:
        return CupertinoActivityIndicator(
          radius: _radius * scale,
          color: widget.foregroundColor,
        );
      default:
        return Container();
    }
  }

  Widget _buildWaterDrop() {
    Widget waterDropWidget = CustomPaint(
      painter: WaterDropPainter(
        offset: _offset,
        actualTriggerOffset: _actualTriggerOffset,
        color: widget.backgroundColor ?? Theme.of(context).splashColor,
      ),
    );
    return AnimatedBuilder(
      animation: _waterDropHiddenController,
      builder: (context, _) {
        double opacity = 1;
        if (_mode == IndicatorMode.drag) {
          final scale = (_offset / _actualTriggerOffset).clamp(0.0, 1.0);
          const Curve opacityCurve = Interval(
            0.0,
            0.8,
            curve: Curves.easeInOut,
          );
          opacity = opacityCurve.transform(scale);
        } else if (_mode == IndicatorMode.armed) {
          opacity = 1;
        } else if (_mode == IndicatorMode.ready ||
            _mode == IndicatorMode.processing ||
            _mode == IndicatorMode.processed ||
            _mode == IndicatorMode.done) {
          opacity = 1 - _waterDropHiddenController.value;
        } else {
          opacity = 0;
        }
        return Opacity(
          opacity: opacity,
          child: waterDropWidget,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: _offset,
          width: double.infinity,
        ),
        // WaterDrop.
        if (widget.userWaterDrop &&
            widget.state.indicator.infiniteOffset == null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: _offset,
              width: double.infinity,
              child: _buildWaterDrop(),
            ),
          ),
        // Indicator.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            alignment: Alignment.center,
            height: _actualTriggerOffset,
            width: double.infinity,
            child: _buildIndicator(),
          ),
        ),
      ],
    );
  }
}

class WaterDropPainter extends CustomPainter {
  final Color color;
  final double offset;
  final double actualTriggerOffset;

  WaterDropPainter({
    required this.color,
    required this.offset,
    required this.actualTriggerOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    double topRadius = _maxCircleRadius;
    double bottomRadius = _maxCircleRadius;
    if (offset > actualTriggerOffset) {
      const radiusLimit = _maxCircleRadius - _minCircleRadius;
      final radiusDifference = radiusLimit *
          (1 - math.pow(100, -(offset - actualTriggerOffset) / 200));
      topRadius = topRadius - radiusDifference / 4;
      bottomRadius = bottomRadius - radiusDifference;
    }
    Path path = Path();
    final paint = Paint()..color = color;
    final topCenterY = actualTriggerOffset / 2;
    final centerX = width / 2;
    path.addOval(
      Rect.fromCircle(
        center: Offset(
          centerX,
          actualTriggerOffset / 2,
        ),
        radius: topRadius,
      ),
    );
    if (offset > actualTriggerOffset) {
      final bottomCenterY =
          offset - (actualTriggerOffset / 2 - topRadius) - bottomRadius;
      path.addOval(
        Rect.fromCircle(
          center: Offset(
            centerX,
            bottomCenterY,
          ),
          radius: bottomRadius,
        ),
      );

      final bezierPath = Path();
      final angle =
          math.asin((topRadius - bottomRadius) / (topCenterY - bottomCenterY));
      final topX1 = centerX - topRadius * math.cos(angle);
      final topY1 = topCenterY + topRadius * math.sin(angle);
      final topX2 = centerX + topRadius * math.cos(angle);
      final topY2 = topY1;
      final bottomX1 = centerX - bottomRadius * math.cos(angle);
      final bottomY1 = bottomCenterY + bottomRadius * math.sin(angle);
      final bottomX2 = centerX + bottomRadius * math.cos(angle);
      final bottomY2 = bottomY1;
      bezierPath.moveTo(centerX, topCenterY);
      bezierPath.lineTo(topX1, topY1);
      bezierPath.quadraticBezierTo((centerX - bottomRadius),
          (bottomCenterY + topCenterY) / 2, bottomX1, bottomY1);
      bezierPath.lineTo(bottomX2, bottomY2);
      bezierPath.quadraticBezierTo(
          (centerX + bottomRadius), (bottomCenterY + topY2) / 2, topX2, topY2);
      bezierPath.close();

      path = Path.combine(PathOperation.union, path, bezierPath);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaterDropPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.actualTriggerOffset != actualTriggerOffset ||
        (oldDelegate.offset != offset &&
            !(oldDelegate.offset < oldDelegate.actualTriggerOffset &&
                offset < actualTriggerOffset));
  }
}
