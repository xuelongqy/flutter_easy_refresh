import 'dart:async';

import 'package:flutter/material.dart';

import 'src/footer/load_indicator.dart';
import 'src/footer/footer.dart';

/// 球脉冲Footer
class BallPulseFooter extends Footer {
  /// Key
  final Key key;

  /// 颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  final LinkFooterNotifier linkNotifier = LinkFooterNotifier();

  BallPulseFooter({
    this.key,
    this.color = Colors.blue,
    this.backgroundColor,
    bool enableHapticFeedback = true,
    bool enableInfiniteLoad = true,
  }) : super(
          extent: 70.0,
          triggerDistance: 70.0,
          float: false,
          enableHapticFeedback: enableHapticFeedback,
          enableInfiniteLoad: enableInfiniteLoad,
        );

  @override
  Widget contentBuilder(
      BuildContext context,
      LoadMode loadState,
      double pulledExtent,
      double loadTriggerPullDistance,
      double loadIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration completeDuration,
      bool enableInfiniteLoad,
      bool success,
      bool noMore) {
    // 不能为水平方向
    assert(
        axisDirection == AxisDirection.down ||
            axisDirection == AxisDirection.up,
        'Widget cannot be horizontal');
    linkNotifier.contentBuilder(
        context,
        loadState,
        pulledExtent,
        loadTriggerPullDistance,
        loadIndicatorExtent,
        axisDirection,
        float,
        completeDuration,
        enableInfiniteLoad,
        success,
        noMore);
    return BallPulseFooterWidget(
      key: key,
      color: color,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}

/// 球脉冲组件
class BallPulseFooterWidget extends StatefulWidget {
  /// 颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  final LinkFooterNotifier linkNotifier;

  const BallPulseFooterWidget({
    Key key,
    this.color,
    this.backgroundColor,
    this.linkNotifier,
  }) : super(key: key);

  @override
  BallPulseFooterWidgetState createState() {
    return BallPulseFooterWidgetState();
  }
}

class BallPulseFooterWidgetState extends State<BallPulseFooterWidget> {
  LoadMode get _refreshState => widget.linkNotifier.loadState;
  double get _indicatorExtent => widget.linkNotifier.loadIndicatorExtent;
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
    if (_refreshState == LoadMode.done || _refreshState == LoadMode.inactive) {
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
