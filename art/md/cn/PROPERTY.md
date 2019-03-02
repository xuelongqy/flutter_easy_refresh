# 代码示例
~~~dart
class _BasicPageState extends State<BasicPage> {

  List<String> addStr=["1","2","3","4","5","6","7","8","9","0"];
  List<String> str=["1","2","3","4","5","6","7","8","9","0"];
  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text("basicUse")),
      ),
      body: Center(
          child: new EasyRefresh(
            key: _easyRefreshKey,
            autoLoad: false,
            behavior: ScrollOverBehavior(),
            refreshHeader: ClassicsHeader(
              key: _headerKey,
              refreshText: Translations.of(context).text("pullToRefresh"),
              refreshReadyText: Translations.of(context).text("releaseToRefresh"),
              refreshingText: Translations.of(context).text("refreshing") + "...",
              refreshedText: Translations.of(context).text("refreshed"),
              moreInfo: Translations.of(context).text("updateAt"),
              bgColor: Colors.transparent,
              textColor: Colors.black87,
              moreInfoColor: Colors.black54,
              showMore: true,
            ),
            refreshFooter: ClassicsFooter(
              key: _footerKey,
              loadText: Translations.of(context).text("pushToLoad"),
              loadReadyText: Translations.of(context).text("releaseToLoad"),
              loadingText: Translations.of(context).text("loading"),
              loadedText: Translations.of(context).text("loaded"),
              noMoreText: Translations.of(context).text("noMore"),
              moreInfo: Translations.of(context).text("updateAt"),
              bgColor: Colors.transparent,
              textColor: Colors.black87,
              moreInfoColor: Colors.black54,
              showMore: true,
            ),
            child: new ListView.builder(
              //ListView的Item
                itemCount: str.length,
                itemBuilder: (BuildContext context,int index){
                  return new Container(
                      height: 70.0,
                      child: Card(
                        child: new Center(
                          child: new Text(str[index],style: new TextStyle(fontSize: 18.0),),
                        ),
                      )
                  );
                }
            ),
            onRefresh: () async{
              await new Future.delayed(const Duration(seconds: 1), () {
                setState(() {
                  str.clear();
                  str.addAll(addStr);
                });
              });
            },
            loadMore: () async {
              await new Future.delayed(const Duration(seconds: 1), () {
                if (str.length < 20) {
                  setState(() {
                    str.addAll(addStr);
                  });
                }
              });
            },
          )
      ),
      persistentFooterButtons: <Widget>[
        FlatButton(onPressed: () {
          _easyRefreshKey.currentState.callRefresh();
        }, child: Text(Translations.of(context).text("refresh"), style: TextStyle(color: Colors.black))),
        FlatButton(onPressed: () {
          _easyRefreshKey.currentState.callLoadMore();
        }, child: Text(Translations.of(context).text("loadMore"), style: TextStyle(color: Colors.black)))
      ],// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
~~~

# 属性表格 - EasyRefresh
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| key | EasyRefresh的键     | GlobalKey<EasyRefreshState>  | null | 可选(用于手动触发加载和刷新) |
| child      | 内容视图     | Widget   |   null |  必需 |
| autoLoad | 底部自动加载     | bool  | false | 可选 |
| firstRefresh | 首次刷新     | bool |false | 可选 |
| firstRefreshWidget | 首次刷新视图     | Widget |null | 可选(为null时使用refreshHeader, 可以为RefreshHeader类型) |
| emptyWidget | 空视图     | Widget |null | 可选(当ScrollView的semanticChildCount为0时显示) |
| limitScroll | 限制滚动     | bool  | false | 可选 |
| autoControl | 自动控制(刷新和加载完成)     | bool  | true | 可选 |
| behavior | 越界效果(自带光晕或回弹)     | ScrollBehavior | RefreshBehavior | 可选 |
| refreshHeader | 顶部视图     | RefreshHeader | ClassicsHeader | 可选 |
| refreshFooter | 底部视图     | RefreshFooter | ClassicsFooter | 可选 |
| headerStatusChanged | Header状态改变回调     | (HeaderStatus) => void | null | 可选 |
| footerStatusChanged | Footer状态改变回调     | (FooterStatus) => void | null | 可选 |
| headerHeightChanged | Header高度改变回调     | (double) => void | null | 可选 |
| footerHeightChanged | Footer高度改变回调     | (double) => void | null | 可选 |
| outerController | 外部滚动控制器(例如NestedScrollView)     | ScrollController | null | 可选 |
| onRefresh | 刷新回调方法     | () => Void | null | 可选(为null时无法触发刷新) |
| loadMore | 加载回调方法     | () => Void | null | 可选(为null时无法触发加载) |
| animationStateChangedCallback | EasyRefresh状态回调，用于手动处理刷新加载等操作     | (AnimationStates, RefreshBoxDirectionStatus) => void     | null | 可选(不推荐使用) |
| builder | 过渡构建器，用于添加额外组件，例如滚动条     | (BuildContext, Widget, ScrollController) => Widget     | null | 可选 |

## 属性表格 - RefreshSafeArea(用于包裹滚动冲突的Widget)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| child      | 内容视图     | Widget   |   null |  必需 |

## 属性表格 - ListenerHeader(用于快速在页面定义Header,方便当前页面交互)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| refreshHeight      | 触发刷新的高度     | double   |   70.0 |  可选 |
| finishDelay      | 刷新完成延时     | int   |   1000 |  可选 |
| listener      | Header监听器     | HeaderListener   |   null |  必须 |

## 属性表格 - ConnectorHeader(用于将Header放置到其他位置并做连接)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| header      | 需要连接的Header     | RefreshHeader   |   null |  必须 |

## 属性表格 - ListenerFooter(用于快速在页面定义Footer,方便当前页面交互)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| loadHeight      | 触发加载的高度     | double   |   70.0 |  可选 |
| finishDelay      | 加载完成延时     | int   |   1000 |  可选 |
| listener      | Footer监听器     | FooterListener   |   null |  必须 |

## 属性表格 - ConnectorFooter(用于将Footer放置到其他位置并做连接)
| 属性名称     |     属性描述     | 参数类型 | 默认值  | 要求 |
|---------|--------------------------|:-----:|:-----:|:-----:|
| footer      | 需要连接的Footer     | RefreshFooter   |   null |  必须 |

