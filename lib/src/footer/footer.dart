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

  // 获取键
  GlobalKey<RefreshFooterState> getKey() {
    return this.key;
  }

  // 构造函数
  const RefreshFooter({
    GlobalKey<RefreshFooterState> key,
    @required this.loadHeight,
    this.isFloat: false,
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
  // 回调加载重置方法
  Future onLoadReset() async {
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
  // 刷新完成文字
  final String loadedText;
  // 背景颜色
  final Color bgColor;
  // 字体颜色
  final Color textColor;

  // 构造函数
  ClassicsFooter({
    this.loadText: "Push to load",
    this.loadReadyText: "Release to load",
    this.loadingText: "Loading...",
    this.loadedText: "Load finished",
    this.bgColor: Colors.blue,
    this.textColor: Colors.white,
  }):super(
      key: new GlobalKey<RefreshFooterState>(),
      loadHeight: 50.0
  );

  @override
  _ClassicsFooterState createState() => _ClassicsFooterState();
}
class _ClassicsFooterState extends RefreshFooterState<ClassicsFooter> {
  // 显示的文字
  String _showText;

  // 初始化操作
  @override
  void initState() {
    super.initState();
    _showText = widget.loadText;
  }


  // 准备加载回调
  @override
  Future onLoadReady() async {
    super.onLoadReady();
    setState(() {
      _showText = widget.loadReadyText;
    });
  }

  // 正在加载回调
  @override
  Future onLoading() async {
    super.onLoading();
    setState(() {
      _showText = widget.loadingText;
    });
  }

  // 加载完成回调
  @override
  Future onLoaded() async {
    super.onLoaded();
    setState(() {
      _showText = widget.loadedText;
    });
  }

  // 加载重置回调
  @override
  Future onLoadReset() async {
    super.onLoadReset();
    setState(() {
      _showText = widget.loadText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container( //上拉加载布局
      color: widget.bgColor,
      height: this.height,
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
    );
  }
}