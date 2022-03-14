part of easyrefresh;

/// Header indicator.
abstract class Header extends Indicator {
  const Header({
    required double triggerOffset,
    required bool clamping,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset,
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

/// Build header widget use [IndicatorBuilder].
class BuilderHeader extends Header {
  /// Header widget builder.
  final IndicatorBuilder builder;

  const BuilderHeader({
    required this.builder,
    required double triggerOffset,
    required bool clamping,
    required IndicatorPosition position,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
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

/// Parameters when [EasyRefresh.onRefresh] is null.
/// Overscroll behavior of [ScrollView].
class NotRefreshHeader extends Header {
  const NotRefreshHeader({
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
