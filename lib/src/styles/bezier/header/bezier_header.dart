part of easy_refresh;

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

  const BezierHeader({
    this.key,
    double triggerOffset = 100,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.above,
    Duration processedDuration = kBezierBackgroundDisappearDuration,
    physics.SpringDescription? spring,
    SpringBuilder readySpringBuilder = kBezierSpringBuilder,
    bool springRebound = false,
    FrictionFactor frictionFactor = kBezierFrictionFactor,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    this.showBalls = true,
    this.spinWidget,
    this.noMoreWidget,
    this.spinBuilder,
    this.foregroundColor,
    this.backgroundColor,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
          spring: spring,
          readySpringBuilder: readySpringBuilder,
          springRebound: springRebound,
          frictionFactor: frictionFactor,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          position: position,
          hapticFeedback: hapticFeedback,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _BezierIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      processedDuration: processedDuration,
      showBalls: showBalls,
      spinWidget: spinWidget,
      noMoreWidget: noMoreWidget,
      spinBuilder: spinBuilder,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }
}
