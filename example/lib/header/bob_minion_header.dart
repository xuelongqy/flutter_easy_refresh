import 'dart:math';

import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 小黄人动画类型
enum BobMinionAnimation { Stand, Dance, Jump, Wave }

/// 小黄人(Bob)样式
class BobMinionHeader extends Header {
  /// Key
  final Key key;

  /// 动画类型
  final BobMinionAnimation animation;

  /// 背景颜色
  final Color backgroundColor;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  BobMinionHeader({
    this.key,
    bool enableHapticFeedback = false,
    this.animation = BobMinionAnimation.Stand,
    this.backgroundColor = Colors.transparent,
  }) : super(
          extent: 80.0,
          triggerDistance: 100.0,
          float: false,
          enableHapticFeedback: enableHapticFeedback,
          enableInfiniteRefresh: false,
          completeDuration: const Duration(seconds: 1),
        );

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {
    // 不能为水平方向以及反向
    assert(axisDirection == AxisDirection.down,
        'Widget can only be vertical and cannot be reversed');
    linkNotifier.contentBuilder(
        context,
        refreshState,
        pulledExtent,
        refreshTriggerPullDistance,
        refreshIndicatorExtent,
        axisDirection,
        float,
        completeDuration,
        enableInfiniteRefresh,
        success,
        noMore);
    String animationName;
    switch (animation) {
      case BobMinionAnimation.Stand:
        animationName = 'Stand';
        break;
      case BobMinionAnimation.Dance:
        animationName = 'Dance';
        break;
      case BobMinionAnimation.Jump:
        animationName = 'Jump';
        break;
      case BobMinionAnimation.Wave:
        animationName = 'Wave';
        break;
      default:
        animationName = 'Stand';
        break;
    }
    return BobMinionHeaderWidget(
      key: key,
      linkNotifier: linkNotifier,
      animation: animationName,
      backgroundColor: backgroundColor,
    );
  }
}

/// 小黄人组件
class BobMinionHeaderWidget extends StatefulWidget {
  final LinkHeaderNotifier linkNotifier;

  /// 动画类型
  final String animation;

  /// 背景颜色
  final Color backgroundColor;

  const BobMinionHeaderWidget({
    Key key,
    this.linkNotifier,
    this.animation,
    this.backgroundColor,
  }) : super(key: key);

  @override
  BobMinionHeaderWidgetState createState() {
    return BobMinionHeaderWidgetState();
  }
}

class BobMinionHeaderWidgetState extends State<BobMinionHeaderWidget> {
  RefreshMode get _refreshState => widget.linkNotifier.refreshState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;
  double get _indicatorExtent => widget.linkNotifier.refreshIndicatorExtent;

  // 动画控制器
  BobMinionController _flareControls;

  @override
  void initState() {
    super.initState();
    _flareControls = BobMinionController();
  }

  @override
  Widget build(BuildContext context) {
    if (_refreshState == RefreshMode.armed ||
        _refreshState == RefreshMode.refresh ||
        _refreshState == RefreshMode.refreshed ||
        _refreshState == RefreshMode.done) {
      _flareControls.play(widget.animation);
    } else {
      _flareControls.stop();
    }
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: _pulledExtent > _indicatorExtent
                ? _pulledExtent
                : _indicatorExtent,
            color: widget.backgroundColor,
            child: Container(
              height: 80.0,
              child: FlareActor(
                "assets/flare/Bob(Minion).flr",
                alignment: Alignment.center,
                animation: 'idle',
                fit: BoxFit.fitHeight,
                controller: _flareControls,
              ),
            ),
          ),
        )
      ],
    );
  }
}

/// 小黄人动画控制器
class BobMinionController extends FlareController {
  /// The current [FlutterActorArtboard].
  FlutterActorArtboard _artboard;

  /// 动画列表
  List<String> _animationList = ["Stand", "Dance", "Jump", "Wave"];

  /// The current [ActorAnimation].
  String _animationName;
  double _mixSeconds = 0.1;

  /// The [FlareAnimationLayer]s currently active.
  List<FlareAnimationLayer> _animationLayers = [];

  /// Called at initialization time, it stores the reference
  /// to the current [FlutterActorArtboard].
  void initialize(FlutterActorArtboard artboard) {
    _artboard = artboard;
    _animationLayers = _animationList.map<FlareAnimationLayer>((animationName) {
      var animation = artboard.getAnimation(animationName);
      return FlareAnimationLayer()
        ..name = animationName
        ..animation = animation
        ..mix = 1.0
        ..mixSeconds = 0.2;
    }).toList();
    isActive.value = true;
  }

  /// Listen for when the animation called [name] has completed.
  void onCompleted(String name) {}

  /// 停止动画
  void stop() {
    _animationName = 'idle';
    _animationLayers.forEach((layer) {
      layer.time = 0.0;
      layer.mix = 0.0;
      layer.animation.apply(0.0, _artboard, 1.0);
    });
  }

  /// Add the [FlareAnimationLayer] of the animation named [name],
  /// to the end of the list of currently playing animation layers.
  void play(String name, {double mix = 1.0, double mixSeconds = 0.2}) {
    _animationName = name;
  }

  void setViewTransform(Mat2D viewTransform) {}

  /// Advance all the [FlareAnimationLayer]s that are currently controlled
  /// by this object, and mixes them accordingly.
  ///
  /// If an animation completes during the current frame (and doesn't loop),
  /// the [onCompleted()] callback will be triggered.
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    double lastMix = 0.0;

    /// This loop will mix all the currently active animation layers so that,
    /// if an animation is played on top of the current one, it'll smoothly mix between
    /// the two instead of immediately switching to the new one.
    for (int i = 0; i < _animationLayers.length; i++) {
      FlareAnimationLayer layer = _animationLayers[i];

      /// Apply the animation with the current mix.
      if (layer.name == _animationName) {
        layer.mix += elapsed;
        layer.time += elapsed;

        lastMix = (_mixSeconds == null || _mixSeconds == 0.0)
            ? 1.0
            : min(1.0, layer.mix / _mixSeconds);

        /// Loop the time if needed.
        if (layer.animation.isLooping) {
          layer.time %= layer.animation.duration;
        }
        layer.animation.apply(layer.time, _artboard, lastMix);
      }
    }
    return _animationLayers.isNotEmpty;
  }
}
