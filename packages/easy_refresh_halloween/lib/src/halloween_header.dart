part of '../easy_refresh_halloween.dart';

class HalloweenHeader extends Header {
  final Key? key;

  const HalloweenHeader({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultHalloweenTriggerOffset,
    super.position,
    super.processedDuration = Duration.zero,
    super.spring,
    super.readySpringBuilder,
    super.springRebound = false,
    super.frictionFactor,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
  }) : super(
          safeArea: false,
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
