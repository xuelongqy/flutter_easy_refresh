part of easyrefresh;

/// Spring used by bezier curves.
final SpringDescription _kBezierSpring = SpringDescription.withDampingRatio(
  mass: 0.1,
  stiffness: 100.0,
  ratio: 1.1,
);

/// Bezier curve background.
class BezierBackground extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// Background color.
  final Color? color;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const BezierBackground({
    Key? key,
    required this.state,
    required this.reverse,
    this.color,
  }) : super(key: key);

  @override
  State<BezierBackground> createState() => _BezierBackgroundState();
}

class _BezierBackgroundState extends State<BezierBackground> {
  /// Get background color.
  Color get _color => widget.color ?? Theme.of(context).primaryColor;

  double get _offset => widget.state.offset;

  IndicatorMode get _mode => widget.state.mode;

  Axis get _axis => widget.state.axis;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _offset,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return ClipPath(
            clipper: _BezierPainter(
              axis: _axis,
              reverse: widget.reverse,
              offset: _offset,
              actualTriggerOffset: _actualTriggerOffset,
            ),
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: _color,
            ),
          );
        },
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

  _BezierPainter({
    required this.axis,
    required this.reverse,
    required this.offset,
    required this.actualTriggerOffset,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;
    if (axis == Axis.vertical) {
      if (reverse) {
      } else {
        final startHeight = math.min(height, actualTriggerOffset);
        path.moveTo(width, startHeight);
        path.lineTo(width, 0);
        path.lineTo(0, 0);
        path.lineTo(0, startHeight);
        if (height <= actualTriggerOffset) {
          path.lineTo(width, startHeight);
        } else {
          path.quadraticBezierTo(
            width / 2,
            height + (height - actualTriggerOffset),
            width,
            startHeight,
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
          actualTriggerOffset == other.actualTriggerOffset;

  @override
  int get hashCode =>
      axis.hashCode ^
      reverse.hashCode ^
      offset.hashCode ^
      actualTriggerOffset.hashCode;
}
