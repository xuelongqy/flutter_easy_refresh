part of easy_refresh;

/// Bezier footer.
class BezierFooter extends Footer {
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

  const BezierFooter({
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
    this.spinInCenter = true,
    this.onlySpin = false,
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
      reverse: !state.reverse,
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
