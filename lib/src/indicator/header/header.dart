part of easy_refresh;

/// Header indicator.
abstract class Header extends Indicator {
  const Header({
    required double triggerOffset,
    required bool clamping,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    SpringDescription? horizontalSpring,
    SpringBuilder? readySpringBuilder,
    SpringBuilder? horizontalReadySpringBuilder,
    bool springRebound = true,
    FrictionFactor? frictionFactor,
    FrictionFactor? horizontalFrictionFactor,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    IndicatorPosition position = IndicatorPosition.above,
    bool hapticFeedback = false,
    double? secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    bool notifyWhenInvisible = false,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
          spring: spring,
          horizontalSpring: horizontalSpring,
          readySpringBuilder: readySpringBuilder,
          horizontalReadySpringBuilder: horizontalReadySpringBuilder,
          springRebound: springRebound,
          frictionFactor: frictionFactor,
          horizontalFrictionFactor: horizontalFrictionFactor,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          position: position,
          hapticFeedback: hapticFeedback,
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          secondaryDimension: secondaryDimension,
          notifyWhenInvisible: notifyWhenInvisible,
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
    SpringDescription? horizontalSpring,
    SpringBuilder? readySpringBuilder,
    SpringBuilder? horizontalReadySpringBuilder,
    bool springRebound = true,
    FrictionFactor? frictionFactor,
    FrictionFactor? horizontalFrictionFactor,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    double? secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    bool notifyWhenInvisible = false,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
          spring: spring,
          horizontalSpring: horizontalSpring,
          readySpringBuilder: readySpringBuilder,
          horizontalReadySpringBuilder: horizontalReadySpringBuilder,
          springRebound: springRebound,
          frictionFactor: frictionFactor,
          horizontalFrictionFactor: horizontalFrictionFactor,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          position: position,
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          hapticFeedback: hapticFeedback,
          secondaryDimension: secondaryDimension,
          notifyWhenInvisible: notifyWhenInvisible,
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
    SpringDescription? horizontalSpring,
    FrictionFactor? frictionFactor,
    FrictionFactor? horizontalFrictionFactor,
  }) : super(
          triggerOffset: 0,
          clamping: clamping,
          position: IndicatorPosition.custom,
          spring: spring,
          horizontalSpring: horizontalSpring,
          frictionFactor: frictionFactor,
          horizontalFrictionFactor: horizontalFrictionFactor,
          processedDuration: const Duration(seconds: 0),
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return const SizedBox();
  }
}
