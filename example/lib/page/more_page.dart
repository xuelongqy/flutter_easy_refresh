import 'package:example/generated/translations.dart';
import 'package:example/page/more/support_page.dart';
import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
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
      appBar: AppBar(
        title: Text(Translations.of(context).text("more")),
      ),
      body: EasyRefresh(
        behavior: ScrollOverBehavior(),
        child: ListView(
          children: <Widget>[
            ListItem(
              title: Translations.of(context).text("joinDiscussion"),
              describe: Translations.of(context).text("joinDiscussionDescribe"),
              icon: Icon(
                Icons.supervised_user_circle,
                color: Colors.orange,
              ),
              onPressed: () {
                launch(
                    "mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3DMNLtkvnn4n28UIB0gEgm2-WBmqmGWk0Q");
              },
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              child: Container(
                color: Colors.black12,
              ),
            ),
            ListItem(
              title: Translations.of(context).text("projectAddress"),
              describe: "https://github.com/xuelongqy/flutter_easyrefresh",
              icon: Icon(
                Icons.http,
                color: Colors.orange,
              ),
              onPressed: () {
                launch("https://github.com/xuelongqy/flutter_easyrefresh");
              },
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              child: Container(
                color: Colors.black12,
              ),
            ),
            ListItem(
              title: Translations.of(context).text("supportAuthor"),
              describe: Translations.of(context).text("supportAuthorDescribe"),
              icon: Icon(
                Icons.star,
                color: Colors.orange,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return SupportPage();
                }));
              },
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              child: Container(
                color: Colors.black12,
              ),
            ),
            ListItem(
              title: Translations.of(context).text("about"),
              icon: Icon(
                Icons.info,
                color: Colors.orange,
              ),
              onPressed: () {
                launch("https://github.com/xuelongqy/flutter_easyrefresh");
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
