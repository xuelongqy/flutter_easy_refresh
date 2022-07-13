part of easy_refresh_space;

const _kDefaultSpaceTriggerOffset = 180.0;

/// Space indicator.
/// Base widget for [SpaceHeader] and [SpaceFooter].
class _SpaceIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const _SpaceIndicator({
    Key? key,
    required this.state,
    required this.reverse,
  }) : super(key: key);

  @override
  State<_SpaceIndicator> createState() => _SpaceIndicatorState();
}

class _SpaceIndicatorState extends State<_SpaceIndicator> {
  RuntimeArtboard? _artboard;
  late SimpleAnimation _pullController;
  late SimpleAnimation _triggerController;
  late SimpleAnimation _loadingController;

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    _pullController = SimpleAnimation(
      'Pull',
      autoplay: false,
    );
    _triggerController = OneShotAnimation(
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
      _triggerController.isActive = true;
      return;
    }
    if (mode == IndicatorMode.drag || mode == IndicatorMode.armed) {
      if (_triggerController.isActive) {
        _triggerController.isActive = false;
        _triggerController.instance?.animation
            .apply(0, coreContext: _artboard!);
      }
    }
    if (mode == IndicatorMode.done) {
      _triggerController.isActive = false;
      _loadingController.isActive = false;
      return;
    }
    if (mode == IndicatorMode.inactive) {
      _loadingController.reset();
      _triggerController.reset();
      _triggerController.instance?.animation.apply(0, coreContext: _artboard!);
      _loadingController.instance?.animation.apply(0, coreContext: _artboard!);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard != null) {
      if (_mode == IndicatorMode.drag ||
          _mode == IndicatorMode.armed ||
          _mode == IndicatorMode.done) {
        final scale = (_offset / _actualTriggerOffset).clamp(0.0, 1.0);
        _pullController.instance?.animation
            .apply(scale, coreContext: _artboard!);
      }
    }
    return SizedBox(
      width: double.infinity,
      height: _offset,
      child: RiveAnimation.asset(
        'packages/easy_refresh_space/assets/space_reload.riv',
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
