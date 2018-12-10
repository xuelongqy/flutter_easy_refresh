import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_easyrefresh/material_footer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyRefresh Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'EasyRefresh Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<String> addStr=["1","2","3","4","5","6","7","8","9","0"];
  List<String> str=["1","2","3","4","5","6","7","8","9","0"];
  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  GlobalKey<ClassicsHeaderState> _headerKey = new GlobalKey<ClassicsHeaderState>();
  GlobalKey<ClassicsFooterState> _footerKey = new GlobalKey<ClassicsFooterState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: new EasyRefresh(
          key: _easyRefreshKey,
          behavior: ScrollOverBehavior(),
//          refreshHeader: MaterialHeader(),
//          refreshFooter: MaterialFooter(),
          refreshHeader: ClassicsHeader(
            key: _headerKey,
            bgColor: Colors.transparent,
            textColor: Colors.black,
            moreInfoColor: Colors.black54,
            showMore: true,
          ),
          refreshFooter: ClassicsFooter(
            key: _footerKey,
            bgColor: Colors.transparent,
            textColor: Colors.black,
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
        }, child: Text("Refresh")),
        FlatButton(onPressed: () {
          _easyRefreshKey.currentState.callLoadMore();
        }, child: Text("LoadMore"))
      ],// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
