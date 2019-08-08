import 'package:flutter/material.dart';

import 'src/footer/load_indicator.dart';
import 'src/footer/footer.dart';

/// 质感设计Footer
class MaterialFooter extends Footer {
  final Key key;
  final double displacement;

  /// 颜色
  final Animation<Color> valueColor;

  /// 背景颜色
  final Color backgroundColor;

  final LinkFooterNotifier linkNotifier = LinkFooterNotifier();

  MaterialFooter({
    this.key,
    this.displacement = 40.0,
    this.valueColor,
    this.backgroundColor,
    completeDuration = const Duration(seconds: 1),
    bool enableHapticFeedback = false,
    bool enableInfiniteLoad = true,
  }) : super(
          float: true,
          extent: 52.0,
          triggerDistance: 52.0,
          completeDuration: completeDuration == null
              ? Duration(
                  milliseconds: 300,
                )
              : completeDuration +
                  Duration(
                    milliseconds: 300,
                  ),
          enableHapticFeedback: enableHapticFeedback,
          enableInfiniteLoad: enableInfiniteLoad,
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
    return MaterialFooterWidget(
      key: key,
      displacement: displacement,
      valueColor: valueColor,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}

/// 质感设计Footer组件
class MaterialFooterWidget extends StatefulWidget {
  final double displacement;
  // 颜色
  final Animation<Color> valueColor;
  // 背景颜色
  final Color backgroundColor;
  final LinkFooterNotifier linkNotifier;

  const MaterialFooterWidget({
    Key key,
    this.displacement,
    this.valueColor,
    this.backgroundColor,
    this.linkNotifier,
  }) : super(key: key);

  @override
  MaterialFooterWidgetState createState() {
    return MaterialFooterWidgetState();
  }
}

class MaterialFooterWidgetState extends State<MaterialFooterWidget> {
  LoadMode get _refreshState => widget.linkNotifier.loadState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;
  double get _riggerPullDistance => widget.linkNotifier.loadTriggerPullDistance;
  AxisDirection get _axisDirection => widget.linkNotifier.axisDirection;
  bool get _noMore => widget.linkNotifier.noMore;

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
    return Stack(
      children: <Widget>[
        Positioned(
          top: isVertical ? !isReverse ? 0.0 : null : 0.0,
          bottom: isVertical ? isReverse ? 0.0 : null : 0.0,
          left: !isVertical ? !isReverse ? 0.0 : null : 0.0,
          right: !isVertical ? isReverse ? 0.0 : null : 0.0,
          child: Container(
            alignment: isVertical
                ? !isReverse ? Alignment.topCenter : Alignment.bottomCenter
                : !isReverse ? Alignment.centerLeft : Alignment.centerRight,
            child: RefreshProgressIndicator(
              value: _refreshState == LoadMode.armed ||
                      _refreshState == LoadMode.load ||
                      _refreshState == LoadMode.loaded ||
                      _refreshState == LoadMode.done
                  ? null
                  : indicatorValue,
              valueColor: widget.valueColor,
              backgroundColor: widget.backgroundColor,
            ),
          ),
        ),
      ],
    );
  }
}
