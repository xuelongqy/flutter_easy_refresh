part of '../../../easy_refresh.dart';

const double _kDefaultCupertinoIndicatorRadius = 14.0;
const double _kDefaultWaterDropCupertinoIndicatorRadius = 10.0;

const _maxCircleRadius = 20.0;
const _minCircleRadius = _maxCircleRadius / 5;

double kCupertinoFrictionFactor(double overscrollFraction) =>
    0.25 * math.pow(1 - overscrollFraction, 2);

double kCupertinoHorizontalFrictionFactor(double overscrollFraction) =>
    0.52 * math.pow(1 - overscrollFraction, 2);

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

  /// Empty widget.
  /// When result is [IndicatorResult.noMore].
  final Widget? emptyWidget;

  const _CupertinoIndicator({
    super.key,
    required this.state,
    required this.reverse,
    this.foregroundColor,
    this.userWaterDrop = true,
    this.backgroundColor,
    this.emptyWidget,
  });

  @override
  State<_CupertinoIndicator> createState() => _CupertinoIndicatorState();
}

class _CupertinoIndicatorState extends State<_CupertinoIndicator>
    with SingleTickerProviderStateMixin {
  Axis get _axis => widget.state.axis;

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  double get _radius => _useWaterDrop
      ? _kDefaultWaterDropCupertinoIndicatorRadius
      : _kDefaultCupertinoIndicatorRadius;

  late AnimationController _waterDropHiddenController;

  bool get _useWaterDrop =>
      widget.userWaterDrop && widget.state.indicator.infiniteOffset == null;

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
    final scale = (_offset / _actualTriggerOffset).clamp(0.01, 0.99);
    Widget indicator;
    switch (_mode) {
      case IndicatorMode.drag:
      case IndicatorMode.armed:
        const Curve opacityCurve = Interval(
          0.0,
          0.8,
          curve: Curves.easeInOut,
        );
        indicator = Opacity(
          key: const ValueKey('indicator'),
          opacity: opacityCurve.transform(scale),
          child: _CupertinoActivityIndicator.partiallyRevealed(
            radius: _radius,
            progress: scale,
            color: widget.foregroundColor,
          ),
        );
        break;
      case IndicatorMode.ready:
      case IndicatorMode.processing:
      case IndicatorMode.processed:
        indicator = _CupertinoActivityIndicator(
          key: const ValueKey('indicator'),
          radius: _radius,
          color: widget.foregroundColor,
          animating: true,
        );
        break;
      case IndicatorMode.done:
        indicator = _CupertinoActivityIndicator(
          key: const ValueKey('indicator'),
          radius: _radius * scale,
          color: widget.foregroundColor,
          animating: true,
        );
        break;
      default:
        indicator = const SizedBox(
          key: ValueKey('indicator'),
        );
        break;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 100),
      child: widget.state.result == IndicatorResult.noMore
          ? widget.emptyWidget != null
              ? SizedBox(
                  key: const ValueKey('noMore'),
                  child: widget.emptyWidget!,
                )
              : Icon(
                  CupertinoIcons.archivebox,
                  key: const ValueKey('noMore'),
                  color: widget.foregroundColor,
                )
          : indicator,
    );
  }

  Widget _buildWaterDrop() {
    Widget waterDropWidget = CustomPaint(
      painter: _WaterDropPainter(
        axis: _axis,
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
    double offset = _offset;
    if (widget.state.indicator.infiniteOffset != null &&
        widget.state.indicator.position == IndicatorPosition.locator &&
        (_mode != IndicatorMode.inactive ||
            widget.state.result == IndicatorResult.noMore)) {
      offset = _actualTriggerOffset;
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: _axis == Axis.vertical ? offset : double.infinity,
          width: _axis == Axis.vertical ? double.infinity : offset,
        ),
        // WaterDrop.
        if (_useWaterDrop)
          Positioned(
            top: 0,
            left: 0,
            right: _axis == Axis.vertical ? 0 : null,
            bottom: _axis == Axis.vertical ? null : 0,
            child: SizedBox(
              height: _axis == Axis.vertical ? _offset : double.infinity,
              width: _axis == Axis.vertical ? double.infinity : _offset,
              child: _buildWaterDrop(),
            ),
          ),
        // Indicator.
        Positioned(
          top: 0,
          left: 0,
          right: _axis == Axis.vertical ? 0 : null,
          bottom: _axis == Axis.vertical ? null : 0,
          child: Container(
            alignment: Alignment.center,
            height:
                _axis == Axis.vertical ? _actualTriggerOffset : double.infinity,
            width:
                _axis == Axis.vertical ? double.infinity : _actualTriggerOffset,
            child: _buildIndicator(),
          ),
        ),
      ],
    );
  }
}

class _WaterDropPainter extends CustomPainter {
  final Axis axis;
  final Color color;
  final double offset;
  final double actualTriggerOffset;

  _WaterDropPainter({
    required this.axis,
    required this.color,
    required this.offset,
    required this.actualTriggerOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawPath(
        axis == Axis.vertical
            ? _buildVerticalPath(size)
            : _buildHorizontalPath(size),
        paint);
  }

  Path _buildVerticalPath(Size size) {
    Path path = Path();
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
    return path;
  }

  Path _buildHorizontalPath(Size size) {
    Path path = Path();
    final height = size.height;
    double topRadius = _maxCircleRadius;
    double bottomRadius = _maxCircleRadius;
    if (offset > actualTriggerOffset) {
      const radiusLimit = _maxCircleRadius - _minCircleRadius;
      final radiusDifference = radiusLimit *
          (1 - math.pow(100, -(offset - actualTriggerOffset) / 200));
      topRadius = topRadius - radiusDifference / 4;
      bottomRadius = bottomRadius - radiusDifference;
    }
    final topCenterX = actualTriggerOffset / 2;
    final centerY = height / 2;
    path.addOval(
      Rect.fromCircle(
        center: Offset(
          actualTriggerOffset / 2,
          centerY,
        ),
        radius: topRadius,
      ),
    );
    if (offset > actualTriggerOffset) {
      final bottomCenterX =
          offset - (actualTriggerOffset / 2 - topRadius) - bottomRadius;
      path.addOval(
        Rect.fromCircle(
          center: Offset(
            bottomCenterX,
            centerY,
          ),
          radius: bottomRadius,
        ),
      );

      final bezierPath = Path();
      final angle =
          math.asin((topRadius - bottomRadius) / (topCenterX - bottomCenterX));
      final topY1 = centerY - topRadius * math.cos(angle);
      final topX1 = topCenterX + topRadius * math.sin(angle);
      final topY2 = centerY + topRadius * math.cos(angle);
      final topX2 = topX1;
      final bottomY1 = centerY - bottomRadius * math.cos(angle);
      final bottomX1 = bottomCenterX + bottomRadius * math.sin(angle);
      final bottomY2 = centerY + bottomRadius * math.cos(angle);
      final bottomX2 = bottomX1;
      bezierPath.moveTo(topCenterX, centerY);
      bezierPath.lineTo(topX1, topY1);
      bezierPath.quadraticBezierTo((bottomCenterX + topCenterX) / 2,
          (centerY - bottomRadius), bottomX1, bottomY1);
      bezierPath.lineTo(bottomX2, bottomY2);
      bezierPath.quadraticBezierTo(
          (bottomCenterX + topX2) / 2, (centerY + bottomRadius), topX2, topY2);
      bezierPath.close();

      path = Path.combine(PathOperation.union, path, bezierPath);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) {
    return oldDelegate.axis != axis ||
        oldDelegate.color != color ||
        oldDelegate.actualTriggerOffset != actualTriggerOffset ||
        (oldDelegate.offset != offset &&
            !(oldDelegate.offset < oldDelegate.actualTriggerOffset &&
                offset < actualTriggerOffset));
  }
}
