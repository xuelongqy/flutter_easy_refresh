part of easy_refresh;

/// Header indicator.
abstract class Header extends Indicator {
  const Header({
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
    double? infiniteOffset,
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
    physics.SpringDescription? spring,
    physics.SpringDescription? horizontalSpring,
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

/// Listener header.
/// Listen to the indicator state and respond anywhere.
class ListenerHeader extends Header {
  const ListenerHeader({
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
    double? infiniteOffset,
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
    required double secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    double secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
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
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          secondaryDimension: secondaryDimension,
          secondaryCloseTriggerOffset: secondaryCloseTriggerOffset,
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
    required Header header,
    required this.builder,
    required double secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    double secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
    IndicatorStateListenable? listenable,
  }) : super(
          header: header,
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

/// Parameters when [EasyRefresh.onRefresh] is null.
/// Overscroll behavior of [ScrollView].
class NotRefreshHeader extends Header {
  const NotRefreshHeader({
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
