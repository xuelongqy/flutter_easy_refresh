import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/bezier_circle_header.dart';

/// 弹出圆圈样式页面
class BezierCirclePage extends StatefulWidget {
  @override
  _BezierCirclePagePageState createState() => _BezierCirclePagePageState();
}

class _BezierCirclePagePageState extends State<BezierCirclePage> {

  List<String> addStr=["1","2","3","4","5","6","7","8","9","0"];
  List<String> str=["1","2","3","4","5","6","7","8","9","0"];
  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BezierCircle"),
      ),
      body: Center(
          child: new EasyRefresh(
            key: _easyRefreshKey,
            refreshHeader: BezierCircleHeader(
              key: _headerKey,
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
          )
      ),
    );
  }
}