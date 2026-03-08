part of '../../../easy_refresh.dart';

/// Taurus indicator disappear animation duration.
const kTaurusDisappearDuration = Duration(milliseconds: 250);

/// Taurus indicator.
/// Base widget for [TaurusHeader] and [TaurusFooter].
/// Paths from [https://github.com/scwang90/SmartRefreshLayout/blob/main/refresh-header/src/main/java/com/scwang/smart/refresh/header/TaurusHeader.java].
/// SmartRefreshLayout LICENSE [https://github.com/scwang90/SmartRefreshLayout/blob/main/LICENSE].
class _TaurusIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  /// Sky color.
  final Color? skyColor;

  const _TaurusIndicator({
    super.key,
    required this.state,
    required this.reverse,
    this.skyColor,
  });

  @override
  State<_TaurusIndicator> createState() => _TaurusIndicatorState();
}

class _TaurusIndicatorState extends State<_TaurusIndicator>
    with TickerProviderStateMixin {
  static const _maxWidth = 420.0;
  static const _animationDuration = Duration(milliseconds: 1000);

  static const _airplanePaths = [
    'm23 81c0 0 0 -1 0 -1 0 -0.5 0 -1 1.5 -1 2 -1 2.6 -2 2 -2.5 -0.5 -1 -2 -1 -11.6 -2.5 -5 -1 -10 -1 -11 -1.5l-1 0 1 -1c1 -1 1 -1 2 -1 0.6 0 6 0 13 1 6 0 12 1 12.6 0.6l1 0 -1 -2C30 67 16 42 15 40.6l-0.5 -1 4 -1c2 -0.6 4 -1 4 -1 0 0 6 4 13 8.5 14.6 10 17 11 20 12 4.6 2 6 1.6 13 -0.6 13 -5 25 -9 26 -9 0.6 0 3.6 1 -24 -14L51 23 47 16 43 10 43.6 9c1 -1 1 -1 1 -0.5 0 0 4 3 7.5 6 4 3 7 6 7.5 6 0 0 13.6 3 29.5 6 16 3 32 6 35 7l6 1 3 -1c41.6 -14.6 68 -23 85 -28 15 -4 24 -5 32 -2.5 7 2 10 5 8 8 -1.6 2.5 -4.6 4.6 -10.6 7.5 -6 3 -10 4 -25 9 -8 2.6 -16.6 6 -39 14 -67 25 -88 31 -121.6 36 -14.5 2 -24 3 -34 3 -5 0 -5.5 0 -6 -0.5z',
  ];
  static const _airplaneWidth = 65.0;
  static const _airplaneHeight = 20.0;

  static const _cloudPaths = [
    "M552 1A65 65 0 0 0 504 22A51 51 0 0 0 492 20A51 51 0 0 0 442 71A51 51 0 0 0 492 121A51 51 0 0 0 511 118A65 65 0 0 0 517 122L586 122A65 65 0 0 0 600 111A60 60 0 0 0 608 122L696 122A60 60 0 0 0 712 82A60 60 0 0 0 652 22A60 60 0 0 0 611 39A65 65 0 0 0 552 1zM246 2A55 55 0 0 0 195 37A47 47 0 0 0 168 28A47 47 0 0 0 121 75A47 47 0 0 0 168 121A47 47 0 0 0 209 97A55 55 0 0 0 246 111A55 55 0 0 0 269 107A39 39 0 0 0 281 122L328 122A39 39 0 0 0 343 91A39 39 0 0 0 304 52A39 39 0 0 0 301 52A55 55 0 0 0 246 2z",
    "m507 31a53 53 0 0 0 -53 53 53 53 0 0 0 16 38h75a53 53 0 0 0 2 -2 28 28 0 0 0 1 2h213a97 97 0 0 0 -87 -54.8 97 97 0 0 0 -73 34 28 28 0 0 0 -27 -19 28 28 0 0 0 -13 3 53 53 0 0 0 0 -1 53 53 0 0 0 -53 -53zM206 32a54 54 0 0 0 -50 34 74.9 74.9 0 0 0 -47 -17 74.9 74.9 0 0 0 -74 61 31 31 0 0 0 -10 -2 31 31 0 0 0 -26 14L301 122a38 38 0 0 0 0 -4 38 38 0 0 0 -38 -38 38 38 0 0 0 -4 0 54 54 0 0 0 -54 -49z",
    "m424 37a53 53 0 0 0 -41 19 53 53 0 0 0 -1 2 63 63 0 0 0 -5 0 63 63 0 0 0 -61 50 63 63 0 0 0 -1 4 16 16 0 0 0 -10 -4 16 16 0 0 0 -8 2 21 21 0 0 0 -18 -11 21 21 0 0 0 -19 13 22 22 0 0 0 -7 -1 22 22 0 0 0 -19 11L523 122a44 44 0 0 0 -43 -37 44 44 0 0 0 -3 0 53 53 0 0 0 -53 -48zM129 38a50 50 0 0 0 -50 50 50 50 0 0 0 2 15 15 16 0 0 0 -6 2 15 16 0 0 0 -1 1 17 16 0 0 0 -12 -5 17 16 0 0 0 -16 14 20 16 0 0 0 -15 7L224 122a43 43 0 0 0 1 -10 43 43 0 0 0 -43 -43 43 43 0 0 0 -7 1 50 50 0 0 0 -47 -32zM632 83a64 64 0 0 0 -45 18 27 27 0 0 0 -11 -2 27 27 0 0 0 -23 13 17 17 0 0 0 -7 -1 17 17 0 0 0 -16 12h160a64 64 0 0 0 -59 -39z",
  ];
  static const _cloudColors = [
    Color(0xaac7dcf1),
    Color(0xdde8f3fd),
    Color(0xfffdfdfd),
  ];
  static const _cloudWidth = 762.0;
  static const _cloudHeight = 122.0;

  /// Animation controller.
  late AnimationController _animationController;
  int _animationSign = 1;
  late AnimationController _disappearAnimationController;

  /// Wind parameters.
  static const _minWindWidth = 30.0;
  final _windOffsets = <Offset>[];
  double _windWidth = 0;
  double get _windViewHeight => _actualTriggerOffset * 3;

  Color get _skyColor => widget.skyColor ?? Colors.blue;

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_mode == IndicatorMode.processing) {
          _updateWind();
          _animationSign = -_animationSign;
          _animationController.forward(from: 0);
        } else {
          _animationController.stop();
        }
      }
    });
    _disappearAnimationController =
        AnimationController(vsync: this, duration: kTaurusDisappearDuration);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _animationController.dispose();
    _disappearAnimationController.dispose();
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.processing) {
      if (!_animationController.isAnimating) {
        _updateWind();
        _animationSign = 1;
        _animationController.forward(from: 0);
      }
    } else if (mode == IndicatorMode.processed) {
      if (!_disappearAnimationController.isAnimating) {
        _disappearAnimationController.forward(from: 0);
      }
    } else {
      if (_disappearAnimationController.isAnimating) {
        _disappearAnimationController.stop();
      }
    }
  }

  /// Update wind parameters.
  void _updateWind() {
    final random = math.Random();
    _windWidth = _minWindWidth + random.nextDouble() * 30;
    _windOffsets.clear();
    final _windSegment = _windViewHeight / 10;
    for (int i = 0; i < 10; i++) {
      final dx = random.nextDouble() * 40;
      final dy = _windSegment * i + random.nextDouble() * _windSegment;
      _windOffsets.add(Offset(dx, dy));
    }
  }

  Widget _buildWind(double width) {
    final windViewWidth = width * 3;
    final windOffset = _animationController.value * windViewWidth;
    return Positioned(
      top: widget.reverse ? null : 0,
      bottom: widget.reverse ? 0 : null,
      left: width - windOffset,
      height: _windViewHeight,
      child: CustomPaint(
        painter: _WindPainter(
          offsets: _windOffsets,
          width: _windWidth,
        ),
        size: Size(100, _windViewHeight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, _maxWidth);
        final cloudWidth = width * 0.6;
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _skyColor,
          ),
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: width,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                // Animation
                double animationScale = 0;
                if (_mode == IndicatorMode.processing) {
                  final value = _animationController.value;
                  if (value <= 0.5) {
                    animationScale = value / 0.5 * _animationSign;
                  } else {
                    animationScale = (1 - value) / 0.5 * _animationSign;
                  }
                }
                // Cloud
                double sideCloudWidth = cloudWidth;
                double sideCloudBottom = _actualTriggerOffset / 3;
                double centerCloudWidth = width * 0.6;
                double? centerCloudBottom = _actualTriggerOffset / 8;
                double? centerCloudTop;
                if (_offset < _actualTriggerOffset / 2) {
                  sideCloudWidth = cloudWidth * 0.7;
                  centerCloudWidth = centerCloudWidth * 0.8;
                  if (!widget.reverse) {
                    final centerCloudHeight =
                        centerCloudWidth / _cloudWidth * _cloudHeight;
                    if (_offset < centerCloudHeight - centerCloudBottom) {
                      centerCloudBottom = null;
                      centerCloudTop = 0;
                    }
                  }
                } else if (_offset < _actualTriggerOffset / 3 * 2) {
                  final scale = (_actualTriggerOffset / 3 * 2 - _offset) /
                      (_actualTriggerOffset / 3 * 2 - _actualTriggerOffset / 2);
                  sideCloudWidth = sideCloudWidth * 0.7;
                  sideCloudBottom = sideCloudBottom * scale;
                  centerCloudWidth = centerCloudWidth * 0.8;
                  centerCloudBottom = centerCloudBottom * scale;
                } else if (_offset < _actualTriggerOffset) {
                  final scale = 1 -
                      (_actualTriggerOffset - _offset) /
                          (_actualTriggerOffset / 3);
                  sideCloudWidth = sideCloudWidth * (0.7 + 0.3 * scale);
                  sideCloudBottom = 0;
                  centerCloudWidth = centerCloudWidth * (0.8 + 0.2 * scale);
                  centerCloudBottom = 0;
                } else {
                  sideCloudBottom = 0;
                  centerCloudWidth += ((_offset - _actualTriggerOffset) / 2);
                  centerCloudBottom = 0;
                }
                final sideCloudOffset =
                    sideCloudWidth - (sideCloudWidth / 4 + width / 6);
                // Airplane
                double airplaneTop;
                double airplaneLeft;
                double airplaneAngle = 0;
                if (_offset < _actualTriggerOffset) {
                  double scale = _offset / _actualTriggerOffset;
                  airplaneTop = _actualTriggerOffset -
                      (_actualTriggerOffset + _airplaneHeight) / 2 * scale;
                  airplaneLeft = (width - _airplaneWidth) / 2 * scale;
                } else {
                  airplaneTop = (_actualTriggerOffset - _airplaneHeight) / 2;
                  airplaneLeft = (width - _airplaneWidth) / 2;
                  airplaneAngle =
                      math.pi / 9 * ((_offset - _actualTriggerOffset) / 200);
                  airplaneAngle = math.min(airplaneAngle, math.pi / 9);
                }
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: _offset,
                    ),
                    // Left cloud
                    Positioned(
                      bottom: -sideCloudBottom,
                      left: -sideCloudOffset - (animationScale * 2.0),
                      child: Opacity(
                        opacity: 0.3,
                        child: PathsPaint(
                          paths: _cloudPaths,
                          colors: _cloudColors,
                          width: sideCloudWidth,
                        ),
                      ),
                    ),
                    // Right cloud
                    Positioned(
                      bottom: -sideCloudBottom,
                      right: -sideCloudOffset - (animationScale * 2.0),
                      child: Opacity(
                        opacity: 0.3,
                        child: PathsPaint(
                          paths: _cloudPaths,
                          colors: _cloudColors,
                          width: sideCloudWidth,
                        ),
                      ),
                    ),
                    // Wind
                    _buildWind(width),
                    // Airplane
                    AnimatedBuilder(
                      animation: _disappearAnimationController,
                      builder: (context, _) {
                        if (_mode == IndicatorMode.processed ||
                            _mode == IndicatorMode.done) {
                          final value = _disappearAnimationController.value;
                          airplaneTop =
                              (_actualTriggerOffset + _airplaneHeight * 2) /
                                      2 *
                                      (1 - value) -
                                  _airplaneHeight / 2 * 3;
                          airplaneLeft = (width - _airplaneWidth) / 2 +
                              (width / 2 + _airplaneWidth * 3) * value;
                        }
                        return Positioned(
                          top: airplaneTop - (animationScale * 4.0),
                          left: airplaneLeft,
                          child: Transform.rotate(
                            angle: airplaneAngle,
                            child: const PathsPaint(
                              paths: _airplanePaths,
                              colors: [Colors.white],
                              width: _airplaneWidth,
                              height: _airplaneHeight,
                            ),
                          ),
                        );
                      },
                    ),
                    // Center cloud
                    Positioned(
                      top: centerCloudTop,
                      bottom:
                          centerCloudBottom == null ? null : -centerCloudBottom,
                      child: PathsPaint(
                        paths: _cloudPaths,
                        colors: _cloudColors,
                        width: centerCloudWidth - (animationScale * 4.0),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _WindPainter extends CustomPainter {
  static const windHeight = 3.0;

  final double width;
  final List<Offset> offsets;

  _WindPainter({
    required this.width,
    required this.offsets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x50ffffff);
    final path = Path();
    for (final offset in offsets) {
      path.addRect(Rect.fromPoints(
          offset, Offset(offset.dx + width, offset.dy + windHeight)));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WindPainter &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          offsets == other.offsets;

  @override
  int get hashCode => width.hashCode ^ offsets.hashCode;
}
