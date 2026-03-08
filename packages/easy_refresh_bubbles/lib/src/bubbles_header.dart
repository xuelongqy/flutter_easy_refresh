part of '../easy_refresh_bubbles.dart';

class BubblesHeader extends Header {
  final Key? key;

  const BubblesHeader({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultBubblesTriggerOffset,
    super.position,
    super.processedDuration,
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
