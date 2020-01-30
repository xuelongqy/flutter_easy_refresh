import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';
import 'package:url_launcher/url_launcher.dart';

/// 个人中心页面
class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).userProfile,
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0,
          brightness: Brightness.dark,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            EasyRefresh.custom(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    // 顶部栏
                    new Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 220.0,
                          color: Colors.white,
                        ),
                        ClipPath(
                          clipper: new TopBarClipper(
                              MediaQuery.of(context).size.width, 200.0),
                          child: new SizedBox(
                            width: double.infinity,
                            height: 200.0,
                            child: new Container(
                              width: double.infinity,
                              height: 240.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        // 名字
                        Container(
                          margin: new EdgeInsets.only(top: 40.0),
                          child: new Center(
                            child: new Text(
                              'KnoYo',
                              style: new TextStyle(
                                  fontSize: 30.0, color: Colors.white),
                            ),
                          ),
                        ),
                        // 图标
                        Container(
                          margin: new EdgeInsets.only(top: 100.0),
                          child: new Center(
                              child: new Container(
                            width: 100.0,
                            height: 100.0,
                            child: new PreferredSize(
                              child: new Container(
                                child: new ClipOval(
                                  child: new Container(
                                    color: Colors.white,
                                    child: new Image.asset(
                                        'assets/image/head_knoyo.jpg'),
                                  ),
                                ),
                              ),
                              preferredSize: new Size(80.0, 80.0),
                            ),
                          )),
                        ),
                      ],
                    ),
                    // 内容
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                          color: Colors.blue,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                ListItem(
                                  icon: Icon(
                                    Icons.supervised_user_circle,
                                    color: Colors.white,
                                  ),
                                  title: S.of(context).qqGroup,
                                  titleColor: Colors.white,
                                  describe: '554981921',
                                  describeColor: Colors.white,
                                  onPressed: () {
                                    launch(
                                        'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3DMNLtkvnn4n28UIB0gEgm2-WBmqmGWk0Q');
                                  },
                                ),
                                ListItem(
                                  icon: Icon(
                                    Icons.http,
                                    color: Colors.white,
                                  ),
                                  title: S.of(context).github,
                                  titleColor: Colors.white,
                                  describe: 'https://github.com/xuelongqy',
                                  describeColor: Colors.white,
                                  onPressed: () {
                                    launch('https://github.com/xuelongqy');
                                  },
                                )
                              ],
                            ),
                          )),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                          color: Colors.green,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                ListItem(
                                  icon: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  title: S.of(context).name,
                                  titleColor: Colors.white,
                                  describe: 'KnoYo',
                                  describeColor: Colors.white,
                                ),
                                ListItem(
                                  icon: EmptyIcon(),
                                  title: S.of(context).old,
                                  titleColor: Colors.white,
                                  describe: S.of(context).noBald,
                                  describeColor: Colors.white,
                                ),
                                ListItem(
                                  icon: EmptyIcon(),
                                  title: S.of(context).city,
                                  titleColor: Colors.white,
                                  describe: S.of(context).chengdu,
                                  describeColor: Colors.white,
                                )
                              ],
                            ),
                          )),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      child: Card(
                          color: Colors.teal,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                ListItem(
                                  icon: Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                  ),
                                  title: S.of(context).phone,
                                  titleColor: Colors.white,
                                  describe: '18888888888',
                                  describeColor: Colors.white,
                                ),
                                ListItem(
                                  icon: Icon(
                                    Icons.email,
                                    color: Colors.white,
                                  ),
                                  title: S.of(context).email,
                                  titleColor: Colors.white,
                                  describe: 'xuelongqy@foxmail.com',
                                  describeColor: Colors.white,
                                  onPressed: () {
                                    launch(
                                        'mailto:xuelongqy@foxmail.com?subject=EasyRefresh&body=I found a bug');
                                  },
                                )
                              ],
                            ),
                          )),
                    ),
                  ]),
                ),
              ],
            ),
          ],
        ));
  }
}

// 顶部栏裁剪
class TopBarClipper extends CustomClipper<Path> {
  // 宽高
  double width;
  double height;

  TopBarClipper(this.width, this.height);

  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(width, 0.0);
    path.lineTo(width, height / 2);
    path.lineTo(0.0, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
