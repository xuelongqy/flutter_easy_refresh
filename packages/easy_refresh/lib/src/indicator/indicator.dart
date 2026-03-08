part of '../../easy_refresh.dart';

/// The default opening speed of the secondary.
const kDefaultSecondaryVelocity = 3000.0;

/// The default secondary close trigger offset.
const kDefaultSecondaryCloseTriggerOffset = 70.0;

/// Build spring with [IndicatorMode] and offset.
/// [mode] Indicator mode.
/// [offset] Indicator offset.
/// [actualTriggerOffset] Indicator actual trigger offset.
/// [velocity] Indicator actual trigger offset.
typedef SpringBuilder = physics.SpringDescription Function({
  required IndicatorMode mode,
  required double offset,
  required double actualTriggerOffset,
  required double velocity,
});

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

  /// Overscroll and about to trigger a task.
  /// This state indicates that the user has released.
  ready,

  /// Task in progress.
  /// In progress until the task is completed.
  processing,

  /// Task completed.
  /// The task is over, but the whole process is not complete.
  /// Set the ending animation, which will be done after this state.
  processed,

  /// Overscroll and reach the secondary trigger task distance.
  /// This state is released, and open the secondary page.
  secondaryArmed,

  /// Overscroll and about to open the secondary page.
  /// This state indicates that the user has released.
  secondaryReady,

  /// Secondary page is open.
  secondaryOpen,

  /// Secondary page is closing.
  secondaryClosing,

  /// The whole process is done.
  /// When finished, go back to [inactive]
  done,
}

/// The status returned after the task is completed.
enum IndicatorResult {
  /// No state until the task is not triggered.
  none,

  /// Task succeeded.
  success,

  /// Task failed.
  fail,

  /// No more data.
  noMore,
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

  /// Refresh and loading notifier.
  final IndicatorNotifier notifier;

  /// User offset notifier.
  final ValueNotifier<bool> userOffsetNotifier;

  /// Refresh and loading state.
  final IndicatorMode mode;

  /// Task completion result.
  final IndicatorResult result;

  /// Overscroll offset.
  final double offset;

  /// Safe area offset.
  final double safeOffset;

  /// [Scrollable] axis.
  final Axis axis;

  /// [Scrollable] axis direction.
  final AxisDirection axisDirection;

  /// [Scrollable] viewport dimension.
  /// It's helpful for full screen indicator and second floor views.
  final double viewportDimension;

  /// The offset of the trigger task.
  double get triggerOffset => indicator.triggerOffset;

  /// Actual trigger offset.
  /// [triggerOffset] + [safeOffset]
  final double actualTriggerOffset;

  /// Trigger offset for secondary.
  double? get secondaryTriggerOffset => indicator.secondaryTriggerOffset;

  /// Actual secondary trigger offset.
  double? get actualSecondaryTriggerOffset =>
      notifier.actualSecondaryTriggerOffset;

  /// Whether the scroll view direction is reversed.
  /// [AxisDirection.up] or [AxisDirection.left]
  bool get reverse =>
      axisDirection == AxisDirection.up || axisDirection == AxisDirection.left;

  const IndicatorState({
    required this.indicator,
    required this.notifier,
    required this.userOffsetNotifier,
    required this.mode,
    required this.result,
    required this.offset,
    required this.safeOffset,
    required this.axis,
    required this.axisDirection,
    required this.viewportDimension,
    required this.actualTriggerOffset,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndicatorState &&
          runtimeType == other.runtimeType &&
          indicator == other.indicator &&
          notifier == other.notifier &&
          mode == other.mode &&
          result == other.result &&
          offset == other.offset &&
          safeOffset == other.safeOffset &&
          axis == other.axis &&
          axisDirection == other.axisDirection &&
          viewportDimension == other.viewportDimension &&
          actualTriggerOffset == other.actualTriggerOffset;

  @override
  int get hashCode =>
      indicator.hashCode ^
      notifier.hashCode ^
      mode.hashCode ^
      result.hashCode ^
      offset.hashCode ^
      safeOffset.hashCode ^
      axis.hashCode ^
      axisDirection.hashCode ^
      viewportDimension.hashCode ^
      actualTriggerOffset.hashCode;

  @override
  String toString() {
    return 'IndicatorState{indicator: $indicator, notifier: $notifier, userOffsetNotifier: $userOffsetNotifier, mode: $mode, result: $result, offset: $offset, safeOffset: $safeOffset, axis: $axis, axisDirection: $axisDirection, viewportDimension: $viewportDimension, actualTriggerOffset: $actualTriggerOffset}';
  }
}

/// Indicator widget builder.
typedef IndicatorBuilder = Widget Function(
    BuildContext context, IndicatorState state);

/// Secondary indicator widget builder.
typedef SecondaryIndicatorBuilder = Widget Function(
    BuildContext context, IndicatorState state, Indicator indicator);

/// Indicator state listenable.
class IndicatorStateListenable extends ValueListenable<IndicatorState?> {
  /// Indicator notifier.
  IndicatorNotifier? _indicatorNotifier;

  /// Indicator state listeners.
  final List<VoidCallback> _listeners = [];

  /// Bind [IndicatorNotifier].
  void _bind(IndicatorNotifier indicatorNotifier) {
    _indicatorNotifier = indicatorNotifier;
    if (_listeners.isNotEmpty) {
      indicatorNotifier.addListener(_onNotify);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _onNotify();
      });
    }
  }

  /// Unbind [IndicatorNotifier].
  void _unbind() {
    _indicatorNotifier?.removeListener(_onNotify);
    _indicatorNotifier = null;
  }

  /// Rebind [IndicatorNotifier].
  void _rebind(IndicatorNotifier indicatorNotifier) {
    if (_indicatorNotifier == indicatorNotifier) {
      return;
    }
    _unbind();
    _bind(indicatorNotifier);
  }

  /// Listen for notifications
  void _onNotify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    if (_listeners.isEmpty) {
      _indicatorNotifier?.addListener(_onNotify);
    }
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _indicatorNotifier?.removeListener(_onNotify);
    }
  }

  @override
  IndicatorState? get value => _indicatorNotifier?.indicatorState;
}

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

  /// Spring effect when scrollable goes back.
  final physics.SpringDescription? spring;

  /// Horizontal spring effect when scrollable goes back.
  final physics.SpringDescription? horizontalSpring;

  /// Spring effect when the mode is [IndicatorMode.ready].
  final SpringBuilder? readySpringBuilder;

  /// Horizontal spring effect when the mode is [IndicatorMode.ready].
  final SpringBuilder? horizontalReadySpringBuilder;

  /// Whether the spring can rebound.
  /// Only works with [readySpringBuilder].
  final bool springRebound;

  /// Friction factor when list is out of bounds.
  /// See [BouncingScrollPhysics.frictionFactor].
  final FrictionFactor? frictionFactor;

  /// Horizontal friction factor when list is out of bounds.
  /// See [BouncingScrollPhysics.frictionFactor].
  final FrictionFactor? horizontalFrictionFactor;

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

  /// Whether to enable haptic feedback.
  final bool hapticFeedback;

  /// Trigger offset for secondary.
  /// The indicator will expand and fill the scrollview area.
  /// Will not trigger when null.
  final double? secondaryTriggerOffset;

  /// Secondary opening speed.
  final double secondaryVelocity;

  /// Dimension of the second floor.
  /// The default value is [ScrollMetrics.viewportDimension].
  final double? secondaryDimension;

  /// Secondary close trigger offset.
  final double secondaryCloseTriggerOffset;

  /// Notify when invisible.
  /// When [IndicatorNotifier.offset] < 0, scrolling will also trigger notification.
  /// This might have extra performance overhead, but it's very useful when you need it.
  final bool notifyWhenInvisible;

  /// Indicator state listenable.
  /// Monitor state changes in real time.
  final IndicatorStateListenable? listenable;

  /// Trigger immediately when reaching the [triggerOffset].
  final bool triggerWhenReach;

  /// Over [triggerOffset], the release triggers immediately.
  final bool triggerWhenRelease;

  /// Over [triggerOffset], the release triggers immediately.
  /// No need to wait for task execution to complete,
  /// generally used for non-asynchronous events
  /// or external custom indicators.
  final bool triggerWhenReleaseNoWait;

  /// Maximum overscroll offset, will no longer scroll.
  /// When [double.infinity], no limit.
  final double maxOverOffset;

  const Indicator({
    required this.triggerOffset,
    required this.clamping,
    this.processedDuration = const Duration(seconds: 1),
    this.safeArea = true,
    this.spring,
    this.horizontalSpring,
    this.readySpringBuilder,
    this.horizontalReadySpringBuilder,
    this.springRebound = true,
    this.frictionFactor,
    this.horizontalFrictionFactor,
    this.infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    this.position = IndicatorPosition.above,
    this.secondaryTriggerOffset,
    this.hapticFeedback = false,
    this.secondaryVelocity = kDefaultSecondaryVelocity,
    this.secondaryDimension,
    this.secondaryCloseTriggerOffset = kDefaultSecondaryCloseTriggerOffset,
    this.notifyWhenInvisible = false,
    this.listenable,
    this.triggerWhenReach = false,
    this.triggerWhenRelease = false,
    this.triggerWhenReleaseNoWait = false,
    this.maxOverOffset = double.infinity,
  })  : hitOver = hitOver ?? infiniteOffset != null,
        infiniteHitOver = infiniteHitOver ?? infiniteOffset == null,
        assert(infiniteOffset == null || infiniteOffset >= 0,
            'The infiniteOffset cannot be less than 0.'),
        assert(infiniteOffset == null || !clamping,
            'Cannot scroll indefinitely when clamping.'),
        assert(!(hitOver == false && infiniteOffset != null),
            'When hitOver is true, infinite scrolling cannot be used, please set infiniteHitOver.'),
        assert(
            secondaryTriggerOffset == null ||
                secondaryTriggerOffset > triggerOffset,
            'The secondaryTriggerOffset cannot be less than triggerOffset.'),
        assert(!(infiniteOffset != null && secondaryTriggerOffset != null),
            'Infinite scroll and secondary cannot be used together.'),
        assert(
            secondaryDimension == null ||
                secondaryDimension > (secondaryTriggerOffset ?? 0),
            'The secondaryDimension cannot be less than secondaryTriggerOffset.'),
        assert(maxOverOffset == double.infinity || maxOverOffset >= 0,
            'The maxOverOffset cannot be less than 0.');

  /// Build indicator widget.
  Widget build(BuildContext context, IndicatorState state);
}
