import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../easy_refresh.dart';

/// Header
abstract class Footer {
  /// Footer容器高度
  final double extent;

  /// 高度(超过这个高度触发加载)
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
  Widget builder(
      BuildContext context,
      EasyRefresh easyRefresh,
      ValueNotifier<bool> focusNotifier,
      ValueNotifier<bool> taskNotifier,
      ValueNotifier<bool> callLoadNotifier) {
    return EasyRefreshSliverLoadControl(
      loadIndicatorExtent: extent,
      loadTriggerPullDistance: triggerDistance,
      builder: contentBuilder,
      completeDuration: completeDuration,
      onLoad: easyRefresh.onLoad,
      focusNotifier: focusNotifier,
      taskNotifier: taskNotifier,
      callLoadNotifier: callLoadNotifier,
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
      LoadMode loadState,
      double pulledExtent,
      double loadTriggerPullDistance,
      double loadIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration completeDuration,
      bool enableInfiniteLoad,
      bool success,
      bool noMore);
}

/// 通用Footer构造器
class CustomFooter extends Footer {
  /// Footer构造器
  final LoadControlBuilder footerBuilder;

  CustomFooter({
    extent = 60.0,
    triggerDistance = 70.0,
    float = false,
    completeDuration,
    enableInfiniteLoad = false,
    enableHapticFeedback = false,
    @required this.footerBuilder,
  }) : super(
          extent: extent,
          triggerDistance: triggerDistance,
          completeDuration: completeDuration,
          enableInfiniteLoad: enableInfiniteLoad,
          enableHapticFeedback: enableHapticFeedback,
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
    return footerBuilder(
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
  }
}

/// 连接通知器
class LinkFooterNotifier extends ChangeNotifier {
  BuildContext context;
  LoadMode loadState = LoadMode.inactive;
  double pulledExtent = 0.0;
  double loadTriggerPullDistance;
  double loadIndicatorExtent;
  AxisDirection axisDirection;
  bool float;
  Duration completeDuration;
  bool enableInfiniteLoad;
  bool success = true;
  bool noMore = false;

  void contentBuilder(
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
    this.context = context;
    this.loadState = loadState;
    this.pulledExtent = pulledExtent;
    this.loadTriggerPullDistance = loadTriggerPullDistance;
    this.loadIndicatorExtent = loadIndicatorExtent;
    this.axisDirection = axisDirection;
    this.float = float;
    this.completeDuration = completeDuration;
    this.enableInfiniteLoad = enableInfiniteLoad;
    this.success = success;
    this.noMore = noMore;
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      notifyListeners();
    });
  }
}

/// 经典Footer
class ClassicalFooter extends Footer {
  /// Key
  final Key key;

  /// 方位
  final AlignmentGeometry alignment;

  /// 提示加载文字
  final String loadText;

  /// 准备加载文字
  final String loadReadyText;

  /// 正在加载文字
  final String loadingText;

  /// 加载完成文字
  final String loadedText;

  /// 加载失败文字
  final String loadFailedText;

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

  ClassicalFooter({
    extent = 60.0,
    triggerDistance = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
    enableInfiniteLoad = true,
    enableHapticFeedback = true,
    this.key,
    this.alignment,
    this.loadText: "Push to load",
    this.loadReadyText: "Release to load",
    this.loadingText: "Loading...",
    this.loadedText: "Load completed",
    this.loadFailedText: "Load failed",
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
          completeDuration: completeDuration,
          enableInfiniteLoad: enableInfiniteLoad,
          enableHapticFeedback: enableHapticFeedback,
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
    return ClassicalFooterWidget(
      key: key,
      classicalFooter: this,
      loadState: loadState,
      pulledExtent: pulledExtent,
      loadTriggerPullDistance: loadTriggerPullDistance,
      loadIndicatorExtent: loadIndicatorExtent,
      axisDirection: axisDirection,
      float: float,
      completeDuration: completeDuration,
      enableInfiniteLoad: enableInfiniteLoad,
      success: success,
      noMore: noMore,
    );
  }
}

/// 经典Footer组件
class ClassicalFooterWidget extends StatefulWidget {
  final ClassicalFooter classicalFooter;
  final LoadMode loadState;
  final double pulledExtent;
  final double loadTriggerPullDistance;
  final double loadIndicatorExtent;
  final AxisDirection axisDirection;
  final bool float;
  final Duration completeDuration;
  final bool enableInfiniteLoad;
  final bool success;
  final bool noMore;

  ClassicalFooterWidget(
      {Key key,
      this.loadState,
      this.classicalFooter,
      this.pulledExtent,
      this.loadTriggerPullDistance,
      this.loadIndicatorExtent,
      this.axisDirection,
      this.float,
      this.completeDuration,
      this.enableInfiniteLoad,
      this.success,
      this.noMore})
      : super(key: key);

  @override
  ClassicalFooterWidgetState createState() => ClassicalFooterWidgetState();
}

class ClassicalFooterWidgetState extends State<ClassicalFooterWidget>
    with TickerProviderStateMixin<ClassicalFooterWidget> {
  // 是否到达触发加载距离
  bool _overTriggerDistance = false;
  bool get overTriggerDistance => _overTriggerDistance;
  set overTriggerDistance(bool over) {
    if (_overTriggerDistance != over) {
      _overTriggerDistance
          ? _readyController.forward()
          : _restoreController.forward();
    }
    _overTriggerDistance = over;
  }

  // 动画
  AnimationController _readyController;
  Animation<double> _readyAnimation;
  AnimationController _restoreController;
  Animation<double> _restoreAnimation;

  // Icon旋转度
  double _iconRotationValue = 1.0;

  // 显示文字
  String get _showText {
    if (widget.noMore) return widget.classicalFooter.noMoreText;
    if (widget.enableInfiniteLoad) {
      if (widget.loadState == LoadMode.loaded ||
          widget.loadState == LoadMode.inactive ||
          widget.loadState == LoadMode.drag) {
        return widget.classicalFooter.loadedText;
      } else {
        return widget.classicalFooter.loadingText;
      }
    }
    switch (widget.loadState) {
      case LoadMode.load:
        return widget.classicalFooter.loadingText;
      case LoadMode.armed:
        return widget.classicalFooter.loadingText;
      case LoadMode.loaded:
        return _finishedText;
      case LoadMode.done:
        return _finishedText;
      default:
        if (overTriggerDistance) {
          return widget.classicalFooter.loadReadyText;
        } else {
          return widget.classicalFooter.loadText;
        }
    }
  }

  // 加载结束文字
  String get _finishedText {
    if (!widget.success) return widget.classicalFooter.loadFailedText;
    if (widget.noMore) return widget.classicalFooter.noMoreText;
    return widget.classicalFooter.loadedText;
  }

  // 加载结束图标
  IconData get _finishedIcon {
    if (!widget.success) return Icons.error_outline;
    if (widget.noMore) return Icons.hourglass_empty;
    return Icons.done;
  }

  // 更新时间
  DateTime _dateTime;
  // 获取更多信息
  String get _infoText {
    if (widget.loadState == LoadMode.loaded) {
      _dateTime = DateTime.now();
    }
    String fillChar = _dateTime.minute < 10 ? "0" : "";
    return widget.classicalFooter.infoText
        .replaceAll("%T", "${_dateTime.hour}:$fillChar${_dateTime.minute}");
  }

  @override
  void initState() {
    super.initState();
    // 初始化时间
    _dateTime = DateTime.now();
    // 初始化动画
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
  }

  @override
  void dispose() {
    _readyController.dispose();
    _restoreController.dispose();
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
    // 是否到达触发加载距离
    overTriggerDistance = widget.loadState != LoadMode.inactive &&
        widget.pulledExtent >= widget.loadTriggerPullDistance;
    return Stack(
      children: <Widget>[
        Positioned(
          top: !isVertical ? 0.0 : !isReverse ? 0.0 : null,
          bottom: !isVertical ? 0.0 : isReverse ? 0.0 : null,
          left: isVertical ? 0.0 : !isReverse ? 0.0 : null,
          right: isVertical ? 0.0 : isReverse ? 0.0 : null,
          child: Container(
            alignment: widget.classicalFooter.alignment ?? isVertical
                ? !isReverse ? Alignment.topCenter : Alignment.bottomCenter
                : isReverse ? Alignment.centerRight : Alignment.centerLeft,
            width: !isVertical
                ? widget.loadIndicatorExtent > widget.pulledExtent
                    ? widget.loadIndicatorExtent
                    : widget.pulledExtent
                : double.infinity,
            height: isVertical
                ? widget.loadIndicatorExtent > widget.pulledExtent
                    ? widget.loadIndicatorExtent
                    : widget.pulledExtent
                : double.infinity,
            color: widget.classicalFooter.bgColor,
            child: SizedBox(
              height: isVertical ? widget.loadIndicatorExtent : double.infinity,
              width: !isVertical ? widget.loadIndicatorExtent : double.infinity,
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
                child: (widget.loadState == LoadMode.load ||
                        widget.loadState == LoadMode.armed) && !widget.noMore
                    ? Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(
                            widget.classicalFooter.textColor,
                          ),
                        ),
                      )
                    : widget.loadState == LoadMode.loaded ||
                            widget.loadState == LoadMode.done ||
                            (widget.enableInfiniteLoad &&
                                widget.loadState != LoadMode.loaded) ||
                            widget.noMore
                        ? Icon(
                            _finishedIcon,
                            color: widget.classicalFooter.textColor,
                          )
                        : Transform.rotate(
                            child: Icon(
                              !isReverse
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: widget.classicalFooter.textColor,
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
                      color: widget.classicalFooter.textColor,
                    ),
                  ),
                  widget.classicalFooter.showInfo
                      ? Container(
                          margin: EdgeInsets.only(
                            top: 2.0,
                          ),
                          child: Text(
                            _infoText,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: widget.classicalFooter.infoColor,
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
              child: widget.loadState == LoadMode.load ||
                      widget.loadState == LoadMode.armed
                  ? Container(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation(
                          widget.classicalFooter.textColor,
                        ),
                      ),
                    )
                  : widget.loadState == LoadMode.loaded ||
                          widget.loadState == LoadMode.done ||
                          (widget.enableInfiniteLoad &&
                              widget.loadState != LoadMode.loaded) ||
                          widget.noMore
                      ? Icon(
                          _finishedIcon,
                          color: widget.classicalFooter.textColor,
                        )
                      : Transform.rotate(
                          child: Icon(
                            !isReverse ? Icons.arrow_back : Icons.arrow_forward,
                            color: widget.classicalFooter.textColor,
                          ),
                          angle: 2 * pi * _iconRotationValue,
                        ),
            ),
          ];
  }
}
