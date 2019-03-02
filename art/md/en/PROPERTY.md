# Code example
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

# Props Table - EasyRefresh
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| key | EasyRefresh key     | GlobalKey<EasyRefreshState>  | null | optional(Used for manual trigger loading and refreshing) |
| child      | your content View     | Widget   |   null |  necessary |
| autoLoad | Bottom Autoloading     | bool  | false | optional |
| firstRefresh | First refresh     | bool |false | optional |
| firstRefreshWidget | First refresh widget     | Widget |null | optional(Use refreshHeader when null, can be of type RefreshHeader) |
| emptyWidget | Empty widget     | Widget |null | optional(Displayed when the discreteChildCount of the ScrollView is 0) |
| limitScroll | Limit Scroll     | bool  | false | optional |
| autoControl | Automatic control (refresh and load complete)     | bool  | true | optional |
| behavior | Crossing the line effect (with halo or rebound)     | ScrollBehavior | RefreshBehavior | optional |
| refreshHeader | Header view     | RefreshHeader | ClassicsHeader | optional |
| refreshFooter | Footer view     | RefreshFooter | ClassicsFooter | optional |
| headerStatusChanged | Header status change callback     | (HeaderStatus) => void | null | optional |
| footerStatusChanged | Footer status change callback     | (FooterStatus) => void | null | optional |
| headerHeightChanged | Header height change callback     | (double) => void | null | optional |
| footerHeightChanged | Footer height change callback     | (double) => void | null | optional |
| outerController | External scroll controller (eg NestedScrollView)     | ScrollController | null | optional |
| onRefresh | Refresh callback method     | () => Void | null | optional(Cannot trigger refresh for null) |
| loadMore | Loading callback method     | () => Void | null | optional(Cannot trigger loading for null) |
| animationStateChangedCallback | EasyRefresh state callback for manual handling of refresh loading and other operations     | (AnimationStates, RefreshBoxDirectionStatus) => void     | null | optional(不推荐使用) |
| builder | Transition builder for adding additional components, such as scroll bars     | (BuildContext, Widget, ScrollController) => Widget     | null | optional |

## Props Table - RefreshSafeArea(Solve the scroll conflict of Widget)
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| child      | your content View     | Widget   |   null |  necessary |

## Props Table - ListenerHeader(Used to quickly define the Header on the page to facilitate the current page interaction)
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| refreshHeight      | The height at which the refresh is triggered     | double   |   70.0 |  optional |
| finishDelay      | Refresh completion delay     | int   |   1000 |  optional |
| listener      | Header event listener     | HeaderListener   |   null |  necessary |

## Props Table - ConnectorHeader(Used to place the Header in another location and connect)
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| header      | Header that needs to be connected     | RefreshHeader   |   null |  necessary |

## Props Table - ListenerFooter(Used to quickly define Footer on the page to facilitate current page interaction)
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| loadHeight      | Trigger loading height     | double   |   70.0 |  optional |
| finishDelay      | Load completion delay     | int   |   1000 |  optional |
| listener      | Footer event listener     | FooterListener   |   null |  necessary |

## Props Table - ConnectorFooter(Used to place Footer to other locations and connect)
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| footer      | Need to connect to Footer     | RefreshFooter   |   null |  necessary |