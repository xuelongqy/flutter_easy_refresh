part of easy_refresh_halloween;

const _kDefaultHalloweenTriggerOffset = 200.0;

/// Halloween indicator.
/// Base widget for [HalloweenHeader] and [HalloweenFooter].
class _HalloweenIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const _HalloweenIndicator({
    Key? key,
    required this.state,
    required this.reverse,
  }) : super(key: key);

  @override
  State<_HalloweenIndicator> createState() => _HalloweenIndicatorState();
}

class _HalloweenIndicatorState extends State<_HalloweenIndicator> {
  RuntimeArtboard? _artboard;
  late SimpleAnimation _pullController;
  late SimpleAnimation _triggerController;
  late SimpleAnimation _loadingController;

  double get _offset => widget.state.offset;

  IndicatorMode get _mode => widget.state.mode;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    _pullController = OneShotAnimation(
      'Pull',
      autoplay: false,
    );
    _triggerController = _OneShotCustomAnimation(
      'Trigger',
      autoplay: false,
      onStop: () {
        if (_mode == IndicatorMode.processing) {
          _loadingController.isActive = true;
        }
      },
    );
    _loadingController = SimpleAnimation(
      'Loading',
      autoplay: false,
    );
    widget.state.notifier.addModeChangeListener(_onModeChange);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _pullController.dispose();
    _triggerController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.ready) {
      if (!_triggerController.isActive) {
        _triggerController.isActive = true;
      }
      return;
    }
    if (mode == IndicatorMode.drag || mode == IndicatorMode.armed) {
      if (_triggerController.isActive) {
        _triggerController.isActive = false;
      }
      _triggerController.reset();
      _triggerController.instance?.animation.apply(0, coreContext: _artboard!);
    }
    if (mode == IndicatorMode.inactive) {
      _loadingController.isActive = false;
      _loadingController.reset();
      _loadingController.instance?.animation.apply(0, coreContext: _artboard!);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard != null) {
      if (_mode == IndicatorMode.drag || _mode == IndicatorMode.armed) {
        final scale = (_offset / _actualTriggerOffset).clamp(0.0, 1.0);
        _pullController.instance?.animation
            .apply(scale, coreContext: _artboard!);
      }
    }
    return SizedBox(
      width: double.infinity,
      height: _offset,
      child: RiveAnimation.asset(
        'packages/easy_refresh_halloween/assets/halloween.riv',
        controllers: [
          _pullController,
          _triggerController,
          _loadingController,
        ],
        fit: BoxFit.cover,
        onInit: (artboard) {
          if (artboard is RuntimeArtboard) {
            _artboard = artboard;
          }
        },
      ),
    );
  }
}

class _OneShotCustomAnimation extends SimpleAnimation {
  /// Fires when the animation stops being active
  final VoidCallback? onStop;

  _OneShotCustomAnimation(
    String animationName, {
    double mix = 1,
    bool autoplay = true,
    this.onStop,
  }) : super(animationName, mix: mix, autoplay: autoplay) {
    isActiveChanged.addListener(onActiveChanged);
  }

  /// Dispose of any callback listeners
  @override
  void dispose() {
    super.dispose();
    isActiveChanged.removeListener(onActiveChanged);
  }

  /// Perform tasks when the animation's active state changes
  void onActiveChanged() {
    // Fire any callbacks
    if (!isActive) {
      reset();
      onStop?.call();
    }
  }
}
