part of easyrefresh;

/// Classical indicator.
/// Base widget for [ClassicalHeader] and [ClassicalFooter].
class _ClassicalIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// The location of the widget.
  /// Only supports [MainAxisAlignment.center],
  /// [MainAxisAlignment.start] and [MainAxisAlignment.end].
  final MainAxisAlignment mainAxisAlignment;

  /// Background color.
  final Color backgroundColor;

  /// Text on [IndicatorMode.drag].
  final String dragText;

  /// Text on [IndicatorMode.armed].
  final String armedText;

  /// Text on [IndicatorMode.ready].
  final String readyText;

  /// Text on [IndicatorMode.processing].
  final String processingText;

  /// Text on [IndicatorMode.processed].
  final String processedText;

  /// Text on [IndicatorResult.noMore].
  final String noMoreText;

  /// Message text.
  /// %T will be replaced with the last time.
  final String messageText;

  /// Whether to display message.
  final bool showMessage;

  const _ClassicalIndicator({
    Key? key,
    required this.state,
    required this.mainAxisAlignment,
    this.backgroundColor = Colors.transparent,
    required this.dragText,
    required this.armedText,
    required this.readyText,
    required this.processingText,
    required this.processedText,
    required this.noMoreText,
    required this.messageText,
    this.showMessage = true,
  })  : assert(
            mainAxisAlignment == MainAxisAlignment.start ||
                mainAxisAlignment == MainAxisAlignment.center ||
                mainAxisAlignment == MainAxisAlignment.end,
            'Only supports [MainAxisAlignment.center], [MainAxisAlignment.start] and [MainAxisAlignment.end].'),
        super(key: key);

  @override
  State<_ClassicalIndicator> createState() => _ClassicalIndicatorState();
}

class _ClassicalIndicatorState extends State<_ClassicalIndicator> {
  /// Update time.
  late DateTime _updateTime;

  MainAxisAlignment get _mainAxisAlignment => widget.mainAxisAlignment;

  Axis get _axis => widget.state.axis;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  @override
  void initState() {
    super.initState();
    _updateTime = DateTime.now();
  }

  /// When the list direction is vertically.
  Widget _buildVerticalWidget() {
    return Stack(
      children: [
        if (_mainAxisAlignment == MainAxisAlignment.center)
          Positioned(
            left: 0,
            right: 0,
            top: _offset < _actualTriggerOffset
                ? -(_actualTriggerOffset - _offset) / 2
                : 0,
            bottom: _offset < _actualTriggerOffset ? null : 0,
            height:
                _offset < _actualTriggerOffset ? _actualTriggerOffset : null,
            child: Center(
              child: IntrinsicHeight(
                child: _buildVerticalBody(),
              ),
            ),
          ),
        if (_mainAxisAlignment != MainAxisAlignment.center)
          Positioned(
            left: 0,
            right: 0,
            top: _mainAxisAlignment == MainAxisAlignment.start ? 0 : null,
            bottom: _mainAxisAlignment == MainAxisAlignment.end ? 0 : null,
            child: _buildVerticalBody(),
          ),
      ],
    );
  }

  /// The body when the list is vertically direction.
  Widget _buildVerticalBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.readyText),
            Text(widget.messageText),
          ],
        )
      ],
    );
  }

  /// When the list direction is horizontally.
  Widget _buildHorizontalWidget() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      width: _axis == Axis.vertical ? double.infinity : _offset,
      height: _axis == Axis.horizontal ? double.infinity : _offset,
      child: _axis == Axis.vertical
          ? _buildVerticalWidget()
          : _buildHorizontalWidget(),
    );
  }
}
