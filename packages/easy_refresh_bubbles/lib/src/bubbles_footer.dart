part of '../easy_refresh_bubbles.dart';

class BubblesFooter extends Footer {
  final Key? key;

  const BubblesFooter({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultBubblesTriggerOffset,
    super.position,
    super.processedDuration,
    super.spring,
    super.readySpringBuilder,
    super.springRebound = false,
    super.frictionFactor,
    super.infiniteOffset = null,
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
        'BubblesFooter does not support horizontal scrolling.');
    return _BubblesIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
