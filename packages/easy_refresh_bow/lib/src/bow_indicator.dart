part of '../easy_refresh_bow.dart';

const _kDefaultBowTriggerOffset = 200.0;
const _kBowPullMinValue = 10.0;
const _kBowSpring = physics.SpringDescription(
  mass: 1,
  stiffness: 700,
  damping: 63.5,
);

/// Bow indicator.
/// Base widget for [BowHeader] and [BowFooter].
class _BowIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const _BowIndicator({
    super.key,
    required this.state,
    required this.reverse,
  });

  @override
  State<_BowIndicator> createState() => _BowIndicatorState();
}

class _BowIndicatorState extends State<_BowIndicator> {
  File? _file;
  RiveWidgetController? _riveController;
  NumberInput? _pullInput;
  TriggerInput? _advanceTrigger;
  TriggerInput? _restartTrigger;

  int _key = 0;
  int _advanceStep = 0;

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double _resolvePullValue(double offset) {
    final progress = (offset / _kDefaultBowTriggerOffset).clamp(0.0, 1.0);
    if (progress == 0) return 0;
    return _kBowPullMinValue + progress * (100 - _kBowPullMinValue);
  }

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _initRive();
  }

  Future<void> _initRive() async {
    final file = await File.asset(
      'packages/easy_refresh_bow/assets/bow.riv',
      riveFactory: Factory.rive,
    );
    if (!mounted || file == null) return;
    _file = file;
    _setupController();
  }

  void _setupController() {
    final file = _file;
    if (file == null) return;
    _pullInput?.dispose();
    _advanceTrigger?.dispose();
    _restartTrigger?.dispose();
    _riveController?.dispose();
    _riveController = RiveWidgetController(
      file,
      stateMachineSelector: StateMachineNamed('numberSimulation'),
    );
    // ignore: deprecated_member_use
    _pullInput = _riveController!.stateMachine.number('pull');
    // ignore: deprecated_member_use
    _advanceTrigger = _riveController!.stateMachine.trigger('advance');
    // ignore: deprecated_member_use
    _restartTrigger = _riveController!.stateMachine.trigger('restart');
    _advanceStep = 0;
    _setPull(0);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _pullInput?.dispose();
    _advanceTrigger?.dispose();
    _restartTrigger?.dispose();
    _riveController?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _BowIndicator oldWidget) {
    if (_mode == IndicatorMode.drag ||
        _mode == IndicatorMode.armed ||
        _mode == IndicatorMode.ready ||
        _mode == IndicatorMode.done) {
      _setPull(_resolvePullValue(_offset));
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setPull(double value) {
    _pullInput?.value = value;
  }

  void _resetController() {
    _setPull(0);
    _restartTrigger?.fire();
    setState(() {
      _key++;
    });
    _setupController();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.drag || mode == IndicatorMode.armed) {
      _setPull(_resolvePullValue(offset));
      return;
    }
    if (mode == IndicatorMode.ready) {
      _setPull(100);
      return;
    }
    if (mode == IndicatorMode.processing) {
      _setPull(100);
      if (_advanceStep == 0) {
        _advanceTrigger?.fire();
        _advanceStep = 1;
      }
      return;
    }
    if (mode == IndicatorMode.processed) {
      _setPull(100);
      if (_advanceStep == 1) {
        _advanceTrigger?.fire();
        _advanceStep = 2;
      }
      return;
    }
    if (mode == IndicatorMode.done) {
      _setPull(100);
      return;
    }
    if (mode == IndicatorMode.inactive) {
      _resetController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final indicatorHeight = _offset < _kDefaultBowTriggerOffset
        ? _kDefaultBowTriggerOffset
        : _offset;
    final indicatorTop = (_offset - indicatorHeight) / 2;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: _offset,
        ),
        Positioned(
          top: indicatorTop,
          left: 0,
          right: 0,
          child: SizedBox(
            key: ValueKey(_key),
            width: double.infinity,
            height: indicatorHeight,
            child: _riveController != null
                ? RiveWidget(
                    controller: _riveController!,
                    fit: Fit.fitWidth,
                    alignment: Alignment.center,
                  )
                : const SizedBox(),
          ),
        ),
      ],
    );
  }
}
