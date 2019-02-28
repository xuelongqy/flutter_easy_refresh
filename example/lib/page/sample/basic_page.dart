import 'dart:async';

import 'package:example/generated/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 基本使用页面
class BasicPage extends StatefulWidget {
  @override
  _BasicPageState createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  List<String> addStr = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> str = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  bool _loadMore = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text("basicUse")),
      ),
      body: Center(
          child: new EasyRefresh(
        key: _easyRefreshKey,
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
            itemBuilder: (BuildContext context, int index) {
              return new Container(
                  height: 70.0,
                  child: Card(
                    child: new Center(
                      child: new Text(
                        str[index],
                        style: new TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ));
            }),
        onRefresh: () async {
          await new Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              str.clear();
              str.addAll(addStr);
              _easyRefreshKey.currentState.waitState(() {
                setState(() {
                  _loadMore = true;
                });
              });
            });
          });
        },
        loadMore: _loadMore
            ? () async {
                await new Future.delayed(const Duration(seconds: 1), () {
                  if (str.length < 20) {
                    setState(() {
                      str.addAll(addStr);
                    });
                  } else {
                    _easyRefreshKey.currentState.waitState(() {
                      setState(() {
                        _loadMore = false;
                      });
                    });
                  }
                });
              }
            : null,
      )),
      persistentFooterButtons: <Widget>[
        FlatButton(
            onPressed: () {
              _easyRefreshKey.currentState.callRefresh();
            },
            child: Text(Translations.of(context).text("refresh"),
                style: TextStyle(color: Colors.black))),
        FlatButton(
            onPressed: () {
              _easyRefreshKey.currentState.callLoadMore();
            },
            child: Text(Translations.of(context).text("loadMore"),
                style: TextStyle(color: Colors.black)))
      ], // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
