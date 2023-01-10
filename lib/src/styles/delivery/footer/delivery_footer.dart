part of easy_refresh;

/// Delivery footer.
/// https://dribbble.com/shots/2753803-Refresh-your-delivery
class DeliveryFooter extends Footer {
  final Key? key;

  /// Sky color.
  final Color? skyColor;

  const DeliveryFooter({
    this.key,
    double triggerOffset = kDeliveryTriggerOffset,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.above,
    physics.SpringDescription? spring,
    SpringBuilder? readySpringBuilder,
    bool springRebound = false,
    FrictionFactor? frictionFactor,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    this.skyColor,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: const Duration(milliseconds: 100),
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
        'DeliveryFooter does not support horizontal scrolling.');
    return _DeliveryIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      skyColor: skyColor,
    );
  }
}
