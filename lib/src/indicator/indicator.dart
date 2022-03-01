part of easyrefresh;

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

  /// Whether to use a locator in [Scrollable].
  final bool useLocator;

  const Indicator({
    required this.triggerOffset,
    required this.clamping,
    this.processedDuration = const Duration(seconds: 1),
    this.safeArea = true,
    this.spring,
    this.infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    this.useLocator = false,
  })  : hitOver = hitOver ?? infiniteOffset != null,
        infiniteHitOver = infiniteHitOver ?? infiniteOffset == null,
        assert(infiniteOffset == null || infiniteOffset >= 0,
            'The infiniteOffset cannot be smaller than 0.'),
        assert(infiniteOffset == null || !clamping,
            'Cannot scroll indefinitely when clamping.'),
        assert(!clamping || !useLocator, 'Cannot use locator when clamping.');

  /// Build indicator widget.
  Widget build(BuildContext context, IndicatorState state);
}
