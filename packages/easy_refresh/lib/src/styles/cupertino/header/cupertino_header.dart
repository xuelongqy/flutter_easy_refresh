part of '../../../../easy_refresh.dart';

/// Cupertino header.
/// https://github.com/THEONE10211024/WaterDropListView
class CupertinoHeader extends Header {
  final Key? key;

  /// Indicator foreground color.
  final Color? foregroundColor;

  /// Use WaterDrop style.
  final bool userWaterDrop;

  /// WaterDrop background color.
  final Color? backgroundColor;

  /// Empty widget.
  /// When result is [IndicatorResult.noMore].
  final Widget? emptyWidget;

  const CupertinoHeader({
    this.key,
    super.triggerOffset = 60,
    super.clamping = false,
    super.position = IndicatorPosition.behind,
    super.processedDuration = Duration.zero,
    super.spring,
    super.readySpringBuilder,
    super.springRebound = false,
    FrictionFactor? frictionFactor,
    super.safeArea,
    super.infiniteOffset,
    super.hitOver,
    super.infiniteHitOver,
    super.hapticFeedback,
    super.triggerWhenRelease,
    super.maxOverOffset,
    this.foregroundColor,
    this.userWaterDrop = true,
    this.backgroundColor,
    this.emptyWidget,
  }) : super(
          frictionFactor: frictionFactor ??
              (userWaterDrop && infiniteOffset == null
                  ? kCupertinoFrictionFactor
                  : null),
          horizontalFrictionFactor: kCupertinoHorizontalFrictionFactor,
        );

  @override
  Widget build(BuildContext context, IndicatorState state) {
    return _CupertinoIndicator(
      key: key,
      state: state,
      reverse: state.reverse,
      foregroundColor: foregroundColor,
      userWaterDrop: userWaterDrop,
      backgroundColor: backgroundColor,
      emptyWidget: emptyWidget,
    );
  }
}
