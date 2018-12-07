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
  const RefreshHeader({
    GlobalKey<RefreshHeaderState> key,
    this.refreshHeight: 50.0,
    this.isFloat: false,
    this.finishDelay: 1000
  }) : super(key: key);
}
abstract class RefreshHeaderState<T extends RefreshHeader> extends State<T> {
  // 顶部栏状态
  RefreshHeaderStatus refreshHeaderStatus = RefreshHeaderStatus.NO_REFRESH;
  // 高度
  double height = 0.0;

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
  // 回调刷新恢复方法
  Future onRefreshRestore() async {
    refreshHeaderStatus = RefreshHeaderStatus.NO_REFRESH;
  }
  // 回调刷新结束方法
  Future onRefreshEnd() async {
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
  // 触发刷新的高度
  final double refreshHeight;
  // 是否浮动
  final bool isFloat;

  // 构造函数
  ClassicsHeader({
    GlobalKey<ClassicsHeaderState> key,
    this.refreshText: "Pull to refresh",
    this.refreshReadyText: "Release to refresh",
    this.refreshingText: "Refreshing...",
    this.refreshedText: "Refresh finished",
    this.bgColor: Colors.blue,
    this.textColor: Colors.white,
    this.refreshHeight: 70.0,
    this.isFloat: false
  }):super(
    key: key ?? new GlobalKey<RefreshHeaderState>(),
    refreshHeight: refreshHeight,
    isFloat: isFloat
  );

  @override
  ClassicsHeaderState createState() => ClassicsHeaderState();
}
class ClassicsHeaderState extends RefreshHeaderState<ClassicsHeader> {
  // 提示刷新文字
  String refreshText;
  // 准备刷新文字
  String refreshReadyText;
  // 正在刷新文字
  String refreshingText;
  // 刷新完成文字
  String refreshedText;
  // 显示的文字
  String _showText;

  // 初始化操作
  @override
  void initState() {
    super.initState();
    refreshText = widget.refreshText;
    refreshReadyText = widget.refreshReadyText;
    refreshingText = widget.refreshingText;
    refreshedText = widget.refreshedText;
    _showText = widget.refreshText;
  }

  // 准备刷新回调
  @override
  Future onRefreshReady() async {
    super.onRefreshReady();
    setState(() {
      _showText = refreshReadyText;
    });
  }
  // 正在刷新回调
  @override
  Future onRefreshing() async {
    super.onRefreshing();
    setState(() {
      _showText = refreshingText;
    });
  }
  // 完成刷新回调
  @override
  Future onRefreshed() async {
    super.onRefreshed();
    setState(() {
      _showText = refreshedText;
    });
  }
  // 刷新恢复回调
  @override
  Future onRefreshRestore() async {
    super.onRefreshRestore();
    setState(() {
      _showText = refreshText;
    });
  }
  // 刷新结束回调
  @override
  Future onRefreshEnd() async {
    super.onRefreshEnd();
    setState(() {
      _showText = refreshText;
    });
  }

  // 下拉刷新布局
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: widget.bgColor,
      height: this.height,
      child: ListView(
        children: <Widget>[
          Container(
            height: this.height > 30.0 ? this.height : 30.0,
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
          )
        ],
      ),
    );
  }
}