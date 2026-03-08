part of '../../../../easy_refresh.dart';

/// Delivery footer.
/// https://dribbble.com/shots/2753803-Refresh-your-delivery
class DeliveryFooter extends Footer {
  final Key? key;

  /// Sky color.
  final Color? skyColor;

  const DeliveryFooter({
    this.key,
    super.triggerOffset = kDeliveryTriggerOffset,
    super.clamping = false,
    super.position,
    super.spring,
    super.readySpringBuilder,
    super.springRebound = false,
    super.frictionFactor,
    super.infiniteOffset = null,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    this.skyColor,
  }) : super(
          processedDuration: const Duration(milliseconds: 100),
          safeArea: false,
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
