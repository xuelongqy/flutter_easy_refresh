part of easyrefresh;

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
  final Widget? spin;

  const _BezierIndicator({
    Key? key,
    required this.state,
    required this.reverse,
    this.showBalls = true,
    this.spin,
  }) : super(key: key);

  @override
  State<_BezierIndicator> createState() => _BezierIndicatorState();
}

class _BezierIndicatorState extends State<_BezierIndicator> {
  static const _ballSize = 12.0;
  static const _ballArea = 400.0;
  static const _animationDuration = Duration(milliseconds: 200);

  Axis get _axis => widget.state.axis;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  double get _safeOffset => widget.state.safeOffset;

  Widget get _spin => widget.spin ?? const SizedBox();

  @override
  void initState() {
    super.initState();
    widget.state.notifier.addModeChangeListener(_onModeChange);
  }

  @override
  void dispose() {
    widget.state.notifier.removeModeChangeListener(_onModeChange);
    super.dispose();
  }

  /// Mode change listener.
  void _onModeChange(IndicatorMode mode, double offset) {}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: _axis == Axis.vertical ? double.infinity : _offset,
          height: _axis == Axis.horizontal ? double.infinity : _offset,
        ),
        BezierBackground(
          state: widget.state,
          reverse: widget.reverse,
          useAnimation: true,
        ),
        if (widget.showBalls && _offset > _safeOffset)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
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
                        child: AnimatedOpacity(
                          opacity:
                              widget.state.mode == IndicatorMode.inactive ||
                                      widget.state.mode == IndicatorMode.drag ||
                                      widget.state.mode == IndicatorMode.armed
                                  ? 1
                                  : 0,
                          duration: _animationDuration,
                          child: Opacity(
                            opacity: (1 - ((0.8 / 3) * (i - 3).abs())) *
                                math.min(1, scale),
                            child: Container(
                              width: ballSize,
                              height: ballSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(ballSize / 2)),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
