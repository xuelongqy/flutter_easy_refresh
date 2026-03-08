part of '../../../easy_refresh.dart';

/// A builder that builds a spin widget.
/// [context] BuildContext.
/// [value] Animation value.
typedef BezierSpinBuilder = Widget Function(BuildContext context, double value);

/// Bezier indicator.
/// Base widget for [BezierHeader] and [BezierFooter].
class _BezierIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  /// Show the ball during the pull.
  final bool showBalls;

  /// Spin widget.
  final Widget? spinWidget;

  /// No more widget.
  final Widget? noMoreWidget;

  /// Spin widget builder.
  final BezierSpinBuilder? spinBuilder;

  /// Task completion delay.
  /// [IndicatorMode.processed] duration of state.
  final Duration processedDuration;

  /// Foreground color.
  final Color? foregroundColor;

  /// Background color.
  final Color? backgroundColor;

  /// Whether the spin widget is in the center.
  final bool spinInCenter;

  /// Only display the spin.
  /// When true, the balls are no longer displayed.
  final bool onlySpin;

  const _BezierIndicator({
    super.key,
    required this.state,
    required this.reverse,
    required this.processedDuration,
    this.showBalls = true,
    this.spinInCenter = true,
    this.onlySpin = false,
    this.spinWidget,
    this.noMoreWidget,
    this.spinBuilder,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  State<_BezierIndicator> createState() => _BezierIndicatorState();
}

class _BezierIndicatorState extends State<_BezierIndicator>
    with SingleTickerProviderStateMixin {
  static const _ballSize = 12.0;
  static const _ballArea = 400.0;
  static const _animationDuration = Duration(milliseconds: 300);

  IndicatorMode get _mode => widget.state.mode;

  Axis get _axis => widget.state.axis;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  double get _safeOffset => widget.state.safeOffset;

  bool get _reverse => widget.reverse;

  /// Animation controller.
  late AnimationController _animationController;

  Color get _foregroundColor => widget.foregroundColor ?? Colors.white;

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    _animationController.dispose();
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {
    if (mode == IndicatorMode.ready || mode == IndicatorMode.processing) {
      if (!_animationController.isAnimating) {
        _animationController.forward(from: 0);
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
    }
  }

  /// Build balls.
  Widget _buildBalls() {
    final extent = (!widget.spinInCenter && _offset > _actualTriggerOffset)
        ? _actualTriggerOffset
        : null;
    final full = widget.spinInCenter ||
        (!widget.spinInCenter && _offset <= _actualTriggerOffset);
    return Positioned(
      top: (_axis == Axis.vertical && _reverse && !full) ? null : 0,
      bottom: (_axis == Axis.vertical && !_reverse && !full) ? null : 0,
      left: (_axis == Axis.horizontal && _reverse && !full) ? null : 0,
      right: (_axis == Axis.horizontal && !_reverse && !full) ? null : 0,
      height: _axis == Axis.vertical ? extent : null,
      width: _axis == Axis.horizontal ? extent : null,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final ballSize = math.min(_ballSize, _offset);
          final scale = _offset / _actualTriggerOffset;
          final length = _axis == Axis.vertical
              ? constraints.maxWidth
              : constraints.maxHeight;
          final ballArea = math.min(_ballArea, length);
          return Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < 7; i++)
                Positioned(
                  left: _axis == Axis.vertical
                      ? ((length - ballSize) / 2) +
                          (ballArea / 8 * scale) * (i - 3)
                      : null,
                  bottom: _axis == Axis.horizontal
                      ? ((length - ballSize) / 2) +
                          (ballArea / 8 * scale) * (i - 3)
                      : null,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (ctx, _) {
                      double aValue;
                      if (_mode == IndicatorMode.inactive ||
                          _mode == IndicatorMode.drag ||
                          _mode == IndicatorMode.armed) {
                        aValue = 1;
                      } else {
                        aValue = _animationController.isAnimating
                            ? 1 - _animationController.value
                            : 0;
                      }
                      return Opacity(
                        opacity: (1 - ((0.8 / 3) * (i - 3).abs())) *
                            math.min(1, scale) *
                            aValue,
                        child: Container(
                          width: ballSize,
                          height: ballSize,
                          decoration: BoxDecoration(
                            color: _foregroundColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(ballSize / 2)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Build spin widget.
  Widget _buildSpin() {
    Widget spinWidget;
    if (widget.spinBuilder != null) {
      spinWidget = widget.spinBuilder!(context, _animationController.value);
    } else {
      spinWidget = widget.spinWidget ??
          _SpinKitHourGlass(
            color: _foregroundColor,
            size: 32,
          );
    }
    Widget animatedWidget = AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Transform.scale(
          scale: widget.onlySpin ? 1 : _animationController.value,
          child: spinWidget,
        );
      },
    );
    if (widget.onlySpin && _offset < _actualTriggerOffset) {
      return Positioned(
        top: (_axis == Axis.vertical && !_reverse)
            ? -(_actualTriggerOffset - _offset) / 2
            : null,
        bottom: (_axis == Axis.vertical && _reverse)
            ? -(_actualTriggerOffset - _offset) / 2
            : null,
        left: (_axis == Axis.horizontal && !_reverse)
            ? -(_actualTriggerOffset - _offset) / 2
            : null,
        right: (_axis == Axis.horizontal && _reverse)
            ? -(_actualTriggerOffset - _offset) / 2
            : null,
        height: _axis == Axis.vertical ? _actualTriggerOffset : null,
        width: _axis == Axis.vertical ? null : _actualTriggerOffset,
        child: Center(
          child: animatedWidget,
        ),
      );
    }
    if (!widget.spinInCenter) {
      return Positioned(
        top: (_axis == Axis.vertical && _reverse) ? null : 0,
        bottom: (_axis == Axis.vertical && !_reverse) ? null : 0,
        left: (_axis == Axis.horizontal && _reverse) ? null : 0,
        right: (_axis == Axis.horizontal && !_reverse) ? null : 0,
        height: _axis == Axis.vertical ? _actualTriggerOffset : null,
        width: _axis == Axis.vertical ? null : _actualTriggerOffset,
        child: Center(
          child: animatedWidget,
        ),
      );
    }
    return animatedWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: _axis == Axis.vertical ? double.infinity : _offset,
          height: _axis == Axis.horizontal ? double.infinity : _offset,
        ),
        BezierBackground(
          state: widget.state,
          reverse: widget.reverse,
          useAnimation: true,
          disappearAnimation: true,
          disappearAnimationDuration: widget.processedDuration,
          color: widget.backgroundColor,
        ),
        if (widget.showBalls &&
            !widget.onlySpin &&
            _offset > _safeOffset &&
            widget.state.result != IndicatorResult.noMore)
          _buildBalls(),
        if (_mode == IndicatorMode.ready ||
            _mode == IndicatorMode.processing ||
            (widget.onlySpin &&
                (_mode == IndicatorMode.drag || _mode == IndicatorMode.armed)))
          _buildSpin(),
        if (widget.state.result == IndicatorResult.noMore)
          Positioned(
            left: _axis == Axis.horizontal
                ? (_offset < _actualTriggerOffset
                    ? -(_actualTriggerOffset - _offset) / 2
                    : 0)
                : 0,
            right: _axis == Axis.horizontal
                ? (_offset < _actualTriggerOffset ? null : 0)
                : 0,
            top: _axis == Axis.vertical
                ? (_offset < _actualTriggerOffset
                    ? -(_actualTriggerOffset - _offset) / 2
                    : 0)
                : 0,
            bottom: _axis == Axis.vertical
                ? (_offset < _actualTriggerOffset ? null : 0)
                : 0,
            height: _axis == Axis.vertical
                ? (_offset < _actualTriggerOffset ? _actualTriggerOffset : null)
                : null,
            width: _axis == Axis.horizontal
                ? (_offset < _actualTriggerOffset ? _actualTriggerOffset : null)
                : null,
            child: Center(
              child: widget.noMoreWidget ??
                  Icon(
                    Icons.inbox_outlined,
                    color: _foregroundColor,
                    size: 32,
                  ),
            ),
          ),
      ],
    );
  }
}
