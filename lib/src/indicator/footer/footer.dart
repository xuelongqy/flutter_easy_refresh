part of easy_refresh;

/// Footer indicator.
abstract class Footer extends Indicator {
  const Footer({
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
    double? infiniteOffset = 0,
    bool? hitOver,
    bool? infiniteHitOver,
    IndicatorPosition position = IndicatorPosition.above,
    bool hapticFeedback = false,
    double? secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    bool notifyWhenInvisible = false,
    IndicatorStateListenable? listenable,
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
          listenable: listenable,
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
    SpringDescription? horizontalSpring,
    SpringBuilder? readySpringBuilder,
    SpringBuilder? horizontalReadySpringBuilder,
    bool springRebound = true,
    FrictionFactor? frictionFactor,
    FrictionFactor? horizontalFrictionFactor,
    bool safeArea = true,
    double? infiniteOffset = 0,
    bool? hitOver,
    bool? infiniteHitOver,
    IndicatorPosition position = IndicatorPosition.above,
    bool hapticFeedback = false,
    double? secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    bool notifyWhenInvisible = false,
    IndicatorStateListenable? listenable,
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
          listenable: listenable,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return builder(context, state);
  }
}

/// Listener footer.
/// Listen to the indicator state and respond anywhere.
class ListenerFooter extends Footer {
  const ListenerFooter({
    required IndicatorStateListenable listenable,
    required double triggerOffset,
    bool clamping = true,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    SpringDescription? horizontalSpring,
    SpringBuilder? readySpringBuilder,
    SpringBuilder? horizontalReadySpringBuilder,
    bool springRebound = true,
    FrictionFactor? frictionFactor,
    FrictionFactor? horizontalFrictionFactor,
    bool safeArea = true,
    double? infiniteOffset = 0,
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
          position: IndicatorPosition.custom,
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          hapticFeedback: hapticFeedback,
          secondaryDimension: secondaryDimension,
          notifyWhenInvisible: notifyWhenInvisible,
          listenable: listenable,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return const SizedBox();
  }
}

/// Secondary footer.
/// Combine existing [Footer] with secondary.
abstract class SecondaryFooter extends Footer {
  /// Existing [Footer].
  final Footer footer;

  SecondaryFooter({
    required this.footer,
    required double secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    IndicatorStateListenable? listenable,
  }) : super(
          triggerOffset: footer.triggerOffset,
          clamping: footer.clamping,
          processedDuration: footer.processedDuration,
          spring: footer.spring,
          horizontalSpring: footer.horizontalSpring,
          readySpringBuilder: footer.readySpringBuilder,
          horizontalReadySpringBuilder: footer.horizontalReadySpringBuilder,
          springRebound: footer.springRebound,
          frictionFactor: footer.frictionFactor,
          horizontalFrictionFactor: footer.horizontalFrictionFactor,
          safeArea: footer.safeArea,
          infiniteOffset: footer.infiniteOffset,
          hitOver: footer.hitOver,
          infiniteHitOver: footer.infiniteHitOver,
          position: footer.position,
          hapticFeedback: footer.hapticFeedback,
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          secondaryDimension: secondaryDimension,
          notifyWhenInvisible: footer.notifyWhenInvisible,
          listenable: listenable ?? footer.listenable,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return secondaryBuild(context, state, footer);
  }

  Widget secondaryBuild(
      BuildContext context, IndicatorState state, Indicator indicator);
}

/// Secondary builder footer.
class SecondaryBuilderFooter extends SecondaryFooter {
  /// Footer widget builder.
  final SecondaryIndicatorBuilder builder;

  SecondaryBuilderFooter({
    required Footer footer,
    required this.builder,
    required double secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    IndicatorStateListenable? listenable,
  }) : super(
          footer: footer,
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          secondaryDimension: secondaryDimension,
          listenable: listenable,
        );

  @override
  Widget secondaryBuild(
      BuildContext context, IndicatorState state, Indicator indicator) {
    return builder(context, state, indicator);
  }
}

/// Parameters when [EasyRefresh.onLoad] is null.
/// Overscroll behavior of [ScrollView].
class NotLoadFooter extends Footer {
  const NotLoadFooter({
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
