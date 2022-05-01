part of easyrefresh;

/// Classical footer.
class ClassicalFooter extends Footer {
  final Key? key;

  /// The location of the widget.
  /// Only supports [MainAxisAlignment.center],
  /// [MainAxisAlignment.start] and [MainAxisAlignment.end].
  final MainAxisAlignment mainAxisAlignment;

  /// Background color.
  final Color? backgroundColor;

  /// Text on [IndicatorMode.drag].
  final String? dragText;

  /// Text on [IndicatorMode.armed].
  final String? armedText;

  /// Text on [IndicatorMode.ready].
  final String? readyText;

  /// Text on [IndicatorMode.processing].
  final String? processingText;

  /// Text on [IndicatorMode.processed].
  final String? processedText;

  /// Text on [IndicatorResult.noMore].
  final String? noMoreText;

  /// Text on [IndicatorMode.failed].
  final String? failedText;

  /// Whether to display text.
  final bool showText;

  /// Message text.
  /// %T will be replaced with the last time.
  final String? messageText;

  /// Whether to display message.
  final bool showMessage;

  /// The dimension of the text area.
  /// When less than 0, calculate the length of the text widget.
  final double? textDimension;

  /// The dimension of the icon area.
  final double iconDimension;

  /// Spacing between text and icon.
  final double spacing;

  const ClassicalFooter({
    this.key,
    double triggerOffset = 70,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.behind,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset = 70,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    double? secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.backgroundColor,
    this.dragText,
    this.armedText,
    this.readyText,
    this.processingText,
    this.processedText,
    this.noMoreText,
    this.failedText,
    this.showText = true,
    this.messageText,
    this.showMessage = true,
    this.textDimension,
    this.iconDimension = 24,
    this.spacing = 16,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
          spring: spring,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          position: position,
          secondaryTriggerOffset: secondaryTriggerOffset,
          secondaryVelocity: secondaryVelocity,
          hapticFeedback: hapticFeedback,
          secondaryDimension: secondaryDimension,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _ClassicalIndicator(
      state: state,
      mainAxisAlignment: MainAxisAlignment.start,
      dragText: dragText ?? 'Pull to load',
      armedText: armedText ?? 'Release ready',
      readyText: readyText ?? 'Loading...',
      processingText: processingText ?? 'Loading...',
      processedText: processedText ?? 'Succeeded',
      noMoreText: noMoreText ?? 'No more',
      failedText: failedText ?? 'Failed',
      showText: showText,
      messageText: messageText ?? 'Last updated at %T',
      showMessage: showMessage,
      textDimension: textDimension,
      iconDimension: iconDimension,
      spacing: spacing,
      reverse: !state.reverse,
    );
  }
}
