part of easyrefresh;

const _kBallRadius = 16.0;

const _kProgressRadius = _kBallRadius + 4;

const kBezierCircleDisappearDuration = Duration(milliseconds: 800);

/// Bezier indicator.
/// Base widget for [BezierCircleHeader] and [BezierCircleFooter].
class _BezierCircleIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// Foreground color.
  final Color? foregroundColor;

  /// Background color.
  final Color? backgroundColor;

  const _BezierCircleIndicator({
    Key? key,
    required this.state,
    this.foregroundColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<_BezierCircleIndicator> createState() => _BezierCircleIndicatorState();
}

class _BezierCircleIndicatorState extends State<_BezierCircleIndicator>
    with TickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 300);
  static const _processedAnimationDuration = Duration(milliseconds: 500);

  late AnimationController _animationController;
  late AnimationController _processedAnimationController;
  late AnimationController _disappearAnimationController;

  final _reboundOffsetNotifier = ValueNotifier(0.0);

  Color get _foregroundColor => widget.foregroundColor ?? Colors.white;

  IndicatorMode get _mode => widget.state.mode;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _animationController = AnimationController.unbounded(
        vsync: this, duration: _animationDuration);
    _processedAnimationController =
        AnimationController(vsync: this, duration: _processedAnimationDuration);
    _disappearAnimationController = AnimationController.unbounded(
        vsync: this,
        duration: kBezierCircleDisappearDuration - _processedAnimationDuration);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _animationController.dispose();
    _processedAnimationController.dispose();
    _disappearAnimationController.dispose();
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.processing) {
      // Start animation.
      if (!_animationController.isAnimating) {
        _animationController.value = _kBallRadius * 2 + offset;
        _animationController.animateTo(_actualTriggerOffset / 2 - _kBallRadius);
      }
    } else if (mode == IndicatorMode.processed) {
      // Processed animation.
      if (!_processedAnimationController.isAnimating) {
        _processedAnimationController.forward(from: 0).then((_) {
          // Disappear animation.
          _disappearAnimationController.value =
              _actualTriggerOffset / 2 - _kBallRadius;
          _disappearAnimationController
              .animateTo(_kBallRadius * 2 + _actualTriggerOffset);
        });
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      if (_processedAnimationController.isAnimating) {
        _processedAnimationController.stop();
      }
    }
  }

  /// Build ball.
  Widget _buildBall(double offset) {
    return Positioned(
      top: offset,
      child: Container(
        height: _kBallRadius * 2,
        width: _kBallRadius * 2,
        decoration: BoxDecoration(
          color: _foregroundColor,
          borderRadius: BorderRadius.circular(_kBallRadius),
        ),
      ),
    );
  }

  /// Build
  Widget _buildProgress(double radius, double? value, double opacity) {
    return Positioned(
      top: _actualTriggerOffset / 2 - radius,
      child: SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: Opacity(
          opacity: opacity,
          child: CircularProgressIndicator(
            color: _foregroundColor,
            strokeWidth: 2,
            value: value,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BezierBackground(
          state: widget.state,
          reverse: false,
          useAnimation: true,
          color: widget.backgroundColor,
          onReboundOffsetChanged: (value) {
            _reboundOffsetNotifier.value = value;
          },
        ),
        // Ball
        if (_mode == IndicatorMode.processing) ...[
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return _buildBall(_animationController.value);
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return _animationController.isAnimating
                  ? const SizedBox()
                  : _buildProgress(_kProgressRadius, null, 1);
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              final value = _animationController.value;
              if (!_animationController.isAnimating || value < _kBallRadius) {
                return const SizedBox();
              }
              return Positioned(
                top: _animationController.value - _kBallRadius,
                child: CustomPaint(
                  painter: _BallTailPaint(
                    color: _foregroundColor,
                    bollOffset: _animationController.value - _kBallRadius,
                    scale: (_actualTriggerOffset - _animationController.value) /
                        (_actualTriggerOffset / 2 + _kBallRadius),
                    reboundOffset: _reboundOffsetNotifier.value,
                  ),
                ),
              );
            },
          ),
        ],
        if (_mode == IndicatorMode.processed) ...[
          AnimatedBuilder(
            animation: _disappearAnimationController,
            builder: (context, _) {
              return _buildBall(_disappearAnimationController.isAnimating
                  ? _disappearAnimationController.value
                  : _actualTriggerOffset / 2 - _kBallRadius);
            },
          ),
          AnimatedBuilder(
            animation: _processedAnimationController,
            builder: (context, _) {
              final value = _processedAnimationController.value;
              return _processedAnimationController.isAnimating
                  ? _buildProgress(_kProgressRadius + value * 4, 1, 1 - value)
                  : const SizedBox();
            },
          ),
        ],
      ],
    );
  }
}

class _BallTailPaint extends CustomPainter {
  final Color color;
  final double bollOffset;
  final double scale;
  final double reboundOffset;

  _BallTailPaint({
    required this.color,
    required this.bollOffset,
    required this.scale,
    required this.reboundOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final width = size.width;
    final bottom = reboundOffset - bollOffset;
    final startY = bollOffset + _kBallRadius * scale / 2;
    final startX = width / 2 +
        math.sqrt(_kBallRadius * _kBallRadius * (1 - scale * scale / 4));
    final bezier1x = (width / 2 + (_kBallRadius * 3 / 4) * (1 - scale));
    final bezier2x = bezier1x + _kBallRadius;
    final path = Path();
    path.reset();
    path.moveTo(startX, startY);
    path.quadraticBezierTo(bezier1x, bottom, bezier2x, bottom);
    path.lineTo(width - bezier2x, bottom);
    path.quadraticBezierTo(width - bezier1x, bottom, width - startX, startY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BallTailPaint &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          bollOffset == other.bollOffset &&
          scale == other.scale &&
          reboundOffset == other.reboundOffset;

  @override
  int get hashCode =>
      color.hashCode ^
      bollOffset.hashCode ^
      scale.hashCode ^
      reboundOffset.hashCode;
}
