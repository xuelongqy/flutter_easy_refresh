part of easyrefresh;

/// Header indicator.
abstract class Header extends Indicator {
  const Header({
    required double triggerOffset,
    required bool clamping,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    SpringBuilder? readySpringBuilder,
    bool springRebound = true,
    FrictionFactor? frictionFactor,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    IndicatorPosition position = IndicatorPosition.above,
    bool hapticFeedback = false,
    double? secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
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
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          secondaryDimension: secondaryDimension,
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
    SpringBuilder? readySpringBuilder,
    bool springRebound = true,
    FrictionFactor? frictionFactor,
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
          readySpringBuilder: readySpringBuilder,
          springRebound: springRebound,
          frictionFactor: frictionFactor,
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
    return builder(context, state);
  }
}

/// Parameters when [EasyRefresh.onRefresh] is null.
/// Overscroll behavior of [ScrollView].
class NotRefreshHeader extends Header {
  const NotRefreshHeader({
    bool clamping = false,
    SpringDescription? spring,
    FrictionFactor? frictionFactor,
  }) : super(
          triggerOffset: 0,
          clamping: clamping,
          position: IndicatorPosition.custom,
          spring: spring,
          frictionFactor: frictionFactor,
          processedDuration: const Duration(seconds: 0),
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return const SizedBox();
  }
}
