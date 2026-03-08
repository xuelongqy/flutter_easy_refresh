part of '../../../../easy_refresh.dart';

/// Taurus footer.
/// https://github.com/Yalantis/Taurus
class TaurusFooter extends Footer {
  final Key? key;

  /// Sky color.
  final Color? skyColor;

  const TaurusFooter({
    this.key,
    super.triggerOffset = 100,
    super.clamping = false,
    super.position,
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
  }) : super(
          processedDuration: kTaurusDisappearDuration,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'TaurusFooter does not support horizontal scrolling.');
    return _TaurusIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      skyColor: skyColor,
    );
  }
}
