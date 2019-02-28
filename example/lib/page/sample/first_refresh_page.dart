import 'dart:async';

import 'package:example/generated/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// 首次刷新页面
class FirstRefreshPage extends StatefulWidget {
  @override
  _FirstRefreshPageState createState() => _FirstRefreshPageState();
}

class _FirstRefreshPageState extends State<FirstRefreshPage> {
  List<String> addStr = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  List<String> str = [];
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text("firstRefresh")),
      ),
      body: Center(
          child: new EasyRefresh(
        key: _easyRefreshKey,
        refreshHeader: ClassicsHeader(
            key: _headerKey,
            refreshText: Translations.of(context).text("pullToRefresh"),
            refreshReadyText: Translations.of(context).text("releaseToRefresh"),
            refreshingText: Translations.of(context).text("refreshing") + "...",
            refreshedText: Translations.of(context).text("refreshed"),
            moreInfo: Translations.of(context).text("updateAt"),
            bgColor: Colors.orange),
        refreshFooter: ClassicsFooter(
            key: _footerKey,
            loadHeight: 50.0,
            loadText: Translations.of(context).text("pushToLoad"),
            loadReadyText: Translations.of(context).text("releaseToLoad"),
            loadingText: Translations.of(context).text("loading"),
            loadedText: Translations.of(context).text("loaded"),
            noMoreText: Translations.of(context).text("noMore"),
            moreInfo: Translations.of(context).text("updateAt"),
            bgColor: Colors.orange),
        firstRefresh: true,
        firstRefreshWidget: new Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black12,
          child: new Center(
              child: SizedBox(
            height: 200.0,
            width: 300.0,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    height: 50.0,
                    child: SpinKitFadingCube(
                      color: Theme.of(context).primaryColor,
                      size: 25.0,
                    ),
                  ),
                  Container(
                    child:
                        Text(Translations.of(context).text("loading") + "..."),
                  )
                ],
              ),
            ),
          )),
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
          await new Future.delayed(const Duration(seconds: 3), () {
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
      )),
    );
  }
}
