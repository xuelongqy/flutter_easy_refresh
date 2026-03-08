part of '../../../easy_refresh.dart';

/// See [ProgressIndicator] _kMinCircularProgressIndicatorSize.
const double _kCircularProgressIndicatorSize = 48;

/// Friction factor used by material.
double kMaterialFrictionFactor(double overscrollFraction) =>
    0.875 * math.pow(1 - overscrollFraction, 2);

/// Friction factor used by material horizontal.
double kMaterialHorizontalFrictionFactor(double overscrollFraction) =>
    1.0 * math.pow(1 - overscrollFraction, 2);

/// Spring description used by material.
physics.SpringDescription kMaterialSpringBuilder({
  required IndicatorMode mode,
  required double offset,
  required double actualTriggerOffset,
  required double velocity,
}) =>
    physics.SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: 500,
      ratio: 1.1,
    );

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

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  /// Icon when [IndicatorResult.noMore].
  final Widget? noMoreIcon;

  /// Show bezier background.
  final bool showBezierBackground;

  /// Bezier background color.
  /// See [BezierBackground.color].
  final Color? bezierBackgroundColor;

  /// Bezier background animation.
  /// See [BezierBackground.useAnimation].
  final bool bezierBackgroundAnimation;

  /// Bezier background bounce.
  /// See [BezierBackground.bounce].
  final bool bezierBackgroundBounce;

  const _MaterialIndicator({
    super.key,
    required this.state,
    required this.disappearDuration,
    required this.reverse,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.semanticsLabel,
    this.semanticsValue,
    this.noMoreIcon,
    this.showBezierBackground = false,
    this.bezierBackgroundColor,
    this.bezierBackgroundAnimation = false,
    this.bezierBackgroundBounce = false,
  });

  @override
  State<_MaterialIndicator> createState() => _MaterialIndicatorState();
}

class _MaterialIndicatorState extends State<_MaterialIndicator> {
  /// Indicator value.
  /// See [ProgressIndicator.value].
  double? get _value {
    if (_result == IndicatorResult.noMore) {
      return 0;
    }
    if (_mode == IndicatorMode.drag || _mode == IndicatorMode.armed) {
      const noneOffset = _kCircularProgressIndicatorSize * 0.25;
      if (_offset < noneOffset) {
        return 0;
      }
      return math.min(
              (_offset - noneOffset) /
                  (_actualTriggerOffset * 1.25 - noneOffset),
              1) *
          0.75;
    }
    return null;
  }

  /// Indicator value.
  Color? get _color {
    if (_result == IndicatorResult.noMore) {
      return Colors.transparent;
    }
    if (widget.valueColor != null) {
      return null;
    }
    final color = widget.color ??
        ProgressIndicatorTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;
    return color.withOpacity(math.min(_offset / _actualTriggerOffset, 1));
  }

  IndicatorMode get _mode => widget.state.mode;

  IndicatorResult get _result => widget.state.result;

  Axis get _axis => widget.state.axis;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  /// Build [RefreshProgressIndicator].
  Widget _buildIndicator() {
    if (_offset <= 0) {
      return const SizedBox();
    }
    return Container(
      alignment: _axis == Axis.vertical
          ? (widget.reverse ? Alignment.topCenter : Alignment.bottomCenter)
          : (widget.reverse ? Alignment.centerLeft : Alignment.centerRight),
      height: _axis == Axis.vertical ? _actualTriggerOffset : double.infinity,
      width: _axis == Axis.horizontal ? _actualTriggerOffset : double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedScale(
            duration: widget.disappearDuration,
            scale:
                _mode == IndicatorMode.processed || _mode == IndicatorMode.done
                    ? 0
                    : 1,
            child: RefreshProgressIndicator(
              value: _value,
              backgroundColor: widget.backgroundColor,
              color: _color,
              valueColor: widget.valueColor,
              semanticsLabel: widget.semanticsLabel,
              semanticsValue: widget.semanticsValue,
            ),
          ),
          if (_mode == IndicatorMode.inactive &&
              _result == IndicatorResult.noMore)
            widget.noMoreIcon ?? const Icon(Icons.inbox_outlined),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double offset = _offset;
    if (widget.state.indicator.infiniteOffset != null &&
        widget.state.indicator.position == IndicatorPosition.locator &&
        (_mode != IndicatorMode.inactive ||
            _result == IndicatorResult.noMore)) {
      offset = _actualTriggerOffset;
    }
    final padding = math.max(_offset - _kCircularProgressIndicatorSize, 0) / 2;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: _axis == Axis.vertical ? double.infinity : offset,
          height: _axis == Axis.horizontal ? double.infinity : offset,
        ),
        if (widget.showBezierBackground)
          Positioned(
            top: _axis == Axis.vertical
                ? widget.reverse
                    ? null
                    : 0
                : 0,
            left: _axis == Axis.horizontal
                ? widget.reverse
                    ? null
                    : 0
                : 0,
            right: _axis == Axis.horizontal
                ? widget.reverse
                    ? 0
                    : null
                : 0,
            bottom: _axis == Axis.vertical
                ? widget.reverse
                    ? 0
                    : null
                : 0,
            child: BezierBackground(
              state: widget.state,
              color: widget.bezierBackgroundColor,
              useAnimation: widget.bezierBackgroundAnimation,
              bounce: widget.bezierBackgroundBounce,
              reverse: widget.reverse,
            ),
          ),
        Positioned(
          top: _axis == Axis.vertical
              ? widget.reverse
                  ? padding
                  : null
              : 0,
          bottom: _axis == Axis.vertical
              ? widget.reverse
                  ? null
                  : padding
              : 0,
          left: _axis == Axis.horizontal
              ? widget.reverse
                  ? padding
                  : null
              : 0,
          right: _axis == Axis.horizontal
              ? widget.reverse
                  ? null
                  : padding
              : 0,
          child: Center(
            child: _buildIndicator(),
          ),
        ),
      ],
    );
  }
}
