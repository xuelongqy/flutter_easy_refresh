part of easy_refresh_bubbles;

class BubblesHeader extends Header {
  final Key? key;

  const BubblesHeader({
    this.key,
    bool clamping = false,
    double triggerOffset = _kDefaultBubblesTriggerOffset,
    IndicatorPosition position = IndicatorPosition.above,
    Duration processedDuration = _kBubblesProcessed,
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
          triggerWhenRelease: true,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'BubblesHeader does not support horizontal scrolling.');
    return _BubblesIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
