part of easy_refresh_bubbles;

const _kDefaultBubblesTriggerOffset = 180.0;

const _kBubblesProcessed = Duration(seconds: 1);

/// Bubbles indicator.
/// Base widget for [BubblesHeader] and [BubblesFooter].
class _BubblesIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const _BubblesIndicator({
    Key? key,
    required this.state,
    required this.reverse,
  }) : super(key: key);

  @override
  State<_BubblesIndicator> createState() => _BubblesIndicatorState();
}

class _BubblesIndicatorState extends State<_BubblesIndicator>
    with SingleTickerProviderStateMixin {
  StateMachineController? _controller;
  SMIInput<double>? _numDragInput;
  SMIInput<double>? _numLoadInput;
  late final AnimationController _loadController;

  int _key = 0;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  IndicatorMode get _mode => widget.state.mode;

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadController.addListener(_onLoadChanged);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _controller?.dispose();
    _loadController.removeListener(_onLoadChanged);
    _loadController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _BubblesIndicator oldWidget) {
    if (_numDragInput != null) {
      if (_offset < _actualTriggerOffset / 7 * 4) {
        _numDragInput?.value = 0;
      } else if (_offset < _actualTriggerOffset) {
        _numDragInput?.value = (_offset - (_actualTriggerOffset / 7 * 4)) /
            (_actualTriggerOffset / 7 * 3) *
            99;
      } else {
        _numDragInput?.value = _mode == IndicatorMode.processing ? 100 : 99;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onRiveInit(Artboard artboard) {
    _controller?.dispose();
    _controller = StateMachineController.fromArtboard(artboard, 'Motion')!;
    artboard.addController(_controller!);
    _numDragInput = _controller!.findInput<double>('numDrag')!;
    _numLoadInput = _controller!.findInput<double>('numLoad')!;
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.processing) {
      if (!_loadController.isAnimating) {
        _loadController.forward(from: 0);
      }
    }
    if (mode == IndicatorMode.processed) {
      if (_loadController.isAnimating) {
        _loadController.stop();
      }
      _numLoadInput?.value = 100;
    }
    if (mode == IndicatorMode.inactive) {
      setState(() {
        _key++;
      });
    }
  }

  void _onLoadChanged() {
    _numLoadInput?.value = _loadController.value * 99;
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
            height:
                _offset < _actualTriggerOffset ? _actualTriggerOffset : _offset,
            child: RiveAnimation.asset(
              'packages/easy_refresh_bubbles/assets/bubbles.riv',
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
