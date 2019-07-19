import 'package:flutter/widgets.dart';

import '../../easy_refresh.dart';

/// Header
abstract class Header {
  /// Header容器高度
  final double extent;
  /// 触发刷新高度
  final double triggerDistance;
  /// 是否浮动
  final bool float;
  /// 完成延时
  final Duration completeDuration;
  /// 是否开启无限刷新
  final bool enableInfiniteRefresh;
  /// 开启震动反馈
  final bool enableHapticFeedback;


  Header({
    this.extent = 60.0,
    this.triggerDistance = 70.0,
    this.float = false,
    this.completeDuration,
    this.enableInfiniteRefresh = false,
    this.enableHapticFeedback = false,
  });

  // 构造器
  Widget builder(BuildContext context, EasyRefresh easyRefresh,
      ValueNotifier<bool> focusNotifier) {
    return EasyRefreshSliverRefreshControl(
      refreshIndicatorExtent: extent,
      refreshTriggerPullDistance: triggerDistance,
      builder: contentBuilder,
      completeDuration: completeDuration,
      onRefresh: easyRefresh.onRefresh,
      focusNotifier: focusNotifier,
      enableControlFinishRefresh: easyRefresh.enableControlFinishRefresh,
      enableInfiniteRefresh: enableInfiniteRefresh && !float,
      enableHapticFeedback: enableHapticFeedback,
      headerFloat: float,
      bindRefreshIndicator: (finishRefresh, resetRefreshState) {
        if (easyRefresh.controller != null) {
          easyRefresh.controller.finishRefresh = finishRefresh;
          easyRefresh.controller.resetRefreshState = resetRefreshState;
        }
      },
    );
  }

  // Header构造器
  Widget contentBuilder(
      BuildContext context,
      RefreshIndicatorMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      bool success, bool noMore);
}

/// 通用Header
class CustomHeader extends Header {

  /// Header构造器
  final RefreshControlIndicatorBuilder headerBuilder;

  CustomHeader({
    extent = 60.0,
    triggerDistance = 70.0,
    float = false,
    completeDuration,
    @required this.headerBuilder,
  }) : super (
    extent: extent,
    triggerDistance: triggerDistance,
    float: float,
    completeDuration: completeDuration,
  );

  @override
  Widget contentBuilder(BuildContext context,
      RefreshIndicatorMode refreshState, double pulledExtent,
      double refreshTriggerPullDistance, double refreshIndicatorExtent,
      bool success, bool noMore) {
    return headerBuilder(context, refreshState, pulledExtent,
      refreshTriggerPullDistance, refreshIndicatorExtent, success, noMore);
  }
}

/// 经典Header
class ClassicalHeader extends Header{

  ClassicalHeader({
    extent = 60.0,
    triggerDistance = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
    enableInfiniteRefresh = false,
    enableHapticFeedback = true,
  }): super(
    extent: extent,
    triggerDistance: triggerDistance,
    float: float,
    completeDuration: completeDuration,
    enableInfiniteRefresh: enableInfiniteRefresh,
    enableHapticFeedback: enableHapticFeedback,
  );

  @override
  Widget contentBuilder(BuildContext context, RefreshIndicatorMode refreshState,
      double pulledExtent, double refreshTriggerPullDistance,
      double refreshIndicatorExtent, bool success, bool noMore) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFF000000),
    );
  }
}