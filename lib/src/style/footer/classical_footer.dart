part of easyrefresh;

/// Classical footer.
class ClassicalFooter extends Footer {
  final Key? key;

  const ClassicalFooter({
    this.key,
    double triggerOffset = 70,
    bool clamping = false,
    IndicatorPosition position = IndicatorPosition.behind,
    Duration processedDuration = const Duration(seconds: 1),
    SpringDescription? spring,
    bool safeArea = true,
    double? infiniteOffset,
    bool? hitOver,
    bool? infiniteHitOver,
    bool hapticFeedback = false,
    double? secondaryTriggerOffset,
    double secondaryVelocity = kDefaultSecondaryVelocity,
    double? secondaryDimension,
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
    return _ClassicalFooterWidget(key: key, state: state);
  }
}

class _ClassicalFooterWidget extends StatefulWidget {
  final IndicatorState state;

  const _ClassicalFooterWidget({Key? key, required this.state})
      : super(key: key);

  @override
  State<_ClassicalFooterWidget> createState() => _ClassicalFooterWidgetState();
}

class _ClassicalFooterWidgetState extends State<_ClassicalFooterWidget> {
  @override
  Widget build(BuildContext context) {
    return _ClassicalIndicator(
      state: widget.state,
      mainAxisAlignment: MainAxisAlignment.start,
      dragText: 'Pull up load',
      armedText: 'Release ready',
      readyText: 'Loading...',
      processingText: 'Loading...',
      processedText: 'Succeeded',
      noMoreText: 'No more',
      failedText: 'Failed',
      messageText: 'Last updated at %T',
      reverse: true,
    );
  }
}
