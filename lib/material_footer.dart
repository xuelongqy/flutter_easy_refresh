import 'package:flutter/material.dart';
import 'src/footer/footer.dart';
import 'dart:async';

// How much the scroll's drag gesture can overshoot the RefreshIndicator's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 3.0;

// The duration of the ScaleTransition that starts when the refresh action
// has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// 质感设计底部视图
/// Copy from [RefreshIndicator]
class MaterialFooter extends RefreshFooter {
  /// The distance from the child's top or bottom edge to where the refresh
  /// indicator will settle. During the drag that exposes the refresh indicator,
  /// its actual displacement may significantly exceed this value.
  final double displacement;
  // 颜色
  final Animation<Color> valueColor;
  // 背景颜色
  final Color backgroundColor;

  MaterialFooter({
    @required GlobalKey<RefreshFooterState> key,
    this.displacement: 40.0,
    this.valueColor,
    this.backgroundColor,
  }) : super(
            key: key ?? new GlobalKey<RefreshFooterState>(),
            loadHeight: 70.0,
            isFloat: true);
  @override
  MaterialFooterState createState() => MaterialFooterState();
}

class MaterialFooterState extends RefreshFooterState<MaterialFooter>
    with TickerProviderStateMixin<MaterialFooter> {
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

  // 加载完成回调
  @override
  void onLoaded() async {
    super.onLoaded();
    // 此处延时用于等待加载完成显示时间
    await Future.delayed(new Duration(milliseconds: widget.finishDelay - 200));
    if (!mounted) return;
    _scaleController.animateTo(1.0, duration: _kIndicatorScaleDuration);
  }

  // 没有更多数据回调
  @override
  void onNoMore() async {
    super.onNoMore();
    // 此处延时用于等待加载完成显示时间
    await Future.delayed(new Duration(milliseconds: widget.finishDelay - 200));
    if (!mounted) return;
    _scaleController.animateTo(1.0, duration: _kIndicatorScaleDuration);
  }

  // 加载结束回调
  @override
  void onLoadEnd() {
    super.onLoadEnd();
    _scaleController.animateTo(0.0, duration: Duration(milliseconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    // 计算进度值
    double indicatorValue = this.height / (widget.loadHeight + 20.0);
    indicatorValue = indicatorValue < 0.75 ? indicatorValue : 0.75;
    return Stack(
      children: <Widget>[
        Positioned(
          top: null,
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: SizeTransition(
            axisAlignment: 0.0,
            sizeFactor: _positionFactor, // this is what brings it down
            child: Container(
              padding: EdgeInsets.only(top: widget.displacement),
              alignment: Alignment.bottomCenter,
              child: ScaleTransition(
                scale: _scaleFactor,
                child: AnimatedBuilder(
                  animation: _positionController,
                  builder: (BuildContext context, Widget child) {
                    return RefreshProgressIndicator(
                      value: this.refreshFooterStatus ==
                                  RefreshFooterStatus.LOADING ||
                              this.refreshFooterStatus ==
                                  RefreshFooterStatus.LOADED
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
