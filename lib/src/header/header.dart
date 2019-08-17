import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
  Widget builder(
      BuildContext context,
      EasyRefresh easyRefresh,
      ValueNotifier<bool> focusNotifier,
      ValueNotifier<bool> taskNotifier,
      ValueNotifier<bool> callRefreshNotifier) {
    return EasyRefreshSliverRefreshControl(
      refreshIndicatorExtent: extent,
      refreshTriggerPullDistance: triggerDistance,
      builder: contentBuilder,
      completeDuration: completeDuration,
      onRefresh: easyRefresh.onRefresh,
      focusNotifier: focusNotifier,
      taskNotifier: taskNotifier,
      callRefreshNotifier: callRefreshNotifier,
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
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore);
}

/// 通用Header
class CustomHeader extends Header {
  /// Header构造器
  final RefreshControlBuilder headerBuilder;

  CustomHeader({
    extent = 60.0,
    triggerDistance = 70.0,
    float = false,
    completeDuration,
    enableInfiniteRefresh = false,
    enableHapticFeedback = false,
    @required this.headerBuilder,
  }) : super(
          extent: extent,
          triggerDistance: triggerDistance,
          float: float,
          completeDuration: completeDuration,
          enableInfiniteRefresh: enableInfiniteRefresh,
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
    return headerBuilder(
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
  }
}

/// 连接通知器
class LinkHeaderNotifier extends ChangeNotifier {
  BuildContext context;
  RefreshMode refreshState = RefreshMode.inactive;
  double pulledExtent = 0.0;
  double refreshTriggerPullDistance;
  double refreshIndicatorExtent;
  AxisDirection axisDirection;
  bool float;
  Duration completeDuration;
  bool enableInfiniteRefresh;
  bool success = true;
  bool noMore = false;

  void contentBuilder(
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
    this.context = context;
    this.refreshState = refreshState;
    this.pulledExtent = pulledExtent;
    this.refreshTriggerPullDistance = refreshTriggerPullDistance;
    this.refreshIndicatorExtent = refreshIndicatorExtent;
    this.axisDirection = axisDirection;
    this.float = float;
    this.completeDuration = completeDuration;
    this.enableInfiniteRefresh = enableInfiniteRefresh;
    this.success = success;
    this.noMore = noMore;
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      notifyListeners();
    });
  }
}

/// 连接器Header
class LinkHeader extends Header {
  final LinkHeaderNotifier linkNotifier;

  LinkHeader(
    this.linkNotifier, {
    extent = 60.0,
    triggerDistance = 70.0,
    completeDuration,
    enableHapticFeedback = false,
  }) : super(
          extent: extent,
          triggerDistance: triggerDistance,
          float: true,
          completeDuration: completeDuration,
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
    return SizedBox(
      width: 0.0,
      height: 0.0,
    );
  }
}

/// 经典Header
class ClassicalHeader extends Header {
  /// Key
  final Key key;

  /// 方位
  final AlignmentGeometry alignment;

  /// 提示刷新文字
  final String refreshText;

  /// 准备刷新文字
  final String refreshReadyText;

  /// 正在刷新文字
  final String refreshingText;

  /// 刷新完成文字
  final String refreshedText;

  /// 刷新失败文字
  final String refreshFailedText;

  /// 没有更多文字
  final String noMoreText;

  /// 显示额外信息(默认为时间)
  final bool showInfo;

  /// 更多信息
  final String infoText;

  /// 背景颜色
  final Color bgColor;

  /// 字体颜色
  final Color textColor;

  /// 更多信息文字颜色
  final Color infoColor;

  ClassicalHeader({
    extent = 60.0,
    triggerDistance = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
    enableInfiniteRefresh = false,
    enableHapticFeedback = true,
    this.key,
    this.alignment,
    this.refreshText: "Pull to refresh",
    this.refreshReadyText: "Release to refresh",
    this.refreshingText: "Refreshing...",
    this.refreshedText: "Refresh completed",
    this.refreshFailedText: "Refresh failed",
    this.noMoreText: "No more",
    this.showInfo: true,
    this.infoText: "Updated at %T",
    this.bgColor: Colors.transparent,
    this.textColor: Colors.black,
    this.infoColor: Colors.teal,
  }) : super(
          extent: extent,
          triggerDistance: triggerDistance,
          float: float,
          completeDuration: float
              ? completeDuration == null
                  ? Duration(
                      milliseconds: 400,
                    )
                  : completeDuration +
                      Duration(
                        milliseconds: 400,
                      )
              : completeDuration,
          enableInfiniteRefresh: enableInfiniteRefresh,
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
    return ClassicalHeaderWidget(
      key: key,
      classicalHeader: this,
      refreshState: refreshState,
      pulledExtent: pulledExtent,
      refreshTriggerPullDistance: refreshTriggerPullDistance,
      refreshIndicatorExtent: refreshIndicatorExtent,
      axisDirection: axisDirection,
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
  final RefreshMode refreshState;
  final double pulledExtent;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;
  final AxisDirection axisDirection;
  final bool float;
  final Duration completeDuration;
  final bool enableInfiniteRefresh;
  final bool success;
  final bool noMore;

  ClassicalHeaderWidget(
      {Key key,
      this.refreshState,
      this.classicalHeader,
      this.pulledExtent,
      this.refreshTriggerPullDistance,
      this.refreshIndicatorExtent,
      this.axisDirection,
      this.float,
      this.completeDuration,
      this.enableInfiniteRefresh,
      this.success,
      this.noMore})
      : super(key: key);

  @override
  ClassicalHeaderWidgetState createState() => ClassicalHeaderWidgetState();
}

class ClassicalHeaderWidgetState extends State<ClassicalHeaderWidget>
    with TickerProviderStateMixin<ClassicalHeaderWidget> {
  // 是否到达触发刷新距离
  bool _overTriggerDistance = false;

  bool get overTriggerDistance => _overTriggerDistance;

  set overTriggerDistance(bool over) {
    if (_overTriggerDistance != over) {
      _overTriggerDistance
          ? _readyController.forward()
          : _restoreController.forward();
      _overTriggerDistance = over;
    }
  }

  // 是否刷新完成
  bool _refreshFinish = false;

  set refreshFinish(bool finish) {
    if (_refreshFinish != finish) {
      if (finish && widget.float) {
        Future.delayed(widget.completeDuration - Duration(milliseconds: 400),
            () {
          if (mounted) {
            _floatBackController.forward();
          }
        });
        Future.delayed(widget.completeDuration, () {
          _floatBackDistance = null;
          _refreshFinish = false;
        });
      }
      _refreshFinish = finish;
    }
  }

  // 动画
  AnimationController _readyController;
  Animation<double> _readyAnimation;
  AnimationController _restoreController;
  Animation<double> _restoreAnimation;
  AnimationController _floatBackController;
  Animation<double> _floatBackAnimation;

  // Icon旋转度
  double _iconRotationValue = 1.0;

  // 浮动时,收起距离
  double _floatBackDistance;

  // 显示文字
  String get _showText {
    if (widget.noMore) return widget.classicalHeader.noMoreText;
    if (widget.enableInfiniteRefresh) {
      if (widget.refreshState == RefreshMode.refreshed ||
          widget.refreshState == RefreshMode.inactive ||
          widget.refreshState == RefreshMode.drag) {
        return widget.classicalHeader.refreshedText;
      } else {
        return widget.classicalHeader.refreshingText;
      }
    }
    switch (widget.refreshState) {
      case RefreshMode.refresh:
        return widget.classicalHeader.refreshingText;
      case RefreshMode.armed:
        return widget.classicalHeader.refreshingText;
      case RefreshMode.refreshed:
        return _finishedText;
      case RefreshMode.done:
        return _finishedText;
      default:
        if (overTriggerDistance) {
          return widget.classicalHeader.refreshReadyText;
        } else {
          return widget.classicalHeader.refreshText;
        }
    }
  }

  // 刷新结束文字
  String get _finishedText {
    if (!widget.success) return widget.classicalHeader.refreshFailedText;
    if (widget.noMore) return widget.classicalHeader.noMoreText;
    return widget.classicalHeader.refreshedText;
  }

  // 刷新结束图标
  IconData get _finishedIcon {
    if (!widget.success) return Icons.error_outline;
    if (widget.noMore) return Icons.hourglass_empty;
    return Icons.done;
  }

  // 更新时间
  DateTime _dateTime;

  // 获取更多信息
  String get _infoText {
    if (widget.refreshState == RefreshMode.refreshed) {
      _dateTime = DateTime.now();
    }
    String fillChar = _dateTime.minute < 10 ? "0" : "";
    return widget.classicalHeader.infoText
        .replaceAll("%T", "${_dateTime.hour}:$fillChar${_dateTime.minute}");
  }

  @override
  void initState() {
    super.initState();
    // 初始化时间
    _dateTime = DateTime.now();
    // 准备动画
    _readyController = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _readyAnimation = new Tween(begin: 0.5, end: 1.0).animate(_readyController)
      ..addListener(() {
        setState(() {
          if (_readyAnimation.status != AnimationStatus.dismissed) {
            _iconRotationValue = _readyAnimation.value;
          }
        });
      });
    _readyAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _readyController.reset();
      }
    });
    // 恢复动画
    _restoreController = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _restoreAnimation =
        new Tween(begin: 1.0, end: 0.5).animate(_restoreController)
          ..addListener(() {
            setState(() {
              if (_restoreAnimation.status != AnimationStatus.dismissed) {
                _iconRotationValue = _restoreAnimation.value;
              }
            });
          });
    _restoreAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _restoreController.reset();
      }
    });
    // float收起动画
    _floatBackController = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _floatBackAnimation =
        new Tween(begin: widget.refreshIndicatorExtent, end: 0.0)
            .animate(_floatBackController)
              ..addListener(() {
                setState(() {
                  if (_floatBackAnimation.status != AnimationStatus.dismissed) {
                    _floatBackDistance = _floatBackAnimation.value;
                  }
                });
              });
    _floatBackAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _floatBackController.reset();
      }
    });
  }

  @override
  void dispose() {
    _readyController.dispose();
    _restoreController.dispose();
    _floatBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 是否为垂直方向
    bool isVertical = widget.axisDirection == AxisDirection.down ||
        widget.axisDirection == AxisDirection.up;
    // 是否反向
    bool isReverse = widget.axisDirection == AxisDirection.up ||
        widget.axisDirection == AxisDirection.left;
    // 是否到达触发刷新距离
    overTriggerDistance = widget.refreshState != RefreshMode.inactive &&
        widget.pulledExtent >= widget.refreshTriggerPullDistance;
    if (widget.refreshState == RefreshMode.refreshed) {
      refreshFinish = true;
    }
    return Stack(
      children: <Widget>[
        Positioned(
          top: !isVertical
              ? 0.0
              : isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance)
                  : null,
          bottom: !isVertical
              ? 0.0
              : !isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance)
                  : null,
          left: isVertical
              ? 0.0
              : isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance)
                  : null,
          right: isVertical
              ? 0.0
              : !isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance)
                  : null,
          child: Container(
            alignment: widget.classicalHeader.alignment ?? isVertical
                ? isReverse ? Alignment.topCenter : Alignment.bottomCenter
                : !isReverse ? Alignment.centerRight : Alignment.centerLeft,
            width: isVertical
                ? double.infinity
                : _floatBackDistance == null
                    ? (widget.refreshIndicatorExtent > widget.pulledExtent
                        ? widget.refreshIndicatorExtent
                        : widget.pulledExtent)
                    : widget.refreshIndicatorExtent,
            height: isVertical
                ? _floatBackDistance == null
                    ? (widget.refreshIndicatorExtent > widget.pulledExtent
                        ? widget.refreshIndicatorExtent
                        : widget.pulledExtent)
                    : widget.refreshIndicatorExtent
                : double.infinity,
            color: widget.classicalHeader.bgColor,
            child: SizedBox(
              height:
                  isVertical ? widget.refreshIndicatorExtent : double.infinity,
              width:
                  !isVertical ? widget.refreshIndicatorExtent : double.infinity,
              child: isVertical
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildContent(isVertical, isReverse),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildContent(isVertical, isReverse),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建显示内容
  List<Widget> _buildContent(bool isVertical, bool isReverse) {
    return isVertical
        ? <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(
                  right: 10.0,
                ),
                child: (widget.refreshState == RefreshMode.refresh ||
                            widget.refreshState == RefreshMode.armed) &&
                        !widget.noMore
                    ? Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(
                            widget.classicalHeader.textColor,
                          ),
                        ),
                      )
                    : widget.refreshState == RefreshMode.refreshed ||
                            widget.refreshState == RefreshMode.done ||
                            (widget.enableInfiniteRefresh &&
                                widget.refreshState != RefreshMode.refreshed) ||
                            widget.noMore
                        ? Icon(
                            _finishedIcon,
                            color: widget.classicalHeader.textColor,
                          )
                        : Transform.rotate(
                            child: Icon(
                              isReverse
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: widget.classicalHeader.textColor,
                            ),
                            angle: 2 * pi * _iconRotationValue,
                          ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _showText,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: widget.classicalHeader.textColor,
                    ),
                  ),
                  widget.classicalHeader.showInfo
                      ? Container(
                          margin: EdgeInsets.only(
                            top: 2.0,
                          ),
                          child: Text(
                            _infoText,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: widget.classicalHeader.infoColor,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(),
            ),
          ]
        : <Widget>[
            Container(
              child: widget.refreshState == RefreshMode.refresh ||
                      widget.refreshState == RefreshMode.armed
                  ? Container(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation(
                          widget.classicalHeader.textColor,
                        ),
                      ),
                    )
                  : widget.refreshState == RefreshMode.refreshed ||
                          widget.refreshState == RefreshMode.done ||
                          (widget.enableInfiniteRefresh &&
                              widget.refreshState != RefreshMode.refreshed) ||
                          widget.noMore
                      ? Icon(
                          _finishedIcon,
                          color: widget.classicalHeader.textColor,
                        )
                      : Transform.rotate(
                          child: Icon(
                            isReverse ? Icons.arrow_back : Icons.arrow_forward,
                            color: widget.classicalHeader.textColor,
                          ),
                          angle: 2 * pi * _iconRotationValue,
                        ),
            )
          ];
  }
}

/// 首次刷新Header
class FirstRefreshHeader extends Header {
  /// 子组件
  final Widget child;

  FirstRefreshHeader(this.child)
      : super(
          extent: double.infinity,
          triggerDistance: 60.0,
          float: true,
          enableInfiniteRefresh: false,
          enableHapticFeedback: false,
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
    return (refreshState == RefreshMode.armed ||
                refreshState == RefreshMode.refresh) &&
            pulledExtent >
                refreshTriggerPullDistance + EasyRefresh.callOverExtent
        ? child
        : Container();
  }
}
