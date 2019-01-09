import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 顶部栏状态
enum  RefreshHeaderStatus {
  NO_REFRESH,
  REFRESH_READY,
  REFRESHING,
  REFRESHED,
}

/// 下拉刷新顶部视图抽象类
/// 自定义视图需要实现此类中的方法
abstract class RefreshHeader extends StatefulWidget {
  // 触发刷新的高度
  final double refreshHeight;
  // 是否浮动
  final bool isFloat;
  // 完成延时时间(ms)
  final int finishDelay;

  // 获取键
  GlobalKey<RefreshHeaderState> getKey() {
    return this.key;
  }

  // 构造函数
  RefreshHeader({
    @required GlobalKey<RefreshHeaderState> key,
    this.refreshHeight: 70.0,
    this.isFloat: false,
    this.finishDelay: 1000
  }) : super(key: key){
    assert(this.key != null);
  }
}
abstract class RefreshHeaderState<T extends RefreshHeader> extends State<T> {
  // 顶部栏状态
  RefreshHeaderStatus refreshHeaderStatus = RefreshHeaderStatus.NO_REFRESH;
  // 高度
  double height = 0.0;

  // 更新视图高度
  @mustCallSuper
  void updateHeight(double newHeight) {
    setState(() {
      height = newHeight;
    });
  }
  // 回调开始刷新方法
  @mustCallSuper
  Future onRefreshStart() async {
    refreshHeaderStatus = RefreshHeaderStatus.NO_REFRESH;
  }
  // 回调准备刷新方法
  @mustCallSuper
  Future onRefreshReady() async {
    refreshHeaderStatus = RefreshHeaderStatus.REFRESH_READY;
  }
  // 回调开始刷新方法
  @mustCallSuper
  Future onRefreshing() async {
    refreshHeaderStatus = RefreshHeaderStatus.REFRESHING;
  }
  // 回调刷新完成方法
  @mustCallSuper
  Future onRefreshed() async {
    refreshHeaderStatus = RefreshHeaderStatus.REFRESHED;
  }
  // 回调刷新恢复方法
  @mustCallSuper
  Future onRefreshRestore() async {
    refreshHeaderStatus = RefreshHeaderStatus.NO_REFRESH;
  }
  // 回调刷新结束方法
  @mustCallSuper
  Future onRefreshEnd() async {
    refreshHeaderStatus = RefreshHeaderStatus.NO_REFRESH;
  }
}

/// Header监听器
abstract class HeaderListener {
  // 更新视图高度
  void updateHeight(double newHeight){}
  // 回调开始刷新方法
  void onRefreshStart(){}
  // 回调准备刷新方法
  void onRefreshReady(){}
  // 回调开始刷新方法
  void onRefreshing(){}
  // 回调刷新完成方法
  void onRefreshed(){}
  // 回调刷新恢复方法
  void onRefreshRestore(){}
  // 回调刷新结束方法
  void onRefreshEnd(){}
}

/// 监听器Header
class ListenerHeader extends RefreshHeader {
  // 触发刷新的高度
  final double refreshHeight;
  // 完成延时时间(ms)
  final int finishDelay;
  // 监听器
  final HeaderListener listener;

  // 构造函数
  ListenerHeader({
    @required GlobalKey<RefreshHeaderState> key,
    @required this.listener,
    this.refreshHeight: 70.0,
    this.finishDelay: 1000,
  }):super(
    key: key,
    refreshHeight: refreshHeight,
    finishDelay: finishDelay,
  ){
    assert(listener != null);
  }

  @override
  _ListenerHeaderState createState() => _ListenerHeaderState();
}
class _ListenerHeaderState extends RefreshHeaderState<ListenerHeader> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  @override
  Future onRefreshEnd() async {
    super.onRefreshEnd();
    widget.listener.onRefreshEnd();
  }
  @override
  Future onRefreshRestore() async {
    super.onRefreshRestore();
    widget.listener.onRefreshRestore();
  }
  @override
  Future onRefreshed() async {
    super.onRefreshed();
    widget.listener.onRefreshed();
  }
  @override
  Future onRefreshing() async {
    super.onRefreshing();
    widget.listener.onRefreshing();
  }
  @override
  Future onRefreshReady() async {
    super.onRefreshReady();
    widget.listener.onRefreshReady();
  }
  @override
  Future onRefreshStart() async {
    super.onRefreshStart();
    widget.listener.onRefreshStart();
  }
  @override
  void updateHeight(double newHeight) {
    super.updateHeight(newHeight);
    widget.listener.updateHeight(newHeight);
  }
}

/// Header连接器
class ConnectorHeader extends RefreshHeader {
  // 需要连接的Header
  final RefreshHeader header;

  get refreshHeight => header.refreshHeight;
  get isFloat => header.isFloat;
  get finishDelay => header.finishDelay;

  ConnectorHeader({
    @required GlobalKey<RefreshHeaderState> key,
    @required this.header
  }):super(
    key: key
  ){
    assert(header != null);
  }

  @override
  GlobalKey<RefreshHeaderState> getKey() {
    return header.getKey();
  }

  @override
  _ConnectorHeaderState createState() => _ConnectorHeaderState();
}
class _ConnectorHeaderState extends RefreshHeaderState<ConnectorHeader>{
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/// 经典(默认)顶部视图
class ClassicsHeader extends RefreshHeader {
  // 提示刷新文字
  final String refreshText;
  // 准备刷新文字
  final String refreshReadyText;
  // 正在刷新文字
  final String refreshingText;
  // 刷新完成文字
  final String refreshedText;
  // 背景颜色
  final Color bgColor;
  // 字体颜色
  final Color textColor;
  // 触发刷新的高度
  final double refreshHeight;
  // 是否浮动
  final bool isFloat;
  // 显示额外信息(默认为时间)
  final bool showMore;
  // 更多信息
  final String moreInfo;
  // 更多信息文字颜色
  final Color moreInfoColor;

  // 构造函数
  ClassicsHeader({
    @required GlobalKey<RefreshHeaderState> key,
    this.refreshText: "Pull to refresh",
    this.refreshReadyText: "Release to refresh",
    this.refreshingText: "Refreshing...",
    this.refreshedText: "Refresh finished",
    this.bgColor: Colors.blue,
    this.textColor: Colors.white,
    this.moreInfoColor: Colors.white,
    this.refreshHeight: 70.0,
    this.isFloat: false,
    this.showMore: false,
    this.moreInfo: "Updated at %T"
  }):super(
    key: key,
    refreshHeight: refreshHeight,
    isFloat: isFloat
  );

  @override
  ClassicsHeaderState createState() => ClassicsHeaderState();
}
class ClassicsHeaderState extends RefreshHeaderState<ClassicsHeader> with TickerProviderStateMixin<ClassicsHeader> {
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
    _showText = widget.refreshText;
    _dateTime = DateTime.now();
    // 初始化动画
    _readyController = new AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _readyAnimation = new Tween(begin: 1.0, end: 0.5).animate(_readyController)
      ..addListener(() {
        setState(() {
          if (_readyAnimation.status != AnimationStatus.dismissed) {
            _iconRotationValue = _readyAnimation.value;
          }
        });
      });
    _readyAnimation.addStatusListener((status){
      if (status == AnimationStatus.completed) {
        _readyController.reset();
      }
    });
    _restoreController = new AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _restoreAnimation = new Tween(begin: 0.5, end: 1.0).animate(_restoreController)
      ..addListener(() {
        setState(() {
          if (_restoreAnimation.status != AnimationStatus.dismissed) {
            _iconRotationValue = _restoreAnimation.value;
          }
        });
      });
    _restoreAnimation.addStatusListener((status){
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

  // 准备刷新回调
  @override
  Future onRefreshReady() async {
    super.onRefreshReady();
    setState(() {
      _showText = widget.refreshReadyText;
    });
    if (_restoreController.isAnimating) {
      _restoreController.reset();
    }
    _readyController.forward();
  }
  // 正在刷新回调
  @override
  Future onRefreshing() async {
    super.onRefreshing();
    setState(() {
      _showText = widget.refreshingText;
    });
  }
  // 完成刷新回调
  @override
  Future onRefreshed() async {
    super.onRefreshed();
    setState(() {
      _dateTime = DateTime.now();
      _showText = widget.refreshedText;
    });
  }
  // 刷新恢复回调
  @override
  Future onRefreshRestore() async {
    super.onRefreshRestore();
    setState(() {
      _showText = widget.refreshText;
    });
    if (_readyController.isAnimating) {
      _readyController.reset();
    }
    _restoreController.forward();
  }
  // 刷新结束回调
  @override
  Future onRefreshEnd() async {
    super.onRefreshEnd();
    setState(() {
      _showText = widget.refreshText;
      _iconRotationValue = 1.0;
    });
  }

  // 获取更多信息
  String _getMoreInfo() {
    String fillChar = _dateTime.minute < 10 ? "0" : "";
    return widget.moreInfo.replaceAll("%T", "${_dateTime.hour}:$fillChar${_dateTime.minute}");
  }

  // 下拉刷新布局
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: widget.bgColor,
      height: this.height,
      child: SingleChildScrollView(
        child: Container(
          height: this.height > 45.0 ? this.height : 45.0,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded (
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      this.refreshHeaderStatus == RefreshHeaderStatus.NO_REFRESH || this.refreshHeaderStatus == RefreshHeaderStatus.REFRESH_READY ? Transform.rotate(
                        child: Icon(
                          Icons.arrow_upward,
                          color: widget.textColor,
                        ),
                        angle: pi / _iconRotationValue,
                      ): Container(),
                      this.refreshHeaderStatus == RefreshHeaderStatus.REFRESHING ? new Align(
                        alignment: Alignment.centerLeft,
                        child: new Container(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation(widget.textColor),
                          ),
                        ),
                      ): new Container(),
                      this.refreshHeaderStatus == RefreshHeaderStatus.REFRESHED ? Icon(
                        Icons.done,
                        color: widget.textColor,
                      ): Container(),
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
                    new Text(_showText,
                      style: new TextStyle(
                        color: widget.textColor,
                        fontSize: 16.0
                      ),
                    ),
                    Container(
                      height: 2.0,
                    ),
                    widget.showMore ? new Text(_getMoreInfo(),
                      style: new TextStyle(
                          color: widget.moreInfoColor,
                          fontSize: 12.0
                      ),
                    ) : Container(),
                  ],
                )
              ),
              Expanded (
                flex: 1,
                child: Container(),
              )
            ],
          ),
        )
      ),
    );
  }
}