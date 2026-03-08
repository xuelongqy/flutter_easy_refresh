part of '../../../easy_refresh.dart';

const _kBallRadius = 16.0;

const _kProgressRadius = _kBallRadius + 4;

const kBezierCircleDisappearDuration = Duration(milliseconds: 800);

/// Bezier indicator.
/// Base widget for [BezierCircleHeader].
class _BezierCircleIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// Foreground color.
  final Color? foregroundColor;

  /// Background color.
  final Color? backgroundColor;

  const _BezierCircleIndicator({
    super.key,
    required this.state,
    this.foregroundColor,
    this.backgroundColor,
  });

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
      return;
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
    }
    if (mode == IndicatorMode.processed) {
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
      return;
    } else {
      if (_processedAnimationController.isAnimating) {
        _processedAnimationController.stop();
      }
    }
  }

  /// Build ball.
  Widget _buildBall(double offset) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        painter: _BallPaint(
          color: _foregroundColor,
          ballCenterY: offset + _kBallRadius,
          reboundOffset: _animationController.isAnimating
              ? _reboundOffsetNotifier.value
              : null,
        ),
      ),
    );
  }

  /// Build ball tail.
  Widget _buildBallTail() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        painter: _BallTailPaint(
          color: _foregroundColor,
          ballCenterY: _animationController.value + _kBallRadius,
          scale: (_actualTriggerOffset - _animationController.value) /
              (_actualTriggerOffset / 2 + _kBallRadius),
          reboundOffset: _reboundOffsetNotifier.value,
        ),
      ),
    );
  }

  /// Build progress
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

  /// Build ball drop
  Widget _buildBallDrop() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        painter: _BallDropPaint(
          color: _foregroundColor,
          ballCenterY: _disappearAnimationController.value + _kBallRadius,
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
              return _buildBallTail();
            },
          ),
        ],
        if (_mode == IndicatorMode.processed) ...[
          AnimatedBuilder(
            animation: _disappearAnimationController,
            builder: (context, _) {
              if (!_disappearAnimationController.isAnimating &&
                  !_processedAnimationController.isAnimating) {
                return const SizedBox();
              }
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
          AnimatedBuilder(
            animation: _disappearAnimationController,
            builder: (context, _) {
              if (!_disappearAnimationController.isAnimating) {
                return const SizedBox();
              }
              return _buildBallDrop();
            },
          ),
        ],
      ],
    );
  }
}

Path _getBezierBackgroundPath(Size size, double reboundOffset) {
  final width = size.width;
  final height = size.height;
  final path = Path();
  path.moveTo(width, height);
  path.lineTo(width, 0);
  path.lineTo(0, 0);
  path.lineTo(0, height);
  path.quadraticBezierTo(
    width / 2,
    (reboundOffset - height) * 2 + height,
    width,
    height,
  );
  return path;
}

class _BallPaint extends CustomPainter {
  final Color color;
  final double ballCenterY;
  final double? reboundOffset;

  _BallPaint({
    required this.color,
    required this.ballCenterY,
    this.reboundOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final width = size.width;
    final height = size.height;
    final path = Path();
    path.addOval(Rect.fromCircle(
        center: Offset(width / 2, ballCenterY), radius: _kBallRadius));
    final bgPath = _getBezierBackgroundPath(size, reboundOffset ?? height);
    canvas.drawPath(Path.combine(PathOperation.intersect, path, bgPath), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BallPaint &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          ballCenterY == other.ballCenterY &&
          reboundOffset == other.reboundOffset;

  @override
  int get hashCode =>
      color.hashCode ^ ballCenterY.hashCode ^ reboundOffset.hashCode;
}

class _BallTailPaint extends CustomPainter {
  final Color color;
  final double ballCenterY;
  final double scale;
  final double reboundOffset;

  _BallTailPaint({
    required this.color,
    required this.ballCenterY,
    required this.scale,
    required this.reboundOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (reboundOffset - ballCenterY < _kBallRadius) {
      return;
    }
    final paint = Paint()..color = color;
    final width = size.width;
    final bottom = reboundOffset;
    final startY = ballCenterY + _kBallRadius * scale / 2;
    final startX = width / 2 +
        math.sqrt(_kBallRadius * _kBallRadius * (1 - scale * scale / 4));
    final bezier1x = (width / 2 + (_kBallRadius * 3 / 4) * (1 - scale));
    final bezier2x = bezier1x + _kBallRadius;
    final path = Path();
    path.moveTo(startX, startY);
    path.quadraticBezierTo(bezier1x, bottom, bezier2x, bottom);
    path.lineTo(width - bezier2x, bottom);
    path.quadraticBezierTo(width - bezier1x, bottom, width - startX, startY);
    final bgPath = _getBezierBackgroundPath(size, reboundOffset);
    canvas.drawPath(Path.combine(PathOperation.intersect, path, bgPath), paint);
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
          ballCenterY == other.ballCenterY &&
          scale == other.scale &&
          reboundOffset == other.reboundOffset;

  @override
  int get hashCode =>
      color.hashCode ^
      ballCenterY.hashCode ^
      scale.hashCode ^
      reboundOffset.hashCode;
}

class _BallDropPaint extends CustomPainter {
  final Color color;
  final double ballCenterY;

  _BallDropPaint({
    required this.color,
    required this.ballCenterY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final height = size.height;
    final width = size.width;
    Path path = Path();
    final rectPath = Path();
    rectPath.addRect(Rect.fromPoints(
      const Offset(0, 0),
      Offset(width, height),
    ));
    if (ballCenterY > height) {
      final bezierHeight = _kBallRadius *
          ((height + 2 * _kBallRadius - ballCenterY) / (3 * _kBallRadius));
      final bezierWidth = _kBallRadius * _kBallRadius * 2 / bezierHeight;
      path.moveTo((width - bezierWidth) / 2, height);
      path.quadraticBezierTo(width / 2, height - bezierHeight * 2,
          (width + bezierWidth) / 2, height);
      path.close();
      canvas.drawPath(
          Path.combine(PathOperation.intersect, path, rectPath), paint);
    } else if (ballCenterY > height - _kBallRadius * 2) {
      final scale = 1 - ((ballCenterY - _kBallRadius) / height);
      final bottom = height;
      final startY = ballCenterY + _kBallRadius * scale / 2;
      final startX = width / 2 +
          math.sqrt(_kBallRadius * _kBallRadius * (1 - scale * scale / 4));
      final bezier1x = (width / 2 + (_kBallRadius * 3 / 4) * (1 - scale));
      final bezier2x = bezier1x + _kBallRadius;
      path.moveTo(startX, startY);
      path.quadraticBezierTo(bezier1x, bottom, bezier2x, bottom);
      path.lineTo(width - bezier2x, bottom);
      path.quadraticBezierTo(width - bezier1x, bottom, width - startX, startY);
      canvas.drawPath(
          Path.combine(PathOperation.intersect, path, rectPath), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate == this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BallDropPaint &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          ballCenterY == other.ballCenterY;

  @override
  int get hashCode => color.hashCode ^ ballCenterY.hashCode;
}
