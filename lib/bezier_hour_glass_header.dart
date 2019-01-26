import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'src/header/header.dart';
import 'dart:math' as math;

/// 弹出HourGlass顶部视图
class BezierHourGlassHeader extends RefreshHeader {
  // 颜色
  final Color color;
  // 背景颜色
  final Color backgroundColor;

  BezierHourGlassHeader({
    @required GlobalKey<RefreshHeaderState> key,
    this.color: Colors.white,
    this.backgroundColor: Colors.blue,
  }) : super(
            key: key ?? new GlobalKey<RefreshHeaderState>(),
            refreshHeight: 80.0);

  @override
  BezierHourGlassHeaderState createState() => BezierHourGlassHeaderState();
}

class BezierHourGlassHeaderState
    extends RefreshHeaderState<BezierHourGlassHeader>
    with TickerProviderStateMixin<BezierHourGlassHeader> {
  // 顶部拉动偏差
  ValueNotifier<double> _topOffsetLis = new ValueNotifier(0.0);
  // 回弹动画
  AnimationController _backController;
  Animation<double> _backAnimation;
  // 回弹高度
  ValueNotifier<double> _backOffsetLis = new ValueNotifier(0.0);
  // 是否显示水波纹
  bool isHidingRipple = false;
  // 是否显示HourGlass
  bool showHourGlass = false;

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

  // 正在刷新
  @override
  void onRefreshing() {
    super.onRefreshing();
    _backController.reset();
    _backController.forward();
    setState(() {
      showHourGlass = true;
    });
  }

  // 刷新完成
  @override
  void onRefreshed() {
    super.onRefreshed();
    setState(() {
      isHidingRipple = true;
    });
  }

  // 刷新结束
  @override
  void onRefreshEnd() {
    super.onRefreshEnd();
    setState(() {
      isHidingRipple = false;
      showHourGlass = false;
    });
  }

  @override
  void dispose() {
    _backController.dispose();
    super.dispose();
  }

  // 高度更新
  @override
  void updateHeight(double newHeight) {
    _topOffsetLis.value = newHeight > widget.refreshHeight
        ? newHeight - widget.refreshHeight
        : 0.0;
    super.updateHeight(newHeight);
  }

  @override
  Widget build(BuildContext context) {
    // 计算小球透明度
    double ballOpacity;
    if (this.height > widget.refreshHeight + 40.0) {
      ballOpacity = 1.0;
    } else if (this.height > widget.refreshHeight) {
      ballOpacity = (this.height - widget.refreshHeight) / 40.0;
    } else {
      ballOpacity = 0.0;
    }
    // 计算水波纹宽度
    double rippleWidth = MediaQuery.of(context).size.width *
        ((widget.refreshHeight - this.height) / widget.refreshHeight);
    rippleWidth = rippleWidth < 0.0 ? 0.0 : rippleWidth;
    rippleWidth = rippleWidth < MediaQuery.of(context).size.width
        ? rippleWidth
        : MediaQuery.of(context).size.width;
    return new Container(
        height: this.height,
        child: Column(
          children: <Widget>[
            Container(
                width: double.infinity,
                height: this.height < widget.refreshHeight
                    ? this.height
                    : widget.refreshHeight,
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
                      offstage: !showHourGlass,
                      child: SpinKitHourGlass(
                        color: widget.color,
                        size: 30.0,
                      ),
                    ),
                    Offstage(
                        offstage: !isHidingRipple,
                        child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                              child: Container(
                                width: rippleWidth,
                                height: double.infinity,
                                color: widget.color,
                              ),
                            ))),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ClipPath(
                        clipper: CirclePainter(
                            offset: _backOffsetLis.value, up: false),
                        child: Container(
                          color: widget.color,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ],
                )),
            Container(
              width: double.infinity,
              height: this.height > widget.refreshHeight
                  ? this.height - widget.refreshHeight
                  : 0.0,
              child: ClipPath(
                clipper: CirclePainter(offset: _topOffsetLis.value, up: true),
                child: new Container(
                  color: widget.backgroundColor,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            )
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

/// HourGlass
/// 来源于flutter_spinkit
/*
MIT License

Copyright (c) 2018 Jeremiah Ogbomo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
class SpinKitHourGlass extends StatefulWidget {
  final Color color;
  final double size;

  const SpinKitHourGlass({
    Key key,
    @required this.color,
    this.size = 50.0,
  })  : assert(color != null),
        assert(size != null),
        super(key: key);

  @override
  _SpinKitHourGlassState createState() => _SpinKitHourGlassState();
}

class _SpinKitHourGlassState extends State<SpinKitHourGlass>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _animation1 = Tween(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    )..addListener(() => setState(() => <String, void>{}));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = Matrix4.identity()
      ..rotateZ((_animation1.value) * math.pi);
    return Center(
      child: Transform(
        transform: transform,
        alignment: FractionalOffset.center,
        child: CustomPaint(
          child: Container(
            height: widget.size,
            width: widget.size,
          ),
          painter: _HourGlassPainter(color: widget.color),
        ),
      ),
    );
  }
}

class _HourGlassPainter extends CustomPainter {
  Paint p = Paint();
  final double weight;

  _HourGlassPainter({this.weight = 90.0, Color color}) {
    p.color = color;
    p.strokeWidth = 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      0.0,
      getRadian(weight),
      true,
      p,
    );
    canvas.drawArc(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      getRadian(180.0),
      getRadian(weight),
      true,
      p,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double angle) {
    return math.pi / 180 * angle;
  }
}
