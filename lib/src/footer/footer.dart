import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 底部栏状态
enum  RefreshFooterStatus {
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
  const RefreshFooter({
    GlobalKey<RefreshFooterState> key,
    @required this.loadHeight,
    this.isFloat: false,
    this.finishDelay: 1000
  }) : super(key: key);
}

abstract class RefreshFooterState<T extends RefreshFooter> extends State<T> {
  // 底部栏状态
  RefreshFooterStatus refreshFooterStatus = RefreshFooterStatus.NO_LOAD;
  // 高度
  double height = 0.0;

  // 更新视图高度
  void updateHeight(double newHeight) {
    setState(() {
      height = newHeight;
    });
  }

  // 回调准备加载方法
  Future onLoadReady() async {
    refreshFooterStatus = RefreshFooterStatus.LOAD_READY;
  }
  // 回调开始加载方法
  Future onLoading() async {
    refreshFooterStatus = RefreshFooterStatus.LOADING;
  }
  // 回调加载完成方法
  Future onLoaded() async {
    refreshFooterStatus = RefreshFooterStatus.LOADED;
  }
  // 回调没有更多数据方法
  Future onNoMore() async {
    refreshFooterStatus = RefreshFooterStatus.LOADED;
  }
  // 回调加载恢复方法
  Future onLoadRestore() async {
    refreshFooterStatus = RefreshFooterStatus.NO_LOAD;
  }
  // 回调加载结束方法
  Future onLoadEnd() async {
    refreshFooterStatus = RefreshFooterStatus.NO_LOAD;
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

  // 构造函数
  ClassicsFooter({
    GlobalKey<ClassicsFooterState> key,
    this.loadText: "Push to load",
    this.loadReadyText: "Release to load",
    this.loadingText: "Loading...",
    this.loadedText: "Load finished",
    this.noMoreText: "No more",
    this.bgColor: Colors.blue,
    this.textColor: Colors.white,
    this.loadHeight: 70.0,
    this.isFloat: false
  }):super(
    key: key ?? new GlobalKey<ClassicsFooterState>(),
    loadHeight: loadHeight,
    isFloat: isFloat
  );

  @override
  ClassicsFooterState createState() => ClassicsFooterState();
}
class ClassicsFooterState extends RefreshFooterState<ClassicsFooter> {
  // 提示加载文字
  String loadText;
  // 准备加载文字
  String loadReadyText;
  // 正在加载文字
  String loadingText;
  // 没有更多文字
  String noMoreText;
  // 刷新完成文字
  String loadedText;
  // 显示的文字
  String _showText;

  // 初始化操作
  @override
  void initState() {
    super.initState();
    loadText = widget.loadText;
    loadReadyText = widget.loadReadyText;
    loadingText = widget.loadingText;
    noMoreText = widget.noMoreText;
    loadedText = widget.loadedText;
    _showText = widget.loadText;
  }


  // 准备加载回调
  @override
  Future onLoadReady() async {
    super.onLoadReady();
    setState(() {
      _showText = loadReadyText;
    });
  }

  // 正在加载回调
  @override
  Future onLoading() async {
    super.onLoading();
    setState(() {
      _showText = loadingText;
    });
  }

  // 加载完成回调
  @override
  Future onLoaded() async {
    super.onLoaded();
    setState(() {
      _showText = loadedText;
    });
  }

  // 没有更多数据回调
  @override
  Future onNoMore() async {
    super.onNoMore();
    setState(() {
      _showText = noMoreText;
    });
  }

  // 加载恢复回调
  @override
  Future onLoadRestore() async {
    super.onLoadRestore();
    setState(() {
      _showText = loadText;
    });
  }

  // 加载结束回调
  @override
  Future onLoadEnd() async {
    super.onLoadEnd();
    setState(() {
      _showText = loadText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container( //上拉加载布局
      color: widget.bgColor,
      height: this.height,
      child: ListView(
        children: <Widget>[
          Container(
            height: this.height > 30.0 ? this.height : 30.0,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                this.refreshFooterStatus == RefreshFooterStatus.NO_LOAD ? Icon(
                  Icons.arrow_upward,
                  color: widget.textColor,
                ): Container(),
                this.refreshFooterStatus == RefreshFooterStatus.LOADING ? new Align(
                  alignment: Alignment.centerLeft,
                  child: new Container(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation(widget.textColor),
                    ),
                  ),
                ): Container(),
                this.refreshFooterStatus == RefreshFooterStatus.LOAD_READY ? Icon(
                  Icons.arrow_downward,
                  color: widget.textColor,
                ): Container(),
                this.refreshFooterStatus == RefreshFooterStatus.LOADED ? Icon(
                  Icons.done,
                  color: widget.textColor,
                ): Container(),
                new Container(margin: EdgeInsets.only(right: 10.0),),
                new Align(
                  alignment: Alignment.centerRight,
                  child: new Text(_showText,
                    style: new TextStyle(color: widget.textColor),),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}