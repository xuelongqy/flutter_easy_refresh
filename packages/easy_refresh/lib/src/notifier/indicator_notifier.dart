// ignore_for_file: invalid_use_of_visible_for_testing_member

part of '../../easy_refresh.dart';

/// Indicator widget builder.
typedef CanProcessCallBack = bool Function();

/// Mode change listener.
typedef ModeChangeListener = void Function(IndicatorMode mode, double offset);

/// Indicator data and trigger notification.
abstract class IndicatorNotifier extends ChangeNotifier {
  /// Refresh and loading Indicator.
  Indicator _indicator;

  /// Used to provide [clamping] animation.
  final TickerProviderStateMixin vsync;

  /// User triggered notifier.
  /// Record user triggers and releases.
  @protected
  final ValueNotifier<bool> userOffsetNotifier;

  /// Tasks that need to be executed when triggered.
  /// Can return [IndicatorResult] to set the completion result.
  FutureOr Function()? _task;

  /// Wait for the task to complete.
  bool _waitTaskResult;

  /// Mounted on EasyRefresh.
  bool _mounted = false;

  /// Direction of execution.
  /// Other scroll directions will not show indicators and perform task.
  Axis? _triggerAxis;

  IndicatorNotifier({
    required Indicator indicator,
    required this.vsync,
    required this.userOffsetNotifier,
    required CanProcessCallBack onCanProcess,
    required bool canProcessAfterNoMore,
    required bool isNested,
    Axis? triggerAxis,
    bool waitTaskResult = true,
    FutureOr Function()? task,
  })  : _indicator = indicator,
        _onCanProcess = onCanProcess,
        _canProcessAfterNoMore = canProcessAfterNoMore,
        _isNested = isNested,
        _triggerAxis = triggerAxis,
        _waitTaskResult = waitTaskResult,
        _task = task {
    _initClampingAnimation();
    userOffsetNotifier.addListener(_onUserOffset);
    indicator.listenable?._bind(this);
    _mounted = true;
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

  double get maxOverOffset => _indicator.maxOverOffset;

  double get actualMaxOverOffset => maxOverOffset == double.infinity
      ? maxOverOffset
      : (maxOverOffset + safeOffset);

  /// Spring description.
  physics.SpringDescription? get _spring {
    if (_axis == Axis.horizontal) {
      return _indicator.horizontalSpring ?? _indicator.spring;
    } else {
      return _indicator.spring;
    }
  }

  physics.SpringDescription get spring => _physics.spring;

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
      _indicator.secondaryDimension ?? viewportDimension;

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
  ScrollMetrics get position => _position!;

  ScrollPosition? _effectiveScrollPosition() {
    if (_position is ScrollPosition) {
      return _position as ScrollPosition;
    }
    return null;
  }

  ScrollController? _matchingScrollController(
      ScrollController? scrollController, ScrollPosition position) {
    if (!(scrollController?.hasClients ?? false)) {
      return null;
    }
    return scrollController!.positions.contains(position)
        ? scrollController
        : null;
  }

  /// Handling NestedScrollView
  bool _isNested;

  bool get isNested => _isNested;

  set position(ScrollMetrics value) {
    if (_isNested) {
      if (value.isNestedOuter) {
        _viewportDimension = value.viewportDimension;
      } else if (value.isNestedInner) {
        if (WidgetsBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks) {
          _viewportDimension = value.axis == Axis.vertical
              ? vsync.context.size?.height
              : vsync.context.size?.width;
        }
      }
    } else {
      _viewportDimension = null;
    }
    _position = value;
    _lastMaxScrollExtent = value.maxScrollExtent;
  }

  ScrollMetrics? _position;

  /// Cache maxScrollExtent.
  /// Used to compare the last value.
  double? _lastMaxScrollExtent;

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

  /// Whether to support the direction.
  bool get _isSupportAxis {
    if (_triggerAxis == null || _axis == null) {
      return true;
    }
    return _axis == _triggerAxis;
  }

  /// Keep the extent of the [Scrollable] out of bounds.
  double get overExtent {
    // If the direction is different do not change.
    if (!_isSupportAxis) {
      return 0;
    }
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

  bool get _canProcess => _onCanProcess?.call() ?? false;

  /// Task completion result.
  IndicatorResult _result = IndicatorResult.none;

  /// Whether to execute the task after no more.
  bool _canProcessAfterNoMore;

  /// State lock when no more.
  bool get noMoreLocked =>
      !_canProcessAfterNoMore &&
      _result == IndicatorResult.noMore &&
      _mode == IndicatorMode.inactive;

  /// [Scrollable] viewport dimension.
  double get viewportDimension =>
      _viewportDimension ?? position.viewportDimension;

  double? _viewportDimension;

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
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  Future animateToOffset({
    required double offset,
    required IndicatorMode mode,
    bool jumpToEdge = true,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
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
    _mounted = false;
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
    } else {
      _releaseOffset = _offset;
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

  /// Calculate distance from edge.
  double get edgeOffset;

  /// Update parameters.
  /// When the EasyRefresh parameters is updated.
  void _update({
    Indicator? indicator,
    bool? canProcessAfterNoMore,
    Axis? triggerAxis,
    FutureOr Function()? task,
    bool? waitTaskRefresh,
    bool? isNested,
  }) {
    if (indicator != null) {
      if (indicator.listenable == _indicator.listenable) {
        indicator.listenable?._rebind(this);
      } else {
        _indicator.listenable?._unbind();
        indicator.listenable?._bind(this);
      }
      if (indicator != _indicator) {
        _indicator = indicator;
      }
    }
    _canProcessAfterNoMore = canProcessAfterNoMore ?? _canProcessAfterNoMore;
    _triggerAxis = triggerAxis;
    _task = task;
    _waitTaskResult = waitTaskRefresh ?? _waitTaskResult;
    if (_indicator.clamping && _clampingAnimationController == null) {
      _initClampingAnimation();
    } else if (!_indicator.clamping && _clampingAnimationController != null) {
      _clampingAnimationController?.stop();
      _clampingAnimationController?.dispose();
      _clampingAnimationController = null;
    }
    if (isNested != null) {
      _isNested = isNested;
    }
    notifyListeners();
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
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  /// [force] Enforce execution even if the task is in progress. But you have to handle the completion event.
  Future callTask({
    required double overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) {
    if (!_mounted) {
      return Future.value();
    }
    if (!force) {
      if (modeLocked || noMoreLocked || secondaryLocked || !_canProcess) {
        return Future.value();
      }
    } else {
      _offset = 0;
      _mode = IndicatorMode.inactive;
      _processing = false;
    }
    return animateToOffset(
      offset: actualTriggerOffset + overOffset,
      mode: IndicatorMode.ready,
      duration: duration,
      curve: curve,
      scrollController: scrollController,
    );
  }

  /// Animation listener for [clamping].
  void _clampingTick() {
    final mOffset = calculateOffsetWithPixels(
        position, _clampingAnimationController!.value);
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
    _velocity = velocity;
    // Update axis and direction.
    if (_axis != position.axis || _axisDirection != position.axisDirection) {
      _axis = position.axis;
      _axisDirection = position.axisDirection;
      Future(() {
        if (_mounted) {
          notifyListeners();
        }
      });
    }
    this.position = position;
    final oldMode = _mode;
    // Update offset on release
    _updateOffset(position, position.pixels, true);
    // If clamping is true and offset is greater than 0, start animation
    if (clamping &&
        _offset > 0 &&
        ((_indicator.triggerWhenRelease && oldMode == IndicatorMode.armed) ||
            !(modeLocked || secondaryLocked))) {
      final simulation = createBallisticSimulation(position, velocity);
      if (simulation != null) {
        _startClampingAnimation(simulation);
      }
    }
  }

  /// Temporary solutions, sometimes with slight deviation.
  void _slightDeviation() {
    if ((_offset - actualTriggerOffset).abs() <= precisionErrorTolerance) {
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
    if ((clamping && _mode == IndicatorMode.done && bySimulation) ||
        (!userOffsetNotifier.value &&
            clamping &&
            _offset > 0 &&
            !bySimulation)) {
      return;
    }
    this.position = position;
    // Record old state.
    final oldOffset = _offset;
    final oldMode = _mode;
    // Calculate and update the offset.
    _offset = _calculateOffset(position, value);
    _slightDeviation();
    // Do nothing if not out of bounds.
    if (oldOffset == 0 && _offset == 0) {
      if (_mode == IndicatorMode.done ||
          // Handling infinite scroll
          (infiniteOffset != null &&
              (!(_isNested && position.isNestedOuter) &&
                  edgeOffset < infiniteOffset!) &&
              !bySimulation &&
              !_infiniteExclude(position, value))) {
        // Update mode
        _updateMode(oldOffset);
        notifyListeners();
      }
      if (_indicator.notifyWhenInvisible && !bySimulation) {
        notifyListeners();
      }
      return;
    }
    // Update mode
    _updateMode(oldOffset);
    // Need notify
    if (oldOffset == _offset && oldMode == _mode) {
      return;
    }
    // Haptic feedback
    if (hapticFeedback && userOffsetNotifier.value) {
      if (_indicator.triggerWhenReach) {
        if (_mode == IndicatorMode.processing &&
            oldMode == IndicatorMode.drag) {
          HapticFeedback.mediumImpact();
        }
      } else {
        if (_mode == IndicatorMode.armed && oldMode != IndicatorMode.armed) {
          HapticFeedback.mediumImpact();
        }
      }
    }
    // Avoid setState() during drawing
    if (bySimulation) {
      // Notify when list length changes
      if (_offset <= actualTriggerOffset) {
        Future(() {
          if (_mounted) {
            notifyListeners();
          }
        });
      }
      return;
    }
    notifyListeners();
  }

  /// Update indicator state.
  void _updateMode([double? oldOffset]) {
    // When the orientation is different, no modification is made.
    if (!_isSupportAxis) {
      return;
    }
    // No task, keep IndicatorMode.inactive state.
    if (_task == null) {
      if (_mode != IndicatorMode.inactive) {
        _mode = IndicatorMode.inactive;
      }
      return;
    }
    // Not updated during task execution and task completion.
    if (!(modeLocked || noMoreLocked || secondaryLocked)) {
      // In the non-executable task state.
      if (!_canProcess) {
        _mode = IndicatorMode.inactive;
        return;
      }
      // Infinite scroll
      if (infiniteOffset != null &&
          (!(_isNested && position.isNestedOuter) &&
              edgeOffset < infiniteOffset!)) {
        if (_mode == IndicatorMode.done &&
            position.maxScrollExtent != position.minScrollExtent) {
          if ((_result == IndicatorResult.fail ||
                  (_result == IndicatorResult.noMore &&
                      _canProcessAfterNoMore)) &&
              oldOffset != null &&
              oldOffset < _offset) {
            // Trigger task if in failed state.
            _result = IndicatorResult.none;
            _mode = IndicatorMode.processing;
          } else {
            // The state does not change until the end
            return;
          }
        } else {
          if (_mode == IndicatorMode.done) {
            if (offset == 0) {
              _mode = IndicatorMode.inactive;
            }
          } else {
            _result = IndicatorResult.none;
            _mode = IndicatorMode.processing;
          }
        }
      } else if (_mode == IndicatorMode.done && offset > 0) {
        // The state does not change until the end
        return;
      } else if (_offset == 0) {
        if (!(_mode == IndicatorMode.ready && !userOffsetNotifier.value)) {
          // Prevent Spring from having repeated rebounds.
          _mode = IndicatorMode.inactive;
          if (_result != IndicatorResult.noMore || _canProcessAfterNoMore) {
            _result = IndicatorResult.none;
          }
          _releaseOffset = 0;
        }
      } else if (_offset < actualTriggerOffset) {
        if (_canProcessAfterNoMore &&
            _result == IndicatorResult.noMore &&
            userOffsetNotifier.value) {
          _result = IndicatorResult.none;
        }
        if (!(_mode == IndicatorMode.ready && !userOffsetNotifier.value)) {
          // Prevent Spring from having repeated rebounds.
          _mode = IndicatorMode.drag;
        }
      } else if (_offset == actualTriggerOffset) {
        // Must be exceeded to trigger the task
        if (userOffsetNotifier.value) {
          if (_indicator.triggerWhenReach) {
            _mode = IndicatorMode.processing;
          } else {
            _mode = (_releaseOffset > actualTriggerOffset
                ? IndicatorMode.ready
                : IndicatorMode.armed);
          }
        } else {
          _mode = IndicatorMode.processing;
        }
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
          if (userOffsetNotifier.value) {
            _mode = _indicator.triggerWhenReach
                ? IndicatorMode.processing
                : IndicatorMode.armed;
          } else {
            if (_releaseOffset > actualTriggerOffset) {
              if (_indicator.triggerWhenReleaseNoWait) {
                // Immediately trigger the task.
                // No need to wait for events to complete.
                // Mode changes to IndicatorMode.done.
                if (_task != null) {
                  Future.sync(_task!);
                }
                _mode = IndicatorMode.done;
              } else if (_indicator.triggerWhenRelease) {
                // Immediately trigger the task.
                _mode = IndicatorMode.processing;
              } else {
                _mode = IndicatorMode.ready;
              }
            } else {
              _mode = IndicatorMode.armed;
            }
          }
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
      Future.sync(_task!);
    }
  }

  /// Finish task and return the result.
  /// [result] Result of task completion.
  void _finishTask([IndicatorResult result = IndicatorResult.success]) {
    _result = result;
    if (!_waitTaskResult && mode == IndicatorMode.processing) {
      _setMode(IndicatorMode.processed);
      _processing = false;
    }
  }

  /// Start [clamping] animation
  void _startClampingAnimation(Simulation simulation) {
    if (!clamping) {
      return;
    }
    if (_clampingAnimationController == null) {
      _initClampingAnimation();
    }
    if (_offset <= 0 || _clampingAnimationController!.isAnimating) {
      return;
    }
    _clampingAnimationController!.animateWith(simulation);
  }

  /// Reset ballistic.
  /// Trigger [_ERScrollPhysics.createBallisticSimulation].
  void _resetBallistic() {
    if (!_mounted) {
      return;
    }
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
    if (delegate != null) {
      delegate.goBallistic(velocity);
    } else {
      if (clamping && _offset > 0 && !(modeLocked || secondaryLocked)) {
        final simulation = createBallisticSimulation(position, velocity);
        if (simulation != null) {
          _startClampingAnimation(simulation);
        }
      }
    }
  }

  /// Set mode.
  /// Internal use of EasyRefresh.
  void _setMode(IndicatorMode mode) {
    if (_mode == mode) {
      return;
    }
    // Do not continue if not mounted.
    if (!_mounted) {
      return;
    }
    final oldMode = _mode;
    _mode = mode;
    notifyListeners();
    // Task processed
    if (this.mode == IndicatorMode.processed) {
      _scheduleProcessedCompletion(oldMode);
      // Actively update the offset if the user does not release
      if (!clamping && userOffsetNotifier.value) {
        Future(() {
          if (!_mounted || _position == null) {
            return;
          }
          _updateOffset(position, position.pixels, false);
        });
      }
    }
  }

  void _scheduleProcessedCompletion(IndicatorMode oldMode) {
    if (processedDuration == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _completeProcessedMode(oldMode);
      });
      return;
    }
    Future.delayed(processedDuration, () {
      _completeProcessedMode(oldMode);
    });
  }

  void _completeProcessedMode(IndicatorMode oldMode) {
    if (!_mounted) {
      return;
    }
    if (mode != IndicatorMode.processed) {
      return;
    }
    _syncFooterOffsetAfterProcessed();
    _setMode(IndicatorMode.done);
    if (offset == 0) {
      _setMode(IndicatorMode.inactive);
    }
    // Trigger [Scrollable] rollback
    if (oldMode == IndicatorMode.processing && !userOffsetNotifier.value) {
      _resetBallistic();
    }
  }

  void _syncFooterOffsetAfterProcessed() {
    if (!_mounted ||
        _offset == 0 ||
        _position == null ||
        _position!.outOfRange ||
        this is! FooterNotifier) {
      return;
    }
    final oldOffset = _offset;
    if (!clamping) {
      _offset = _calculateOffset(_position!, _position!.pixels);
    }
    if (_offset != oldOffset) {
      notifyListeners();
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
      viewportDimension: viewportDimension,
      actualTriggerOffset: actualTriggerOffset,
    );
  }

  /// Build indicator widget.
  Widget _build(BuildContext context) {
    if (_axis == null || _axisDirection == null) {
      return const SizedBox();
    }
    if (!_isSupportAxis) {
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
    required super.userOffsetNotifier,
    required super.vsync,
    required CanProcessCallBack onCanRefresh,
    super.canProcessAfterNoMore = false,
    super.isNested = false,
    bool canProcessAfterFail = true,
    super.triggerAxis,
    FutureOr Function()? onRefresh,
    bool waitRefreshResult = true,
  }) : super(
          indicator: header,
          onCanProcess: onCanRefresh,
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
    // Moving distance
    final move = position.minScrollExtent - value;
    if (clamping) {
      if (value > position.minScrollExtent) {
        // Rollback first minus offset.
        return math.max(_offset > 0 ? (move + _offset) : 0, 0);
      } else {
        // Overscroll accumulated offset.
        final mOffset = move + _offset;
        if (hasSecondary && mOffset > secondaryDimension) {
          // Cannot exceed secondary offset.
          return secondaryDimension;
        }
        // Maximum overscroll offset
        if (actualMaxOverOffset != double.infinity) {
          return math.min(mOffset, actualMaxOverOffset);
        }
        return mOffset;
      }
    } else {
      return value > position.minScrollExtent ? 0 : move;
    }
  }

  /// See [IndicatorNotifier.calculateOffsetWithPixels].
  @override
  double calculateOffsetWithPixels(ScrollMetrics position, double pixels) =>
      math.max(position.minScrollExtent - pixels, 0.0);

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
        tolerance: _physics.toleranceFor(position),
      );
    }
    return null;
  }

  /// See [IndicatorNotifier.edgeOffset].
  @override
  double get edgeOffset => position.pixels;

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
    ScrollController? scrollController,
  }) async {
    final effectivePosition = _effectiveScrollPosition();
    if (effectivePosition == null) {
      return;
    }
    final matchedController =
        _matchingScrollController(scrollController, effectivePosition);
    final scrollTo = -offset;
    _releaseOffset = offset;
    if (jumpToEdge) {
      if (matchedController != null) {
        matchedController.jumpTo(effectivePosition.minScrollExtent);
      } else {
        effectivePosition.jumpTo(effectivePosition.minScrollExtent);
      }
    }
    if (clamping) {
      if (duration == null) {
        _offset = offset;
        _mode = mode;
        _updateBySimulation(effectivePosition, 0);
      } else {
        userOffsetNotifier.value = true;
        _clampingAnimationController!.value = effectivePosition.minScrollExtent;
        await _clampingAnimationController!
            .animateTo(scrollTo, duration: duration, curve: curve);
        userOffsetNotifier.value = false;
        _updateBySimulation(effectivePosition, 0);
      }
    } else {
      if (duration == null) {
        if (matchedController != null) {
          matchedController.jumpTo(scrollTo);
        } else {
          effectivePosition.jumpTo(scrollTo);
        }
      } else {
        userOffsetNotifier.value = true;
        if (matchedController != null) {
          await matchedController.animateTo(scrollTo,
              duration: duration, curve: curve);
        } else {
          await effectivePosition.animateTo(scrollTo,
              duration: duration, curve: curve);
        }
        userOffsetNotifier.value = false;
        notifyListeners();
      }
    }
  }
}

/// [Footer] notifier
/// [Footer] status and Notifications
class FooterNotifier extends IndicatorNotifier {
  FooterNotifier({
    required Footer footer,
    required super.userOffsetNotifier,
    required super.vsync,
    required CanProcessCallBack onCanLoad,
    super.canProcessAfterNoMore = false,
    super.isNested = false,
    bool canProcessAfterFail = true,
    super.triggerAxis,
    FutureOr Function()? onLoad,
    bool waitLoadResult = true,
  }) : super(
          indicator: footer,
          onCanProcess: onCanLoad,
          task: onLoad,
          waitTaskResult: waitLoadResult,
        );

  /// Keep the extent of the [Scrollable] out of bounds.
  @override
  double get overExtent {
    /// When the content of the list is not full,
    /// the infinite scroll does not cross the bounds.
    if (infiniteOffset != null &&
        position.maxScrollExtent <= position.minScrollExtent) {
      return 0;
    }
    return super.overExtent;
  }

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
        // Maximum overscroll offset
        if (actualMaxOverOffset != double.infinity) {
          return math.min(mOffset, actualMaxOverOffset);
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
        tolerance: _physics.toleranceFor(position),
      );
    }
    return null;
  }

  /// See [IndicatorNotifier.edgeOffset].
  @override
  double get edgeOffset => position.maxScrollExtent - position.pixels;

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
    ScrollController? scrollController,
  }) async {
    final effectivePosition = _effectiveScrollPosition();
    if (effectivePosition == null) {
      return;
    }
    final matchedController =
        _matchingScrollController(scrollController, effectivePosition);
    final scrollTo = effectivePosition.maxScrollExtent + offset;
    _releaseOffset = offset;
    if (jumpToEdge) {
      if (matchedController != null) {
        matchedController.jumpTo(effectivePosition.maxScrollExtent);
      } else {
        effectivePosition.jumpTo(effectivePosition.maxScrollExtent);
      }
    }
    if (clamping) {
      if (duration == null) {
        _offset = offset;
        _mode = mode;
        _updateBySimulation(effectivePosition, 0);
      } else {
        userOffsetNotifier.value = true;
        _clampingAnimationController!.value = effectivePosition.maxScrollExtent;
        await _clampingAnimationController!
            .animateTo(scrollTo, duration: duration, curve: curve);
        userOffsetNotifier.value = false;
        _updateBySimulation(effectivePosition, 0);
      }
    } else {
      if (duration == null) {
        if (matchedController != null) {
          matchedController.jumpTo(scrollTo);
        } else {
          effectivePosition.jumpTo(scrollTo);
        }
      } else {
        userOffsetNotifier.value = true;
        if (matchedController != null) {
          await matchedController.animateTo(scrollTo,
              duration: duration, curve: curve);
        } else {
          await effectivePosition.animateTo(scrollTo,
              duration: duration, curve: curve);
        }
        userOffsetNotifier.value = false;
        notifyListeners();
      }
    }
  }
}
