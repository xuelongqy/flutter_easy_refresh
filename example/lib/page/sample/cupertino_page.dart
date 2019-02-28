import 'dart:async';

import 'package:example/generated/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// ios风格页面
class CupertinoPage extends StatefulWidget {
  @override
  _CupertinoPageState createState() => _CupertinoPageState();
}

class _CupertinoPageState extends State<CupertinoPage> {
  List<String> addStr = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> str = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshHeaderState> _connectorHeaderKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshFooterState> _connectorFooterKey =
      new GlobalKey<RefreshFooterState>();

  @override
  Widget build(BuildContext context) {
    Widget header = ClassicsHeader(
      key: _headerKey,
      refreshText: Translations.of(context).text("pullToRefresh"),
      refreshReadyText: Translations.of(context).text("releaseToRefresh"),
      refreshingText: Translations.of(context).text("refreshing") + "...",
      refreshedText: Translations.of(context).text("refreshed"),
      moreInfo: Translations.of(context).text("updateAt"),
      bgColor: Colors.transparent,
      textColor: Colors.black,
    );
    Widget footer = ClassicsFooter(
      key: _footerKey,
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
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                title: Text('Page1'),
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                title: Text('Page2'),
              ),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            return CupertinoTabView(
              builder: (BuildContext context) {
                if (index == 0) {
                  return new EasyRefresh(
                    key: _easyRefreshKey,
                    refreshHeader: ConnectorHeader(
                      key: _connectorHeaderKey,
                      header: header,
                    ),
                    refreshFooter: ConnectorFooter(
                      key: _connectorFooterKey,
                      footer: footer,
                    ),
                    child: new CustomScrollView(
                      semanticChildCount: str.length,
                      slivers: <Widget>[
                        CupertinoSliverNavigationBar(
                          largeTitle: Text("Cupertino"),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(<Widget>[header]),
                        ),
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return new Container(
                                height: 70.0,
                                child: Container(
                                    child: Row(
                                  children: <Widget>[
                                    Card(
                                      elevation: 0.0,
                                      color: Colors.blue,
                                      margin: EdgeInsets.only(left: 10.0),
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: new Text(
                                          str[index],
                                          style: new TextStyle(fontSize: 18.0),
                                        ),
                                      ),
                                    ),
                                    Card(
                                      elevation: 0.0,
                                      margin: EdgeInsets.only(right: 10.0),
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        child: Icon(
                                          CupertinoIcons.add_circled,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                )));
                          },
                          childCount: str.length,
                        )),
                        SliverList(
                          delegate: SliverChildListDelegate(<Widget>[
                            SafeArea(
                              top: false,
                              child: footer,
                            )
                          ]),
                        )
                      ],
                    ),
                    onRefresh: () async {
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
                  );
                } else {
                  return Container();
                }
              },
              defaultTitle: 'Cupertino',
            );
          }),
    );
  }
}
