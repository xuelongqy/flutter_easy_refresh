import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'src/header/header.dart';

/// 弹出圆圈
class BezierCircleHeader extends RefreshHeader {
  // 颜色
  final Color color;
  // 背景颜色
  final Color backgroundColor;

  BezierCircleHeader({
    @required GlobalKey<RefreshHeaderState> key,
    this.color: Colors.white,
    this.backgroundColor: Colors.blue,
  }):super(
      key: key ?? new GlobalKey<RefreshHeaderState>(),
      refreshHeight: 80.0
  );

  @override
  BezierCircleHeaderState createState() => BezierCircleHeaderState();
}
class BezierCircleHeaderState extends RefreshHeaderState<BezierCircleHeader> with TickerProviderStateMixin<BezierCircleHeader> {
  // 顶部拉动偏差
  ValueNotifier<double> _topOffsetLis = new ValueNotifier(0.0);
  // 回弹动画
  AnimationController _backController;
  Animation<double> _backAnimation;
  // 回弹高度
  ValueNotifier<double> _backOffsetLis = new ValueNotifier(0.0);
  // 圆点高度
  ValueNotifier<double> _circlePointOffsetLis = new ValueNotifier(0.0);

  // 初始化
  @override
  void initState() {
    super.initState();
    // 回弹动画
    _backController = new AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _backAnimation = new Tween(begin: 0.0, end: 110.0).animate(_backController)
      ..addListener(() {
        setState(() {
          _circlePointOffsetLis.value = _backAnimation.value < 55.0 ? _backAnimation.value : 55.0;
          if (_backAnimation.value <= 30.0) {
            _backOffsetLis.value = _backAnimation.value;
          }else if (_backAnimation.value > 30.0 && _backAnimation.value <= 50.0) {
            _backOffsetLis.value = (20.0 - (_backAnimation.value - 30.0)) * 3 / 2;
          }else if (_backAnimation.value > 50.0 && _backAnimation.value < 65.0) {
            _backOffsetLis.value = _backAnimation.value - 50.0;
          }else if (_backAnimation.value > 65.0) {
            _backOffsetLis.value = (45.0 - (_backAnimation.value - 65.0)) / 3;
          }
        });
      });
    _backAnimation.addStatusListener((status){
      if (status == AnimationStatus.completed) {
        _backController.reset();
      }
    });
  }

  // 正在刷新
  @override
  Future onRefreshing() async {
    super.onRefreshing();
    _backController.forward();
  }

  // 高度更新
  @override
  void updateHeight(double newHeight) {
    _topOffsetLis.value = newHeight > widget.refreshHeight ? newHeight - widget.refreshHeight : 0.0;
    super.updateHeight(newHeight);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: this.height,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: this.height < widget.refreshHeight ? this.height : widget.refreshHeight,
            color: widget.backgroundColor,
            child: Stack(
              children: <Widget>[
//                Center(
//                  child: Container(
//                    width: 100.0,
//                    height: double.infinity,
//                    child: ClipPath(
//                      clipper: CirclePointPainter(offset: _circlePointOffsetLis.value),
//                      child: Container(
//                        color: widget.color,
//                        width: double.infinity,
//                        height: double.infinity,
//                      ),
//                    ),
//                  ),
//                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipPath(
                    clipper: CirclePainter(offset: _backOffsetLis.value, up:false),
                    child: Container(
                      color: widget.color,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            )
          ),
          Container(
            width: double.infinity,
            height: this.height > widget.refreshHeight ? this.height - widget.refreshHeight : 0.0,
            child: ClipPath(
              clipper: CirclePainter(offset: _topOffsetLis.value,up:true),
              child: new Container(
                color: widget.backgroundColor,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          )
        ],
      )
    );
  }
}

/// 圆面切割
class CirclePainter extends CustomClipper<Path> {
  final double offset;
  final bool up;

  CirclePainter({this.offset,this.up});

  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    final path = new Path();
    if(!up)
      path.moveTo(0.0, size.height);
    path.cubicTo(0.0, up?0.0:size.height, size.width / 2, up?offset*2:size.height-offset*2, size.width, up?0.0:size.height);
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
    // TODO: implement getClip
    final path = new Path();
    path.moveTo(0.0, size.height);
    path.cubicTo(0.0, size.height, size.width / 2, size.height-offset*2, size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return oldClipper != this;
  }
}