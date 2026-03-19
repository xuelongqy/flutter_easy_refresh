part of '../easy_refresh_halloween.dart';

const _kDefaultHalloweenTriggerOffset = 200.0;

/// Custom painter for Halloween animations.
base class _HalloweenPainter extends BasicArtboardPainter {
  _HalloweenPainter({super.fit});

  Animation? _pullAnimation;
  Animation? _triggerAnimation;
  Animation? _loadAnimation;

  bool _triggerActive = false;
  bool _triggerCompleted = false;
  bool _loadActive = false;

  VoidCallback? onTriggerComplete;

  @override
  void artboardChanged(Artboard artboard) {
    super.artboardChanged(artboard);
    _pullAnimation = artboard.animationNamed('Pull');
    _triggerAnimation = artboard.animationNamed('Trigger');
    _loadAnimation = artboard.animationNamed('Loading');
  }

  @override
  bool advance(double elapsedSeconds) {
    // Keep the artboard lifecycle running so manual Pull scrubbing is rendered
    // correctly before layering Trigger/Loading on top.
    bool needsRepaint = super.advance(elapsedSeconds);
    if (_triggerActive) {
      final playing =
          _triggerAnimation?.advanceAndApply(elapsedSeconds) ?? false;
      if (!playing && !_triggerCompleted) {
        _triggerCompleted = true;
        _triggerActive = false;
        onTriggerComplete?.call();
      }
      needsRepaint = true;
    }
    if (_loadActive) {
      _loadAnimation?.advanceAndApply(elapsedSeconds);
      needsRepaint = true;
    }
    return needsRepaint;
  }

  void applyPull(double scale) {
    final anim = _pullAnimation;
    if (anim == null) return;
    // Match the old runtime behavior: scrub Pull by absolute time instead of
    // advancing it like a continuously playing animation.
    anim.time = scale;
    anim.apply();
    scheduleRepaint();
  }

  void startTrigger() {
    if (_triggerActive) return;
    _triggerActive = true;
    _triggerCompleted = false;
    _triggerAnimation?.time = 0;
    notifyListeners();
  }

  void stopTrigger() {
    _triggerActive = false;
    _triggerCompleted = false;
    _triggerAnimation?.time = 0;
    _triggerAnimation?.apply();
    notifyListeners();
  }

  void startLoad() {
    _loadActive = true;
    notifyListeners();
  }

  void stopLoad() {
    _loadActive = false;
    _loadAnimation?.time = 0;
    _loadAnimation?.apply();
    notifyListeners();
  }

  void reset() {
    _triggerActive = false;
    _triggerCompleted = false;
    _loadActive = false;
    _triggerAnimation?.time = 0;
    _triggerAnimation?.apply();
    _loadAnimation?.time = 0;
    _loadAnimation?.apply();
    notifyListeners();
  }
}

/// Halloween indicator.
/// Base widget for [HalloweenHeader] and [HalloweenFooter].
class _HalloweenIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const _HalloweenIndicator({
    super.key,
    required this.state,
    required this.reverse,
  });

  @override
  State<_HalloweenIndicator> createState() => _HalloweenIndicatorState();
}

class _HalloweenIndicatorState extends State<_HalloweenIndicator> {
  File? _file;
  Artboard? _artboard;
  late final _HalloweenPainter _painter;

  double get _offset => widget.state.offset;

  IndicatorMode get _mode => widget.state.mode;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    _painter = _HalloweenPainter(fit: Fit.cover);
    _painter.onTriggerComplete = () {
      if (_mode == IndicatorMode.processing) {
        _painter.startLoad();
      }
    };
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _initRive();
  }

  Future<void> _initRive() async {
    final file = await File.asset(
      'packages/easy_refresh_halloween/assets/halloween.riv',
      riveFactory: Factory.rive,
    );
    if (!mounted || file == null) return;
    _file = file;
    _artboard = file.defaultArtboard();
    if (mounted) setState(() {});
  }

  void _resetArtboard() {
    final file = _file;
    if (file == null) {
      return;
    }
    final previousArtboard = _artboard;
    final nextArtboard = file.defaultArtboard();
    if (nextArtboard == null) {
      return;
    }
    // Recreate the artboard to get back to the file's default visual state
    // after the loading sequence fully collapses.
    setState(() {
      _artboard = nextArtboard;
    });
    if (previousArtboard != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        previousArtboard.dispose();
      });
    }
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _painter.dispose();
    _artboard?.dispose();
    _file?.dispose();
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.ready) {
      _painter.startTrigger();
      return;
    }
    if (mode == IndicatorMode.drag || mode == IndicatorMode.armed) {
      _painter.stopTrigger();
    }
    if (mode == IndicatorMode.inactive) {
      _painter.reset();
      _resetArtboard();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final artboard = _artboard;
    if (artboard != null) {
      if (_mode == IndicatorMode.drag || _mode == IndicatorMode.armed) {
        final scale = (_offset / _actualTriggerOffset).clamp(0.0, 1.0);
        if (scale > 0) {
          _painter.applyPull(scale);
        }
      }
    }
    return SizedBox(
      width: double.infinity,
      height: _offset,
      child: artboard != null
          ? RiveArtboardWidget(
              artboard: artboard,
              painter: _painter,
            )
          : const SizedBox(),
    );
  }
}
