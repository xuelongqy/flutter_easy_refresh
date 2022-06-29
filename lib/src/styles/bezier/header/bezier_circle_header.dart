part of easyrefresh;

/// Bezier circle footer.
class BezierCircleHeader extends Header {
  final Key? key;

  /// Foreground color.
  final Color? foregroundColor;

  /// Background color.
  final Color? backgroundColor;

  BezierCircleHeader({
    this.key,
    double triggerOffset = 100,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.above,
    SpringDescription? spring,
    SpringBuilder readySpringBuilder = kBezierSpringBuilder,
    bool springRebound = false,
    FrictionFactor frictionFactor = kBezierFrictionFactor,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    this.foregroundColor,
    this.backgroundColor,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: kBezierCircleDisappearDuration,
          spring: spring,
          readySpringBuilder: readySpringBuilder,
          springRebound: springRebound,
          frictionFactor: frictionFactor,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          position: position,
          hapticFeedback: hapticFeedback,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'BezierCircleHeader does not support horizontal scrolling.');
    assert(!state.reverse, 'BezierCircleHeader does not support reverse.');
    return _BezierCircleIndicator(
      key: key,
      state: state,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }
}
