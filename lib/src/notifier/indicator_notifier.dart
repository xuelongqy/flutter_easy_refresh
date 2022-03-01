part of easyrefresh;

/// Indicator data and trigger notification.
abstract class IndicatorNotifier extends ChangeNotifier {
  /// Refresh and loading Indicator.
  final Indicator indicator;

  /// Used to provide [clamping] animation.
  final TickerProvider vsync;

  /// User triggered notifier.
  /// Record user triggers and releases.
  @protected
  final ValueNotifier<bool> userOffsetNotifier;

  IndicatorNotifier({
    required this.indicator,
    required this.vsync,
    required this.userOffsetNotifier,
  }) {
    _initClampingAnimation();
    userOffsetNotifier.addListener(_onUserOffset);
  }

  double get triggerOffset => indicator.triggerOffset;

  bool get clamping => indicator.clamping;

  bool get safeArea => indicator.safeArea;

  Duration get processedDuration => indicator.processedDuration;

  double? get infiniteOffset => indicator.infiniteOffset;

  bool get hitOver => indicator.hitOver;

  bool get infiniteHitOver => indicator.infiniteHitOver;

  IndicatorPosition get iPosition => indicator.position;

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

  /// The current state of the indicator.
  IndicatorMode _mode = IndicatorMode.inactive;

  IndicatorMode get mode => _mode;

  /// Animation controller.
  /// Used when [clamping] is true.
  AnimationController? _clampingAnimationController;

  /// EasyRefresh scroll physics.
  late _ERScrollPhysics _physics;

  /// Actual trigger offset.
  /// [triggerOffset] + [safeOffset]
  double get actualTriggerOffset => triggerOffset + safeOffset;

  /// Keep the extent of the [Scrollable] out of bounds.
  double get overExtent {
    if (infiniteOffset != null || _mode == IndicatorMode.ready || modeLocked) {
      return actualTriggerOffset;
    }
    return 0;
  }

  /// Is the state locked.
  bool get modeLocked =>
      _mode == IndicatorMode.processing || _mode == IndicatorMode.processed;

  /// Spring description.
  SpringDescription? get _spring => indicator.spring;

  SpringDescription get spring => _spring ?? _physics.spring;

  /// Indicator listenable.
  ValueListenable<IndicatorNotifier> listenable() => _IndicatorListenable(this);

  /// Animation listener for [clamping].
  void _clampingTick();

  /// Calculate the overscroll offset.
  double _calculateOffset(ScrollMetrics position, double value);

  /// Infinite scroll exclusions.
  bool _infiniteExclude(ScrollMetrics position, double value);

  @override
  void dispose() {
    super.dispose();
    _clampingAnimationController?.dispose();
    userOffsetNotifier.removeListener(_onUserOffset);
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
      // clamping
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
  Simulation? _createBallisticSimulation(
      ScrollMetrics position, double velocity);

  /// Calculate distance from boundary
  double get boundaryOffset;

  /// Update by [ScrollPhysics.createBallisticSimulation].
  void _updateBySimulation(ScrollMetrics position, double velocity) {
    _position = position;
    // Update axis and direction.
    if (_axis != position.axis || _axisDirection != position.axisDirection) {
      _axis = position.axis;
      _axisDirection = position.axisDirection;
    }
    // Update offset on release
    _updateOffset(position, position.pixels, true);
    // If clamping is true and offset is greater than 0, start animation
    if (clamping && _offset > 0 && !modeLocked) {
      final simulation = _createBallisticSimulation(position, velocity);
      if (simulation != null) {
        _startClampingAnimation(simulation);
      }
    }
  }

  /// Update [Scrollable] offset
  void _updateOffset(ScrollMetrics position, double value, bool bySimulation) {
    // clamping
    // In task processing, do nothing.
    if (clamping && modeLocked) {
      return;
    }
    // clamping
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
    // Do nothing if not out of bounds.
    if (oldOffset == 0 && _offset == 0) {
      // Handling infinite scroll
      if (infiniteOffset != null &&
          (boundaryOffset < infiniteOffset! || _mode == IndicatorMode.done) &&
          !bySimulation &&
          !_infiniteExclude(position, value)) {
        // Update mode
        _updateMode();
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
    // Avoid setState() during drawing
    if (bySimulation) {
      // Notify when list length changes
      if (offset < actualTriggerOffset) {
        Future(() {
          notifyListeners();
        });
      }
      return;
    }
    notifyListeners();
  }

  /// Update indicator state
  void _updateMode() {
    // Not updated during task execution and task completion
    if (!modeLocked) {
      // Infinite scroll
      if (infiniteOffset != null && boundaryOffset < infiniteOffset!) {
        if (_mode == IndicatorMode.done &&
            _position.maxScrollExtent != _position.minScrollExtent) {
          // The state does not change until the end
          return;
        } else {
          _mode = IndicatorMode.processing;
          return;
        }
      }
      if (_mode == IndicatorMode.done && offset > 0) {
        // The state does not change until the end
        return;
      } else if (_offset == 0) {
        _mode = IndicatorMode.inactive;
      } else if (_offset < actualTriggerOffset) {
        _mode = IndicatorMode.drag;
      } else if (_offset == actualTriggerOffset) {
        // Must be exceeded to trigger the task
        _mode = _mode != IndicatorMode.ready
            ? IndicatorMode.armed
            : IndicatorMode.processing;
      } else if (_offset > actualTriggerOffset) {
        // If the user is scrolling
        // (the task is not executed if it is not released)
        _mode = userOffsetNotifier.value
            ? IndicatorMode.armed
            : IndicatorMode.ready;
      }
    }
  }

  /// Start [clamping] animation
  void _startClampingAnimation(Simulation simulation) {
    if (_offset <= 0) {
      return;
    }
    _clampingAnimationController!.animateWith(simulation);
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
          (_position as ScrollActivityDelegate).goBallistic(0);
        }
      } else {
        Future.delayed(processedDuration, () {
          _setMode(IndicatorMode.done);
          // Trigger [Scrollable] rollback
          if (_position is ScrollActivityDelegate &&
              !userOffsetNotifier.value) {
            (_position as ScrollActivityDelegate).goBallistic(0);
          }
        });
      }
      // Actively update the offset if the user does not release
      if (!clamping && userOffsetNotifier.value) {
        Future(() {
          _updateOffset(_position, 0, false);
        });
      }
    }
  }

  /// Build indicator widget.
  Widget _build(BuildContext context) {
    if (_axis == null || _axisDirection == null) {
      return const SizedBox();
    }
    return indicator.build(
      context,
      IndicatorState(
        indicator: indicator,
        mode: mode,
        offset: offset,
        safeOffset: safeOffset,
        axis: _axis!,
        axisDirection: _axisDirection!,
      ),
    );
  }
}

/// Indicator listenable.
/// Listen for property changes of the indicator.
/// Used to update widget.
class _IndicatorListenable<T extends IndicatorNotifier>
    extends ValueListenable<T> {
  /// Indicator notifier
  final T indicatorNotifier;

  _IndicatorListenable(this.indicatorNotifier);

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
      indicatorNotifier.addListener(_onNotify);
    }
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      indicatorNotifier.removeListener(_onNotify);
    }
  }

  @override
  T get value => indicatorNotifier;
}

/// [Header] notifier
/// [Header] status and Notifications
class HeaderNotifier extends IndicatorNotifier {
  HeaderNotifier({
    required Header header,
    required ValueNotifier<bool> userOffsetNotifier,
    required TickerProvider vsync,
  }) : super(
          indicator: header,
          userOffsetNotifier: userOffsetNotifier,
          vsync: vsync,
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
        // Rollback first minus offset
        return math.max(_offset > 0 ? (-value + _offset) : 0, 0);
      } else {
        // Overscroll accumulated offset
        return -value + _offset;
      }
    } else {
      return value > position.minScrollExtent ? 0 : -value;
    }
  }

  @override
  Simulation? _createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (clamping && _offset > 0) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels - _offset,
        velocity: velocity,
        leadingExtent: position.minScrollExtent - overExtent,
        trailingExtent: 0,
        tolerance: _physics.tolerance,
      );
    }
    return null;
  }

  @override
  void _clampingTick() {
    _offset = math.max(-_clampingAnimationController!.value, 0);
    _updateMode();
    notifyListeners();
  }

  @override
  double get boundaryOffset => _position.pixels;

  @override
  bool _infiniteExclude(ScrollMetrics position, double value) {
    return value >= position.maxScrollExtent;
  }
}

/// [Footer] notifier
/// [Footer] status and Notifications
class FooterNotifier extends IndicatorNotifier {
  FooterNotifier({
    required Footer footer,
    required ValueNotifier<bool> userOffsetNotifier,
    required TickerProvider vsync,
  }) : super(
          indicator: footer,
          userOffsetNotifier: userOffsetNotifier,
          vsync: vsync,
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
        return move + _offset;
      }
    } else {
      return value < position.maxScrollExtent ? 0 : move;
    }
  }

  @override
  Simulation? _createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (clamping && _offset > 0) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels + _offset,
        velocity: velocity,
        leadingExtent: 0,
        trailingExtent: position.maxScrollExtent + overExtent,
        tolerance: _physics.tolerance,
      );
    }
    return null;
  }

  @override
  void _clampingTick() {
    _offset = math.max(
        _clampingAnimationController!.value - _position.maxScrollExtent, 0);
    _updateMode();
    notifyListeners();
  }

  @override
  double get boundaryOffset => _position.maxScrollExtent - _position.pixels;

  @override
  bool _infiniteExclude(ScrollMetrics position, double value) {
    return value <= position.minScrollExtent;
  }
}
