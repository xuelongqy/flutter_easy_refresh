part of '../easy_refresh_skating.dart';

class SkatingFooter extends Footer {
  final Key? key;

  const SkatingFooter({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultSkatingTriggerOffset,
    super.position,
    super.spring,
    super.readySpringBuilder,
    super.springRebound = false,
    super.frictionFactor,
    super.infiniteOffset = null,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
  }) : super(
          processedDuration: _kSkatingProcessed,
          safeArea: false,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'SkatingFooter does not support horizontal scrolling.');
    return _SkatingIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
    );
  }
}
