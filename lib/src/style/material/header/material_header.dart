part of easyrefresh;

/// Material header.
class MaterialHeader extends Header {
  final Key? key;

  MaterialHeader({
    this.key,
    double triggerOffset = 90,
    bool clamping = true,
    IndicatorPosition position = IndicatorPosition.above,
    Duration processedDuration = const Duration(milliseconds: 200),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
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
          hapticFeedback: hapticFeedback,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _MaterialIndicator(
      key: key,
      state: state,
      disappearDuration: processedDuration,
    );
  }
}
