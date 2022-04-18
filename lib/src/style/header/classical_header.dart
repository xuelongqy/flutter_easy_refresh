part of easyrefresh;

class ClassicalHeader extends Header {
  const ClassicalHeader({
    required double triggerOffset,
    required bool clamping,
    required IndicatorPosition position,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    double? secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
  }) : super(
    triggerOffset: triggerOffset,
    clamping: clamping,
    processedDuration: processedDuration,
    spring: spring,
    safeArea: safeArea,
    infiniteOffset: infiniteOffset,
    hitOver: hitOver,
    infiniteHitOver: infiniteHitOver,
    position: position,
    secondaryTriggerOffset: secondaryTriggerOffset,
    secondaryVelocity: secondaryVelocity,
    hapticFeedback: hapticFeedback,
    secondaryDimension: secondaryDimension,
  );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    // TODO: implement build
    throw UnimplementedError();
  }
}