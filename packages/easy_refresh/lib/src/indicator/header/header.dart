part of '../../../easy_refresh.dart';

/// Header indicator.
abstract class Header extends Indicator {
  const Header({
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
}

/// Build header widget use [IndicatorBuilder].
class BuilderHeader extends Header {
  /// Header widget builder.
  final IndicatorBuilder builder;

  const BuilderHeader({
    required this.builder,
    required super.triggerOffset,
    required super.clamping,
    required super.position,
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

/// Listener header.
/// Listen to the indicator state and respond anywhere.
class ListenerHeader extends Header {
  const ListenerHeader({
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

/// Secondary header.
/// Combine existing [Header] with secondary.
abstract class SecondaryHeader extends Header {
  /// Existing [Header].
  final Header header;

  SecondaryHeader({
    required this.header,
    required double super.secondaryTriggerOffset,
    super.secondaryVelocity,
    super.secondaryDimension,
    super.secondaryCloseTriggerOffset,
    IndicatorStateListenable? listenable,
  }) : super(
          triggerOffset: header.triggerOffset,
          clamping: header.clamping,
          processedDuration: header.processedDuration,
          spring: header.spring,
          horizontalSpring: header.horizontalSpring,
          readySpringBuilder: header.readySpringBuilder,
          horizontalReadySpringBuilder: header.horizontalReadySpringBuilder,
          springRebound: header.springRebound,
          frictionFactor: header.frictionFactor,
          horizontalFrictionFactor: header.horizontalFrictionFactor,
          safeArea: header.safeArea,
          infiniteOffset: header.infiniteOffset,
          hitOver: header.hitOver,
          infiniteHitOver: header.infiniteHitOver,
          position: header.position,
          hapticFeedback: header.hapticFeedback,
          notifyWhenInvisible: header.notifyWhenInvisible,
          listenable: listenable ?? header.listenable,
          triggerWhenReach: header.triggerWhenReach,
          triggerWhenRelease: header.triggerWhenRelease,
          triggerWhenReleaseNoWait: header.triggerWhenReleaseNoWait,
          maxOverOffset: header.maxOverOffset,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return secondaryBuild(context, state, header);
  }

  Widget secondaryBuild(
      BuildContext context, IndicatorState state, Indicator indicator);
}

/// Secondary builder header.
class SecondaryBuilderHeader extends SecondaryHeader {
  /// Header widget builder.
  final SecondaryIndicatorBuilder builder;

  SecondaryBuilderHeader({
    required super.header,
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

/// Parameters when [EasyRefresh.onRefresh] is null.
/// Overscroll behavior of [ScrollView].
class NotRefreshHeader extends Header {
  const NotRefreshHeader({
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

/// Override the Header parameter.
/// First of all you have to make it clear that this is feasible,
/// otherwise please don't use it.
class OverrideHeader extends Header {
  /// Header that needs to be overwritten.
  final Header header;

  OverrideHeader({
    required this.header,
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
          triggerOffset: triggerOffset ?? header.triggerOffset,
          clamping: clamping ?? header.clamping,
          processedDuration: processedDuration ?? header.processedDuration,
          spring: spring ?? header.spring,
          horizontalSpring: horizontalSpring ?? header.horizontalSpring,
          readySpringBuilder: readySpringBuilder ?? header.readySpringBuilder,
          horizontalReadySpringBuilder: horizontalReadySpringBuilder ??
              header.horizontalReadySpringBuilder,
          springRebound: springRebound ?? header.springRebound,
          frictionFactor: frictionFactor ?? header.frictionFactor,
          horizontalFrictionFactor:
              horizontalFrictionFactor ?? header.horizontalFrictionFactor,
          safeArea: safeArea ?? header.safeArea,
          infiniteOffset: infiniteOffset ?? header.infiniteOffset,
          hitOver: hitOver ?? header.hitOver,
          infiniteHitOver: infiniteHitOver ?? header.infiniteHitOver,
          position: position ?? header.position,
          hapticFeedback: hapticFeedback ?? header.hapticFeedback,
          secondaryTriggerOffset:
              secondaryTriggerOffset ?? header.secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity ?? header.secondaryVelocity,
          secondaryDimension: secondaryDimension ?? header.secondaryDimension,
          secondaryCloseTriggerOffset:
              secondaryCloseTriggerOffset ?? header.secondaryCloseTriggerOffset,
          notifyWhenInvisible:
              notifyWhenInvisible ?? header.notifyWhenInvisible,
          listenable: listenable ?? header.listenable,
          triggerWhenReach: triggerWhenReach ?? header.triggerWhenReach,
          triggerWhenRelease: triggerWhenRelease ?? header.triggerWhenRelease,
          triggerWhenReleaseNoWait:
              triggerWhenReleaseNoWait ?? header.triggerWhenReleaseNoWait,
          maxOverOffset: maxOverOffset ?? header.maxOverOffset,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return header.build(context, state);
  }
}
