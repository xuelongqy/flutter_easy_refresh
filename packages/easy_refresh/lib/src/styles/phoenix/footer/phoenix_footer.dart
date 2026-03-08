part of '../../../../easy_refresh.dart';

/// Phoenix footer.
/// https://github.com/Yalantis/Phoenix
class PhoenixFooter extends Footer {
  final Key? key;

  /// Sky color.
  final Color? skyColor;

  const PhoenixFooter({
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
    super.infiniteOffset = null,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    this.skyColor,
  });

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'PhoenixFooter does not support horizontal scrolling.');
    return _PhoenixIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      skyColor: skyColor,
    );
  }
}
