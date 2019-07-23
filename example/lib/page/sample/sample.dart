import 'package:example/page/sample/basic.dart';
import 'package:example/widget/circular_icon.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// 示例页面
class SamplePage extends StatefulWidget {
  @override
  _SamplePageState createState() => _SamplePageState();
}
class _SamplePageState extends State<SamplePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EasyRefresh.custom(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(FlutterI18n.translate(context, 'sample')),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListItem(
                title: FlutterI18n.translate(context, 'basicUse'),
                describe: FlutterI18n.translate(context, 'basicUseDescribe'),
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return BasicPage();
                    },));
                },
                icon: CircularIcon(
                  bgColor: Theme.of(context).primaryColor,
                  icon: Icons.format_list_bulleted,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}