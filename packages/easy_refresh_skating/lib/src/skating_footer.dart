part of easy_refresh_skating;

class SkatingFooter extends Footer {
  final Key? key;

  const SkatingFooter({
    this.key,
    bool clamping = false,
    double triggerOffset = _kDefaultSkatingTriggerOffset,
    IndicatorPosition position = IndicatorPosition.above,
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
          processedDuration: _kSkatingProcessed,
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
        'SkatingFooter does not support horizontal scrolling.');
    return _SkatingIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
