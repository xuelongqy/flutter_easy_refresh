import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'src/header/header.dart';

// How much the scroll's drag gesture can overshoot the RefreshIndicator's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

// The duration of the ScaleTransition that starts when the refresh action
// has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// 质感设计顶部视图
/// Copy from [RefreshIndicator]
class MaterialHeader extends RefreshHeader {
  /// The distance from the child's top or bottom edge to where the refresh
  /// indicator will settle. During the drag that exposes the refresh indicator,
  /// its actual displacement may significantly exceed this value.
  final double displacement;
  // 颜色
  final Animation<Color> valueColor;
  // 背景颜色
  final Color backgroundColor;

  MaterialHeader({
    @required GlobalKey<RefreshHeaderState> key,
    this.displacement: 40.0,
    this.valueColor,
    this.backgroundColor,
  }) : super(
            key: key ?? new GlobalKey<RefreshHeaderState>(),
            refreshHeight: 70.0,
            isFloat: true);

  @override
  MaterialHeaderState createState() => new MaterialHeaderState();
}

class MaterialHeaderState extends RefreshHeaderState<MaterialHeader>
    with TickerProviderStateMixin<MaterialHeader> {
  AnimationController _positionController;
  AnimationController _scaleController;
  Animation<double> _positionFactor;
  Animation<double> _scaleFactor;

  static final Animatable<double> _kDragSizeFactorLimitTween =
      Tween<double>(begin: 0.0, end: _kDragSizeFactorLimit);
  static final Animatable<double> _oneToZeroTween =
      Tween<double>(begin: 1.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);
  }

  // 更新视图高度
  void updateHeight(double newHeight) {
    super.updateHeight(newHeight);
    double positionValue = newHeight / 105.0;
    _positionController.value = positionValue < _kDragSizeFactorLimit
        ? positionValue
        : _kDragSizeFactorLimit;
  }

  // 完成刷新回调
  @override
  void onRefreshed() async {
    super.onRefreshed();
    // 此处延时用于等待加载完成显示时间
    await Future.delayed(new Duration(milliseconds: widget.finishDelay - 200));
    if (!mounted) return;
    _scaleController.animateTo(1.0, duration: _kIndicatorScaleDuration);
  }

  // 刷新结束回调
  @override
  void onRefreshEnd() {
    super.onRefreshEnd();
    _scaleController.animateTo(0.0, duration: Duration(milliseconds: 10));
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 计算进度值
    double indicatorValue = this.height / (widget.refreshHeight + 20.0);
    indicatorValue = indicatorValue < 0.75 ? indicatorValue : 0.75;
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0.0,
          bottom: null,
          left: 0.0,
          right: 0.0,
          child: SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: _positionFactor, // this is what brings it down
            child: Container(
              padding: EdgeInsets.only(top: widget.displacement),
              alignment: Alignment.topCenter,
              child: ScaleTransition(
                scale: _scaleFactor,
                child: AnimatedBuilder(
                  animation: _positionController,
                  builder: (BuildContext context, Widget child) {
                    return RefreshProgressIndicator(
                      value: this.refreshHeaderStatus ==
                                  RefreshHeaderStatus.REFRESHING ||
                              this.refreshHeaderStatus ==
                                  RefreshHeaderStatus.REFRESHED
                          ? null
                          : indicatorValue,
                      valueColor: widget.valueColor,
                      backgroundColor: widget.backgroundColor,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
