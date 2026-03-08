part of '../../../../easy_refresh.dart';

/// Bezier header.
class BezierHeader extends Header {
  final Key? key;

  /// Show the ball during the pull.
  final bool showBalls;

  /// Spin widget.
  final Widget? spinWidget;

  /// No more widget.
  final Widget? noMoreWidget;

  /// Spin widget builder.
  final BezierSpinBuilder? spinBuilder;

  /// Foreground color.
  final Color? foregroundColor;

  /// Background color.
  final Color? backgroundColor;

  /// Whether the spin widget is in the center.
  final bool spinInCenter;

  /// Only display the spin.
  /// When true, the balls are no longer displayed.
  final bool onlySpin;

  const BezierHeader({
    this.key,
    super.triggerOffset = 100,
    super.clamping = false,
    super.position,
    super.processedDuration = kBezierBackgroundDisappearDuration,
    super.spring,
    SpringBuilder super.readySpringBuilder = kBezierSpringBuilder,
    super.springRebound = false,
    FrictionFactor super.frictionFactor = kBezierFrictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    this.showBalls = true,
    this.spinInCenter = true,
    this.onlySpin = false,
    this.spinWidget,
    this.noMoreWidget,
    this.spinBuilder,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _BezierIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      processedDuration: processedDuration,
      showBalls: showBalls,
      spinInCenter: spinInCenter,
      onlySpin: onlySpin,
      spinWidget: spinWidget,
      noMoreWidget: noMoreWidget,
      spinBuilder: spinBuilder,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }
}
