import 'package:example/page/more/support.dart';
import 'package:example/widget/circular_icon.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';
import 'package:url_launcher/url_launcher.dart';

/// 更多页面
class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage>
    with AutomaticKeepAliveClientMixin {
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
              title: Text(S.of(context).more),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListItem(
                title: S.of(context).joinDiscussion,
                describe: S.of(context).joinDiscussionDescribe,
                icon: CircularIcon(
                  bgColor: Colors.blue,
                  icon: Icons.supervised_user_circle,
                ),
                onPressed: () {
                  launch(
                      "mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3DMNLtkvnn4n28UIB0gEgm2-WBmqmGWk0Q");
                },
              ),
              ListItem(
                title: S.of(context).projectAddress,
                describe: "https://github.com/xuelongqy/flutter_easyrefresh",
                icon: CircularIcon(
                  bgColor: Colors.teal,
                  icon: Icons.http,
                ),
                onPressed: () {
                  launch("https://github.com/xuelongqy/flutter_easyrefresh");
                },
              ),
              ListItem(
                title: S.of(context).supportAuthor,
                describe: S.of(context).supportAuthorDescribe,
                icon: CircularIcon(
                  bgColor: Colors.red,
                  icon: Icons.star,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return SupportPage();
                  }));
                },
              ),
              ListItem(
                title: S.of(context).about,
                icon: CircularIcon(
                  bgColor: Colors.green,
                  icon: Icons.info_outline,
                ),
                onPressed: () {
                  launch("https://github.com/xuelongqy/flutter_easyrefresh");
                },
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
