part of easy_refresh_squats;

const _kDefaultSquatsTriggerOffset = 190.0;

/// Squats indicator.
/// Base widget for [SquatsHeader] and [SquatsFooter].
class _SquatsIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  /// Background color.
  final Color? backgroundColor;

  const _SquatsIndicator({
    Key? key,
    required this.state,
    required this.reverse,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<_SquatsIndicator> createState() => _SquatsIndicatorState();
}

class _SquatsIndicatorState extends State<_SquatsIndicator> {
  late SimpleAnimation _idleController;
  late SimpleAnimation _squatsController;

  double get _offset => widget.state.offset;

  @override
  void initState() {
    super.initState();
    _idleController = SimpleAnimation('Idle');
    _squatsController = SimpleAnimation('Demo');
    widget.state.notifier.addModeChangeListener(_onModeChange);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _idleController.dispose();
    _squatsController.dispose();
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.processing ||
        mode == IndicatorMode.processed ||
        mode == IndicatorMode.done) {
      if (_idleController.isActive) {
        _idleController.isActive = false;
        _idleController.reset();
      }
      if (!_squatsController.isActive) {
        _squatsController.isActive = true;
      }
    } else {
      if (_squatsController.isActive) {
        _squatsController.isActive = false;
        _squatsController.reset();
      }
      if (!_idleController.isActive) {
        _idleController.isActive = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: _offset,
      color: widget.backgroundColor,
      child: SizedBox(
        width: _offset > 214 ? null : 214,
        height: _offset,
        child: RiveAnimation.asset(
          'packages/easy_refresh_squats/assets/lumberjack_squats.riv',
          controllers: [
            _squatsController,
            _idleController,
          ],
          fit: _offset > 214 ? BoxFit.fitHeight : BoxFit.fitWidth,
        ),
      ),
    );
  }
}
