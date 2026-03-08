part of '../../../../easy_refresh.dart';

/// Bezier circle footer.
/// https://dribbble.com/shots/1797373-Pull-Down-To-Refresh
class BezierCircleHeader extends Header {
  final Key? key;

  /// Foreground color.
  final Color? foregroundColor;

  /// Background color.
  final Color? backgroundColor;

  const BezierCircleHeader({
    this.key,
    super.triggerOffset = 100,
    super.clamping = false,
    super.position,
    super.spring,
    SpringBuilder super.readySpringBuilder = kBezierSpringBuilder,
    super.springRebound = false,
    FrictionFactor super.frictionFactor = kBezierFrictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    this.foregroundColor,
    this.backgroundColor,
  }) : super(
          processedDuration: kBezierCircleDisappearDuration,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    assert(state.axis == Axis.vertical,
        'BezierCircleHeader does not support horizontal scrolling.');
    assert(!state.reverse, 'BezierCircleHeader does not support reverse.');
    return _BezierCircleIndicator(
      key: key,
      state: state,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }
}
