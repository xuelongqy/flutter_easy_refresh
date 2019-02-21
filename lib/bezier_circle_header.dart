import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'src/header/header.dart';
import 'dart:async';

/// 弹出圆圈顶部视图
class BezierCircleHeader extends RefreshHeader {
  // 颜色
  final Color color;
  // 背景颜色
  final Color backgroundColor;

  BezierCircleHeader({
    @required GlobalKey<RefreshHeaderState> key,
    this.color: Colors.white,
    this.backgroundColor: Colors.blue,
  }) : super(
            key: key ?? new GlobalKey<RefreshHeaderState>(),
            refreshHeight: 80.0);

  @override
  BezierCircleHeaderState createState() => BezierCircleHeaderState();
}

class BezierCircleHeaderState extends RefreshHeaderState<BezierCircleHeader>
    with TickerProviderStateMixin<BezierCircleHeader> {
  // 顶部拉动偏差
  ValueNotifier<double> _topOffsetLis = new ValueNotifier(0.0);
  // 回弹动画
  AnimationController _backController;
  Animation<double> _backAnimation;
  // 恢复动画
  AnimationController _recoveryController;
  Animation<double> _recoveryAnimation;
  // 回弹高度
  ValueNotifier<double> _backOffsetLis = new ValueNotifier(0.0);
  // 圆点位移偏差
  ValueNotifier<double> _circlePointOffsetLis = new ValueNotifier(0.0);
  // 是否显示进度条
  bool _showProgress = false;
  // 进度值
  double progressValue;

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
          _circlePointOffsetLis.value = _backAnimation.value;
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
            _showProgress = true;
            _backOffsetLis.value = (45.0 - (_backAnimation.value - 65.0)) / 3;
          }
        });
      });
    // 恢复动画
    _recoveryController = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _recoveryAnimation =
        new Tween(begin: 55.0, end: 0.0).animate(_recoveryController)
          ..addListener(() {
            setState(() {
              _circlePointOffsetLis.value = _recoveryAnimation.value;
            });
          });
  }

  // 正在刷新
  @override
  void onRefreshing() {
    super.onRefreshing();
    _backController.reset();
    _backController.forward();
  }

  // 刷新结束
  @override
  void onRefreshed() async {
    super.onRefreshed();
    setState(() {
      progressValue = 1.0;
    });
    await new Future.delayed(const Duration(milliseconds: 400), () {});
    if (!mounted) return;
    setState(() {
      _showProgress = false;
      progressValue = null;
    });
    _recoveryController.reset();
    _recoveryController.forward();
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
  void dispose() {
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 圆点大小
    double circlePointSize;
    if (_circlePointOffsetLis.value <= 10.0) {
      circlePointSize = 0.0;
    } else if (_circlePointOffsetLis.value < 45.0) {
      circlePointSize = _circlePointOffsetLis.value - 10.0;
    } else {
      circlePointSize = 30.0;
    }
    // 圆点底部距离
    double circlePointBottomOffset;
    if (_circlePointOffsetLis.value <= 40.0) {
      circlePointBottomOffset = 0.0;
    } else if (_circlePointOffsetLis.value < 55.0) {
      circlePointBottomOffset = _circlePointOffsetLis.value - 30.0;
    } else {
      circlePointBottomOffset = 25.0;
    }
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
                    Center(
                      child: Offstage(
                        offstage: !_showProgress,
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(widget.color),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ClipOval(
                          child: Container(
                            color: widget.color,
                            height: circlePointSize,
                            width: circlePointSize,
                          ),
                        ),
                        Container(
                          height: circlePointBottomOffset,
                        )
                      ],
                    ),
                    Center(
                      child: Container(
                        width: 100.0,
                        height: double.infinity,
                        child: ClipPath(
                          clipper: CirclePointPainter(
                              offset: _circlePointOffsetLis.value),
                          child: Container(
                            color: widget.color,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
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

// 圆点切割
class CirclePointPainter extends CustomClipper<Path> {
  final double offset;

  CirclePointPainter({this.offset});

  @override
  Path getClip(Size size) {
    final path = new Path();
    if (offset < 55.0) {
      double width = size.width - offset / 2;
      path.moveTo((size.width - width) / 2, size.height);
      path.cubicTo(
          (size.width - width) / 2,
          size.height,
          size.width / 2,
          size.height - offset * 2,
          size.width - (size.width - width) / 2,
          size.height);
      path.close();
    } else if (offset >= 55.0 && offset < 90.0) {
      double width = 30.0;
      path.moveTo((size.width - width) / 2, size.height - 40.0);
      path.cubicTo(
          (size.width - width) / 2,
          size.height - 40.0,
          (size.width - width) / 2 + (offset - 55.0),
          size.height - 20.0,
          (size.width - width) / 2,
          size.height);
      path.lineTo(size.width - (size.width - width) / 2, size.height);
      path.cubicTo(
          size.width - (size.width - width) / 2,
          size.height,
          size.width - (size.width - width) / 2 - (offset - 55.0),
          size.height - 20.0,
          size.width - (size.width - width) / 2,
          size.height - 40.0);
      path.close();
    } else {
      double width = 30.0 + (offset - 90.0) * 3;
      double height = size.height - (110.0 - offset) * 2;
      path.moveTo((size.width - width) / 2, size.height);
      path.cubicTo((size.width - width) / 2, size.height, size.width / 2,
          height, size.width - (size.width - width) / 2, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return oldClipper != this;
  }
}
