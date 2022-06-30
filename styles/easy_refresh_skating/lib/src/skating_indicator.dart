part of easy_refresh_skating;

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
    Key? key,
    required this.state,
    required this.reverse,
  }) : super(key: key);

  @override
  State<_SkatingIndicator> createState() => _SkatingIndicatorState();
}

class _SkatingIndicatorState extends State<_SkatingIndicator> {
  StateMachineController? _controller;
  late SMIInput<double>? _pullAmountInput;
  late SMITrigger? _pullReleaseTrigger;
  late SMITrigger? _loadFinishedTrigger;

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _SkatingIndicator oldWidget) {
    if (_offset < _actualTriggerOffset) {
      _pullAmountInput?.value = _offset / _actualTriggerOffset * 100;
    } else {
      _pullAmountInput?.value = 100;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onRiveInit(Artboard artboard) {
    _controller?.dispose();
    _controller = StateMachineController.fromArtboard(artboard, 'Reload')!;
    artboard.addController(_controller!);
    _pullAmountInput = _controller!.findInput<double>('pullAmount')!;
    _pullReleaseTrigger =
        _controller!.findInput<bool>('pullRelease')! as SMITrigger;
    _loadFinishedTrigger =
        _controller!.findInput<bool>('loadFinished')! as SMITrigger;
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.ready || mode == IndicatorMode.processing) {
      if (!_pullReleaseTrigger!.value) {
        _pullReleaseTrigger!.fire();
      }
    } else {
      if (_pullReleaseTrigger!.value) {
        _pullReleaseTrigger!.advance();
      }
    }
    if (mode == IndicatorMode.processed) {
      if (!_loadFinishedTrigger!.value) {
        _loadFinishedTrigger!.fire();
      }
    } else {
      if (_loadFinishedTrigger!.value) {
        _loadFinishedTrigger!.advance();
      }
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
            width: double.infinity,
            height: _offset < 140 ? 140 : _offset,
            child: _offset == 0 && _mode == IndicatorMode.inactive
                ? const SizedBox()
                : RiveAnimation.asset(
                    'packages/easy_refresh_skating/assets/skating.riv',
                    fit: BoxFit.cover,
                    onInit: _onRiveInit,
                    antialiasing: false,
                  ),
          ),
        ),
      ],
    );
  }
}
