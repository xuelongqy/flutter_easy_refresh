part of '../easy_refresh_space.dart';

class SpaceHeader extends Header {
  final Key? key;

  const SpaceHeader({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultSpaceTriggerOffset,
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
        'SpaceHeader does not support horizontal scrolling.');
    return _SpaceIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
