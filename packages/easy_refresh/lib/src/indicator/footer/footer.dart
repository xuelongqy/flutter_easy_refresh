part of '../../../easy_refresh.dart';

/// Footer indicator.
abstract class Footer extends Indicator {
  const Footer({
    required super.triggerOffset,
    required super.clamping,
    super.processedDuration,
    super.spring,
    super.horizontalSpring,
    super.readySpringBuilder,
    super.horizontalReadySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.horizontalFrictionFactor,
    super.safeArea,
    super.infiniteOffset = 0,
    super.hitOver,
    super.infiniteHitOver,
    super.position,
    super.hapticFeedback,
    super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    super.notifyWhenInvisible,
    super.listenable,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.triggerWhenReleaseNoWait,
    super.maxOverOffset,
  });
}

/// Build footer widget use [IndicatorBuilder].
class BuilderFooter extends Footer {
  /// Footer widget builder.
  final IndicatorBuilder builder;

  const BuilderFooter({
    required this.builder,
    required super.triggerOffset,
    required super.clamping,
    super.processedDuration,
    super.spring,
    super.horizontalSpring,
    super.readySpringBuilder,
    super.horizontalReadySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.horizontalFrictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.position,
    super.hapticFeedback,
    super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    super.notifyWhenInvisible,
    super.listenable,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.triggerWhenReleaseNoWait,
    super.maxOverOffset,
  });

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return builder(context, state);
  }
}

/// Listener footer.
/// Listen to the indicator state and respond anywhere.
class ListenerFooter extends Footer {
  const ListenerFooter({
    required IndicatorStateListenable super.listenable,
    required super.triggerOffset,
    super.clamping = true,
    super.processedDuration,
    super.spring,
    super.horizontalSpring,
    super.readySpringBuilder,
    super.horizontalReadySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.horizontalFrictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    super.notifyWhenInvisible,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.triggerWhenReleaseNoWait,
    super.maxOverOffset,
  }) : super(
          position: IndicatorPosition.custom,
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
    required double super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
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
    required super.footer,
    required this.builder,
    required super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    super.listenable,
  });

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
    super.clamping = false,
    super.position = IndicatorPosition.custom,
    super.spring,
    super.horizontalSpring,
    super.frictionFactor,
    super.horizontalFrictionFactor,
    super.hitOver,
    super.maxOverOffset,
  }) : super(
          triggerOffset: 0,
          infiniteOffset: null,
          processedDuration: const Duration(seconds: 0),
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
