import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'src/header/header.dart';

/// 球脉冲顶部视图
class BallPulseHeader extends RefreshHeader {
  // 颜色
  final Color color;
  // 背景颜色
  final Color backgroundColor;

  BallPulseHeader({
    @required GlobalKey<RefreshHeaderState> key,
    this.color: Colors.blue,
    this.backgroundColor: Colors.transparent,
  }) : super(
            key: key ?? new GlobalKey<RefreshHeaderState>(),
            refreshHeight: 70.0);

  @override
  BallPulseHeaderState createState() => BallPulseHeaderState();
}

class BallPulseHeaderState extends RefreshHeaderState<BallPulseHeader>
    with TickerProviderStateMixin<BallPulseHeader> {
  // 开始动画
  AnimationController _startController;
  Animation<double> _startAnimation;
  // 循环动画
  AnimationController _cycleController;
  Animation<double> _cycleAnimation;
  // 结束动画
  AnimationController _endController;
  Animation<double> _endAnimation;
  // 是否开启动画
  bool _isAnimation = false;

  // 三个球的大小
  double ballSize1 = 20.0;
  double ballSize2 = 20.0;
  double ballSize3 = 20.0;

  @override
  void initState() {
    super.initState();
    // 初始化开始动画
    _startController = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _startAnimation = new Tween(begin: 6.0, end: 20.0).animate(_startController)
      ..addListener(() {
        if (!mounted) return;
        if (_startAnimation.status == AnimationStatus.dismissed) return;
        setState(() {
          // 计算大小
          ballSize1 = 26.0 - _startAnimation.value;
          if (13.0 <= _startAnimation.value) {
            ballSize2 = 33.0 - _startAnimation.value;
          } else {
            ballSize2 = 20.0;
          }
          ballSize3 = 20.0;
        });
      });
    _startAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startController.reset();
        _cycleController.forward();
      }
    });
    // 初始化循环动画
    _cycleController = new AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _cycleAnimation = new Tween(begin: 6.0, end: 34.0).animate(_cycleController)
      ..addListener(() {
        if (!mounted) return;
        setState(() {
          // 计算大小
          ballSize1 = _cycleAnimation.value <= 20.0
              ? _cycleAnimation.value
              : 40.0 - _cycleAnimation.value;
          if (13.0 <= _cycleAnimation.value && _cycleAnimation.value <= 27.0) {
            ballSize2 = _cycleAnimation.value - 7.0;
          } else if (_cycleAnimation.value > 27.0) {
            ballSize2 = 47.0 - _cycleAnimation.value;
          } else {
            ballSize2 = 18.0 - _cycleAnimation.value;
          }
          ballSize3 = _cycleAnimation.value < 20.0
              ? 26.0 - _cycleAnimation.value
              : _cycleAnimation.value - 15.0;
        });
      });
    _cycleAnimation.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.completed) {
        _cycleController.reset();
        if (_isAnimation) {
          _cycleController.forward();
        } else {
          _endController.forward();
        }
      }
    });
    // 初始化结束动画
    _endController = new AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _endAnimation = new Tween(begin: 6.0, end: 20.0).animate(_endController)
      ..addListener(() {
        if (!mounted) return;
        setState(() {
          // 计算大小
          ballSize1 = _endAnimation.value;
          if (_endAnimation.value < 13.0) {
            ballSize2 = _endAnimation.value + 7.0;
          } else {
            ballSize2 = 20.0;
          }
          ballSize3 = 20.0;
        });
      });
    _startAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _endController.reset();
      }
    });
  }

  // 开始刷新
  @override
  void onRefreshStart() {
    super.onRefreshStart();
    _isAnimation = true;
    _startController.forward();
  }

  // 刷新结束
  @override
  void onRefreshClose() {
    super.onRefreshClose();
    _isAnimation = false;
  }

  @override
  void dispose() {
    _cycleController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: widget.backgroundColor,
        height: this.height,
        child: SingleChildScrollView(
            child: Container(
          height: this.height > 30.0 ? this.height : 30.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Center(
                    child: ClipOval(
                      child: Container(
                        color: widget.color,
                        height: ballSize1,
                        width: ballSize1,
                      ),
                    ),
                  )),
              Container(
                width: 5.0,
              ),
              SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Center(
                    child: ClipOval(
                      child: Container(
                        color: widget.color,
                        height: ballSize2,
                        width: ballSize2,
                      ),
                    ),
                  )),
              Container(
                width: 5.0,
              ),
              SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Center(
                    child: ClipOval(
                      child: Container(
                        color: widget.color,
                        height: ballSize3,
                        width: ballSize3,
                      ),
                    ),
                  )),
            ],
          ),
        )));
  }
}
