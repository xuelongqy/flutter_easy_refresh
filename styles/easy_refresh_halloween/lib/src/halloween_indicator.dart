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
  late SimpleAnimation _pullController;
  late SimpleAnimation _triggerController;
  late SimpleAnimation _loadingController;

  double get _offset => widget.state.offset;

  bool _reset = true;

  IndicatorMode get _mode => widget.state.mode;

  @override
  void initState() {
    super.initState();
    _pullController = SimpleAnimation(
      'Pull',
      autoplay: true,
    );
    _triggerController = _OneShotCustomAnimation(
      'Trigger',
      autoplay: false,
      onStop: () {
        _loadingController.isActive = true;
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
    if (mode == IndicatorMode.inactive) {
      _reset = true;
      if (_loadingController.isActive) {
        _loadingController.isActive = false;
      }
      _triggerController.reset();
      _loadingController.reset();
    } else {
      if (_reset) {
        _reset = false;
        _pullController.isActive = true;
      }
    }
    if (mode == IndicatorMode.ready) {
      _triggerController.isActive = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _offset,
      child: _offset == 0 && _mode == IndicatorMode.inactive
          ? const SizedBox()
          : RiveAnimation.asset(
              'packages/easy_refresh_halloween/assets/halloween.riv',
              controllers: [
                _pullController,
                _triggerController,
                _loadingController,
              ],
              fit: BoxFit.cover,
            ),
    );
  }
}

T? _ambiguate<T>(T? value) => value;

class _OneShotCustomAnimation extends SimpleAnimation {
  /// Fires when the animation stops being active
  final VoidCallback? onStop;

  /// Fires when the animation starts being active
  final VoidCallback? onStart;

  _OneShotCustomAnimation(
    String animationName, {
    double mix = 1,
    bool autoplay = true,
    this.onStop,
    this.onStart,
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
    isActive
        ? onStart?.call()
        // onStop can fire while widgets are still drawing
        : _ambiguate(WidgetsBinding.instance)
            ?.addPostFrameCallback((_) => onStop?.call());
  }
}
