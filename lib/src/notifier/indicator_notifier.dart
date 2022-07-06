// ignore_for_file: invalid_use_of_visible_for_testing_member

part of easy_refresh;

/// Indicator widget builder.
typedef CanProcessCallBack = bool Function();

/// Mode change listener.
typedef ModeChangeListener = void Function(IndicatorMode mode, double offset);

/// Indicator data and trigger notification.
abstract class IndicatorNotifier extends ChangeNotifier {
  /// Refresh and loading Indicator.
  Indicator _indicator;

  /// Used to provide [clamping] animation.
  final TickerProvider vsync;

  /// User triggered notifier.
  /// Record user triggers and releases.
  @protected
  final ValueNotifier<bool> userOffsetNotifier;

  /// Tasks that need to be executed when triggered.
  /// Can return [IndicatorResult] to set the completion result.
  FutureOr Function()? _task;

  /// Wait for the task to complete.
  bool _waitTaskResult;

  IndicatorNotifier({
    required Indicator indicator,
    required this.vsync,
    required this.userOffsetNotifier,
    required CanProcessCallBack onCanProcess,
    required bool noMoreProcess,
    bool waitTaskResult = true,
    FutureOr Function()? task,
  })  : _indicator = indicator,
        _onCanProcess = onCanProcess,
        _noMoreProcess = noMoreProcess,
        _waitTaskResult = waitTaskResult,
        _task = task {
    _initClampingAnimation();
    userOffsetNotifier.addListener(_onUserOffset);
    indicator.listenable?._bind(this);
  }

  double get triggerOffset => _indicator.triggerOffset;

  bool get clamping => _indicator.clamping;

  bool get safeArea => _indicator.safeArea;

  Duration get processedDuration => _indicator.processedDuration;

  double? get infiniteOffset => _indicator.infiniteOffset;

  bool get hitOver => _indicator.hitOver;

  bool get infiniteHitOver => _indicator.infiniteHitOver;

  IndicatorPosition get iPosition => _indicator.position;

  double? get secondaryTriggerOffset => _indicator.secondaryTriggerOffset;

  double get secondaryVelocity => _indicator.secondaryVelocity;

  /// Spring description.
  SpringDescription? get _spring {
    if (_axis == Axis.horizontal) {
      return _indicator.horizontalSpring ?? _indicator.spring;
    } else {
      return _indicator.spring;
    }
  }

  SpringDescription get spring => _physics.spring;

  SpringBuilder? get readySpringBuilder {
    if (_axis == Axis.horizontal) {
      return _indicator.horizontalReadySpringBuilder ??
          _indicator.readySpringBuilder;
    } else {
      return _indicator.readySpringBuilder;
    }
  }

  FrictionFactor? get _frictionFactor {
    if (_axis == Axis.horizontal) {
      return _indicator.horizontalFrictionFactor ?? _indicator.frictionFactor;
    } else {
      return _indicator.frictionFactor;
    }
  }

  FrictionFactor get frictionFactor => _physics.frictionFactor;

  double get secondaryDimension =>
      _indicator.secondaryDimension ?? _position.viewportDimension;

  double get secondaryCloseTriggerOffset =>
      _indicator.secondaryCloseTriggerOffset;

  bool get hapticFeedback => _indicator.hapticFeedback;

  bool get hasSecondary => secondaryTriggerOffset != null;

  /// [Scrollable] axis and direction
  Axis? _axis;

  Axis? get axis => _axis;

  AxisDirection? _axisDirection;

  AxisDirection? get axisDirection => _axisDirection;

  /// Safe area offset.
  /// Refer to [SafeArea].
  /// Used to solve the problem that the safe area is blocked.
  /// The final trigger offset is [triggerOffset] + [safeOffset]
  double? _safeOffset;

  double get safeOffset => safeArea ? _safeOffset ?? 0 : 0;

  /// Overscroll offset.
  double _offset = 0;

  double get offset => _offset;

  /// The current scroll position.
  late ScrollMetrics _position;

  ScrollMetrics get position => _position;

  /// The current scroll velocity.
  double _velocity = 0;

  double get velocity => _velocity;

  /// The current state of the indicator.
  IndicatorMode __mode = IndicatorMode.inactive;

  IndicatorMode get _mode => __mode;

  set _mode(IndicatorMode mode) {
    final oldMode = __mode;
    __mode = mode;
    if (mode != oldMode) {
      for (final listener in _modeChangeListeners) {
        listener(mode, _offset);
      }
    }
  }

  IndicatorMode get mode => _mode;

  /// Animation controller.
  /// Used when [clamping] is true.
  AnimationController? _clampingAnimationController;

  /// EasyRefresh scroll physics.
  late _ERScrollPhysics _physics;

  /// Offset on release.
  /// Meet the premise of the task.
  double _releaseOffset = 0;

  /// Mode change listeners.
  final Set<ModeChangeListener> _modeChangeListeners = {};

  /// Actual trigger offset.
  /// [triggerOffset] + [safeOffset]
  double get actualTriggerOffset => triggerOffset + safeOffset;

  /// Actual secondary trigger offset.
  /// [secondaryTriggerOffset] + [safeOffset]
  double get actualSecondaryTriggerOffset =>
      secondaryTriggerOffset! + safeOffset;

  /// Keep the extent of the [Scrollable] out of bounds.
  double get overExtent {
    // State that doesn't change.
    if (_task == null ||
        (!_canProcess && !noMoreLocked) ||
        (noMoreLocked && infiniteOffset == null)) {
      return 0;
    }
    // State that triggers the task.
    if (infiniteOffset != null ||
        _mode == IndicatorMode.ready ||
        modeLocked ||
        noMoreLocked) {
      return actualTriggerOffset;
    }
    // State that triggers the secondary.
    if (_mode == IndicatorMode.secondaryArmed && userOffsetNotifier.value) {
      return offset;
    }
    if (_mode == IndicatorMode.secondaryReady ||
        _mode == IndicatorMode.secondaryOpen) {
      return secondaryDimension;
    }
    return 0;
  }

  /// Is the state locked.
  bool get modeLocked =>
      _mode == IndicatorMode.processing || _mode == IndicatorMode.processed;

  /// Out of scroll area.
  bool get outOfRange {
    if (clamping) {
      return !modeLocked && _offset > 0;
    }
    return _offset > 0;
  }

  /// Indicator listenable.
  ValueListenable<IndicatorNotifier> listenable() => _IndicatorListenable(this);

  /// Is the task in progress.
  bool _processing = false;

  /// Can it be process.
  CanProcessCallBack? _onCanProcess;

  bool get _canProcess => _onCanProcess!.call();

  /// Task completion result.
  IndicatorResult _result = IndicatorResult.none;

  /// Whether to execute the task after no more.
  bool _noMoreProcess;

  /// State lock when no more.
  bool get noMoreLocked =>
      !_noMoreProcess &&
      _result == IndicatorResult.noMore &&
      _mode == IndicatorMode.inactive;

  /// Calculate the overscroll offset.
  double _calculateOffset(ScrollMetrics position, double value);

  /// Calculate the overscroll offset with pixels.
  double calculateOffsetWithPixels(ScrollMetrics position, double pixels);

  /// Infinite scroll exclusions.
  bool _infiniteExclude(ScrollMetrics position, double value);

  /// Animates the position from its current value to the given value.
  /// [offset] The offset to scroll to.
  /// [mode] When duration is null and clamping is true, set the state.
  /// [jumpToEdge] Whether to jump to the edge before scrolling.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  Future animateToOffset({
    required double offset,
    required IndicatorMode mode,
    bool jumpToEdge = true,
    Duration? duration,
    Curve curve = Curves.linear,
  });

  bool get secondaryLocked =>
      _mode == IndicatorMode.secondaryOpen ||
      _mode == IndicatorMode.secondaryClosing;

  @override
  void dispose() {
    _onCanProcess = null;
    _clampingAnimationController?.dispose();
    userOffsetNotifier.removeListener(_onUserOffset);
    _task = null;
    _modeChangeListeners.clear();
    _indicator.listenable?._unbind();
    super.dispose();
  }

  /// Add mode change listener.
  void addModeChangeListener(ModeChangeListener listener) {
    _modeChangeListeners.add(listener);
  }

  /// Remove mode change listener.
  void removeModeChangeListener(ModeChangeListener listener) {
    _modeChangeListeners.remove(listener);
  }

  /// Initialize the [clamping] animation controller
  void _initClampingAnimation() {
    if (clamping) {
      _clampingAnimationController = AnimationController.unbounded(
        vsync: vsync,
      );
      _clampingAnimationController!.addListener(_clampingTick);
    }
  }

  /// Listen for user events
  void _onUserOffset() {
    if (userOffsetNotifier.value) {
      // Clamping
      // Cancel animation, update offset
      if (clamping && _clampingAnimationController!.isAnimating) {
        _clampingAnimationController!.stop(canceled: true);
      }
    }
  }

  /// Bind physics behavior
  void _bindPhysics(_ERScrollPhysics physics) {
    _physics = physics;
  }

  /// Create a ballistic simulation.
  /// Use for [clamping].
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity);

  /// Calculate distance from boundary.
  double get boundaryOffset;

  /// Update parameters.
  /// When the EasyRefresh parameters is updated.
  void _update({
    Indicator? indicator,
    bool? noMoreProcess,
    FutureOr Function()? task,
    bool? waitTaskRefresh,
  }) {
    if (indicator != null) {
      _indicator.listenable?._unbind();
      indicator.listenable?._bind(this);
      _indicator = indicator;
    }
    _noMoreProcess = noMoreProcess ?? _noMoreProcess;
    _task = task;
    _waitTaskResult = waitTaskRefresh ?? _waitTaskResult;
    if (_indicator.clamping && _clampingAnimationController == null) {
      _initClampingAnimation();
    } else if (!_indicator.clamping && _clampingAnimationController != null) {
      _clampingAnimationController?.stop();
      _clampingAnimationController?.dispose();
      _clampingAnimationController = null;
    }
  }

  /// Reset partial state, e.g. no more.
  void _reset() {
    if (_result == IndicatorResult.noMore) {
      _result = IndicatorResult.none;
    }
  }

  /// Automatically trigger task.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  Future callTask({
    required double overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    if (modeLocked || noMoreLocked || secondaryLocked || !_canProcess) {
      return Future.value();
    }
    return animateToOffset(
      offset: actualTriggerOffset + overOffset,
      mode: IndicatorMode.ready,
      duration: duration,
      curve: curve,
    );
  }

  /// Animation listener for [clamping].
  void _clampingTick() {
    final mOffset = calculateOffsetWithPixels(
        _position, _clampingAnimationController!.value);
    if (hasSecondary &&
        !noMoreLocked &&
        mOffset > secondaryDimension &&
        _mode == IndicatorMode.secondaryReady) {
      // After fully opening the secondary, turn off the animation.
      _offset = secondaryDimension;
      _clampingAnimationController!.stop();
    } else {
      // Stop spring rebound.
      if (_mode == IndicatorMode.ready &&
          !_indicator.springRebound &&
          mOffset < actualTriggerOffset) {
        _offset = actualTriggerOffset;
        _clampingAnimationController!.stop();
      } else {
        if (mOffset < 0) {
          _offset = 0;
          _clampingAnimationController!.stop();
        }
        _offset = mOffset;
      }
    }
    _slightDeviation();
    _updateMode();
    notifyListeners();
  }

  /// Update by [ScrollPhysics.createBallisticSimulation].
  void _updateBySimulation(ScrollMetrics position, double velocity) {
    _position = position;
    _velocity = velocity;
    // Update axis and direction.
    if (_axis != position.axis || _axisDirection != position.axisDirection) {
      _axis = position.axis;
      _axisDirection = position.axisDirection;
      Future(() {
        notifyListeners();
      });
    }
    // Update offset on release
    _updateOffset(position, position.pixels, true);
    // If clamping is true and offset is greater than 0, start animation
    if (clamping && _offset > 0 && !(modeLocked || secondaryLocked)) {
      final simulation = createBallisticSimulation(position, velocity);
      if (simulation != null) {
        _startClampingAnimation(simulation);
      }
    }
  }

  /// Temporary solutions, sometimes with slight deviation.
  void _slightDeviation() {
    if ((_offset - actualTriggerOffset).abs() < 0.000001) {
      _offset = actualTriggerOffset;
    }
  }

  /// Update [Scrollable] offset
  void _updateOffset(ScrollMetrics position, double value, bool bySimulation) {
    // Clamping
    // In task processing, do nothing.
    if (clamping && (modeLocked || secondaryLocked)) {
      return;
    }
    // Clamping
    // In the case of release, and offset is greater than 0, it is controlled by animation.
    if (!userOffsetNotifier.value && clamping && _offset > 0 && !bySimulation) {
      return;
    }
    _position = position;
    // Record old state.
    final oldOffset = _offset;
    final oldMode = _mode;
    // Calculate and update the offset.
    _offset = _calculateOffset(position, value);
    _slightDeviation();
    if (bySimulation) {
      _releaseOffset = _offset;
    }
    // Do nothing if not out of bounds.
    if (oldOffset == 0 && _offset == 0) {
      if (_mode == IndicatorMode.done ||
          // Handling infinite scroll
          (infiniteOffset != null &&
              boundaryOffset < infiniteOffset! &&
              !bySimulation &&
              !_infiniteExclude(position, value))) {
        // Update mode
        _updateMode();
        notifyListeners();
      }
      if (_indicator.notifyWhenInvisible && !bySimulation) {
        notifyListeners();
      }
      return;
    }
    // Update mode
    _updateMode();
    // Need notify
    if (oldOffset == _offset && oldMode == _mode) {
      return;
    }
    // Haptic feedback
    if (hapticFeedback &&
        _mode == IndicatorMode.armed &&
        oldMode != IndicatorMode.armed &&
        userOffsetNotifier.value) {
      HapticFeedback.mediumImpact();
    }
    // Avoid setState() during drawing
    if (bySimulation) {
      // Notify when list length changes
      if (_offset <= actualTriggerOffset) {
        Future(() {
          notifyListeners();
        });
      }
      return;
    }
    notifyListeners();
  }

  /// Update indicator state.
  void _updateMode() {
    // No task, keep IndicatorMode.inactive state.
    if (_task == null) {
      if (_mode != IndicatorMode.inactive) {
        _mode = IndicatorMode.inactive;
      }
    }
    // Not updated during task execution and task completion.
    if (!(modeLocked || noMoreLocked || secondaryLocked)) {
      // In the non-executable task state.
      if (!_canProcess) {
        _mode = IndicatorMode.inactive;
        return;
      }
      // Infinite scroll
      if (infiniteOffset != null && boundaryOffset < infiniteOffset!) {
        if (_mode == IndicatorMode.done &&
            _position.maxScrollExtent != _position.minScrollExtent) {
          // The state does not change until the end
          return;
        } else {
          _mode = IndicatorMode.processing;
        }
      } else if (_mode == IndicatorMode.done && offset > 0) {
        // The state does not change until the end
        return;
      } else if (_offset == 0) {
        if (!(_mode == IndicatorMode.ready && !userOffsetNotifier.value)) {
          // Prevent Spring from having repeated rebounds.
          _mode = IndicatorMode.inactive;
          if (_result != IndicatorResult.noMore || _noMoreProcess) {
            _result = IndicatorResult.none;
          }
          _releaseOffset = 0;
        }
      } else if (_offset < actualTriggerOffset) {
        if (!(_mode == IndicatorMode.ready && !userOffsetNotifier.value)) {
          // Prevent Spring from having repeated rebounds.
          _mode = IndicatorMode.drag;
        }
      } else if (_offset == actualTriggerOffset) {
        // Must be exceeded to trigger the task
        _mode = userOffsetNotifier.value
            ? (_releaseOffset > actualTriggerOffset
                ? IndicatorMode.ready
                : IndicatorMode.armed)
            : IndicatorMode.processing;
      } else if (_offset > actualTriggerOffset) {
        if (hasSecondary &&
            _offset >= actualSecondaryTriggerOffset &&
            (_releaseOffset == 0 ||
                _releaseOffset >= actualSecondaryTriggerOffset)) {
          // Secondary
          if (_offset < secondaryDimension) {
            _mode = userOffsetNotifier.value
                ? IndicatorMode.secondaryArmed
                : IndicatorMode.secondaryReady;
          } else {
            _mode = userOffsetNotifier.value
                ? IndicatorMode.secondaryReady
                : IndicatorMode.secondaryOpen;
          }
        } else {
          // Process
          // If the user is scrolling
          // (the task is not executed if it is not released)
          _mode = userOffsetNotifier.value
              ? IndicatorMode.armed
              : (_releaseOffset > actualTriggerOffset
                  ? IndicatorMode.ready
                  : IndicatorMode.armed);
        }
      }
      // Execute the task.
      if (_mode == IndicatorMode.processing) {
        _onTask();
      }
    }
    // Close secondary
    if (secondaryLocked) {
      _mode = secondaryDimension - _offset >= secondaryCloseTriggerOffset
          ? IndicatorMode.secondaryClosing
          : IndicatorMode.secondaryOpen;
      if (_offset == 0) {
        _mode = IndicatorMode.inactive;
      }
    }
  }

  /// Execute the task and process the result.
  void _onTask() async {
    if (!(_canProcess && !_processing && _task != null)) {
      return;
    }
    _processing = true;
    if (_waitTaskResult) {
      try {
        final res = await Future.sync(_task!);
        if (res is IndicatorResult) {
          _result = res;
        } else {
          _result = IndicatorResult.success;
        }
      } catch (_) {
        _result = IndicatorResult.fail;
        rethrow;
      } finally {
        _setMode(IndicatorMode.processed);
        _processing = false;
      }
    } else {
      _task!.call();
    }
  }

  /// Finish task and return the result.
  /// [result] Result of task completion.
  void _finishTask([IndicatorResult result = IndicatorResult.success]) {
    if (!_waitTaskResult) {
      _result = result;
      _setMode(IndicatorMode.processed);
      _processing = false;
    }
  }

  /// Start [clamping] animation
  void _startClampingAnimation(Simulation simulation) {
    if (_offset <= 0) {
      return;
    }
    _clampingAnimationController!.animateWith(simulation);
  }

  /// Reset ballistic.
  /// Trigger [_ERScrollPhysics.createBallisticSimulation].
  void _resetBallistic() {
    ScrollActivityDelegate? delegate;
    double velocity = 0;
    if (_position is ScrollPosition) {
      // ignore: invalid_use_of_protected_member
      final activity = (_position as ScrollPosition).activity;
      delegate = activity?.delegate;
      velocity = activity?.velocity ?? 0;
    } else if (_position is ScrollActivityDelegate) {
      delegate = _position as ScrollActivityDelegate;
    }
    delegate?.goBallistic(velocity);
  }

  /// Set mode.
  /// Internal use of EasyRefresh.
  void _setMode(IndicatorMode mode) {
    if (_mode == mode) {
      return;
    }
    final oldMode = _mode;
    _mode = mode;
    notifyListeners();
    // Task processed
    if (this.mode == IndicatorMode.processed) {
      // Completion delay
      if (processedDuration == Duration.zero) {
        _mode = IndicatorMode.done;
        // Trigger [Scrollable] rollback
        if (oldMode == IndicatorMode.processing &&
            _position is ScrollActivityDelegate &&
            !userOffsetNotifier.value) {
          _resetBallistic();
        }
      } else {
        Future.delayed(processedDuration, () {
          _setMode(IndicatorMode.done);
          // Trigger [Scrollable] rollback
          if (_position is ScrollActivityDelegate &&
              !userOffsetNotifier.value) {
            _resetBallistic();
          }
        });
      }
      // Actively update the offset if the user does not release
      if (!clamping && userOffsetNotifier.value) {
        Future(() {
          _updateOffset(_position, _position.pixels, false);
        });
      }
    }
  }

  /// Get indicator state;
  IndicatorState? get indicatorState {
    if (_axis == null || _axisDirection == null) {
      return null;
    }
    return IndicatorState(
      indicator: _indicator,
      userOffsetNotifier: userOffsetNotifier,
      notifier: this,
      mode: mode,
      result: _result,
      offset: offset,
      safeOffset: safeOffset,
      axis: _axis!,
      axisDirection: _axisDirection!,
      viewportDimension: _position.viewportDimension,
      actualTriggerOffset: actualTriggerOffset,
    );
  }

  /// Build indicator widget.
  Widget _build(BuildContext context) {
    if (_axis == null || _axisDirection == null) {
      return const SizedBox();
    }
    return _indicator.build(
      context,
      indicatorState!,
    );
  }
}

/// Indicator listenable.
/// Listen for property changes of the indicator.
/// Used to update widget.
class _IndicatorListenable<T extends IndicatorNotifier>
    extends ValueListenable<T> {
  /// Indicator notifier
  final T _indicatorNotifier;

  _IndicatorListenable(this._indicatorNotifier);

  final List<VoidCallback> _listeners = [];

  /// Listen for notifications
  void _onNotify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    if (_listeners.isEmpty) {
      _indicatorNotifier.addListener(_onNotify);
    }
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _indicatorNotifier.removeListener(_onNotify);
    }
  }

  @override
  T get value => _indicatorNotifier;
}

/// [Header] notifier
/// [Header] status and Notifications
class HeaderNotifier extends IndicatorNotifier {
  HeaderNotifier({
    required Header header,
    required ValueNotifier<bool> userOffsetNotifier,
    required TickerProvider vsync,
    required CanProcessCallBack onCanRefresh,
    bool noMoreRefresh = false,
    FutureOr Function()? onRefresh,
    bool waitRefreshResult = true,
  }) : super(
          indicator: header,
          userOffsetNotifier: userOffsetNotifier,
          vsync: vsync,
          onCanProcess: onCanRefresh,
          noMoreProcess: noMoreRefresh,
          task: onRefresh,
          waitTaskResult: waitRefreshResult,
        );

  @override
  double _calculateOffset(ScrollMetrics position, double value) {
    if (value >= position.minScrollExtent &&
        _offset != 0 &&
        !(clamping && _offset > 0)) {
      return 0;
    }
    if (clamping) {
      if (value > position.minScrollExtent) {
        // Rollback first minus offset.
        return math.max(_offset > 0 ? (-value + _offset) : 0, 0);
      } else {
        // Overscroll accumulated offset.
        final mOffset = -value + _offset;
        if (hasSecondary && mOffset > secondaryDimension) {
          // Cannot exceed secondary offset.
          return secondaryDimension;
        }
        return mOffset;
      }
    } else {
      return value > position.minScrollExtent ? 0 : -value;
    }
  }

  /// See [IndicatorNotifier.calculateOffsetWithPixels].
  @override
  double calculateOffsetWithPixels(ScrollMetrics position, double pixels) =>
      math.max(-pixels - position.minScrollExtent, 0.0);

  /// See [IndicatorNotifier.createBallisticSimulation].
  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final mVelocity =
        hasSecondary && !noMoreLocked && _offset >= actualSecondaryTriggerOffset
            ? -secondaryVelocity
            : velocity;
    if (_offset > 0) {
      return BouncingScrollSimulation(
        spring: spring,
        position:
            clamping ? position.minScrollExtent - _offset : position.pixels,
        velocity: mVelocity,
        leadingExtent: position.minScrollExtent - overExtent,
        trailingExtent: 0,
        tolerance: _physics.tolerance,
      );
    }
    return null;
  }

  /// See [IndicatorNotifier.boundaryOffset].
  @override
  double get boundaryOffset => _position.pixels;

  @override
  bool _infiniteExclude(ScrollMetrics position, double value) {
    return value >= position.maxScrollExtent;
  }

  @override
  Future animateToOffset({
    required double offset,
    required IndicatorMode mode,
    bool jumpToEdge = true,
    Duration? duration,
    Curve curve = Curves.linear,
  }) async {
    final scrollTo = -offset;
    _releaseOffset = offset;
    if (jumpToEdge) {
      (_position as ScrollPosition).jumpTo(_position.minScrollExtent);
    }
    if (clamping) {
      if (duration == null) {
        _offset = offset;
        _mode = mode;
        _updateBySimulation(_position, 0);
      } else {
        userOffsetNotifier.value = true;
        await _clampingAnimationController!
            .animateTo(scrollTo, duration: duration, curve: curve);
        userOffsetNotifier.value = false;
        _updateBySimulation(_position, 0);
      }
    } else {
      if (_position is ScrollPosition) {
        if (duration == null) {
          (_position as ScrollPosition).jumpTo(scrollTo);
        } else {
          userOffsetNotifier.value = true;
          await (_position as ScrollPosition)
              .animateTo(scrollTo, duration: duration, curve: curve);
          userOffsetNotifier.value = false;
          notifyListeners();
        }
      }
    }
  }
}

/// [Footer] notifier
/// [Footer] status and Notifications
class FooterNotifier extends IndicatorNotifier {
  FooterNotifier({
    required Footer footer,
    required ValueNotifier<bool> userOffsetNotifier,
    required TickerProvider vsync,
    required CanProcessCallBack onCanLoad,
    bool noMoreLoad = false,
    FutureOr Function()? onLoad,
    bool waitLoadResult = true,
  }) : super(
          indicator: footer,
          userOffsetNotifier: userOffsetNotifier,
          vsync: vsync,
          onCanProcess: onCanLoad,
          noMoreProcess: noMoreLoad,
          task: onLoad,
          waitTaskResult: waitLoadResult,
        );

  @override
  double _calculateOffset(ScrollMetrics position, double value) {
    if (value <= position.maxScrollExtent &&
        _offset != 0 &&
        !(clamping && _offset > 0)) {
      return 0;
    }
    // Moving distance
    final move = value - position.maxScrollExtent;
    if (clamping) {
      if (value < position.maxScrollExtent) {
        // Rollback first minus offset
        return math.max(_offset > 0 ? (move + _offset) : 0, 0);
      } else {
        // Overscroll accumulated offset
        final mOffset = move + _offset;
        if (hasSecondary && mOffset > secondaryDimension) {
          // Cannot exceed secondary offset.
          return secondaryDimension;
        }
        return mOffset;
      }
    } else {
      return value < position.maxScrollExtent ? 0 : move;
    }
  }

  /// See [IndicatorNotifier.calculateOffsetWithPixels].
  @override
  double calculateOffsetWithPixels(ScrollMetrics position, double pixels) =>
      math.max(pixels - position.maxScrollExtent, 0.0);

  /// See [IndicatorNotifier.createBallisticSimulation].
  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final mVelocity =
        hasSecondary && !noMoreLocked && _offset >= actualSecondaryTriggerOffset
            ? secondaryVelocity
            : velocity;
    if (_offset > 0) {
      return BouncingScrollSimulation(
        spring: spring,
        position:
            clamping ? position.maxScrollExtent + _offset : position.pixels,
        velocity: mVelocity,
        leadingExtent: 0,
        trailingExtent: position.maxScrollExtent + overExtent,
        tolerance: _physics.tolerance,
      );
    }
    return null;
  }

  /// See [IndicatorNotifier.boundaryOffset].
  @override
  double get boundaryOffset => _position.maxScrollExtent - _position.pixels;

  @override
  bool _infiniteExclude(ScrollMetrics position, double value) {
    return value <= position.minScrollExtent;
  }

  @override
  Future animateToOffset({
    required double offset,
    required IndicatorMode mode,
    Duration? duration,
    Curve curve = Curves.linear,
    bool jumpToEdge = true,
  }) async {
    final scrollTo = _position.maxScrollExtent + offset;
    _releaseOffset = offset;
    if (jumpToEdge) {
      (_position as ScrollPosition).jumpTo(_position.maxScrollExtent);
    }
    if (clamping) {
      if (duration == null) {
        _offset = offset;
        _mode = mode;
        _updateBySimulation(_position, 0);
      } else {
        userOffsetNotifier.value = true;
        await _clampingAnimationController!
            .animateTo(scrollTo, duration: duration, curve: curve);
        userOffsetNotifier.value = false;
        _updateBySimulation(_position, 0);
      }
    } else {
      if (_position is ScrollPosition) {
        if (duration == null) {
          (_position as ScrollPosition).jumpTo(scrollTo);
        } else {
          userOffsetNotifier.value = true;
          await (_position as ScrollPosition)
              .animateTo(scrollTo, duration: duration, curve: curve);
          userOffsetNotifier.value = false;
          notifyListeners();
        }
      }
    }
  }
}
