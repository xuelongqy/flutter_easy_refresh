import 'package:flutter/widgets.dart';

import '../../easy_refresh.dart';

/// Header
abstract class Footer {
  /// Footer容器高度
  final double extent;
  /// 高度(超过这个高度出发刷新)
  final double triggerDistance;
  @Deprecated('目前还没有找到方案,设置无效')
  final bool float;
  // 完成延时
  final Duration completeDuration;
  /// 是否开启无限加载
  final bool enableInfiniteLoad;
  /// 开启震动反馈
  final bool enableHapticFeedback;

  Footer({
    this.extent = 60.0,
    this.triggerDistance = 70.0,
    this.float = false,
    this.completeDuration,
    this.enableInfiniteLoad = true,
    this.enableHapticFeedback = false,
  });

  // 构造器
  Widget builder(BuildContext context, EasyRefresh easyRefresh,
      ValueNotifier<bool> focusNotifier, ValueNotifier<bool> taskNotifier) {
    return EasyRefreshSliverLoadControl(
      loadIndicatorExtent: extent,
      loadTriggerPullDistance: triggerDistance,
      builder: contentBuilder,
      completeDuration: completeDuration,
      onLoad: easyRefresh.onLoad,
      focusNotifier: focusNotifier,
      taskNotifier: taskNotifier,
      taskIndependence: easyRefresh.taskIndependence,
      enableControlFinishLoad: easyRefresh.enableControlFinishLoad,
      enableInfiniteLoad: enableInfiniteLoad,
      //enableInfiniteLoad: enableInfiniteLoad && !float,
      enableHapticFeedback: enableHapticFeedback,
      //footerFloat: float,
      bindLoadIndicator: (finishLoad, resetLoadState) {
        if (easyRefresh.controller != null) {
          easyRefresh.controller.finishLoadCallBack = finishLoad;
          easyRefresh.controller.resetLoadStateCallBack = resetLoadState;
        }
      },
    );
  }

  // Header构造器
  Widget contentBuilder(
      BuildContext context,
      LoadIndicatorMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      bool float,
      Duration completeDuration,
      bool enableInfiniteLoad,
      bool success, bool noMore);
}

/// 通用Footer构造器
class CustomFooter extends Footer {

  /// Header构造器
  final LoadControlIndicatorBuilder footerBuilder;

  CustomFooter({
    extent = 60.0,
    triggerDistance = 70.0,
    completeDuration,
    @required this.footerBuilder,
  }) : super (
    extent: extent,
    triggerDistance: triggerDistance,
    completeDuration: completeDuration,
  );

  @override
  Widget contentBuilder(BuildContext context,
      LoadIndicatorMode loadState, double pulledExtent,
      double refreshTriggerPullDistance, double refreshIndicatorExtent,
      bool float,
      Duration completeDuration,
      bool enableInfiniteLoad,
      bool success, bool noMore) {
    return footerBuilder(context, loadState, pulledExtent,
        refreshTriggerPullDistance, refreshIndicatorExtent, float,
        completeDuration, enableInfiniteLoad, success, noMore);
  }
}

/// 经典Footer
class ClassicalFooter extends Footer {

  ClassicalFooter({
    extent = 60.0,
    triggerDistance = 70.0,
    completeDuration = const Duration(seconds: 1),
    enableInfiniteLoad = false,
    enableHapticFeedback = true,
  }): super(
    extent: extent,
    triggerDistance: triggerDistance,
    completeDuration: completeDuration,
    enableInfiniteLoad: enableInfiniteLoad,
    enableHapticFeedback: enableHapticFeedback,
  );

  @override
  Widget contentBuilder(BuildContext context, LoadIndicatorMode loadState,
      double pulledExtent, double refreshTriggerPullDistance,
      double refreshIndicatorExtent, bool float, Duration completeDuration,
      bool enableInfiniteLoad, bool success, bool noMore) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFF000000),
    );
  }
}