part of '../easy_refresh_bow.dart';

class BowHeader extends Header {
  final Key? key;

  const BowHeader({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultBowTriggerOffset,
    super.position,
    super.processedDuration,
    physics.SpringDescription? spring,
    super.readySpringBuilder,
    super.springRebound = false,
    super.frictionFactor,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.safeArea = false,
  }) : super(
          spring: spring ?? _kBowSpring,
          triggerWhenRelease: true,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'BowHeader does not support horizontal scrolling.');
    return _BowIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
