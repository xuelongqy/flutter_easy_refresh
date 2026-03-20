part of '../easy_refresh_space.dart';

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
    super.key,
    required this.state,
    required this.reverse,
  });

  @override
  State<_SpaceIndicator> createState() => _SpaceIndicatorState();
}

class _SpaceIndicatorState extends State<_SpaceIndicator> {
  File? _file;
  RiveWidgetController? _riveController;
  NumberInput? _pullAmountInput;
  dynamic _startInput;

  int _key = 0;
  bool _startActive = false;

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _initRive();
  }

  Future<void> _initRive() async {
    final file = await File.asset(
      'packages/easy_refresh_space/assets/space_reload.riv',
      riveFactory: Factory.rive,
    );
    if (!mounted || file == null) return;
    _file = file;
    _setupController();
  }

  void _setupController() {
    final file = _file;
    if (file == null) return;
    _pullAmountInput?.dispose();
    _startInput?.dispose();
    _riveController?.dispose();
    _riveController = RiveWidgetController(
      file,
      stateMachineSelector: StateMachineNamed('Reload'),
    );
    // ignore: deprecated_member_use
    _pullAmountInput = _riveController!.stateMachine.number('Pull Amount');
    // ignore: deprecated_member_use
    _startInput = _riveController!.stateMachine.boolean('Start');
    _startActive = false;
    _setPullAmount(0);
    _setStart(false);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _pullAmountInput?.dispose();
    _startInput?.dispose();
    _riveController?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SpaceIndicator oldWidget) {
    if (_mode == IndicatorMode.drag ||
        _mode == IndicatorMode.armed ||
        _mode == IndicatorMode.ready ||
        _mode == IndicatorMode.done) {
      final scale = (_offset / _actualTriggerOffset).clamp(0.0, 1.0);
      _setPullAmount(scale * 100);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setPullAmount(double value) {
    _pullAmountInput?.value = value;
  }

  void _setStart(bool value) {
    if (_startActive == value) return;
    _startActive = value;
    _startInput?.value = value;
  }

  void _resetController() {
    _setStart(false);
    _setPullAmount(0);
    setState(() {
      _key++;
    });
    _setupController();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.drag || mode == IndicatorMode.armed) {
      final scale = (offset / _actualTriggerOffset).clamp(0.0, 1.0);
      _setStart(false);
      _setPullAmount(scale * 100);
      return;
    }
    if (mode == IndicatorMode.ready) {
      _setPullAmount(100);
      _setStart(true);
      return;
    }
    if (mode == IndicatorMode.processing || mode == IndicatorMode.processed) {
      _setPullAmount(100);
      _setStart(true);
      return;
    }
    if (mode == IndicatorMode.done) {
      _setPullAmount(100);
      return;
    }
    if (mode == IndicatorMode.inactive) {
      _resetController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: _offset,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            key: ValueKey(_key),
            width: double.infinity,
            height: _offset < _kDefaultSpaceTriggerOffset
                ? _kDefaultSpaceTriggerOffset
                : _offset,
            child: _riveController != null
                ? RiveWidget(
                    controller: _riveController!,
                    fit: Fit.cover,
                  )
                : const SizedBox(),
          ),
        ),
      ],
    );
  }
}
