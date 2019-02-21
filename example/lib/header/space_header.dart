import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_dart/math/mat2d.dart';
import "package:flare_flutter/flare_actor.dart";
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

/// Flare Space Header
class SpaceHeader extends RefreshHeader {
  SpaceHeader({
    @required GlobalKey<RefreshHeaderState> key,
    double refreshHeight = 180.0,
  }) : super(
          key: key ?? new GlobalKey<RefreshHeaderState>(),
          refreshHeight: refreshHeight,
        );

  @override
  SpaceHeaderState createState() => SpaceHeaderState();
}

class SpaceHeaderState extends RefreshHeaderState<SpaceHeader>
    implements FlareController {
  ActorAnimation _loadingAnimation;
  ActorAnimation _successAnimation;
  ActorAnimation _pullAnimation;
  ActorAnimation _cometAnimation;

  double _pulledExtent;
  double _refreshTriggerPullDistance;
  double _successTime = 0.0;
  double _loadingTime = 0.0;
  double _cometTime = 0.0;

  // 是否环绕
  bool _isSurround;

  // 初始化
  @override
  void initState() {
    super.initState();
    _pulledExtent = 0.0;
    _refreshTriggerPullDistance = widget.refreshHeight;
    _isSurround = false;
  }

  void initialize(FlutterActorArtboard actor) {
    _pullAnimation = actor.getAnimation("pull");
    _successAnimation = actor.getAnimation("success");
    _loadingAnimation = actor.getAnimation("loading");
    _cometAnimation = actor.getAnimation("idle comet");
  }

  void setViewTransform(Mat2D viewTransform) {}

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    double animationPosition = _pulledExtent / _refreshTriggerPullDistance;
    animationPosition *= animationPosition;
    _cometTime += elapsed;
    _cometAnimation.apply(_cometTime % _cometAnimation.duration, artboard, 1.0);
    _pullAnimation.apply(
        _pullAnimation.duration * animationPosition, artboard, 1.0);
    if (_isSurround) {
      _successTime += elapsed;
      if (_successTime >= _successAnimation.duration) {
        _loadingTime += elapsed;
      }
    } else {
      _successTime = _loadingTime = 0.0;
    }
    if (_successTime >= _successAnimation.duration) {
      _loadingAnimation.apply(
          _loadingTime % _loadingAnimation.duration, artboard, 1.0);
    } else if (_successTime > 0.0) {
      _successAnimation.apply(_successTime, artboard, 1.0);
    }
    return true;
  }

  // 开始刷新
  @override
  void onRefreshStart() {
    _successTime = _loadingTime = _cometTime = 0.0;
    super.onRefreshStart();
  }

  // 正在刷新
  @override
  void onRefreshing() {
    _isSurround = true;
    super.onRefreshing();
  }

  // 刷新结束
  @override
  void onRefreshEnd() {
    _isSurround = false;
    super.onRefreshEnd();
  }

  // 高度更新
  @override
  void updateHeight(double newHeight) {
    _pulledExtent = newHeight;
    _refreshTriggerPullDistance = widget.refreshHeight;
    super.updateHeight(newHeight);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      child: height > 0.0
          ? FlareActor("assets/flare/Space Demo.flr",
              alignment: Alignment.center,
              animation: "idle",
              fit: BoxFit.cover,
              controller: this)
          : Container(),
    );
  }
}
