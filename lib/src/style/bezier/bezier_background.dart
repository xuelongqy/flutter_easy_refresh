part of easyrefresh;

/// Spring used by bezier curves.
const SpringDescription kBezierSpring =
    SpringDescription(mass: 3, stiffness: 700, damping: 50);

/// Friction factor used by bezier curves.
double kBezierFrictionFactor(double overscrollFraction) =>
    0.375 * math.pow(1 - overscrollFraction, 2);

/// Bezier curve background.
class BezierBackground extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// Background color.
  final Color? color;

  /// Whether to rebound after retraction.
  final bool rebound;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const BezierBackground({
    Key? key,
    required this.state,
    required this.reverse,
    this.rebound = true,
    this.color,
  }) : super(key: key);

  @override
  State<BezierBackground> createState() => _BezierBackgroundState();
}

class _BezierBackgroundState extends State<BezierBackground>
    with SingleTickerProviderStateMixin {
  /// Minimum rebound value.
  static const _kMinReboundOffset = 10.0;

  /// Maximum rebound value.
  static const _kMaxReboundOffset = 50.0;

  double get _offset => widget.state.offset;

  IndicatorMode get _mode => widget.state.mode;

  Axis get _axis => widget.state.axis;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  /// Get background color.
  Color get _color => widget.color ?? Theme.of(context).primaryColor;

  /// [Scrollable] pull value.
  /// Log when mode is [IndicatorMode.ready].
  double _pullOffset = 0;

  /// Rebound animation controller.
  late AnimationController _reboundController;

  @override
  void initState() {
    super.initState();
    _reboundController = AnimationController.unbounded(vsync: this);
    _reboundController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _reboundController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BezierBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mode == IndicatorMode.ready &&
        oldWidget.state.mode != IndicatorMode.ready) {
      _pullOffset = widget.state.offset;
    } else if (_mode == IndicatorMode.processing &&
        oldWidget.state.mode != IndicatorMode.processing &&
        widget.rebound) {
      // Start rebound;
      double reboundOffset = (_pullOffset - _actualTriggerOffset) / 2;
      reboundOffset = math.min(reboundOffset, _kMaxReboundOffset);
      if (reboundOffset >= _kMinReboundOffset) {
        _onRebound(reboundOffset);
      }
    }
  }

  /// Rebound animation.
  void _onRebound(double reboundOffset) {
    _reboundController
        .animateTo(reboundOffset,
            duration: const Duration(milliseconds: 150), curve: Curves.easeOut)
        .whenComplete(() => _reboundController.animateTo(0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.bounceIn.flipped));
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BezierPainter(
        axis: _axis,
        reverse: widget.reverse,
        offset: _offset,
        actualTriggerOffset: _actualTriggerOffset,
        reboundOffset:
            _reboundController.isAnimating ? _reboundController.value : null,
      ),
      child: Container(
        width: _axis == Axis.horizontal ? _offset : double.infinity,
        height: _axis == Axis.vertical ? _offset : double.infinity,
        color: _color,
      ),
    );
  }
}

/// Bezier curve painter.
class _BezierPainter extends CustomClipper<Path> {
  /// [Scrollable] axis.
  final Axis axis;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  /// Overscroll offset.
  final double offset;

  /// Actual trigger offset.
  final double actualTriggerOffset;

  /// Rebound offset.
  final double? reboundOffset;

  _BezierPainter({
    required this.axis,
    required this.reverse,
    required this.offset,
    required this.actualTriggerOffset,
    this.reboundOffset,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;
    if (axis == Axis.vertical) {
      if (reverse) {
        // Up
        final startHeight =
            height > actualTriggerOffset ? height - actualTriggerOffset : 0.0;
        path.moveTo(width, startHeight);
        path.lineTo(width, height);
        path.lineTo(0, height);
        path.lineTo(0, startHeight);
        if (height <= actualTriggerOffset) {
          if (reboundOffset == null) {
            path.lineTo(width, startHeight);
          } else {
            path.quadraticBezierTo(
              width / 2,
              reboundOffset! * 2,
              width,
              startHeight,
            );
          }
        } else {
          path.quadraticBezierTo(
            width / 2,
            -(height - actualTriggerOffset),
            width,
            startHeight,
          );
        }
      } else {
        // Bottom
        final startHeight = math.min(height, actualTriggerOffset);
        path.moveTo(width, startHeight);
        path.lineTo(width, 0);
        path.lineTo(0, 0);
        path.lineTo(0, startHeight);
        if (height <= actualTriggerOffset) {
          if (reboundOffset == null) {
            path.lineTo(width, startHeight);
          } else {
            path.quadraticBezierTo(
              width / 2,
              height - (reboundOffset! * 2),
              width,
              startHeight,
            );
          }
        } else {
          path.quadraticBezierTo(
            width / 2,
            height + (height - actualTriggerOffset),
            width,
            startHeight,
          );
        }
      }
    } else {
      if (reverse) {
        // Left
        final startWidth =
            width > actualTriggerOffset ? width - actualTriggerOffset : 0.0;
        path.moveTo(startWidth, 0);
        path.lineTo(width, 0);
        path.lineTo(width, height);
        path.lineTo(startWidth, height);
        if (width <= actualTriggerOffset) {
          if (reboundOffset == null) {
            path.lineTo(startWidth, 0);
          } else {
            path.quadraticBezierTo(
              reboundOffset! * 2,
              height / 2,
              startWidth,
              0,
            );
          }
        } else {
          path.quadraticBezierTo(
            -(width - actualTriggerOffset),
            height / 2,
            startWidth,
            0,
          );
        }
      } else {
        // Right
        final startWidth = math.min(width, actualTriggerOffset);
        path.moveTo(startWidth, 0);
        path.lineTo(0, 0);
        path.lineTo(0, height);
        path.lineTo(startWidth, height);
        if (width <= actualTriggerOffset) {
          if (reboundOffset == null) {
            path.lineTo(startWidth, 0);
          } else {
            path.quadraticBezierTo(
              width - (reboundOffset! * 2),
              height / 2,
              startWidth,
              0,
            );
          }
        } else {
          path.quadraticBezierTo(
            width + (width - actualTriggerOffset),
            height / 2,
            startWidth,
            0,
          );
        }
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BezierPainter &&
          runtimeType == other.runtimeType &&
          axis == other.axis &&
          reverse == other.reverse &&
          offset == other.offset &&
          actualTriggerOffset == other.actualTriggerOffset &&
          reboundOffset == other.reboundOffset;

  @override
  int get hashCode =>
      axis.hashCode ^
      reverse.hashCode ^
      offset.hashCode ^
      actualTriggerOffset.hashCode ^
      reboundOffset.hashCode;
}
