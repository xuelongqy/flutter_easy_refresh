part of easyrefresh;

/// Footer indicator.
abstract class Footer extends Indicator {
  const Footer({
    required double triggerOffset,
    required bool clamping,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset = 0,
    bool? hitOver,
    bool? infiniteHitOver,
    bool useLocator = false,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
          spring: spring,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          useLocator: useLocator,
        );
}

/// Build footer widget use [IndicatorBuilder].
class BuilderFooter extends Footer {
  /// Footer widget builder.
  final IndicatorBuilder builder;

  const BuilderFooter({
    required this.builder,
    required double triggerOffset,
    required bool clamping,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset = 0,
    bool? hitOver,
    bool? infiniteHitOver,
    bool useLocator = false,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
          spring: spring,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          useLocator: useLocator,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return builder(context, state);
  }
}
