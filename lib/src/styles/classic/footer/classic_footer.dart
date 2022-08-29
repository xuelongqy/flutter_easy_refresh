part of easy_refresh;

/// Classic footer.
class ClassicFooter extends Footer {
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
    double triggerOffset = 70,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.above,
    Duration processedDuration = Duration.zero,
    SpringDescription? spring,
    SpringBuilder? readySpringBuilder,
    bool springRebound = true,
    FrictionFactor? frictionFactor,
    bool safeArea = true,
    double? infiniteOffset = 70,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    bool triggerWhenReach = false,
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
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          processedDuration: processedDuration,
          spring: spring,
          readySpringBuilder: readySpringBuilder,
          springRebound: springRebound,
          frictionFactor: frictionFactor,
          safeArea: safeArea,
          infiniteOffset: infiniteOffset,
          hitOver: hitOver,
          infiniteHitOver: infiniteHitOver,
          position: position,
          hapticFeedback: hapticFeedback,
          triggerWhenReach: triggerWhenReach,
        );

  /// get default footer.
  static ClassicFooter get defaultFooter {
    assert(EasyRefresh._defaultFooter is ClassicFooter,"The default footer is not ClassicFooter");
    return EasyRefresh._defaultFooter as ClassicFooter;
  }

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _ClassicIndicator(
      key: key,
      state: state,
      backgroundColor: backgroundColor,
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


  /// copyWith ClassicFooter
  ClassicFooter copyWith({
    Key? key,
    double? triggerOffset,
    bool? clamping,
    IndicatorPosition? position,
    Duration? processedDuration,
    SpringDescription? spring,
    SpringBuilder? readySpringBuilder,
    bool? springRebound,
    FrictionFactor? frictionFactor,
    bool? safeArea,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool? hapticFeedback,
    bool? triggerWhenReach,
    MainAxisAlignment? mainAxisAlignment,
    Color? backgroundColor,
    String? dragText,
    String? armedText,
    String? readyText,
    String? processingText,
    String? processedText,
    String? noMoreText,
    String? failedText,
    bool? showText,
    String? messageText,
    bool? showMessage,
    double? textDimension,
    double? iconDimension,
    double? spacing,
    Widget? succeededIcon,
    Widget? failedIcon,
    Widget? noMoreIcon,
    CIPullIconBuilder? pullIconBuilder,
    TextStyle? textStyle,
    CITextBuilder? textBuilder,
    TextStyle? messageStyle,
    CIMessageBuilder? messageBuilder,
    Clip? clipBehavior,
    IconThemeData? iconTheme,
    double? progressIndicatorSize,
    double? progressIndicatorStrokeWidth
  }) =>
      ClassicFooter(
          key: key ?? this.key,
          triggerOffset: triggerOffset ?? this.triggerOffset,
          clamping: clamping ?? this.clamping,
          position: position ?? this.position,
          processedDuration: processedDuration ?? this.processedDuration,
          spring: spring ?? this.spring,
          readySpringBuilder: readySpringBuilder ?? this.readySpringBuilder,
          springRebound: springRebound ?? this.springRebound,
          frictionFactor: frictionFactor ?? this.frictionFactor,
          safeArea: safeArea ?? this.safeArea,
          infiniteOffset: infiniteOffset ?? this.infiniteOffset,
          hitOver: hitOver ?? this.hitOver,
          infiniteHitOver: infiniteHitOver ?? this.infiniteHitOver,
          hapticFeedback: hapticFeedback ?? this.hapticFeedback,
          triggerWhenReach: triggerWhenReach ?? this.triggerWhenReach,
          mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
          backgroundColor: backgroundColor ?? this.backgroundColor,
          dragText: dragText ?? this.dragText,
          armedText: armedText ?? this.armedText,
          readyText: readyText ?? this.readyText,
          processingText: processingText ?? this.processingText,
          processedText: processedText ?? this.processedText,
          noMoreText: noMoreText ?? this.noMoreText,
          failedText: failedText ?? this.failedText,
          showText: showText ?? this.showText,
          messageText: messageText ?? this.messageText,
          showMessage: showMessage ?? this.showMessage,
          textDimension: textDimension ?? this.textDimension,
          iconDimension: iconDimension ?? this.iconDimension,
          spacing: spacing ?? this.spacing,
          succeededIcon: succeededIcon ?? this.succeededIcon,
          failedIcon: failedIcon ?? this.failedIcon,
          noMoreIcon: noMoreIcon ?? this.noMoreIcon,
          pullIconBuilder: pullIconBuilder ?? this.pullIconBuilder,
          textStyle: textStyle ?? this.textStyle,
          textBuilder: textBuilder ?? this.textBuilder,
          messageStyle: messageStyle ?? this.messageStyle,
          messageBuilder: messageBuilder ?? this.messageBuilder,
          clipBehavior: clipBehavior ?? this.clipBehavior,
          iconTheme: iconTheme ?? this.iconTheme,
          progressIndicatorSize: progressIndicatorSize ?? this.progressIndicatorSize,
          progressIndicatorStrokeWidth: progressIndicatorStrokeWidth ?? this.progressIndicatorStrokeWidth
      );
}
