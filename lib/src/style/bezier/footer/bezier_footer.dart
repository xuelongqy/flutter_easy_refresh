part of easyrefresh;

/// Bezier footer.
class BezierFooter extends Footer {
  final Key? key;

  BezierFooter({
    this.key,
    double triggerOffset = 100,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.above,
    Duration processedDuration = kDisappearAnimationDuration,
    SpringDescription? spring,
    SpringBuilder readySpringBuilder = kBezierSpringBuilder,
    bool springRebound = false,
    FrictionFactor frictionFactor = kBezierFrictionFactor,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
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
    return _BezierIndicator(
      key: key,
      state: state,
      reverse: !state.reverse,
      processedDuration: processedDuration,
    );
  }
}
