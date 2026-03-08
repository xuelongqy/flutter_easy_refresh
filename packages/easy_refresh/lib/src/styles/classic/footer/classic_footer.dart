part of '../../../../easy_refresh.dart';

/// Classic footer.
class ClassicFooter extends Footer {
  final Key? key;

  /// The location of the widget.
  /// Only supports [MainAxisAlignment.center],
  /// [MainAxisAlignment.start] and [MainAxisAlignment.end].
  final MainAxisAlignment mainAxisAlignment;

  /// Background color.
  /// Ignored if [boxDecoration] is not null.
  final Color? backgroundColor;

  /// Box decoration.
  final BoxDecoration? boxDecoration;

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

  /// Text on [IndicatorResult.fail].
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

  /// Icon when [IndicatorResult.success].
  final Widget? succeededIcon;

  /// Icon when [IndicatorResult.fail].
  final Widget? failedIcon;

  /// Icon when [IndicatorResult.noMore].
  final Widget? noMoreIcon;

  /// Icon on pull.
  final CIPullIconBuilder? pullIconBuilder;

  /// Text style.
  final TextStyle? textStyle;

  /// Build text.
  final CITextBuilder? textBuilder;

  /// Text style.
  final TextStyle? messageStyle;

  /// Build message.
  final CIMessageBuilder? messageBuilder;

  /// Link [Stack.clipBehavior].
  final Clip clipBehavior;

  /// Icon style.
  final IconThemeData? iconTheme;

  /// Progress indicator size.
  final double? progressIndicatorSize;

  /// Progress indicator stroke width.
  /// See [CircularProgressIndicator.strokeWidth].
  final double? progressIndicatorStrokeWidth;

  const ClassicFooter({
    this.key,
    super.triggerOffset = 70,
    super.clamping = false,
    super.position,
    super.processedDuration = Duration.zero,
    super.spring,
    super.readySpringBuilder,
    super.springRebound,
    super.frictionFactor,
    super.safeArea,
    super.infiniteOffset = 70,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.triggerWhenReach,
    super.triggerWhenRelease,
    super.maxOverOffset,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.backgroundColor,
    this.boxDecoration,
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
    this.succeededIcon,
    this.failedIcon,
    this.noMoreIcon,
    this.pullIconBuilder,
    this.textStyle,
    this.textBuilder,
    this.messageStyle,
    this.messageBuilder,
    this.clipBehavior = Clip.hardEdge,
    this.iconTheme,
    this.progressIndicatorSize,
    this.progressIndicatorStrokeWidth,
  });

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _ClassicIndicator(
      key: key,
      state: state,
      backgroundColor: backgroundColor,
      boxDecoration: boxDecoration,
      mainAxisAlignment: mainAxisAlignment,
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
      succeededIcon: succeededIcon,
      failedIcon: failedIcon,
      noMoreIcon: noMoreIcon,
      pullIconBuilder: pullIconBuilder,
      textStyle: textStyle,
      textBuilder: textBuilder,
      messageStyle: messageStyle,
      messageBuilder: messageBuilder,
      clipBehavior: clipBehavior,
      iconTheme: iconTheme,
      progressIndicatorSize: progressIndicatorSize,
      progressIndicatorStrokeWidth: progressIndicatorStrokeWidth,
    );
  }
}
