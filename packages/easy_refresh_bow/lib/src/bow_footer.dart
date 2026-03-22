part of '../easy_refresh_bow.dart';

class BowFooter extends Footer {
  final Key? key;

  const BowFooter({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultBowTriggerOffset,
    super.position,
    super.processedDuration,
    physics.SpringDescription? spring,
    super.readySpringBuilder,
    super.springRebound = false,
    super.frictionFactor,
    super.infiniteOffset = null,
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
        'BowFooter does not support horizontal scrolling.');
    return _BowIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
