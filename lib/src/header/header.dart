import 'package:flutter/widgets.dart';

import '../listener/scroll_notification_listener.dart';
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
  /// 指示器滚动焦点变化回调
  ScrollFocusCallback _onFocus;

  Header({
    this.extent = 60.0,
    this.triggerDistance = 70.0,
    this.float = false,
    this.completeDuration,
    this.enableInfiniteRefresh = false,
    this.enableHapticFeedback = false,
  });

  // 滚动焦点变化
  void onFocus(bool focus) {
    if (_onFocus != null) _onFocus(focus);
  }

  // 构造器
  Widget builder(BuildContext context, EasyRefresh easyRefresh) {
    return EasyRefreshSliverRefreshControl(
      refreshIndicatorExtent: extent,
      refreshTriggerPullDistance: triggerDistance,
      builder: contentBuilder,
      completeDuration: completeDuration,
      onRefresh: easyRefresh.onRefresh,
      enableControlFinishRefresh: easyRefresh.enableControlFinishRefresh,
      enableInfiniteRefresh: enableInfiniteRefresh,
      enableHapticFeedback: enableHapticFeedback,
      bindRefreshIndicator: (finishRefresh, onFocus) {
        if (easyRefresh.controller != null) {
          easyRefresh.controller.finishRefresh = finishRefresh;
        }
        this._onFocus = onFocus;
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
      bool success, bool nomore);
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
      bool success, bool nomore) {
    return headerBuilder(context, refreshState, pulledExtent,
      refreshTriggerPullDistance, refreshIndicatorExtent, success, nomore);
  }
}

/// 经典Header
class ClassicalHeader extends Header{

  ClassicalHeader({
    extent = 60.0,
    triggerDistance = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
    enableHapticFeedback = true,
  }): super(
    extent: extent,
    triggerDistance: triggerDistance,
    float: float,
    completeDuration: completeDuration,
    enableHapticFeedback: enableHapticFeedback,
  );

  @override
  Widget contentBuilder(BuildContext context, RefreshIndicatorMode refreshState,
      double pulledExtent, double refreshTriggerPullDistance,
      double refreshIndicatorExtent, bool success, bool nomore) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFF000000),
    );
  }
}