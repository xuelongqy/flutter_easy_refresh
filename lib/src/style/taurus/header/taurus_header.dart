part of easyrefresh;

class TaurusHeader extends Header {
  final Key? key;

  /// Sky color.
  final Color? skyColor;

  TaurusHeader({
    this.key,
    double triggerOffset = 100,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.above,
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
    this.skyColor,
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
    'TaurusHeader does not support horizontal scrolling.');
    return _TaurusIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      skyColor: skyColor,
    );
  }
}