part of easy_refresh;

/// Footer indicator.
abstract class Footer extends Indicator {
  const Footer({
    required double triggerOffset,
    required bool clamping,
    Duration processedDuration = const Duration(seconds: 1),
    physics.SpringDescription? spring,
    physics.SpringDescription? horizontalSpring,
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
    double secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
    bool notifyWhenInvisible = false,
    IndicatorStateListenable? listenable,
    bool triggerWhenReach = false,
    bool triggerWhenRelease = false,
    bool triggerWhenReleaseNoWait = false,
    double maxOverOffset = double.infinity,
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
          secondaryCloseTriggerOffset: secondaryCloseTriggerOffset,
          notifyWhenInvisible: notifyWhenInvisible,
          listenable: listenable,
          triggerWhenReach: triggerWhenReach,
          triggerWhenRelease: triggerWhenRelease,
          triggerWhenReleaseNoWait: triggerWhenReleaseNoWait,
          maxOverOffset: maxOverOffset,
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
    physics.SpringDescription? spring,
    physics.SpringDescription? horizontalSpring,
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
    double secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
    bool notifyWhenInvisible = false,
    IndicatorStateListenable? listenable,
    bool triggerWhenReach = false,
    bool triggerWhenRelease = false,
    bool triggerWhenReleaseNoWait = false,
    double maxOverOffset = double.infinity,
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
          secondaryCloseTriggerOffset: secondaryCloseTriggerOffset,
          notifyWhenInvisible: notifyWhenInvisible,
          listenable: listenable,
          triggerWhenReach: triggerWhenReach,
          triggerWhenRelease: triggerWhenRelease,
          triggerWhenReleaseNoWait: triggerWhenReleaseNoWait,
          maxOverOffset: maxOverOffset,
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
    physics.SpringDescription? spring,
    physics.SpringDescription? horizontalSpring,
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
    double secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
    bool notifyWhenInvisible = false,
    bool triggerWhenReach = false,
    bool triggerWhenRelease = false,
    bool triggerWhenReleaseNoWait = false,
    double maxOverOffset = double.infinity,
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
          secondaryCloseTriggerOffset: secondaryCloseTriggerOffset,
          notifyWhenInvisible: notifyWhenInvisible,
          listenable: listenable,
          triggerWhenReach: triggerWhenReach,
          triggerWhenRelease: triggerWhenRelease,
          triggerWhenReleaseNoWait: triggerWhenReleaseNoWait,
          maxOverOffset: maxOverOffset,
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
    double secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
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
          secondaryCloseTriggerOffset: secondaryCloseTriggerOffset,
          notifyWhenInvisible: footer.notifyWhenInvisible,
          listenable: listenable ?? footer.listenable,
          triggerWhenReach: footer.triggerWhenReach,
          triggerWhenRelease: footer.triggerWhenRelease,
          triggerWhenReleaseNoWait: footer.triggerWhenReleaseNoWait,
          maxOverOffset: footer.maxOverOffset,
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
    double secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
    IndicatorStateListenable? listenable,
  }) : super(
          footer: footer,
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          secondaryDimension: secondaryDimension,
          secondaryCloseTriggerOffset: secondaryCloseTriggerOffset,
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
    IndicatorPosition position = IndicatorPosition.custom,
    physics.SpringDescription? spring,
    physics.SpringDescription? horizontalSpring,
    FrictionFactor? frictionFactor,
    FrictionFactor? horizontalFrictionFactor,
    bool? hitOver,
    double maxOverOffset = double.infinity,
  }) : super(
          triggerOffset: 0,
          clamping: clamping,
          infiniteOffset: null,
          position: position,
          spring: spring,
          horizontalSpring: horizontalSpring,
          frictionFactor: frictionFactor,
          horizontalFrictionFactor: horizontalFrictionFactor,
          processedDuration: const Duration(seconds: 0),
          hitOver: hitOver,
          maxOverOffset: maxOverOffset,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return const SizedBox();
  }
}

/// Override the Footer parameter.
/// First of all you have to make it clear that this is feasible,
/// otherwise please don't use it.
class OverrideFooter extends Footer {
  /// Footer that needs to be overwritten.
  final Footer footer;

  OverrideFooter({
    required this.footer,
    double? triggerOffset,
    bool? clamping,
    IndicatorPosition? position,
    Duration? processedDuration,
    physics.SpringDescription? spring,
    physics.SpringDescription? horizontalSpring,
    SpringBuilder? readySpringBuilder,
    SpringBuilder? horizontalReadySpringBuilder,
    bool? springRebound,
    FrictionFactor? frictionFactor,
    FrictionFactor? horizontalFrictionFactor,
    bool? safeArea,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool? hapticFeedback,
    double? secondaryTriggerOffset,
    double? secondaryVelocity,
    double? secondaryDimension,
    double? secondaryCloseTriggerOffset,
    bool? notifyWhenInvisible,
    IndicatorStateListenable? listenable,
    bool? triggerWhenReach,
    bool? triggerWhenRelease,
    bool? triggerWhenReleaseNoWait,
    double? maxOverOffset,
  }) : super(
          triggerOffset: triggerOffset ?? footer.triggerOffset,
          clamping: clamping ?? footer.clamping,
          processedDuration: processedDuration ?? footer.processedDuration,
          spring: spring ?? footer.spring,
          horizontalSpring: horizontalSpring ?? footer.horizontalSpring,
          readySpringBuilder: readySpringBuilder ?? footer.readySpringBuilder,
          horizontalReadySpringBuilder: horizontalReadySpringBuilder ??
              footer.horizontalReadySpringBuilder,
          springRebound: springRebound ?? footer.springRebound,
          frictionFactor: frictionFactor ?? footer.frictionFactor,
          horizontalFrictionFactor:
              horizontalFrictionFactor ?? footer.horizontalFrictionFactor,
          safeArea: safeArea ?? footer.safeArea,
          infiniteOffset: infiniteOffset ?? footer.infiniteOffset,
          hitOver: hitOver ?? footer.hitOver,
          infiniteHitOver: infiniteHitOver ?? footer.infiniteHitOver,
          position: position ?? footer.position,
          hapticFeedback: hapticFeedback ?? footer.hapticFeedback,
          secondaryTriggerOffset:
              secondaryTriggerOffset ?? footer.secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity ?? footer.secondaryVelocity,
          secondaryDimension: secondaryDimension ?? footer.secondaryDimension,
          secondaryCloseTriggerOffset:
              secondaryCloseTriggerOffset ?? footer.secondaryCloseTriggerOffset,
          notifyWhenInvisible:
              notifyWhenInvisible ?? footer.notifyWhenInvisible,
          listenable: listenable ?? footer.listenable,
          triggerWhenReach: triggerWhenReach ?? footer.triggerWhenReach,
          triggerWhenRelease: triggerWhenRelease ?? footer.triggerWhenRelease,
          triggerWhenReleaseNoWait:
              triggerWhenReleaseNoWait ?? footer.triggerWhenReleaseNoWait,
          maxOverOffset: maxOverOffset ?? footer.maxOverOffset,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return footer.build(context, state);
  }
}
