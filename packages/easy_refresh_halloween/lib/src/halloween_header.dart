part of easy_refresh_halloween;

class HalloweenHeader extends Header {
  final Key? key;

  const HalloweenHeader({
    this.key,
    bool clamping = false,
    double triggerOffset = _kDefaultHalloweenTriggerOffset,
    IndicatorPosition position = IndicatorPosition.above,
    Duration processedDuration = Duration.zero,
    physics.SpringDescription? spring,
    SpringBuilder? readySpringBuilder,
    bool springRebound = false,
    FrictionFactor? frictionFactor,
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
          safeArea: false,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          position: position,
          hapticFeedback: hapticFeedback,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'HalloweenHeader does not support horizontal scrolling.');
    return _HalloweenIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
