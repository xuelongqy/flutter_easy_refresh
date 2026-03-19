part of '../easy_refresh_skating.dart';

const _kDefaultSkatingTriggerOffset = 180.0;

const _kSkatingProcessed = Duration(milliseconds: 700);

/// Skating indicator.
/// Base widget for [SkatingHeader] and [SkatingFooter].
class _SkatingIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const _SkatingIndicator({
    super.key,
    required this.state,
    required this.reverse,
  });

  @override
  State<_SkatingIndicator> createState() => _SkatingIndicatorState();
}

class _SkatingIndicatorState extends State<_SkatingIndicator> {
  File? _file;
  RiveWidgetController? _riveController;
  NumberInput? _pullAmountInput;
  TriggerInput? _pullReleaseTrigger;
  TriggerInput? _loadFinishedTrigger;
  bool _pullReleaseFired = false;
  bool _loadFinishedFired = false;

  int _key = 0;

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
      'packages/easy_refresh_skating/assets/skating.riv',
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
    _pullReleaseTrigger?.dispose();
    _loadFinishedTrigger?.dispose();
    _riveController?.dispose();
    _riveController = RiveWidgetController(
      file,
      stateMachineSelector: StateMachineNamed('Reload'),
    );
    _pullAmountInput = _riveController!.stateMachine.number('pullAmount');
    _pullReleaseTrigger = _riveController!.stateMachine.trigger('pullRelease');
    _loadFinishedTrigger =
        _riveController!.stateMachine.trigger('loadFinished');
    _pullReleaseFired = false;
    _loadFinishedFired = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _pullAmountInput?.dispose();
    _pullReleaseTrigger?.dispose();
    _loadFinishedTrigger?.dispose();
    _riveController?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SkatingIndicator oldWidget) {
    if (_pullAmountInput != null) {
      if (_offset < _actualTriggerOffset) {
        _pullAmountInput?.value = _offset / _actualTriggerOffset * 100;
      } else {
        _pullAmountInput?.value = 100;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.ready || mode == IndicatorMode.processing) {
      if (!_pullReleaseFired) {
        _pullReleaseTrigger?.fire();
        _pullReleaseFired = true;
      }
    } else {
      _pullReleaseFired = false;
    }
    if (mode == IndicatorMode.processed) {
      if (!_loadFinishedFired) {
        _loadFinishedTrigger?.fire();
        _loadFinishedFired = true;
      }
    } else {
      _loadFinishedFired = false;
    }
    if (mode == IndicatorMode.inactive) {
      setState(() {
        _key++;
      });
      _setupController();
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
            height: _offset < 140 ? 140 : _offset,
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
