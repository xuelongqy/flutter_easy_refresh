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

/// Indicator data and trigger notification.
abstract class IndicatorNotifier extends ChangeNotifier {
  /// Used to provide [clamping] animation.
  final TickerProvider vsync;

  /// The offset of the trigger task.
  final double triggerOffset;

  /// User triggered notifier.
  /// Record user triggers and releases.
  @protected
  final ValueNotifier<bool> userOffsetNotifier;

  /// Hold to keep the [Scrollable] from going out of bounds.
  final bool clamping;

  /// Whether to calculate the safe area.
  final bool safeArea;

  /// Task completion delay.
  /// [IndicatorMode.processed] duration of state.
  final Duration processedDuration;

  /// Structure that describes a spring's constants.
  final SpringDescription? _spring;

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

  IndicatorNotifier({
    required this.triggerOffset,
    required this.clamping,
    required this.userOffsetNotifier,
    required this.vsync,
    this.processedDuration = const Duration(seconds: 1),
    this.safeArea = true,
    SpringDescription? spring,
    this.infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    this.useLocator = false,
  })  : _spring = spring,
        hitOver = hitOver ?? infiniteOffset != null,
        infiniteHitOver = infiniteHitOver ?? infiniteOffset == null,
        assert(infiniteOffset == null || infiniteOffset >= 0,
            'The infiniteOffset cannot be smaller than 0.'),
        assert(infiniteOffset == null || !clamping,
            'Cannot scroll indefinitely when clamping.'),
        assert(!clamping || !useLocator, 'Cannot use locator when clamping.') {
    _initClampingAnimation();
    userOffsetNotifier.addListener(_onUserOffset);
  }

  /// 方向
  Axis? _axis;

  Axis? get axis => _axis;

  AxisDirection? _axisDirection;

  AxisDirection? get axisDirection => _axisDirection;

  /// 安全偏移量
  /// 参考[SafeArea]
  /// 用于解决安全区域被遮挡问题
  /// 最终触发偏移量为[triggerOffset] + [safeOffset]
  double? _safeOffset;

  double get safeOffset => safeArea ? _safeOffset ?? 0 : 0;

  /// 偏移量
  double _offset = 0;

  double get offset => _offset;

  /// 位置
  late ScrollMetrics _position;

  /// 状态
  IndicatorMode _mode = IndicatorMode.inactive;

  IndicatorMode get mode => _mode;

  /// 动画控制器
  /// [clamping]为true时，用到
  AnimationController? _clampingAnimationController;

  /// 滚动物理形式
  late _ERScrollPhysics _physics;

  /// 最终触发偏移量
  /// [triggerOffset] + [safeOffset]
  double get actualTriggerOffset => triggerOffset + safeOffset;

  /// 列表越界范围
  double get overExtent {
    if (infiniteOffset != null || _mode == IndicatorMode.ready || modeLocked) {
      return actualTriggerOffset;
    }
    return 0;
  }

  /// 状态锁定
  bool get modeLocked =>
      _mode == IndicatorMode.processing || _mode == IndicatorMode.processed;

  /// 获取弹性属性
  SpringDescription get spring => _spring ?? _physics.spring;

  /// 监听提供器
  ValueListenable<IndicatorNotifier> listenable() => _IndicatorListenable(this);

  /// [clamping]动画监听器
  void _clampingTick();

  /// 计算偏移量
  double _calculateOffset(ScrollMetrics position, double value);

  /// 无限滚动排除条件
  bool infiniteExclude(ScrollMetrics position, double value);

  @override
  void dispose() {
    super.dispose();
    _clampingAnimationController?.dispose();
    userOffsetNotifier.removeListener(_onUserOffset);
  }

  /// 初始化[clamping]动画控制器
  void _initClampingAnimation() {
    if (clamping) {
      _clampingAnimationController = AnimationController.unbounded(
        vsync: vsync,
      );
      _clampingAnimationController!.addListener(_clampingTick);
    }
  }

  /// 监听用户事件
  void _onUserOffset() {
    if (userOffsetNotifier.value) {
      // clamping
      // 取消动画，更新偏移量
      if (clamping && _clampingAnimationController!.isAnimating) {
        _clampingAnimationController!.stop(canceled: true);
      }
    }
  }

  /// 绑定物理形式
  void _bindPhysics(_ERScrollPhysics physics) {
    _physics = physics;
  }

  /// 创建回弹模拟
  /// [clamping]使用
  Simulation? _createBallisticSimulation(
      ScrollMetrics position, double velocity);

  /// 计算边界距离
  double get boundaryOffset;

  /// 模拟器更新
  void _updateBySimulation(ScrollMetrics position, double velocity) {
    _position = position;
    // 更新方向
    if (_axis != position.axis || _axisDirection != position.axisDirection) {
      _axis = position.axis;
      _axisDirection = position.axisDirection;
    }
    // 更新释放时的偏移量
    _updateOffset(position, position.pixels, true);
    // 如果为clamping，且offset大于0，则开始动画
    if (clamping && _offset > 0 && !modeLocked) {
      final simulation = _createBallisticSimulation(position, velocity);
      if (simulation != null) {
        _startClampingAnimation(simulation);
      }
    }
  }

  /// 更新偏移量
  void _updateOffset(ScrollMetrics position, double value, bool bySimulation) {
    // clamping
    // 在任务处理中，不做任何处理
    if (clamping && modeLocked) {
      return;
    }
    // clamping
    // 在释放情况下，且offset大于0，则由动画控制
    if (!userOffsetNotifier.value && clamping && _offset > 0 && !bySimulation) {
      return;
    }
    _position = position;
    // 记录旧状态
    final oldOffset = _offset;
    final oldMode = _mode;
    // 更新偏移量
    _offset = _calculateOffset(position, value);
    // 如果没有越界则不操作
    if (oldOffset == 0 && _offset == 0) {
      // 处理无限滚动
      if (infiniteOffset != null &&
          (boundaryOffset < infiniteOffset! || _mode == IndicatorMode.done) &&
          !bySimulation &&
          !infiniteExclude(position, value)) {
        // 更新状态
        _updateMode();
        notifyListeners();
      }
      return;
    }
    // 更新状态
    _updateMode();
    // 是否需要通知
    if (oldOffset == _offset && oldMode == _mode) {
      return;
    }
    // 避免绘制过程中setState()
    if (bySimulation) {
      // 当列表长度变更时，通知
      if (offset < actualTriggerOffset) {
        Future(() {
          notifyListeners();
        });
      }
      return;
    }
    notifyListeners();
  }

  /// 更新状态
  void _updateMode() {
    // 任务执行中和任务完成中不更新
    if (!modeLocked) {
      // 无限滚动
      if (infiniteOffset != null && boundaryOffset < infiniteOffset!) {
        if (_mode == IndicatorMode.done &&
            _position.maxScrollExtent != _position.minScrollExtent) {
          // 没结束前状态不改变
          return;
        } else {
          _mode = IndicatorMode.processing;
          return;
        }
      }
      if (_mode == IndicatorMode.done && offset > 0) {
        // 没结束前状态不改变
        return;
      } else if (_offset == 0) {
        _mode = IndicatorMode.inactive;
      } else if (_offset < actualTriggerOffset) {
        _mode = IndicatorMode.drag;
      } else if (_offset == actualTriggerOffset) {
        // 必须超过才能触发任务
        _mode = _mode != IndicatorMode.ready
            ? IndicatorMode.armed
            : IndicatorMode.processing;
      } else if (_offset > actualTriggerOffset) {
        // 如果是用户在滑动(未释放则不执行任务)
        _mode = userOffsetNotifier.value
            ? IndicatorMode.armed
            : IndicatorMode.ready;
      }
    }
  }

  /// 开始[clamping]动画
  void _startClampingAnimation(Simulation simulation) {
    if (_offset <= 0) {
      return;
    }
    _clampingAnimationController!.animateWith(simulation);
  }

  /// 设置状态
  void _setMode(IndicatorMode mode) {
    if (_mode == mode) {
      return;
    }
    final oldMode = _mode;
    _mode = mode;
    notifyListeners();
    // 完成任务
    if (this.mode == IndicatorMode.processed) {
      // 完成延时
      if (processedDuration == Duration.zero) {
        _mode = IndicatorMode.done;
        // 触发列表回滚
        if (oldMode == IndicatorMode.processing &&
            _position is ScrollActivityDelegate &&
            !userOffsetNotifier.value) {
          (_position as ScrollActivityDelegate).goBallistic(0);
        }
      } else {
        Future.delayed(processedDuration, () {
          _setMode(IndicatorMode.done);
          // 触发列表回滚
          if (_position is ScrollActivityDelegate &&
              !userOffsetNotifier.value) {
            (_position as ScrollActivityDelegate).goBallistic(0);
          }
        });
      }
      // 如果用户未释放，则主动更新偏移量
      if (!clamping && userOffsetNotifier.value) {
        Future(() {
          _updateOffset(_position, 0, false);
        });
      }
    }
  }
}

/// 指示器监听提供器
class _IndicatorListenable<T extends IndicatorNotifier>
    extends ValueListenable<T> {
  /// 指示通知器
  final T indicatorNotifier;

  _IndicatorListenable(this.indicatorNotifier);

  final List<VoidCallback> _listeners = [];

  /// 监听通知
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

/// Header通知器
class HeaderNotifier extends IndicatorNotifier {
  HeaderNotifier({
    required double triggerOffset,
    required bool clamping,
    required ValueNotifier<bool> userOffsetNotifier,
    required TickerProvider vsync,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool useLocator = false,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          userOffsetNotifier: userOffsetNotifier,
          vsync: vsync,
          processedDuration: processedDuration,
          spring: spring,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          useLocator: useLocator,
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
        // 回收先减去偏移量
        return math.max(_offset > 0 ? (-value + _offset) : 0, 0);
      } else {
        // 越界累加偏移量
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
  bool infiniteExclude(ScrollMetrics position, double value) {
    return value >= position.maxScrollExtent;
  }
}

/// Footer通知器
class FooterNotifier extends IndicatorNotifier {
  FooterNotifier({
    required double triggerOffset,
    required bool clamping,
    required ValueNotifier<bool> userOffsetNotifier,
    required TickerProvider vsync,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset = 0,
    bool? hitOver,
    bool? infiniteHitOver,
    bool useLocator = false,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          userOffsetNotifier: userOffsetNotifier,
          vsync: vsync,
          processedDuration: processedDuration,
          spring: spring,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          useLocator: useLocator,
        );

  @override
  double _calculateOffset(ScrollMetrics position, double value) {
    if (value <= position.maxScrollExtent &&
        _offset != 0 &&
        !(clamping && _offset > 0)) {
      return 0;
    }
    // 移动量
    final move = value - position.maxScrollExtent;
    if (clamping) {
      if (value < position.maxScrollExtent) {
        // 回收先减去偏移量
        return math.max(_offset > 0 ? (move + _offset) : 0, 0);
      } else {
        // 越界累加偏移量
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
  bool infiniteExclude(ScrollMetrics position, double value) {
    return value <= position.minScrollExtent;
  }
}
