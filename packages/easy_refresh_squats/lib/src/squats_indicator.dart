part of '../easy_refresh_squats.dart';

const _kDefaultSquatsTriggerOffset = 190.0;
const _kSquatsFitSwitchOffset = 214.0;

/// Custom painter for Squats animations.
base class _SquatsPainter extends BasicArtboardPainter {
  Animation? _idleAnimation;
  Animation? _squatsAnimation;
  bool _squatting = false;

  @override
  void artboardChanged(Artboard artboard) {
    super.artboardChanged(artboard);
    _idleAnimation = artboard.animationNamed('Idle');
    _squatsAnimation = artboard.animationNamed('Demo');
  }

  @override
  bool advance(double elapsedSeconds) {
    bool needsRepaint = super.advance(elapsedSeconds);
    if (_squatting) {
      needsRepaint =
          (_squatsAnimation?.advanceAndApply(elapsedSeconds) ?? false) ||
              needsRepaint;
    } else {
      needsRepaint =
          (_idleAnimation?.advanceAndApply(elapsedSeconds) ?? false) ||
              needsRepaint;
    }
    return needsRepaint;
  }

  void setSquatting(bool value) {
    if (_squatting == value) return;
    _squatting = value;
    if (!value) {
      _squatsAnimation?.time = 0;
    } else {
      _idleAnimation?.time = 0;
    }
    notifyListeners();
  }
}

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
    super.key,
    required this.state,
    required this.reverse,
    this.backgroundColor,
  });

  @override
  State<_SquatsIndicator> createState() => _SquatsIndicatorState();
}

class _SquatsIndicatorState extends State<_SquatsIndicator> {
  File? _file;
  Artboard? _artboard;
  late final _SquatsPainter _painter;

  double get _offset => widget.state.offset;

  @override
  void initState() {
    super.initState();
    _painter = _SquatsPainter();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _initRive();
  }

  Future<void> _initRive() async {
    final file = await File.asset(
      'packages/easy_refresh_squats/assets/lumberjack_squats.riv',
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
    if (mode == IndicatorMode.processing ||
        mode == IndicatorMode.processed ||
        mode == IndicatorMode.done) {
      _painter.setSquatting(true);
    } else {
      _painter.setSquatting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final artboard = _artboard;
    _painter.fit = Fit.fitWidth;
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: _offset,
      color: widget.backgroundColor,
      child: SizedBox(
        width: _kSquatsFitSwitchOffset,
        height: _offset,
        child: artboard != null
            ? RiveArtboardWidget(
                artboard: artboard,
                painter: _painter,
              )
            : const SizedBox(),
      ),
    );
  }
}
