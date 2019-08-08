import 'dart:async';

import 'package:flutter/material.dart';

import 'src/header/refresh_indicator.dart';
import 'src/header/header.dart';

/// 球脉冲Header
class BallPulseHeader extends Header {
  /// Key
  final Key key;

  /// 颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  BallPulseHeader({
    this.key,
    this.color = Colors.blue,
    this.backgroundColor,
    bool enableHapticFeedback = true,
    bool enableInfiniteRefresh = false,
  }) : super(
          extent: 70.0,
          triggerDistance: 70.0,
          float: false,
          enableHapticFeedback: enableHapticFeedback,
          enableInfiniteRefresh: enableInfiniteRefresh,
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
    // 不能为水平方向
    assert(
        axisDirection == AxisDirection.down ||
            axisDirection == AxisDirection.up,
        'Widget cannot be horizontal');
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
    return BallPulseHeaderWidget(
      key: key,
      color: color,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}

/// 球脉冲组件
class BallPulseHeaderWidget extends StatefulWidget {
  /// 颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  final LinkHeaderNotifier linkNotifier;

  const BallPulseHeaderWidget({
    Key key,
    this.color,
    this.backgroundColor,
    this.linkNotifier,
  }) : super(key: key);

  @override
  BallPulseHeaderWidgetState createState() {
    return BallPulseHeaderWidgetState();
  }
}

class BallPulseHeaderWidgetState extends State<BallPulseHeaderWidget> {
  RefreshMode get _refreshState => widget.linkNotifier.refreshState;
  double get _indicatorExtent => widget.linkNotifier.refreshIndicatorExtent;
  bool get _noMore => widget.linkNotifier.noMore;

  // 球大小
  double _ballSize1, _ballSize2, _ballSize3;
  // 动画阶段
  int animationPhase = 1;
  // 动画过渡时间
  Duration _ballSizeDuration = Duration(milliseconds: 200);
  // 是否运行动画
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    _ballSize1 = _ballSize2 = _ballSize3 = 0.0;
  }

  // 循环动画
  void _loopAnimated() {
    Future.delayed(_ballSizeDuration, () {
      if (!mounted) return;
      if (_isAnimated) {
        setState(() {
          if (animationPhase == 1) {
            _ballSize1 = 13.0;
            _ballSize2 = 6.0;
            _ballSize3 = 13.0;
          } else if (animationPhase == 2) {
            _ballSize1 = 20.0;
            _ballSize2 = 13.0;
            _ballSize3 = 6.0;
          } else if (animationPhase == 3) {
            _ballSize1 = 13.0;
            _ballSize2 = 20.0;
            _ballSize3 = 13.0;
          } else {
            _ballSize1 = 6.0;
            _ballSize2 = 13.0;
            _ballSize3 = 20.0;
          }
        });
        animationPhase++;
        animationPhase = animationPhase >= 5 ? 1 : animationPhase;
        _loopAnimated();
      } else {
        setState(() {
          _ballSize1 = 0.0;
          _ballSize2 = 0.0;
          _ballSize3 = 0.0;
        });
        animationPhase = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_noMore) return Container();
    // 开启动画
    if (_refreshState == RefreshMode.done ||
        _refreshState == RefreshMode.inactive) {
      _isAnimated = false;
    } else if (!_isAnimated) {
      _isAnimated = true;
      setState(() {
        _ballSize1 = 6.0;
        _ballSize2 = 13.0;
        _ballSize3 = 20.0;
      });
      _loopAnimated();
    }
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0.0,
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            alignment: Alignment.center,
            height: _indicatorExtent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Center(
                    child: ClipOval(
                      child: AnimatedContainer(
                        color: widget.color,
                        height: _ballSize1,
                        width: _ballSize1,
                        duration: _ballSizeDuration,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 5.0,
                ),
                SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Center(
                    child: ClipOval(
                      child: AnimatedContainer(
                        color: widget.color,
                        height: _ballSize2,
                        width: _ballSize2,
                        duration: _ballSizeDuration,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 5.0,
                ),
                SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Center(
                    child: ClipOval(
                      child: AnimatedContainer(
                        color: widget.color,
                        height: _ballSize3,
                        width: _ballSize3,
                        duration: _ballSizeDuration,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
