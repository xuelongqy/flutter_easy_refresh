import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 底部栏状态
enum RefreshFooterStatus {
  NO_LOAD,
  LOAD_READY,
  LOADING,
  LOADED,
}

/// 上拉加载视图抽象类
/// 自定义视图需要实现此类中的方法
abstract class RefreshFooter extends StatefulWidget {
  // 触发加载的高度
  final double loadHeight;
  // 是否浮动
  final bool isFloat;
  // 完成延时时间(ms)
  final int finishDelay;

  // 获取键
  GlobalKey<RefreshFooterState> getKey() {
    return this.key;
  }

  // 构造函数
  RefreshFooter(
      {@required GlobalKey<RefreshFooterState> key,
      this.loadHeight: 70.0,
      this.isFloat: false,
      this.finishDelay: 1000})
      : super(key: key) {
    assert(this.key != null);
  }
}

abstract class RefreshFooterState<T extends RefreshFooter> extends State<T> {
  // 底部栏状态
  RefreshFooterStatus refreshFooterStatus = RefreshFooterStatus.NO_LOAD;
  // 高度
  double height = 0.0;

  // 更新视图高度
  @mustCallSuper
  void updateHeight(double newHeight) {
    setState(() {
      height = newHeight;
    });
  }

  // 回调开始加载方法
  @mustCallSuper
  void onLoadStart() {
    refreshFooterStatus = RefreshFooterStatus.NO_LOAD;
  }

  // 回调准备加载方法
  @mustCallSuper
  void onLoadReady() {
    refreshFooterStatus = RefreshFooterStatus.LOAD_READY;
  }

  // 回调开始加载方法
  @mustCallSuper
  void onLoading() {
    refreshFooterStatus = RefreshFooterStatus.LOADING;
  }

  // 回调加载完成方法
  @mustCallSuper
  void onLoaded() {
    refreshFooterStatus = RefreshFooterStatus.LOADED;
  }

  // 回调没有更多数据方法
  @mustCallSuper
  void onNoMore() {
    refreshFooterStatus = RefreshFooterStatus.LOADED;
  }

  // 回调加载恢复方法
  @mustCallSuper
  void onLoadRestore() {
    refreshFooterStatus = RefreshFooterStatus.NO_LOAD;
  }

  // 回调加载结束方法
  @mustCallSuper
  void onLoadEnd() {
    refreshFooterStatus = RefreshFooterStatus.NO_LOAD;
  }

  // 回调加载关闭方法
  @mustCallSuper
  void onLoadClose() {
    refreshFooterStatus = RefreshFooterStatus.NO_LOAD;
  }
}

/// Footer监听器
abstract class FooterListener {
  // 更新视图高度
  void updateFooterHeight(double newHeight) {}
  // 回调开始加载方法
  void onLoadStart() {}
  // 回调准备加载方法
  void onLoadReady() {}
  // 回调开始加载方法
  void onLoading() {}
  // 回调加载完成方法
  void onLoaded() {}
  // 回调没有更多数据方法
  void onNoMore() {}
  // 回调加载恢复方法
  void onLoadRestore() {}
  // 回调加载结束方法
  void onLoadEnd() {}
  // 回调加载结束方法
  void onLoadClose() {}
}

/// 监听器Footer
class ListenerFooter extends RefreshFooter {
  // 触发加载的高度
  final double loadHeight;
  // 完成延时时间(ms)
  final int finishDelay;
  // 监听器
  final FooterListener listener;

  // 构造函数
  ListenerFooter({
    @required GlobalKey<RefreshFooterState> key,
    @required this.listener,
    this.loadHeight: 70.0,
    this.finishDelay: 1000,
  }) : super(
          key: key,
          loadHeight: loadHeight,
          finishDelay: finishDelay,
        ) {
    assert(listener != null);
  }

  @override
  _ListenerFooterState createState() => _ListenerFooterState();
}

class _ListenerFooterState extends RefreshFooterState<ListenerFooter> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void onLoadEnd() {
    super.onLoadEnd();
    widget.listener.onLoadEnd();
  }

  @override
  void onLoadRestore() {
    super.onLoadRestore();
    widget.listener.onLoadRestore();
  }

  @override
  void onNoMore() {
    super.onNoMore();
    widget.listener.onNoMore();
  }

  @override
  void onLoaded() {
    super.onLoaded();
    widget.listener.onLoaded();
  }

  @override
  void onLoading() {
    super.onLoading();
    widget.listener.onLoading();
  }

  @override
  void onLoadReady() {
    super.onLoadReady();
    widget.listener.onLoadReady();
  }

  @override
  void onLoadStart() {
    super.onLoadStart();
    widget.listener.onLoadStart();
  }

  @override
  void onLoadClose() {
    super.onLoadClose();
    widget.listener.onLoadClose();
  }

  @override
  void updateHeight(double newHeight) {
    super.updateHeight(newHeight);
    widget.listener.updateFooterHeight(newHeight);
  }
}

/// Footer连接器
class ConnectorFooter extends RefreshFooter {
  // 需要连接的Header
  final RefreshFooter footer;

  get loadHeight => footer.loadHeight;
  get isFloat => footer.isFloat;
  get finishDelay => footer.finishDelay;

  ConnectorFooter(
      {@required GlobalKey<RefreshFooterState> key, @required this.footer})
      : super(key: key) {
    assert(footer != null);
  }

  @override
  GlobalKey<RefreshFooterState> getKey() {
    return footer.getKey();
  }

  @override
  _ConnectorFooterState createState() => _ConnectorFooterState();
}

class _ConnectorFooterState extends RefreshFooterState<ConnectorFooter> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/// 经典(默认)底部视图
class ClassicsFooter extends RefreshFooter {
  // 提示加载文字
  final String loadText;
  // 准备加载文字
  final String loadReadyText;
  // 正在加载文字
  final String loadingText;
  // 没有更多文字
  final String noMoreText;
  // 刷新完成文字
  final String loadedText;
  // 背景颜色
  final Color bgColor;
  // 字体颜色
  final Color textColor;
  // 触发加载的高度
  final double loadHeight;
  // 是否浮动
  final bool isFloat;
  // 显示额外信息(默认为时间)
  final bool showMore;
  // 更多信息
  final String moreInfo;
  // 更多信息文字颜色
  final Color moreInfoColor;

  // 构造函数
  ClassicsFooter(
      {GlobalKey<RefreshFooterState> key,
      this.loadText: "Push to load",
      this.loadReadyText: "Release to load",
      this.loadingText: "Loading...",
      this.loadedText: "Load finished",
      this.noMoreText: "No more",
      this.bgColor: Colors.blue,
      this.textColor: Colors.white,
      this.moreInfoColor: Colors.white,
      this.loadHeight: 70.0,
      this.isFloat: false,
      this.showMore: false,
      this.moreInfo: "Loaded at %T"})
      : super(key: key, loadHeight: loadHeight, isFloat: isFloat);

  @override
  ClassicsFooterState createState() => ClassicsFooterState();
}

class ClassicsFooterState extends RefreshFooterState<ClassicsFooter>
    with TickerProviderStateMixin<ClassicsFooter> {
  // 显示的文字
  String _showText;
  // 更新时间
  DateTime _dateTime;

  // 动画
  AnimationController _readyController;
  Animation<double> _readyAnimation;
  AnimationController _restoreController;
  Animation<double> _restoreAnimation;
  // Icon旋转度
  double _iconRotationValue = 1.0;

  // 初始化操作
  @override
  void initState() {
    super.initState();
    _showText = widget.loadText;
    _dateTime = DateTime.now();
    // 初始化动画
    _readyController = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _readyAnimation = new Tween(begin: 1.0, end: 0.5).animate(_readyController)
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
        new Tween(begin: 0.5, end: 1.0).animate(_restoreController)
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
    super.dispose();
    _readyController.dispose();
    _restoreController.dispose();
  }

  // 准备加载回调
  @override
  void onLoadReady() {
    super.onLoadReady();
    setState(() {
      _showText = widget.loadReadyText;
    });
    if (_restoreController.isAnimating) {
      _restoreController.reset();
    }
    _readyController.forward();
  }

  // 正在加载回调
  @override
  void onLoading() {
    super.onLoading();
    setState(() {
      _showText = widget.loadingText;
    });
  }

  // 加载完成回调
  @override
  void onLoaded() {
    super.onLoaded();
    setState(() {
      _dateTime = DateTime.now();
      _showText = widget.loadedText;
    });
  }

  // 没有更多数据回调
  @override
  void onNoMore() {
    super.onNoMore();
    setState(() {
      _dateTime = DateTime.now();
      _showText = widget.noMoreText;
    });
  }

  // 加载恢复回调
  @override
  void onLoadRestore() {
    super.onLoadRestore();
    setState(() {
      _showText = widget.loadText;
    });
    if (_readyController.isAnimating) {
      _readyController.reset();
    }
    _restoreController.forward();
  }

  // 加载结束回调
  @override
  void onLoadEnd() {
    super.onLoadEnd();
    setState(() {
      _showText = widget.loadText;
      _iconRotationValue = 1.0;
    });
  }

  // 获取更多信息
  String _getMoreInfo() {
    String fillChar = _dateTime.minute < 10 ? "0" : "";
    return widget.moreInfo
        .replaceAll("%T", "${_dateTime.hour}:$fillChar${_dateTime.minute}");
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      //上拉加载布局
      color: widget.bgColor,
      height: this.height,
      child: SingleChildScrollView(
          child: Container(
        height: this.height > 45.0 ? this.height : 45.0,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: new Container(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    this.refreshFooterStatus == RefreshFooterStatus.NO_LOAD ||
                            this.refreshFooterStatus ==
                                RefreshFooterStatus.LOAD_READY
                        ? Transform.rotate(
                            child: Icon(
                              Icons.arrow_downward,
                              color: widget.textColor,
                            ),
                            angle: pi / _iconRotationValue,
                          )
                        : Container(),
                    this.refreshFooterStatus == RefreshFooterStatus.LOADING
                        ? new Align(
                            alignment: Alignment.centerLeft,
                            child: new Container(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                    AlwaysStoppedAnimation(widget.textColor),
                              ),
                            ),
                          )
                        : Container(),
//                      this.refreshFooterStatus == RefreshFooterStatus.LOAD_READY ? Icon(
//                        Icons.arrow_downward,
//                        color: widget.textColor,
//                      ): Container(),
                    this.refreshFooterStatus == RefreshFooterStatus.LOADED
                        ? Icon(
                            Icons.done,
                            color: widget.textColor,
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            Container(
                width: 150.0,
                height: double.infinity,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      _showText,
                      style: new TextStyle(
                          color: widget.textColor, fontSize: 16.0),
                    ),
                    Container(
                      height: 2.0,
                    ),
                    widget.showMore
                        ? new Text(
                            _getMoreInfo(),
                            style: new TextStyle(
                                color: widget.moreInfoColor, fontSize: 12.0),
                          )
                        : Container(),
                  ],
                )),
            Expanded(
              flex: 1,
              child: Container(),
            )
          ],
        ),
      )),
    );
  }
}
