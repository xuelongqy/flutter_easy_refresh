import 'dart:async';

import 'package:example/generated/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// NestedScrollView页面
class NestedScrollViewPage extends StatefulWidget {
  @override
  _NestedScrollViewPageState createState() => _NestedScrollViewPageState();
}

class _NestedScrollViewPageState extends State<NestedScrollViewPage>
    with SingleTickerProviderStateMixin {
  List<String> addStrList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> strList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> addStrGrid = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0"
  ];
  List<String> strGrid = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0"
  ];
  GlobalKey<RefreshHeaderState> _headerKeyList =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshHeaderState> _connectorHeaderKeyList =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKeyList =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshFooterState> _connectorFooterKeyList =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKeyGrid =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshHeaderState> _connectorHeaderKeyGrid =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKeyGrid =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshFooterState> _connectorFooterKeyGrid =
      new GlobalKey<RefreshFooterState>();
  ScrollController _controller;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = new ScrollController();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Widget headerList = ClassicsHeader(
      key: _headerKeyList,
      refreshText: Translations.of(context).text("pullToRefresh"),
      refreshReadyText: Translations.of(context).text("releaseToRefresh"),
      refreshingText: Translations.of(context).text("refreshing") + "...",
      refreshedText: Translations.of(context).text("refreshed"),
      moreInfo: Translations.of(context).text("updateAt"),
      bgColor: Colors.transparent,
      textColor: Colors.black,
    );
    Widget footerList = ClassicsFooter(
      key: _footerKeyList,
      loadHeight: 50.0,
      loadText: Translations.of(context).text("pushToLoad"),
      loadReadyText: Translations.of(context).text("releaseToLoad"),
      loadingText: Translations.of(context).text("loading"),
      loadedText: Translations.of(context).text("loaded"),
      noMoreText: Translations.of(context).text("noMore"),
      moreInfo: Translations.of(context).text("updateAt"),
      bgColor: Colors.transparent,
      textColor: Colors.black,
    );
    Widget headerGrid = ClassicsHeader(
      key: _headerKeyGrid,
      refreshText: Translations.of(context).text("pullToRefresh"),
      refreshReadyText: Translations.of(context).text("releaseToRefresh"),
      refreshingText: Translations.of(context).text("refreshing") + "...",
      refreshedText: Translations.of(context).text("refreshed"),
      moreInfo: Translations.of(context).text("updateAt"),
      bgColor: Colors.transparent,
      textColor: Colors.black,
    );
    Widget footerGrid = ClassicsFooter(
      key: _footerKeyGrid,
      loadHeight: 50.0,
      loadText: Translations.of(context).text("pushToLoad"),
      loadReadyText: Translations.of(context).text("releaseToLoad"),
      loadingText: Translations.of(context).text("loading"),
      loadedText: Translations.of(context).text("loaded"),
      noMoreText: Translations.of(context).text("noMore"),
      moreInfo: Translations.of(context).text("updateAt"),
      bgColor: Colors.transparent,
      textColor: Colors.black,
    );
    return Scaffold(
      body: new NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            new SliverAppBar(
              title: Text("NestedScrollView"),
              centerTitle: true,
              expandedHeight: 190.0,
              flexibleSpace: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Container(),
              ),
              floating: false,
              pinned: true,
              bottom: new PreferredSize(
                child: new Card(
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
                preferredSize: new Size(double.infinity, 46.0),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            new EasyRefresh(
              outerController: _controller,
              refreshHeader: ConnectorHeader(
                  key: _connectorHeaderKeyList, header: headerList),
              refreshFooter: ConnectorFooter(
                  key: _connectorFooterKeyList, footer: footerList),
              child: CustomScrollView(
                semanticChildCount: strList.length,
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(<Widget>[headerList]),
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                    childCount: strList.length,
                  )),
                  SliverList(
                    delegate: SliverChildListDelegate(<Widget>[footerList]),
                  )
                ],
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
              outerController: _controller,
              refreshHeader: ConnectorHeader(
                  key: _connectorHeaderKeyGrid, header: headerGrid),
              refreshFooter: ConnectorFooter(
                  key: _connectorFooterKeyGrid, footer: footerGrid),
              child: CustomScrollView(
                semanticChildCount: strGrid.length,
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(<Widget>[headerGrid]),
                  ),
                  SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                        childCount: strGrid.length,
                      )),
                  SliverList(
                    delegate: SliverChildListDelegate(<Widget>[footerGrid]),
                  )
                ],
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
                  if (strGrid.length < 40) {
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
    );
  }
}
