part of easyrefresh;

/// Material header.
class MaterialHeader extends Header {
  final Key? key;

  /// See [ProgressIndicator.backgroundColor].
  final Color? backgroundColor;

  /// See [ProgressIndicator.color].
  final Color? color;

  /// See [ProgressIndicator.valueColor].
  final Animation<Color?>? valueColor;

  /// See [ProgressIndicator.semanticsLabel].
  final String? semanticsLabel;

  /// See [ProgressIndicator.semanticsLabel].
  final String? semanticsValue;

  /// Icon when [IndicatorResult.noMore].
  final Widget? noMoreIcon;

  /// Show bezier background.
  final bool showBezierBackground;

  /// Show bezier background.
  final Color? bezierBackgroundColor;

  /// Bezier background animation.
  final bool bezierBackgroundAnimation;

  MaterialHeader({
    this.key,
    double triggerOffset = 100,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.above,
    Duration processedDuration = const Duration(milliseconds: 200),
    SpringDescription? spring,
    bool springRebound = false,
    SpringBuilder? readySpringBuilder,
    FrictionFactor? frictionFactor,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.semanticsLabel,
    this.semanticsValue,
    this.noMoreIcon,
    this.showBezierBackground = true,
    this.bezierBackgroundColor,
    this.bezierBackgroundAnimation = true,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
          spring: spring,
          readySpringBuilder: readySpringBuilder ??
              (showBezierBackground ? kBezierSpringBuilder : null),
          springRebound: springRebound,
          frictionFactor: frictionFactor ??
              (showBezierBackground
                  ? kBezierFrictionFactor
                  : kMaterialFrictionFactor),
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          position: position,
          hapticFeedback: hapticFeedback,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _MaterialIndicator(
      key: key,
      state: state,
      disappearDuration: processedDuration,
      reverse: state.reverse,
      backgroundColor: backgroundColor,
      color: color,
      valueColor: valueColor,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      noMoreIcon: noMoreIcon,
      showBezierBackground: showBezierBackground,
      bezierBackgroundColor: bezierBackgroundColor,
      bezierBackgroundAnimation: bezierBackgroundAnimation,
    );
  }
}
