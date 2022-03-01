part of easyrefresh;

/// The current state of the indicator ([Header] or [Footer]).
enum IndicatorMode {
  /// Default state, without any trigger conditions.
  /// At this time [Header] or [Footer] is not displayed.
  /// Return to this state after the task is completed.
  inactive,

  /// Overscroll but not reached the trigger mission distance.
  /// This state is released and the [Scrollable] is restored.
  drag,

  /// Overscroll and reach the trigger task distance.
  /// This state is released and the list triggers the task.
  armed,

  /// Overscroll and about to trigger a task
  /// This state indicates that the user has released.
  ready,

  /// Task in progress.
  /// In progress until the task is completed.
  processing,

  /// Task completed.
  /// The task is over, but the whole process is not complete.
  /// Set the ending animation, which will be done after this state.
  processed,

  /// The whole process is done.
  /// When finished, go back to [inactive]
  done,
}

/// The position of the indicator.
enum IndicatorPosition {
  /// Above the content.
  /// Above in [Stack] layout.
  above,

  /// Behind the content.
  /// Below in the [Stack] layout.
  behind,

  /// Use locator.
  /// Use [HeaderLocator] or [FooterLocator] in [ScrollView].
  locator,

  /// Customize the indicator anywhere.
  /// Indicator widget will not be build in EasyRefresh.
  custom,
}

/// Indicator properties and state.
class IndicatorState {
  /// Refresh and loading indicator.
  final Indicator indicator;

  /// Refresh and loading state.
  final IndicatorMode mode;

  /// Overscroll offset.
  final double offset;

  /// Safe area offset.
  final double safeOffset;

  /// [Scrollable] axis
  final Axis axis;

  /// [Scrollable] axis direction
  final AxisDirection axisDirection;

  const IndicatorState({
    required this.indicator,
    required this.mode,
    required this.offset,
    required this.safeOffset,
    required this.axis,
    required this.axisDirection,
  });
}

/// Indicator widget builder.
typedef IndicatorBuilder = Widget Function(
    BuildContext context, IndicatorState state);

/// Refresh and loading indicator.
/// Indicator configuration and widget builder.
abstract class Indicator {
  /// The offset of the trigger task.
  final double triggerOffset;

  /// Hold to keep the [Scrollable] from going out of bounds.
  final bool clamping;

  /// Whether to calculate the safe area.
  final bool safeArea;

  /// Task completion delay.
  /// [IndicatorMode.processed] duration of state.
  final Duration processedDuration;

  /// Structure that describes a spring's constants.
  final SpringDescription? spring;

  /// Infinite scroll trigger offset.
  /// The relative offset of the [Scrollable] from the bounds (>= 0)
  /// When null, no infinite scroll.
  final double? infiniteOffset;

  /// Hit boundary over.
  /// When the [Scrollable] scrolls by itself, is it out of bounds.
  /// When [clamping] is false, it takes effect.
  final bool hitOver;

  /// Infinite scroll hits out of bounds.
  /// When the [Scrollable] scrolls by itself,
  /// whether the infinite scroll is out of bounds.
  /// When [clamping] is false, it takes effect.
  final bool infiniteHitOver;

  /// The position of the indicator.
  final IndicatorPosition position;

  const Indicator({
    required this.triggerOffset,
    required this.clamping,
    this.processedDuration = const Duration(seconds: 1),
    this.safeArea = true,
    this.spring,
    this.infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    this.position = IndicatorPosition.above,
  })  : hitOver = hitOver ?? infiniteOffset != null,
        infiniteHitOver = infiniteHitOver ?? infiniteOffset == null,
        assert(infiniteOffset == null || infiniteOffset >= 0,
            'The infiniteOffset cannot be smaller than 0.'),
        assert(infiniteOffset == null || !clamping,
            'Cannot scroll indefinitely when clamping.'),
        assert(!clamping || position != IndicatorPosition.locator,
            'Cannot use locator when clamping.');

  /// Build indicator widget.
  Widget build(BuildContext context, IndicatorState state);
}
