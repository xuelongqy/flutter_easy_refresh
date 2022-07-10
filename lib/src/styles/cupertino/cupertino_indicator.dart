part of easy_refresh;

const double _kDefaultCupertinoIndicatorRadius = 14.0;

/// Cupertino indicator.
/// Base widget for [CupertinoHeader] and [CupertinoFooter].
class _CupertinoIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const _CupertinoIndicator({
    Key? key,
    required this.state,
    required this.reverse,
  }) : super(key: key);

  @override
  State<_CupertinoIndicator> createState() => _CupertinoIndicatorState();
}

class _CupertinoIndicatorState extends State<_CupertinoIndicator> {
  IndicatorMode get _mode => widget.state.mode;
  double get _offset => widget.state.offset;
  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  double get _radius => _kDefaultCupertinoIndicatorRadius;

  Widget _buildIndicator() {
    final scale = (_offset / _actualTriggerOffset).clamp(0.0, 1.0);
    switch (_mode) {
      case IndicatorMode.drag:
      case IndicatorMode.armed:
        const Curve opacityCurve = Interval(
          0.0,
          0.8,
          curve: Curves.easeInOut,
        );
        return Opacity(
          opacity: opacityCurve.transform(scale),
          child: CupertinoActivityIndicator.partiallyRevealed(
            radius: _radius,
            progress: math.min(scale, 0.99),
          ),
        );
      case IndicatorMode.ready:
      case IndicatorMode.processing:
      case IndicatorMode.processed:
        return CupertinoActivityIndicator(
          radius: _radius,
        );
      case IndicatorMode.done:
        return CupertinoActivityIndicator(
          radius: _radius * scale,
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: _offset,
          width: double.infinity,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            alignment: Alignment.center,
            height: _actualTriggerOffset,
            width: double.infinity,
            child: _buildIndicator(),
          ),
        ),
      ],
    );
  }
}
