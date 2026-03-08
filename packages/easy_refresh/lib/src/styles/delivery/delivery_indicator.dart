part of '../../../easy_refresh.dart';

/// Delivery indicator disappear animation duration.
const kDeliveryDisappearDuration = Duration(milliseconds: 500);

/// Delivery indicator trigger offset.
const kDeliveryTriggerOffset = 150.0;

/// Taurus indicator.
/// Base widget for [DeliveryHeader] and [DeliveryFooter].
/// Paths from [https://github.com/scwang90/SmartRefreshLayout/blob/main/refresh-header/src/main/java/com/scwang/smart/refresh/header/DeliveryHeader.java].
/// SmartRefreshLayout LICENSE [https://github.com/scwang90/SmartRefreshLayout/blob/main/LICENSE].
class _DeliveryIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  /// Sky color.
  final Color? skyColor;

  const _DeliveryIndicator({
    super.key,
    required this.state,
    required this.reverse,
    this.skyColor,
  });

  @override
  State<_DeliveryIndicator> createState() => _DeliveryIndicatorState();
}

class _DeliveryIndicatorState extends State<_DeliveryIndicator>
    with TickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 1600);
  static const _mergeDuration = Duration(milliseconds: 200);

  static const _balloonPaths = [
    "m114,329 5,2 16,28h-1zM2,144.5c-4,-77 50,-122 96,-135 6,0 7.1,.2 13,3.5v4.5C63,55.1 56,97.1 43,154.5 37.6,195 16,191 2,144.5Z",
    "m134,359 -1,-27h2.6l-1,26zm-24,-34.6c0,-1 -2,-3.6 -4.5,-6C88,300 7,218.5 2,144.5c18,43.6 33,45 41,10 0,-71 34,-125.5 68,-137 2,3 4,4.5 8,7.5C97,91 96.5,109.4 95.5,175.4 86.5,205 58,208.5 43,154.5c14,64 32,101.6 60.6,147 6,8 15.4,18.5 15.4,29.5 -3.8,-1.3 -8.27988,-2.8 -9,-6.6zM98.5,9.5c4.6,-1.5 18,-4.6 34,-5 1,1 1,2 1,3 -9,1 -16,3 -22,6 -2.5,-1 -8,-3 -13,-4z",
    "m119,331c-1,-7.6 -4,-12 -6.5,-16 -37,-55 -64,-98.9 -69.5,-160.5 20,46 41.5,48.5 52.5,20.9C93.5,122.9 87,84 119,25l31,-.1c40,60.5 25.2,136.5 22.2,150.1 -14,53 -66.7,33.4 -76.7,.4 11.5,50.5 19.7,89.1 29.7,136.1 4,10 4.2,10.1 5,21.5 -3,0 -8,-1 -11,-2z",
    "m172,174.5c5,-51.6 -2,-106 -22,-149.6 2.5,-3 3,-4 6.6,-6 48,22.5 77.5,63 69,140 -24.8,55.8 -48.1,39.2703 -53.6,15.6zM154.6,14C148,11 142.4,9 133,7c0,-1 -.5,-1.5 -.5,-2.5 16,0 31.5,3.5 40.9,6.5C167.9,11 158.6,12 154.6,14Z",
    "m134,359 15,-28 2,-1 -16,29zm7,-26c0,-12 2,-14.4 4,-21.9 12,-47 16,-77.5 27,-137 12,38.5 37.1,22.9 53.6,-15.2 -4,54 -44.6,120.2 -69.6,154.2 -6,9.5 -7.4,16.9 -5,16.9 -2.4,1.4 -6.5,2.4 -10,3z",
    "m225.6,159c1.6,-52 -22,-117 -69,-140 -1.5,-2 -1.6,-2 -2,-5 4,-3 9,-5 15,-4 48.6,10 103,67 96.6,132 -10,46 -35.5,52 -40.6,17z",
    "m156,313.1c33,-59 54.6,-86.2 69.6,-154.2 12,38 28.9,22.1 40.5,-16.9 -2,50.6 -43,113 -99.6,171 -4.6,5 -8,9 -8,10 0,2 -3.5,5 -7,7 -4.6,1 1.5,-13.9 4.5,-16.9z",
    "m130,333c-.5,-11.5 -1.4,-12 -5,-22 -11,-30 -23.5,-89.1 -29.5,-135.6 16.5,39 59.5,33.1 76.5,-.9 -6,59 -11,88.5 -27,139 -2,7 -3,11.6 -4,19.5 -3,.5 -6.5,.5 -11,0zM119,25c-3.5,-1 -7,-3.5 -8,-7.5V13c2.5,-4.5 14.5,-6 22,-6 5,0 15,1 21,6 2,1.6 3.2,3.9 2.6,5.9 -1,3 -4,5 -6.6,6 -14.8,4.2 -31.0,.1 -31,.1z",
  ];
  static const _balloonColors = [
    Color(0xff92dfeb),
    Color(0xff6dd0e9),
    Color(0xff4fc3e7),
    Color(0xff2fb6e6),
    Color(0xff25a9de),
    Color(0xff11abe4),
    Color(0xff0e9bd8),
    Color(0xff40b7e1),
  ];
  static const _balloonWidth = 200.0;

  static const _cloudPaths = [
    "M63,0A22.6,22 0,0 0,42 14,17 17,0 0,0 30.9,10 17,17 0,0 0,13.7 26,9 9,0 0,0 9,24 9,9 0,0 0,0 32h99a8,8 0,0 0,0 -.6,8 8,0 0,0 -8,-8 8,8 0,0 0,-6 2.6,22.6 22,0 0,0 0,-3.6A22.6,22 0,0 0,63 0Z"
  ];
  static const _cloudColors = [
    Color(0xffffffff),
  ];

  static const _boxPaths = [
    "M0,17.5 L3,30 2.9,76 47.5,93 92.8,76V30L95,18 47,.5Z",
    "M3,30 L48,46 47.5,93 2.9,76ZM0,17.5 L48,35 48,46 0,29Z",
    "m56.5,18c0,2 -3.8,3.8 -8.5,3.8 -4.7,0 -8.5,-1.7 -8.5,-3.8 0,-2 3.8,-3.8 8.5,-3.8 4.7,0 8.5,1.7 8.5,3.8zM3,30 L3,34.7l44.7,17 0,-5z",
    "M48,35 L47.5,93 92.8,76V30l2,-.8 0,-10.9z",
    "M82.6,80 L92.8,62 92.8,76ZM47.6,80 L60,88 47.5,93ZM48,46 L92.8,30 92.8,34 48,51.6Z"
  ];
  static const _boxColors = [
    Color(0xfff8b147),
    Color(0xfff2973c),
    Color(0xffed8030),
    Color(0xfffec051),
    Color(0xfff7ad49),
  ];
  static const _boxWidth = 50.0;

  /// Animation controller.
  late AnimationController _animationController;
  double _lastAnimationValue = 0;

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  /// Clouds.
  late final List<double> _cloudsSize;
  late final List<double> _cloudsX;
  late final List<double> _cloudsY;
  late final List<double> _cloudsS;

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    _animationController.addListener(() {
      _updateClouds();
      _lastAnimationValue = _animationController.value;
    });
    _cloudsSize = [64, 72, 54];
    _cloudsX = List.filled(3, 0.0);
    _cloudsY = [
      _actualTriggerOffset / 3 - 20,
      _actualTriggerOffset / 3 * 2 - 15,
      _actualTriggerOffset - 30,
    ];
    _cloudsS = [600, 1600, 900];
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _animationController.dispose();
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.ready ||
        mode == IndicatorMode.processing ||
        mode == IndicatorMode.processed ||
        mode == IndicatorMode.done) {
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
      return;
    } else {
      if (_animationController.isAnimating) {
        _lastAnimationValue = 0;
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  /// Update cloud parameters.
  void _updateClouds() {
    double value = _animationController.value - _lastAnimationValue;
    if (value < 0) {
      value = 1 - _lastAnimationValue + _animationController.value;
    }
    for (int i = 0; i < _cloudsSize.length; i++) {
      _cloudsX[i] += _cloudsS[i] * value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            // Sky
            Container(
              width: double.infinity,
              height: _offset,
              color: widget.skyColor,
            ),
            // Cloud
            for (int i = 0; i < _cloudsSize.length; i++)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, widget) {
                  final size = _cloudsSize[i];
                  return Positioned(
                    left: _cloudsX[i] % (size * 2 + width) - size,
                    top: _cloudsY[i],
                    child: AnimatedOpacity(
                      opacity: _animationController.isAnimating &&
                              _mode != IndicatorMode.done
                          ? 1
                          : 0,
                      child: widget!,
                      duration: kDeliveryDisappearDuration,
                    ),
                  );
                },
                child: PathsPaint(
                  paths: _cloudPaths,
                  colors: _cloudColors,
                  width: _cloudsSize[i],
                ),
              ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                double boxBottom = 20;
                double balloonTop = -100;
                if (_mode == IndicatorMode.ready ||
                    _mode == IndicatorMode.processing ||
                    _mode == IndicatorMode.processed ||
                    _mode == IndicatorMode.done) {
                  boxBottom = 30;
                  balloonTop = 70;
                }
                double angleSin =
                    math.sin(_animationController.value * math.pi * 2);
                double offsetSin =
                    math.sin(_animationController.value * math.pi * 4);
                return AnimatedPositioned(
                  duration: _mode == IndicatorMode.processed ||
                          _mode == IndicatorMode.done
                      ? kDeliveryDisappearDuration
                      : Duration.zero,
                  bottom: _mode == IndicatorMode.processed ||
                          _mode == IndicatorMode.done
                      ? _balloonWidth * 2
                      : offsetSin * 16,
                  left: (width - _balloonWidth) / 2,
                  width: _balloonWidth,
                  height: _balloonWidth * 2,
                  child: Transform.rotate(
                    angle: math.pi / 45 * angleSin,
                    origin: const Offset(0, -200),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Box
                        AnimatedPositioned(
                          bottom: boxBottom,
                          duration: _mergeDuration,
                          child: const PathsPaint(
                            paths: _boxPaths,
                            colors: _boxColors,
                            width: _boxWidth,
                          ),
                        ),
                        // Balloon
                        AnimatedPositioned(
                          top: balloonTop,
                          left: 2,
                          duration: _mergeDuration,
                          child: Opacity(
                            opacity: balloonTop < 0 ? 0 : 1,
                            child: const PathsPaint(
                              paths: _balloonPaths,
                              colors: _balloonColors,
                              width: _balloonWidth,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
