import 'dart:async';

import 'package:flutter/material.dart';

import 'src/header/refresh_indicator.dart';
import 'src/header/header.dart';

/// 弹出圆圈Header
class BezierCircleHeader extends Header {
  /// Key
  final Key key;

  /// 颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  BezierCircleHeader({
    this.key,
    this.color = Colors.white,
    this.backgroundColor = Colors.blue,
    bool enableHapticFeedback = false,
  }) : super(
          extent: 80.0,
          triggerDistance: 80.0,
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
    return BezierCircleHeaderWidget(
      key: key,
      color: color,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}

/// 弹出小球组件
class BezierCircleHeaderWidget extends StatefulWidget {
  /// 颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  final LinkHeaderNotifier linkNotifier;

  const BezierCircleHeaderWidget({
    Key key,
    this.color,
    this.backgroundColor,
    this.linkNotifier,
  }) : super(key: key);

  @override
  BezierCircleHeaderWidgetState createState() {
    return BezierCircleHeaderWidgetState();
  }
}

class BezierCircleHeaderWidgetState extends State<BezierCircleHeaderWidget>
    with TickerProviderStateMixin<BezierCircleHeaderWidget> {
  RefreshMode get _refreshState => widget.linkNotifier.refreshState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;
  double get _indicatorExtent => widget.linkNotifier.refreshIndicatorExtent;
  bool get _noMore => widget.linkNotifier.noMore;

  // 回弹动画
  AnimationController _backController;
  Animation<double> _backAnimation;
  double _backAnimationLength = 110.0;
  double _backAnimationPulledExtent = 0.0;
  bool _showBackAnimation = false;
  set showBackAnimation(bool value) {
    if (_showBackAnimation != value) {
      _showBackAnimation = value;
      if (_showBackAnimation) {
        _backAnimationPulledExtent = _pulledExtent - _indicatorExtent;
        _backAnimation = Tween(
                begin: 0.0,
                end: _backAnimationLength + _backAnimationPulledExtent)
            .animate(_backController);
        _backController.reset();
        _backController.forward();
      }
    }
  }

  // 弹出圆圈动画
  bool _toggleCircle = false;
  set toggleCircle(bool value) {
    if (_toggleCircle != value) {
      _toggleCircle = value;
      if (_toggleCircle) {
        Future.delayed(Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _progressValue = null;
            });
          }
        });
      }
    }
  }

  // 环形进度
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    // 回弹动画
    _backController = new AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _backAnimation =
        Tween(begin: 0.0, end: _backAnimationLength).animate(_backController);
  }

  @override
  void dispose() {
    super.dispose();
    _backController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_noMore) return Container();
    // 启动回弹动画
    if (_refreshState == RefreshMode.armed) {
      showBackAnimation = true;
    } else if (_refreshState == RefreshMode.refreshed) {
      if (_progressValue == null) {
        _progressValue = 1.0;
        Future.delayed(Duration(milliseconds: 200), () {
          if (mounted && _toggleCircle) {
            setState(() {
              _progressValue = 0.0;
              toggleCircle = false;
            });
          }
        });
      }
    } else if (_refreshState == RefreshMode.inactive) {
      showBackAnimation = false;
    }
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Column(
            children: <Widget>[
              Container(
                height: _indicatorExtent,
                width: double.infinity,
                color: widget.backgroundColor,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      bottom: -40.0,
                      left: 0.0,
                      right: 0.0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              bottom: _toggleCircle ? 65.0 : 0.0),
                          duration: Duration(milliseconds: 400),
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: CircularProgressIndicator(
                        value: _progressValue,
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation(widget.color),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _backAnimation,
                      builder: (context, child) {
                        double offset = 0.0;
                        if (_backAnimation.value >=
                            _backAnimationPulledExtent) {
                          var animationValue =
                              _backAnimation.value - _backAnimationPulledExtent;
                          if (animationValue > 0 && animationValue != 110.0) {
                            toggleCircle = true;
                          }
                          if (animationValue <= 30.0) {
                            offset = animationValue;
                          } else if (animationValue > 30.0 &&
                              animationValue <= 50.0) {
                            offset = (20.0 - (animationValue - 30.0)) * 3 / 2;
                          } else if (animationValue > 50.0 &&
                              animationValue < 65.0) {
                            offset = animationValue - 50.0;
                          } else if (animationValue > 65.0) {
                            offset = (45.0 - (animationValue - 65.0)) / 3;
                          }
                        }
                        return ClipPath(
                          clipper: CirclePainter(offset: offset, up: false),
                          child: child,
                        );
                      },
                      child: Container(
                        color: widget.color,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: _pulledExtent > _indicatorExtent
                    ? _pulledExtent - _indicatorExtent
                    : 0.0,
                child: ClipPath(
                  clipper: CirclePainter(
                    offset: _showBackAnimation
                        ? _backAnimation.value < _backAnimationPulledExtent
                            ? _backAnimationPulledExtent - _backAnimation.value
                            : 0.0
                        : (_pulledExtent > _indicatorExtent &&
                                _refreshState != RefreshMode.refresh &&
                                _refreshState != RefreshMode.refreshed &&
                                _refreshState != RefreshMode.done
                            ? _pulledExtent - _indicatorExtent
                            : 0.0),
                    up: true,
                  ),
                  child: Container(
                    color: widget.backgroundColor,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 圆面切割
class CirclePainter extends CustomClipper<Path> {
  final double offset;
  final bool up;

  CirclePainter({this.offset, this.up});

  @override
  Path getClip(Size size) {
    final path = new Path();
    if (!up) path.moveTo(0.0, size.height);
    path.cubicTo(
        0.0,
        up ? 0.0 : size.height,
        size.width / 2,
        up ? offset * 2 : size.height - offset * 2,
        size.width,
        up ? 0.0 : size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return oldClipper != this;
  }
}
