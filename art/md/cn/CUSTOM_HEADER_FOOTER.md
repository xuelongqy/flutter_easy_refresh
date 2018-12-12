# 自定义Header
## 代码示例
必须继承RefreshHeader以及RefreshHeaderState并实现里面的方法即可(和你自定义StatefulWidget是一样的)
~~~dart
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
class ClassicsHeaderState extends RefreshHeaderState<ClassicsHeader> {
  // 显示的文字
  String _showText;
  // 更新时间
  DateTime _dateTime;

  // 初始化操作
  @override
  void initState() {
    super.initState();
    _showText = widget.refreshText;
    _dateTime = DateTime.now();
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
  }
  // 刷新结束回调
  @override
  Future onRefreshEnd() async {
    super.onRefreshEnd();
    setState(() {
      _showText = widget.refreshText;
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
      child: ListView(
        children: <Widget>[
          Container(
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
        ],
      ),
    );
  }
}
~~~

## 属性表格
### RefreshHeader
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| key | RefreshHeader的键     | GlobalKey<RefreshHeaderState>  | null | 必须(不为null) |
| refreshHeight      | 触发刷新的高度     | doubl   |   70.0 |  可选 |
| isFloat | 是否浮动     | bool  | false | 可选 |
| finishDelay | 完成延时,刷新完成后停留时间     | int(ms) | 1000 | 可选 |

### RefreshHeaderState
| 属性名称     |     属性描述     | 参数类型 | 要求  |
|---------|--------------------------|:-----:|:-----:|
| refreshHeaderStatus | 当前刷新状态     | RefreshHeaderStatus  | 不建议修改 |
| height      | 当前拉动刷新的高度(一般用于控制视图高度)     | doubl   |   不建议修改 |
| updateHeight | 高度更新回调     | (double) => void  | 可选继承 |
| onRefreshStart | 开始下拉回调     | () => void | 可选继承 |
| onRefreshReady | 超过刷新高度,准备刷新回调     | () => void | 可选继承 |
| onRefreshing | 正在刷新回调     | () => void | 可选继承 |
| onRefreshed | 刷新完成回调     | () => void | 可选继承 |
| onRefreshRestore | 未刷新,恢复到小于刷新高度回调     | () => void | 可选继承 |
| onRefreshEnd | Header关闭后，刷新结束回调     | () => void | 可选继承 |

# 自定义Footer
## 代码示例
必须继承RefreshFooter以及RefreshFooterState并实现里面的方法即可(和你自定义StatefulWidget是一样的)
~~~dart
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
  ClassicsFooter({
    GlobalKey<RefreshFooterState> key,
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
    this.moreInfo: "Loaded at %T"
  }):super(
    key: key,
    loadHeight: loadHeight,
    isFloat: isFloat
  );

  @override
  ClassicsFooterState createState() => ClassicsFooterState();
}
class ClassicsFooterState extends RefreshFooterState<ClassicsFooter> {
  // 显示的文字
  String _showText;
  // 更新时间
  DateTime _dateTime;

  // 初始化操作
  @override
  void initState() {
    super.initState();
    _showText = widget.loadText;
    _dateTime = DateTime.now();
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
      _dateTime = DateTime.now();
      _showText = widget.loadedText;
    });
  }
  // 没有更多数据回调
  @override
  Future onNoMore() async {
    super.onNoMore();
    setState(() {
      _dateTime = DateTime.now();
      _showText = widget.noMoreText;
    });
  }
  // 加载恢复回调
  @override
  Future onLoadRestore() async {
    super.onLoadRestore();
    setState(() {
      _showText = widget.loadText;
    });
  }
  // 加载结束回调
  @override
  Future onLoadEnd() async {
    super.onLoadEnd();
    setState(() {
      _showText = widget.loadText;
    });
  }

  // 获取更多信息
  String _getMoreInfo() {
    String fillChar = _dateTime.minute < 10 ? "0" : "";
    return widget.moreInfo.replaceAll("%T", "${_dateTime.hour}:$fillChar${_dateTime.minute}");
  }

  @override
  Widget build(BuildContext context) {
    return new Container( //上拉加载布局
      color: widget.bgColor,
      height: this.height,
      child: ListView(
        children: <Widget>[
          Container(
            height: this.height > 45.0 ? this.height : 45.0,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded (
                  flex: 1,
                  child: new Container(
                    alignment: Alignment.centerRight,
                    child: Row (
                      mainAxisAlignment: MainAxisAlignment.end,
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
        ],
      ),
    );
  }
}
~~~

## 属性表格
### RefreshFooter
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| key | RefreshFooter的键     | GlobalKey<RefreshFooterState>  | null | 必须(不为null) |
| loadHeight      | 触发加载的高度     | doubl   |   70.0 |  可选 |
| isFloat | 是否浮动     | bool  | false | 可选 |
| finishDelay | 完成延时,刷新完成后停留时间     | int(ms) | 1000 | 可选 |

### RefreshFooterState
| 属性名称     |     属性描述     | 参数类型 | 要求  |
|---------|--------------------------|:-----:|:-----:|
| refreshFooterStatus | 当前加载状态     | RefreshFooterStatus  | 不建议修改 |
| height      | 当前拉动加载的高度(一般用于控制视图高度)     | doubl   |   不建议修改 |
| updateHeight | 高度更新回调     | (double) => void  | 可选继承 |
| onLoadStart | 开始加载回调     | () => void | 可选继承 |
| onLoadReady | 超过加载高度,准备加载回调     | () => void | 可选继承 |
| onLoading | 正在加载回调     | () => void | 可选继承 |
| onLoaded | 加载完成回调     | () => void | 可选继承 |
| onNoMore | 没有更多回调（加载完成)     | () => void | 可选继承 |
| onLoadRestore | 未加载,恢复到小于加载高度回调     | () => void | 可选继承 |
| onLoadEnd | Footer关闭后，加载结束回调     | () => void | 可选继承 |

