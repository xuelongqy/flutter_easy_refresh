import 'dart:math' as math show sin, pi;

import 'package:flutter/material.dart';

import 'src/footer/load_indicator.dart';
import 'src/footer/footer.dart';

/// BezierBounceFooter
class BezierBounceFooter extends Footer {
  /// Key
  final Key key;

  /// 颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  final LinkFooterNotifier linkNotifier = LinkFooterNotifier();

  BezierBounceFooter({
    this.key,
    this.color = Colors.white,
    this.backgroundColor = Colors.blue,
    bool enableHapticFeedback = false,
  }) : super(
          extent: 80.0,
          triggerDistance: 80.0,
          float: false,
          enableHapticFeedback: enableHapticFeedback,
          enableInfiniteLoad: false,
          completeDuration: const Duration(seconds: 1),
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
    // 不能为水平方向以及反向
    assert(axisDirection == AxisDirection.down,
        'Widget can only be vertical and cannot be reversed');
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
    return BezierBounceFooterWidget(
      key: key,
      color: color,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}

/// BezierBounceFooter组件
class BezierBounceFooterWidget extends StatefulWidget {
  /// 颜色
  final Color color;

  /// 背景颜色
  final Color backgroundColor;

  final LinkFooterNotifier linkNotifier;

  const BezierBounceFooterWidget({
    Key key,
    this.color,
    this.backgroundColor,
    this.linkNotifier,
  }) : super(key: key);

  @override
  BezierBounceFooterWidgetState createState() {
    return BezierBounceFooterWidgetState();
  }
}

class BezierBounceFooterWidgetState extends State<BezierBounceFooterWidget>
    with TickerProviderStateMixin<BezierBounceFooterWidget> {
  LoadMode get _loadState => widget.linkNotifier.loadState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;
  double get _indicatorExtent => widget.linkNotifier.loadIndicatorExtent;
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

  // 是否显示三个小球
  bool _showThreeBall = false;

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
    // 计算小球透明度
    double ballOpacity;
    if (_loadState != LoadMode.drag && _loadState != LoadMode.armed) {
      ballOpacity = 0.0;
    } else if (_pulledExtent > _indicatorExtent + 40.0) {
      ballOpacity = 1.0;
    } else if (_pulledExtent > _indicatorExtent) {
      ballOpacity = (_pulledExtent - _indicatorExtent) / 40.0;
    } else {
      ballOpacity = 0.0;
    }
    // 启动回弹动画
    if (_loadState == LoadMode.armed) {
      showBackAnimation = true;
      _showThreeBall = true;
    } else if (_loadState == LoadMode.inactive) {
      showBackAnimation = false;
      _showThreeBall = false;
    }
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Column(
            children: <Widget>[
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
                                _loadState != LoadMode.load &&
                                _loadState != LoadMode.loaded &&
                                _loadState != LoadMode.done
                            ? _pulledExtent - _indicatorExtent
                            : 0.0),
                    up: false,
                  ),
                  child: Container(
                    color: widget.backgroundColor,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Container(
                height: _indicatorExtent,
                width: double.infinity,
                color: widget.backgroundColor,
                child: Stack(
                  children: <Widget>[
                    // 回弹动画组件
                    AnimatedBuilder(
                      animation: _backAnimation,
                      builder: (context, child) {
                        double offset = 0.0;
                        if (_backAnimation.value >=
                            _backAnimationPulledExtent) {
                          var animationValue =
                              _backAnimation.value - _backAnimationPulledExtent;
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
                          clipper: CirclePainter(offset: offset, up: true),
                          child: child,
                        );
                      },
                      child: Container(
                        color: widget.color,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // 五个小球
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Opacity(
                            opacity: ballOpacity / 4,
                            child: Icon(
                              Icons.lens,
                              size: 15.0,
                              color: widget.color,
                            ),
                          ),
                          Container(
                            width: _pulledExtent / 3,
                          ),
                          Opacity(
                            opacity: ballOpacity / 2,
                            child: Icon(
                              Icons.lens,
                              size: 15.0,
                              color: widget.color,
                            ),
                          ),
                          Container(
                            width: _pulledExtent / 3,
                          ),
                          Opacity(
                            opacity: ballOpacity,
                            child: Icon(
                              Icons.lens,
                              size: 15.0,
                              color: widget.color,
                            ),
                          ),
                          Container(
                            width: _pulledExtent / 3,
                          ),
                          Opacity(
                            opacity: ballOpacity / 2,
                            child: Icon(
                              Icons.lens,
                              size: 15.0,
                              color: widget.color,
                            ),
                          ),
                          Container(
                            width: _pulledExtent / 3,
                          ),
                          Opacity(
                            opacity: ballOpacity / 4,
                            child: Icon(
                              Icons.lens,
                              size: 15.0,
                              color: widget.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 旋转动画组件
                    AnimatedCrossFade(
                      firstChild: SizedBox(
                        width: double.infinity,
                        height: _indicatorExtent,
                        child: SpinKitThreeBounce(
                          color: widget.color,
                          size: 30.0,
                        ),
                      ),
                      secondChild: SizedBox(
                        width: double.infinity,
                        height: _indicatorExtent,
                      ),
                      crossFadeState: _showThreeBall
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 400),
                    ),
                  ],
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

/// 三个小球
/// 来源于flutter_spinkit
/*
MIT License
Copyright (c) 2018 Jeremiah Ogbomo
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
class SpinKitThreeBounce extends StatefulWidget {
  final Color color;
  final double size;
  final IndexedWidgetBuilder itemBuilder;

  SpinKitThreeBounce({
    Key key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
  })  : assert(
            !(itemBuilder is IndexedWidgetBuilder && color is Color) &&
                !(itemBuilder == null && color == null),
            'You should specify either a itemBuilder or a color'),
        assert(size != null),
        super(key: key);

  @override
  _SpinKitThreeBounceState createState() => _SpinKitThreeBounceState();
}

class _SpinKitThreeBounceState extends State<SpinKitThreeBounce>
    with SingleTickerProviderStateMixin {
  AnimationController _scaleCtrl;
  final _duration = const Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: _duration,
    )..repeat();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size(widget.size * 2, widget.size),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _circle(0, .0),
            _circle(1, .2),
            _circle(2, .4),
          ],
        ),
      ),
    );
  }

  Widget _circle(int index, double delay) {
    final _size = widget.size * 0.5;
    return ScaleTransition(
      scale: DelayTween(begin: 0.0, end: 1.0, delay: delay).animate(_scaleCtrl),
      child: SizedBox.fromSize(
        size: Size.square(_size),
        child: _itemBuilder(index),
      ),
    );
  }

  Widget _itemBuilder(int index) {
    return widget.itemBuilder != null
        ? widget.itemBuilder(context, index)
        : DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          );
  }
}

class DelayTween extends Tween<double> {
  final double delay;

  DelayTween({
    double begin,
    double end,
    this.delay,
  }) : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    return super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);
  }

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

class AngleDelayTween extends Tween<double> {
  final double delay;

  AngleDelayTween({
    double begin,
    double end,
    this.delay,
  }) : super(begin: begin, end: end);

  @override
  double lerp(double t) => super.lerp(math.sin((t - delay) * math.pi * 0.5));

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}
