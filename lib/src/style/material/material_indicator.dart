part of easyrefresh;

/// Material indicator.
/// Base widget for [MaterialHeader] and [MaterialFooter].
class _MaterialIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// See [ProgressIndicator.backgroundColor].
  final Color? backgroundColor;

  /// See [ProgressIndicator.color].
  final Color? color;

  /// See [ProgressIndicator.valueColor].
  final Animation<Color?>? valueColor;

  /// See [ProgressIndicator.semanticsLabel].
  final String? semanticsLabel;

  /// See [ProgressIndicator.semanticsLabel].
  final String? semanticsValue;

  /// Indicator disappears duration.
  /// When the mode is [IndicatorMode.processed].
  final Duration disappearDuration;

  const _MaterialIndicator({
    Key? key,
    required this.state,
    required this.disappearDuration,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.semanticsLabel,
    this.semanticsValue,
  }) : super(key: key);

  @override
  State<_MaterialIndicator> createState() => _MaterialIndicatorState();
}

class _MaterialIndicatorState extends State<_MaterialIndicator> {
  /// Indicator value.
  /// See [ProgressIndicator.value].
  double? get _value {
    if (_mode == IndicatorMode.drag || _mode == IndicatorMode.armed) {
      // [_kMinCircularProgressIndicatorSize] is 36
      const noProgressOffset = 36 * 0.25;
      if (_offset < noProgressOffset) {
        return 0;
      }
      return math.min(
              (_offset - noProgressOffset) /
                  (_actualTriggerOffset * 1.25 - noProgressOffset),
              1) *
          0.75;
    }
    return null;
  }

  /// Indicator value.
  Color? get _color {
    if (widget.valueColor != null) {
      return null;
    }
    final color = widget.color ??
        ProgressIndicatorTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;
    return color.withOpacity(math.min(_offset / _actualTriggerOffset, 1));
  }

  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  /// Build [RefreshProgressIndicator].
  Widget _buildIndicator() {
    return Container(
      alignment: Alignment.bottomCenter,
      height: _actualTriggerOffset,
      child: AnimatedScale(
        child: RefreshProgressIndicator(
          value: _value,
          backgroundColor: widget.backgroundColor,
          color: _color,
          valueColor: widget.valueColor,
          semanticsLabel: widget.semanticsLabel,
          semanticsValue: widget.semanticsValue,
        ),
        duration: widget.disappearDuration,
        scale: _mode == IndicatorMode.processed || _mode == IndicatorMode.done
            ? 0
            : 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _offset,
      child: Stack(
        children: [
          Positioned(
            top: null,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
