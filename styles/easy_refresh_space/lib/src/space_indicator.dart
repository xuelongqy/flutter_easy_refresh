part of easy_refresh_space;

const _kDefaultSpaceTriggerOffset = 180.0;

/// Space indicator.
/// Base widget for [SpaceHeader] and [SpaceFooter].
class _SpaceIndicator extends StatefulWidget {
  /// Indicator properties and state.
  final IndicatorState state;

  /// True for up and left.
  /// False for down and right.
  final bool reverse;

  const _SpaceIndicator({
    Key? key,
    required this.state,
    required this.reverse,
  }) : super(key: key);

  @override
  State<_SpaceIndicator> createState() => _SpaceIndicatorState();
}

class _SpaceIndicatorState extends State<_SpaceIndicator> with FlareController {
  IndicatorMode get _mode => widget.state.mode;

  double get _offset => widget.state.offset;

  double get _actualTriggerOffset => widget.state.actualTriggerOffset;

  late ActorAnimation _loadingAnimation;
  late ActorAnimation _successAnimation;
  late ActorAnimation _pullAnimation;
  late ActorAnimation _cometAnimation;
  double _successTime = 0.0;
  double _loadingTime = 0.0;
  double _cometTime = 0.0;

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    double animationPosition = _offset / _actualTriggerOffset;
    animationPosition *= animationPosition;
    _cometTime += elapsed;
    _cometAnimation.apply(_cometTime % _cometAnimation.duration, artboard, 1.0);
    _pullAnimation.apply(
        _pullAnimation.duration * animationPosition, artboard, 1.0);
    if (_mode == IndicatorMode.ready ||
        _mode == IndicatorMode.processing ||
        _mode == IndicatorMode.processed) {
      _successTime += elapsed;
      if (_successTime >= _successAnimation.duration) {
        _loadingTime += elapsed;
      }
    } else {
      _successTime = _loadingTime = 0.0;
    }
    if (_mode == IndicatorMode.inactive) {
      _successTime = _loadingTime = 0.0;
      _loadingAnimation.apply(0.0, artboard, 1.0);
    } else if (_successTime >= _successAnimation.duration) {
      _loadingAnimation.apply(
          _loadingTime % _loadingAnimation.duration, artboard, 1.0);
    } else if (_successTime > 0.0) {
      _successAnimation.apply(_successTime, artboard, 1.0);
    }
    return true;
  }

  @override
  void initialize(FlutterActorArtboard actor) {
    _pullAnimation = actor.getAnimation("pull")!;
    _successAnimation = actor.getAnimation("success")!;
    _loadingAnimation = actor.getAnimation("loading")!;
    _cometAnimation = actor.getAnimation("idle comet")!;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _offset,
      child: FlareActor(
        "packages/easy_refresh_space/assets/SpaceDemo.flr",
        alignment: Alignment.center,
        animation: "idle",
        fit: BoxFit.cover,
        controller: this,
      ),
    );
  }
}
