import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Future OnRefreshing();
typedef Future OnRefreshed();
typedef Future OnHeaderHide();
typedef RefreshHeader RefreshHeaderBuilder(BuildContext context, double height);

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

  GlobalKey<RefreshHeaderState> getKey() {
    return this.key;
  }

  const RefreshHeader({
    GlobalKey<RefreshHeaderState> key,
    this.refreshHeight: 50.0,
    this.isFloat: false,
  }) : super(key: key);
}
abstract class RefreshHeaderState<T extends RefreshHeader> extends State<T> {
  // 顶部栏状态
  RefreshHeaderStatus refreshHeaderStatus = RefreshHeaderStatus.NO_REFRESH;
  // 高度
  double height = 0.0;

  @override
  Widget build(BuildContext context) {
    return null;
  }

  // 更新视图高度
  void updateHeight(double newHeight) {
    setState(() {
      height = newHeight;
    });
  }

  // 回调准备刷新方法
  Future onRefreshReady() async {
    refreshHeaderStatus = RefreshHeaderStatus.REFRESH_READY;
  }
  // 回调开始刷新方法
  Future onRefreshing() async {
    refreshHeaderStatus = RefreshHeaderStatus.REFRESHING;
  }
  // 回调刷新完成方法
  Future onRefreshed() async {
    refreshHeaderStatus = RefreshHeaderStatus.REFRESHED;
  }
  // 回调顶部视图隐藏方法
  Future onHeaderHide() async {
    refreshHeaderStatus = RefreshHeaderStatus.NO_REFRESH;
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

  // 视图状态
  final _ClassicsHeaderState _classicsHeaderState = _ClassicsHeaderState();

  // 构造函数
  ClassicsHeader({
    this.refreshText: "Pull to refresh",
    this.refreshReadyText: "Release to refresh",
    this.refreshingText: "Refreshing...",
    this.refreshedText: "Refresh finished",
    this.bgColor: Colors.blue,
    this.textColor: Colors.white,
  }):super(
    key: new GlobalKey<RefreshHeaderState>(),
    refreshHeight: 50.0
  );

  @override
  _ClassicsHeaderState createState() => _classicsHeaderState;
}
class _ClassicsHeaderState extends RefreshHeaderState<ClassicsHeader> {
  // 显示的文字
  String _showText;

  // 初始化操作
  @override
  void initState() {
    super.initState();
    _showText = widget.refreshText;
  }

  // 准备刷新回调
  @override
  Future onRefreshReady() async {
    super.onRefreshReady();
    setState(() {
      _showText = widget.refreshReadyText;
    });
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
      _showText = widget.refreshedText;
    });
  }

  // 顶部视图隐藏回调
  @override
  Future onHeaderHide() async {
    super.onHeaderHide();
    setState(() {
      _showText = widget.refreshText;
    });
  }

  // 下拉刷新布局
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: widget.bgColor,
      height: this.height,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          this.refreshHeaderStatus == RefreshHeaderStatus.NO_REFRESH ? Icon(
            Icons.arrow_downward,
            color: widget.textColor,
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
          this.refreshHeaderStatus == RefreshHeaderStatus.REFRESH_READY ? Icon(
            Icons.arrow_upward,
            color: widget.textColor,
          ): Container(),
          this.refreshHeaderStatus == RefreshHeaderStatus.REFRESHED ? Icon(
            Icons.done,
            color: widget.textColor,
          ): Container(),
          new Container(margin: EdgeInsets.only(right: 10.0),),
          new Align(
            child: new ClipRect(
              child: new Text(_showText,
                style: new TextStyle(color: widget.textColor),),
            ),
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }
}