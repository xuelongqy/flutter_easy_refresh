import 'package:flutter/material.dart';
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
      ValueNotifier<bool> focusNotifier, ValueNotifier<bool> taskNotifier) {
    return EasyRefreshSliverRefreshControl(
      refreshIndicatorExtent: extent,
      refreshTriggerPullDistance: triggerDistance,
      builder: contentBuilder,
      completeDuration: completeDuration,
      onRefresh: easyRefresh.onRefresh,
      focusNotifier: focusNotifier,
      taskNotifier: taskNotifier,
      taskIndependence: easyRefresh.taskIndependence,
      enableControlFinishRefresh: easyRefresh.enableControlFinishRefresh,
      enableInfiniteRefresh: enableInfiniteRefresh && !float,
      enableHapticFeedback: enableHapticFeedback,
      headerFloat: float,
      bindRefreshIndicator: (finishRefresh, resetRefreshState) {
        if (easyRefresh.controller != null) {
          easyRefresh.controller.finishRefreshCallBack = finishRefresh;
          easyRefresh.controller.resetRefreshStateCallBack = resetRefreshState;
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
      bool float,
      Duration completeDuration,
      bool enableInfiniteRefresh,
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
      bool float, Duration completeDuration, bool enableInfiniteRefresh,
      bool success, bool noMore) {
    return headerBuilder(context, refreshState, pulledExtent,
      refreshTriggerPullDistance, refreshIndicatorExtent, float,
        completeDuration, enableInfiniteRefresh, success, noMore);
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
      double refreshIndicatorExtent, bool float,
      Duration completeDuration,
      bool enableInfiniteRefresh, bool success, bool noMore) {
    return ClassicalHeaderWidget(
      classicalHeader: this,
      refreshState: refreshState,
      pulledExtent: pulledExtent,
      refreshTriggerPullDistance: refreshTriggerPullDistance,
      refreshIndicatorExtent: refreshIndicatorExtent,
      float: float,
      completeDuration: completeDuration,
      enableInfiniteRefresh: enableInfiniteRefresh,
      success: success,
      noMore: noMore,
    );
  }
}

/// 经典Header组件
class ClassicalHeaderWidget extends StatefulWidget {
  final ClassicalHeader classicalHeader;
  final RefreshIndicatorMode refreshState;
  final double pulledExtent;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;
  final bool float;
  final Duration completeDuration;
  final bool enableInfiniteRefresh;
  final bool success;
  final bool noMore;

  const ClassicalHeaderWidget({Key key,
    this.refreshState, this.classicalHeader,
    this.pulledExtent, this.refreshTriggerPullDistance,
    this.refreshIndicatorExtent, this.float,
    this.completeDuration, this.enableInfiniteRefresh,
    this.success, this.noMore}) : super(key: key);

  @override
  ClassicalHeaderWidgetState createState() => ClassicalHeaderWidgetState();
}
class ClassicalHeaderWidgetState extends State<ClassicalHeaderWidget> {
  // 显示文字
  String get _showText {
    switch (widget.refreshState) {
      case RefreshIndicatorMode.refresh:
        return '正在刷新...';
      case RefreshIndicatorMode.refreshed:
        return '刷新完成';
      case RefreshIndicatorMode.done:
        return '刷新完成';
      default:
        return '下拉刷新';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            width: double.infinity,
            height: widget.refreshIndicatorExtent > widget.pulledExtent
                ? widget.refreshIndicatorExtent : widget.pulledExtent,
            child: Container(
              height: widget.refreshIndicatorExtent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 10.0,),
                      child: widget.refreshState == RefreshIndicatorMode.refresh
                          ? Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(Colors.black,),
                        ),
                      ) : Transform.rotate(
                        child: Icon(
                          widget.refreshState == RefreshIndicatorMode.refreshed
                              ||  widget.refreshState == RefreshIndicatorMode.done
                              ? Icons.done : Icons.arrow_downward,
                        ),
                        angle: 0.0,
                      ),
                    )
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(_showText,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}