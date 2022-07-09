part of easy_refresh;

class DeliveryHeader extends Header {
  final Key? key;

  /// Sky color.
  final Color? skyColor;

  DeliveryHeader({
    this.key,
    double triggerOffset = kDeliveryTriggerOffset,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.above,
    SpringDescription? spring,
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
        'DeliveryHeader does not support horizontal scrolling.');
    return _DeliveryIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      skyColor: skyColor,
    );
  }
}
