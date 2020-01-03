import 'package:example/generated/i18n.dart';
import 'package:example/page/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 设置EasyRefresh的默认样式
    EasyRefresh.defaultHeader = ClassicalHeader(
      enableInfiniteRefresh: false,
    );
    EasyRefresh.defaultFooter = ClassicalFooter(
      enableInfiniteLoad: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      // App名字
      title: 'EasyRefresh',
      // App主题
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      // 主页
      home: HomePage(),
      localizationsDelegates: [
        S.delegate,
        GlobalEasyRefreshLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}
