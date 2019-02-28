import 'dart:async';

import 'package:example/generated/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// TabView页面
class TabViewPage extends StatefulWidget {
  @override
  _TabViewPageState createState() => _TabViewPageState();
}

class _TabViewPageState extends State<TabViewPage>
    with SingleTickerProviderStateMixin {
  List<String> addStrList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> strList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> addStrGrid = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> strGrid = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  GlobalKey<RefreshHeaderState> _headerKeyList =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKeyList =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKeyGrid =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKeyGrid =
      new GlobalKey<RefreshFooterState>();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Translations.of(context).text("TabView")),
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            new Card(
              color: Theme.of(context).primaryColor,
              elevation: 0.0,
              margin: new EdgeInsets.all(0.0),
              shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0)),
              ),
              child: new TabBar(controller: _tabController, tabs: <Widget>[
                new Tab(
                  text: Translations.of(context).text("List"),
                ),
                new Tab(
                  text: Translations.of(context).text("Grid"),
                ),
              ]),
            ),
            new Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  new EasyRefresh(
                    refreshHeader: ClassicsHeader(
                      key: _headerKeyList,
                      refreshText:
                          Translations.of(context).text("pullToRefresh"),
                      refreshReadyText:
                          Translations.of(context).text("releaseToRefresh"),
                      refreshingText:
                          Translations.of(context).text("refreshing") + "...",
                      refreshedText: Translations.of(context).text("refreshed"),
                      moreInfo: Translations.of(context).text("updateAt"),
                      bgColor: Colors.transparent,
                      textColor: Colors.black,
                    ),
                    refreshFooter: ClassicsFooter(
                        key: _footerKeyList,
                        loadHeight: 50.0,
                        loadText: Translations.of(context).text("pushToLoad"),
                        loadReadyText:
                            Translations.of(context).text("releaseToLoad"),
                        loadingText: Translations.of(context).text("loading"),
                        loadedText: Translations.of(context).text("loaded"),
                        noMoreText: Translations.of(context).text("noMore"),
                        moreInfo: Translations.of(context).text("updateAt"),
                        textColor: Colors.black,
                        bgColor: Colors.transparent),
                    child: new ListView.builder(
                      //ListView的Item
                      itemCount: strList.length,
                      itemBuilder: (context, index) {
                        return new Container(
                            height: 70.0,
                            child: Card(
                              child: new Center(
                                child: new Text(
                                  strList[index],
                                  style: new TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ));
                      },
                    ),
                    onRefresh: () async {
                      await new Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          strList.clear();
                          strList.addAll(addStrList);
                        });
                      });
                    },
                    loadMore: () async {
                      await new Future.delayed(const Duration(seconds: 1), () {
                        if (strList.length < 20) {
                          setState(() {
                            strList.addAll(addStrList);
                          });
                        }
                      });
                    },
                  ),
                  new EasyRefresh(
                    refreshHeader: ClassicsHeader(
                      key: _headerKeyGrid,
                      refreshText:
                          Translations.of(context).text("pullToRefresh"),
                      refreshReadyText:
                          Translations.of(context).text("releaseToRefresh"),
                      refreshingText:
                          Translations.of(context).text("refreshing") + "...",
                      refreshedText: Translations.of(context).text("refreshed"),
                      moreInfo: Translations.of(context).text("updateAt"),
                      bgColor: Colors.transparent,
                      textColor: Colors.black,
                    ),
                    refreshFooter: ClassicsFooter(
                        key: _footerKeyGrid,
                        loadHeight: 50.0,
                        loadText: Translations.of(context).text("pushToLoad"),
                        loadReadyText:
                            Translations.of(context).text("releaseToLoad"),
                        loadingText: Translations.of(context).text("loading"),
                        loadedText: Translations.of(context).text("loaded"),
                        noMoreText: Translations.of(context).text("noMore"),
                        moreInfo: Translations.of(context).text("updateAt"),
                        textColor: Colors.black,
                        bgColor: Colors.transparent),
                    child: new GridView.builder(
                      //ListView的Item
                      itemCount: strGrid.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (BuildContext context, int index) {
                        return new Container(
                            height: 100.0,
                            child: Card(
                              child: new Center(
                                child: new Text(
                                  strGrid[index],
                                  style: new TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ));
                      },
                    ),
                    onRefresh: () async {
                      await new Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          strGrid.clear();
                          strGrid.addAll(addStrGrid);
                        });
                      });
                    },
                    loadMore: () async {
                      await new Future.delayed(const Duration(seconds: 1), () {
                        if (strGrid.length < 20) {
                          setState(() {
                            strGrid.addAll(addStrGrid);
                          });
                        }
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
