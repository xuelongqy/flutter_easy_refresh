part of easy_refresh;

class CupertinoHeader extends Header {
  final Key? key;

  /// Indicator foreground color.
  final Color? foregroundColor;

  /// Use WaterDrop style.
  final bool userWaterDrop;

  /// WaterDrop background color.
  final Color? backgroundColor;

  const CupertinoHeader({
    this.key,
    double triggerOffset = 60,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.behind,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    SpringBuilder? readySpringBuilder,
    bool springRebound = false,
    FrictionFactor? frictionFactor,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    this.foregroundColor,
    this.userWaterDrop = true,
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
    assert(state.axis == Axis.vertical,
        'CupertinoHeader does not support horizontal scrolling.');
    return _CupertinoIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      foregroundColor: foregroundColor,
      userWaterDrop: userWaterDrop,
      backgroundColor: backgroundColor,
    );
  }
}
