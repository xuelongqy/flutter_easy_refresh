import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

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

  List<String> addStrs=["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
  List<String> strs=["1","2","3","4","5","6","7","8","9","0"];

  ScrollController controller = new ScrollController();
  ScrollPhysics scrollPhysics = new RefreshAlwaysScrollPhysics();


  Future _loadData(bool isPullDown) async{
    setState(() {
      //拿到数据后，对数据进行梳理
      if(isPullDown){
        strs.clear();
        strs.addAll(addStrs);
      }else{
        strs.addAll(addStrs);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new EasyRefresh(
          child: new ListView.builder(
            //ListView的Item
            itemCount: strs.length,
            controller: controller,
            physics: scrollPhysics,
            itemBuilder: (BuildContext context,int index){
              return new Container(
                height: 35.0,
                child: new Center(
                  child: new Text(strs[index],style: new TextStyle(fontSize: 18.0),),
                ),
              );
            }
          ),
          onRefresh: () async{
            setState(() {
              strs.clear();
              strs.addAll(addStrs);
            });
          },
          loadMore: () async {
            setState(() {
              strs.addAll(addStrs);
            });
          },
          scrollPhysicsChanged: (ScrollPhysics physics) {
            setState(() {
              scrollPhysics = physics;
            });
          },
        )
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
