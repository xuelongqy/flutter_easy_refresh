# Custom Header
## Code example
The importing the RefreshHeaderand RefreshHeaderStatestandardmethods (and the customicStatefulWidgetis the use)
~~~dart
/// Classic (default) Header
class ClassicsHeader extends RefreshHeader {
  final String refreshText;
  final String refreshReadyText;
  final String refreshingText;
  final String refreshedText;
  final Color bgColor;
  final Color textColor;
  final double refreshHeight;
  final bool isFloat;
  final bool showMore;
  final String moreInfo;
  final Color moreInfoColor;

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
  String _showText;
  DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _showText = widget.refreshText;
    _dateTime = DateTime.now();
  }

  @override
  Future onRefreshReady() async {
    super.onRefreshReady();
    setState(() {
      _showText = widget.refreshReadyText;
    });
  }
  @override
  Future onRefreshing() async {
    super.onRefreshing();
    setState(() {
      _showText = widget.refreshingText;
    });
  }
  @override
  Future onRefreshed() async {
    super.onRefreshed();
    setState(() {
      _dateTime = DateTime.now();
      _showText = widget.refreshedText;
    });
  }
  @override
  Future onRefreshRestore() async {
    super.onRefreshRestore();
    setState(() {
      _showText = widget.refreshText;
    });
  }
  @override
  Future onRefreshEnd() async {
    super.onRefreshEnd();
    setState(() {
      _showText = widget.refreshText;
    });
  }

  String _getMoreInfo() {
    String fillChar = _dateTime.minute < 10 ? "0" : "";
    return widget.moreInfo.replaceAll("%T", "${_dateTime.hour}:$fillChar${_dateTime.minute}");
  }

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

## Props Table
### RefreshHeader
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| key | RefreshHeader key     | GlobalKey<RefreshHeaderState>  | null | necessary(not null) |
| refreshHeight      | Height of trigger refresh     | doubl   |   70.0 |  optional |
| isFloat | Whether floating     | bool  | false | optional |
| finishDelay | Completion Delay, Residence Time after Refresh Completion     | int(ms) | 1000 | optional |

### RefreshHeaderState
| Attribute Name     |     Attribute Explain     | Parameter Type | Requirement  |
|---------|--------------------------|:-----:|:-----:|
| refreshHeaderStatus | Current refresh status     | RefreshHeaderStatus  | Not recommended to modify |
| height      | The height of the current pull refresh (generally is used to control the view level)     | doubl   |   Not recommended to modify |
| updateHeight | Highly update callbacks     | (double) => void  | Optional extends |
| onRefreshStart | Start pull-down callback     | () => void | Optional extends |
| onRefreshReady | More than refresh height, ready to refresh the callback     | () => void | Optional extends |
| onRefreshing | The callback is refreshing     | () => void | Optional extends |
| onRefreshed | Refresh the callback     | () => void | Optional extends |
| onRefreshRestore | Not refresh, back to less than the refresh height correction     | () => void | Optional extends |
| onRefreshEnd | The Header is turned off, refreshes the back end     | () => void | Optional extends |

# Custom Footer
## Code example
The importing the RefreshFooterand RefreshFooterStateStatestandardmethods (and the customicStatefulWidgetis the use)
~~~dart
/// Classic (default) Footer
class ClassicsFooter extends RefreshFooter {
  final String loadText;
  final String loadReadyText;
  final String loadingText;
  final String noMoreText;
  final String loadedText;
  final Color bgColor;
  final Color textColor;
  final double loadHeight;
  final bool isFloat;
  final bool showMore;
  final String moreInfo;
  final Color moreInfoColor;

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
  String _showText;
  DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _showText = widget.loadText;
    _dateTime = DateTime.now();
  }

  @override
  Future onLoadReady() async {
    super.onLoadReady();
    setState(() {
      _showText = widget.loadReadyText;
    });
  }
  @override
  Future onLoading() async {
    super.onLoading();
    setState(() {
      _showText = widget.loadingText;
    });
  }
  @override
  Future onLoaded() async {
    super.onLoaded();
    setState(() {
      _dateTime = DateTime.now();
      _showText = widget.loadedText;
    });
  }
  @override
  Future onNoMore() async {
    super.onNoMore();
    setState(() {
      _dateTime = DateTime.now();
      _showText = widget.noMoreText;
    });
  }
  @override
  Future onLoadRestore() async {
    super.onLoadRestore();
    setState(() {
      _showText = widget.loadText;
    });
  }
  @override
  Future onLoadEnd() async {
    super.onLoadEnd();
    setState(() {
      _showText = widget.loadText;
    });
  }

  String _getMoreInfo() {
    String fillChar = _dateTime.minute < 10 ? "0" : "";
    return widget.moreInfo.replaceAll("%T", "${_dateTime.hour}:$fillChar${_dateTime.minute}");
  }

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

## Props Table
### RefreshFooter
| Attribute Name     |     Attribute Explain     | Parameter Type | Default Value  | Requirement |
|---------|--------------------------|:-----:|:-----:|:-----:|
| key | RefreshFooter key     | GlobalKey<RefreshFooterState>  | null | necessary(Not null) |
| loadHeight      | Trigger the height of the load     | doubl   |   70.0 |  Optional |
| isFloat | Whether floating     | bool  | false | Optional |
| finishDelay | Complete the time delay, refresh after the completion of the residence time     | int(ms) | 1000 | Optional |

### RefreshFooterState
| Attribute Name     |     Attribute Explain     | Parameter Type | Requirement  |
|---------|--------------------------|:-----:|:-----:|
| refreshFooterStatus | The current load status     | RefreshFooterStatus  | Not recommended to modify |
| height      | The height of the current pull load (generally is used to control the view level)     | doubl   |   Not recommended to modify |
| updateHeight | Highly update callbacks     | (double) => void  | Optional extends |
| onLoadStart | Began to load the callback     | () => void | Optional extends |
| onLoadReady | Over loading height, ready to load the callback     | () => void | Optional extends |
| onLoading | Being loaded callback     | () => void | Optional extends |
| onLoaded | Loaded callback     | () => void | Optional extends |
| onNoMore | There are no more callbacks (loaded)     | () => void | Optional extends |
| onLoadRestore | Not loaded, back to less than the load height correction     | () => void | Optional extends |
| onLoadEnd | The Footer is turned off, the load end of callback     | () => void | Optional extends |

