part of '../easy_refresh_space.dart';

const _kDefaultSpaceTriggerOffset = 180.0;

/// Custom painter for Space animations.
base class _SpacePainter extends BasicArtboardPainter {
  _SpacePainter({super.fit});

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
    _loadActive = false;
    _triggerCompleted = false;
    _triggerAnimation?.time = 0;
    _triggerAnimation?.apply();
    _loadAnimation?.time = 0;
    _loadAnimation?.apply();
    notifyListeners();
  }
}

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
  Artboard? _artboard;
  late final _SpacePainter _painter;

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    _painter = _SpacePainter(fit: Fit.cover);
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
      'packages/easy_refresh_space/assets/space_reload.riv',
      riveFactory: Factory.rive,
    );
    if (!mounted || file == null) return;
    _file = file;
    _artboard = file.defaultArtboard();
    if (mounted) setState(() {});
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
    if (mode == IndicatorMode.done) {
      _painter.stopTrigger();
      _painter.stopLoad();
      return;
    }
    if (mode == IndicatorMode.inactive) {
      _painter.reset();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final artboard = _artboard;
    if (artboard != null) {
      if (_mode == IndicatorMode.drag ||
          _mode == IndicatorMode.armed ||
          _mode == IndicatorMode.done) {
        final scale = (_offset / _actualTriggerOffset).clamp(0.0, 1.0);
        _painter.applyPull(scale);
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
