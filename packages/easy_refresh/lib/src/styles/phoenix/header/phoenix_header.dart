part of '../../../../easy_refresh.dart';

/// Phoenix header.
/// https://github.com/Yalantis/Phoenix
class PhoenixHeader extends Header {
  final Key? key;

  /// Sky color.
  final Color? skyColor;

  const PhoenixHeader({
    this.key,
    super.triggerOffset = 100,
    super.clamping = false,
    super.position,
    super.processedDuration,
    super.spring,
    super.readySpringBuilder,
    super.springRebound = false,
    super.frictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    this.skyColor,
  });

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'PhoenixHeader does not support horizontal scrolling.');
    return _PhoenixIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      skyColor: skyColor,
    );
  }
}
