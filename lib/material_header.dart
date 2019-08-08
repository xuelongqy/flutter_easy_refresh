import 'dart:async';
import 'package:flutter/material.dart';
import 'src/header/refresh_indicator.dart';
import 'src/header/header.dart';

// The duration of the ScaleTransition that starts when the refresh action
// has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// 质感设计Header
class MaterialHeader extends Header {
  final Key key;
  final double displacement;

  /// 颜色
  final Animation<Color> valueColor;

  /// 背景颜色
  final Color backgroundColor;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  MaterialHeader({
    this.key,
    this.displacement = 40.0,
    this.valueColor,
    this.backgroundColor,
    completeDuration = const Duration(seconds: 1),
    bool enableHapticFeedback = false,
  }) : super(
          float: true,
          extent: 70.0,
          triggerDistance: 70.0,
          completeDuration: completeDuration == null
              ? Duration(
                  milliseconds: 300,
                )
              : completeDuration +
                  Duration(
                    milliseconds: 300,
                  ),
          enableInfiniteRefresh: false,
          enableHapticFeedback: enableHapticFeedback,
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
    return MaterialHeaderWidget(
      key: key,
      displacement: displacement,
      valueColor: valueColor,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}

/// 质感设计Header组件
class MaterialHeaderWidget extends StatefulWidget {
  final double displacement;
  // 颜色
  final Animation<Color> valueColor;
  // 背景颜色
  final Color backgroundColor;
  final LinkHeaderNotifier linkNotifier;

  const MaterialHeaderWidget({
    Key key,
    this.displacement,
    this.valueColor,
    this.backgroundColor,
    this.linkNotifier,
  }) : super(key: key);

  @override
  MaterialHeaderWidgetState createState() {
    return MaterialHeaderWidgetState();
  }
}

class MaterialHeaderWidgetState extends State<MaterialHeaderWidget>
    with TickerProviderStateMixin<MaterialHeaderWidget> {
  static final Animatable<double> _oneToZeroTween =
      Tween<double>(begin: 1.0, end: 0.0);

  RefreshMode get _refreshState => widget.linkNotifier.refreshState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;
  double get _riggerPullDistance =>
      widget.linkNotifier.refreshTriggerPullDistance;
  Duration get _completeDuration => widget.linkNotifier.completeDuration;
  AxisDirection get _axisDirection => widget.linkNotifier.axisDirection;
  bool get _noMore => widget.linkNotifier.noMore;

  // 动画
  AnimationController _scaleController;
  Animation<double> _scaleFactor;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);
  }

  @override
  void dispose() {
    super.dispose();
    _scaleController.dispose();
  }

  // 是否刷新完成
  bool _refreshFinish = false;
  set refreshFinish(bool finish) {
    if (_refreshFinish != finish) {
      if (finish) {
        Future.delayed(_completeDuration - Duration(milliseconds: 300), () {
          if (mounted) {
            _scaleController.animateTo(1.0, duration: _kIndicatorScaleDuration);
          }
        });
        Future.delayed(_completeDuration, () {
          _refreshFinish = false;
          _scaleController.animateTo(0.0, duration: Duration(milliseconds: 10));
        });
      }
      _refreshFinish = finish;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_noMore) return Container();
    // 是否为垂直方向
    bool isVertical = _axisDirection == AxisDirection.down ||
        _axisDirection == AxisDirection.up;
    // 是否反向
    bool isReverse = _axisDirection == AxisDirection.up ||
        _axisDirection == AxisDirection.left;
    // 计算进度值
    double indicatorValue = _pulledExtent / _riggerPullDistance;
    indicatorValue = indicatorValue < 1.0 ? indicatorValue : 1.0;
    // 判断是否刷新结束
    if (_refreshState == RefreshMode.refreshed) {
      refreshFinish = true;
    }
    return Container(
      height: isVertical
          ? _refreshState == RefreshMode.inactive ? 0.0 : _pulledExtent
          : double.infinity,
      width: !isVertical
          ? _refreshState == RefreshMode.inactive ? 0.0 : _pulledExtent
          : double.infinity,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: isVertical ? isReverse ? 0.0 : null : 0.0,
            bottom: isVertical ? !isReverse ? 0.0 : null : 0.0,
            left: !isVertical ? isReverse ? 0.0 : null : 0.0,
            right: !isVertical ? !isReverse ? 0.0 : null : 0.0,
            child: Container(
              padding: EdgeInsets.only(
                top: isVertical ? isReverse ? 0.0 : widget.displacement : 0.0,
                bottom:
                    isVertical ? !isReverse ? 0.0 : widget.displacement : 0.0,
                left: !isVertical ? isReverse ? 0.0 : widget.displacement : 0.0,
                right:
                    !isVertical ? !isReverse ? 0.0 : widget.displacement : 0.0,
              ),
              alignment: isVertical
                  ? isReverse ? Alignment.topCenter : Alignment.bottomCenter
                  : isReverse ? Alignment.centerLeft : Alignment.centerRight,
              child: ScaleTransition(
                scale: _scaleFactor,
                child: RefreshProgressIndicator(
                  value: _refreshState == RefreshMode.armed ||
                          _refreshState == RefreshMode.refresh ||
                          _refreshState == RefreshMode.refreshed ||
                          _refreshState == RefreshMode.done
                      ? null
                      : indicatorValue,
                  valueColor: widget.valueColor,
                  backgroundColor: widget.backgroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
