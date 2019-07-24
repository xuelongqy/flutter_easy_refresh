import 'package:example/page/sample/basic.dart';
import 'package:example/widget/circular_icon.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// 样式页面
class StylePage extends StatefulWidget {
  @override
  _StylePageState createState() => _StylePageState();
}
class _StylePageState extends State<StylePage>
    with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: EasyRefresh.custom(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(FlutterI18n.translate(context, 'style')),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // 经典样式
              ListItem(
                title: FlutterI18n.translate(context, 'classic'),
                describe: FlutterI18n.translate(context, 'classicDescribe'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return BasicPage(
                            FlutterI18n.translate(context, 'classic'));
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}