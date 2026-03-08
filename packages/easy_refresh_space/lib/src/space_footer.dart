part of '../easy_refresh_space.dart';

class SpaceFooter extends Footer {
  final Key? key;

  const SpaceFooter({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultSpaceTriggerOffset,
    super.position,
    super.processedDuration = Duration.zero,
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
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'SpaceFooter does not support horizontal scrolling.');
    return _SpaceIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
