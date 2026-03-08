part of '../easy_refresh_squats.dart';

class SquatsHeader extends Header {
  final Key? key;

  /// Background color.
  final Color? backgroundColor;

  const SquatsHeader({
    this.key,
    super.clamping = false,
    super.triggerOffset = _kDefaultSquatsTriggerOffset,
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
    this.backgroundColor,
  }) : super(
          safeArea: false,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'SquatsHeader does not support horizontal scrolling.');
    return _SquatsIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      backgroundColor: backgroundColor,
    );
  }
}
