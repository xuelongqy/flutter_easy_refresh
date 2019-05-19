import 'dart:async';

import 'package:example/generated/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// TabView页面
class TabViews2Page extends StatefulWidget {
  @override
  _TabViews2PageState createState() => _TabViews2PageState();
}

class _TabViews2PageState extends State<TabViews2Page>
    with SingleTickerProviderStateMixin {
  List<String> addStrList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> strList = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> addStrGrid = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> strGrid = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 6, vsync: this);
  }
  
  final List<Tab> justtabs = [
    new Tab(text: "tab1"),
    new Tab(text: "tab2"),
    new Tab(text: "tab3"),
    new Tab(text: "tab4"),
    new Tab(text: "tab5"),
    new Tab(text: "tab6"),
  ];

  final List<GlobalKey<RefreshHeaderState>> headerKeys = [  
    GlobalKey<RefreshHeaderState>(),
    GlobalKey<RefreshHeaderState>(),
    GlobalKey<RefreshHeaderState>(),
    GlobalKey<RefreshHeaderState>(),
    GlobalKey<RefreshHeaderState>(),
    GlobalKey<RefreshHeaderState>(),
  ];

  final List<GlobalKey<RefreshFooterState>> footerKeys = [  
    GlobalKey<RefreshFooterState>(),
    GlobalKey<RefreshFooterState>(),
    GlobalKey<RefreshFooterState>(),
    GlobalKey<RefreshFooterState>(),
    GlobalKey<RefreshFooterState>(),
    GlobalKey<RefreshFooterState>(),
  ];

  @override
  Widget build(BuildContext context) {
    var w = DefaultTabController(
      length: justtabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Tabviews2"),
          elevation: 0.0,
          bottom: TabBar(
            labelColor: Colors.white,
            isScrollable: true,
            tabs: justtabs,
          ),
        ),
        body: TabBarView(
          children: justtabs.map((Tab tab) {
            int index = justtabs.indexOf(tab);
            var v1 = EasyRefresh(
                refreshHeader: ClassicsHeader(
                  key: headerKeys[index],

                  refreshText: Translations.of(context).text("pullToRefresh"),
                  refreshReadyText: Translations.of(context).text("releaseToRefresh"),
                  refreshingText: Translations.of(context).text("refreshing") + "...",
                  refreshedText: Translations.of(context).text("refreshed"),
                  moreInfo: Translations.of(context).text("updateAt"),
                  bgColor: Colors.transparent,
                  textColor: Colors.black,
                ),
                refreshFooter: ClassicsFooter(
                  key: footerKeys[index],
                  loadHeight: 50.0,
                  loadText: Translations.of(context).text("pushToLoad"),
                  loadReadyText: Translations.of(context).text("releaseToLoad"),
                  loadingText: Translations.of(context).text("loading"),
                  loadedText: Translations.of(context).text("loaded"),
                  noMoreText: Translations.of(context).text("noMore"),
                  moreInfo: Translations.of(context).text("updateAt"),
                  textColor: Colors.black,
                  bgColor: Colors.transparent
                ),
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
              
            );
            var v = Container(
              child: Text(" 00000000 "),
            );
            return v1;
          }).toList(),
        ),
      ),
    );

    var w1 = Scaffold(
        appBar: AppBar(
          title: Text(Translations.of(context).text("TabView")),
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            Card(
              color: Colors.green,
              elevation: 0.0,
              margin: new EdgeInsets.all(0.0),
              shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0.0)),
              ),
              child: new TabBar(controller: _tabController, tabs: justtabs, labelColor: Colors.white,)
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: justtabs.map((Tab tab) {
                    var index = justtabs.indexOf(tab);
                    var esfr = EasyRefresh(
                      
                      refreshHeader: ClassicsHeader(
                        key: headerKeys[index],

                        refreshText: Translations.of(context).text("pullToRefresh"),
                        refreshReadyText: Translations.of(context).text("releaseToRefresh"),
                        refreshingText: Translations.of(context).text("refreshing") + "...",
                        refreshedText: Translations.of(context).text("refreshed"),
                        moreInfo: Translations.of(context).text("updateAt"),
                        bgColor: Colors.transparent,
                        textColor: Colors.black,
                      ),
                      refreshFooter: ClassicsFooter(
                        key: footerKeys[index],
                        loadHeight: 50.0,
                        loadText: Translations.of(context).text("pushToLoad"),
                        loadReadyText: Translations.of(context).text("releaseToLoad"),
                        loadingText: Translations.of(context).text("loading"),
                        loadedText: Translations.of(context).text("loaded"),
                        noMoreText: Translations.of(context).text("noMore"),
                        moreInfo: Translations.of(context).text("updateAt"),
                        textColor: Colors.black,
                        bgColor: Colors.transparent
                      ),
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
                    );
                    return esfr;
                }).toList()
              ),
            ),
          ]
        ));
        return w;
  }
}
