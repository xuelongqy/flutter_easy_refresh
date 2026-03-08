part of easy_refresh_squats;

class SquatsHeader extends Header {
  final Key? key;

  /// Background color.
  final Color? backgroundColor;

  const SquatsHeader({
    this.key,
    bool clamping = false,
    double triggerOffset = _kDefaultSquatsTriggerOffset,
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
    this.backgroundColor,
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
        'SquatsHeader does not support horizontal scrolling.');
    return _SquatsIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      backgroundColor: backgroundColor,
    );
  }
}
