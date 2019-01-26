import 'package:flutter_easyrefresh/src/footer/footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math show sin, pi;

/// 弹出底部视图
class BezierBounceFooter extends RefreshFooter {
  // 颜色
  final Color color;
  // 背景颜色
  final Color backgroundColor;

  BezierBounceFooter({
    @required GlobalKey<RefreshFooterState> key,
    this.color: Colors.white,
    this.backgroundColor: Colors.blue,
  }) : super(key: key ?? new GlobalKey<RefreshFooterState>(), loadHeight: 80.0);

  @override
  BezierBounceFooterState createState() => BezierBounceFooterState();
}

class BezierBounceFooterState extends RefreshFooterState<BezierBounceFooter>
    with TickerProviderStateMixin<BezierBounceFooter> {
  // 顶部拉动偏差
  ValueNotifier<double> _bottomOffsetLis = new ValueNotifier(0.0);
  // 回弹动画
  AnimationController _backController;
  Animation<double> _backAnimation;
  // 回弹高度
  ValueNotifier<double> _backOffsetLis = new ValueNotifier(0.0);
  // 是否显示加载球
  bool showBounce = false;

  // 初始化
  @override
  void initState() {
    super.initState();
    // 回弹动画
    _backController = new AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _backAnimation = new Tween(begin: 0.0, end: 110.0).animate(_backController)
      ..addListener(() {
        setState(() {
          if (_backAnimation.value <= 30.0) {
            _backOffsetLis.value = _backAnimation.value;
          } else if (_backAnimation.value > 30.0 &&
              _backAnimation.value <= 50.0) {
            _backOffsetLis.value =
                (20.0 - (_backAnimation.value - 30.0)) * 3 / 2;
          } else if (_backAnimation.value > 50.0 &&
              _backAnimation.value < 65.0) {
            _backOffsetLis.value = _backAnimation.value - 50.0;
          } else if (_backAnimation.value > 65.0) {
            _backOffsetLis.value = (45.0 - (_backAnimation.value - 65.0)) / 3;
          }
        });
      });
  }

  // 高度更新
  @override
  void updateHeight(double newHeight) {
    _bottomOffsetLis.value =
        newHeight > widget.loadHeight ? newHeight - widget.loadHeight : 0.0;
    super.updateHeight(newHeight);
  }

  // 正在加载
  @override
  void onLoading() {
    super.onLoading();
    _backController.reset();
    _backController.forward();
    setState(() {
      showBounce = true;
    });
  }

  // 加载结束
  @override
  void onLoadClose() {
    super.onLoadClose();
    setState(() {
      showBounce = false;
    });
  }

  @override
  void dispose() {
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 计算小球透明度
    double ballOpacity;
    if (this.height > widget.loadHeight + 30.0) {
      ballOpacity = 1.0;
    } else if (this.height > widget.loadHeight) {
      ballOpacity = (this.height - widget.loadHeight) / 30.0;
    } else {
      ballOpacity = 0.0;
    }
    return new Container(
        height: this.height,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: this.height > widget.loadHeight
                  ? this.height - widget.loadHeight
                  : 0.0,
              child: ClipPath(
                clipper:
                    CirclePainter(offset: _bottomOffsetLis.value, up: false),
                child: new Container(
                  color: widget.backgroundColor,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Container(
                width: double.infinity,
                height: this.height < widget.loadHeight
                    ? this.height
                    : widget.loadHeight,
                color: widget.backgroundColor,
                child: Stack(
                  children: <Widget>[
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
                            width: this.height / 3,
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
                            width: this.height / 3,
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
                            width: this.height / 3,
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
                            width: this.height / 3,
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
                    Offstage(
                      offstage: !showBounce,
                      child: SpinKitThreeBounce(
                        color: widget.color,
                        size: 30.0,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ClipPath(
                        clipper: CirclePainter(
                            offset: _backOffsetLis.value, up: true),
                        child: Container(
                          color: widget.color,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ));
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
