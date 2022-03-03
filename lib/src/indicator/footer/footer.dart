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
    IndicatorPosition position = IndicatorPosition.above,
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
    IndicatorPosition position = IndicatorPosition.above,
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
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return builder(context, state);
  }
}

/// Parameters when [EasyRefresh.onLoad] is null.
/// Overscroll behavior of [ScrollView].
class NotLoadFooter extends Footer {
  const NotLoadFooter({
    bool clamping = false,
    SpringDescription? spring,
  }) : super(
    triggerOffset: 0,
    clamping: clamping,
    position: IndicatorPosition.custom,
    spring: spring,
    processedDuration: const Duration(seconds: 0),
  );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return const SizedBox();
  }
}
