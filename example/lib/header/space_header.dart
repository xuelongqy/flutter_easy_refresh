import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 动画来源于Flare-Flutter
/*
MIT License
Copyright (c) 2018 2D, Inc
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

class SpaceHeader extends Header {
  /// Key
  final Key key;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  SpaceHeader({
    this.key,
    bool enableHapticFeedback = false,
  }) : super(
          extent: 140.0,
          triggerDistance: 160.0,
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
    return SpaceHeaderWidget(
      key: key,
      linkNotifier: linkNotifier,
    );
  }
}

/// 星空组件
class SpaceHeaderWidget extends StatefulWidget {
  final LinkHeaderNotifier linkNotifier;

  const SpaceHeaderWidget({
    Key key,
    this.linkNotifier,
  }) : super(key: key);

  @override
  SpaceHeaderWidgetState createState() {
    return SpaceHeaderWidgetState();
  }
}

class SpaceHeaderWidgetState extends State<SpaceHeaderWidget>
    with FlareController {
  RefreshMode get _refreshState => widget.linkNotifier.refreshState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;
  double get _indicatorExtent => widget.linkNotifier.refreshIndicatorExtent;

  List<List<String>> randomizedContacts;

  ActorAnimation _loadingAnimation;
  ActorAnimation _successAnimation;
  ActorAnimation _pullAnimation;
  ActorAnimation _cometAnimation;
  double _successTime = 0.0;
  double _loadingTime = 0.0;
  double _cometTime = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    double animationPosition = _pulledExtent / _indicatorExtent;
    animationPosition *= animationPosition;
    _cometTime += elapsed;
    _cometAnimation.apply(_cometTime % _cometAnimation.duration, artboard, 1.0);
    _pullAnimation.apply(
        _pullAnimation.duration * animationPosition, artboard, 1.0);
    if (_refreshState == RefreshMode.refresh ||
        _refreshState == RefreshMode.armed ||
        _refreshState == RefreshMode.refreshed) {
      _successTime += elapsed;
      if (_successTime >= _successAnimation.duration) {
        _loadingTime += elapsed;
      }
    } else {
      _successTime = _loadingTime = 0.0;
    }
    if (_refreshState == RefreshMode.inactive) {
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

  void initialize(FlutterActorArtboard actor) {
    _pullAnimation = actor.getAnimation("pull");
    _successAnimation = actor.getAnimation("success");
    _loadingAnimation = actor.getAnimation("loading");
    _cometAnimation = actor.getAnimation("idle comet");
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _pulledExtent,
      child: FlareActor("assets/flare/SpaceDemo.flr",
          alignment: Alignment.center,
          animation: "idle",
          fit: BoxFit.cover,
          controller: this),
    );
  }
}
