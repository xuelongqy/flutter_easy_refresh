# flutter_easyrefresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![Pub](https://img.shields.io/badge/pub-v2.1.1-orange.svg)](https://pub.dartlang.org/packages/flutter_easyrefresh)

## [English](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/README_EN.md) | 中文

正如名字一样，EasyRefresh很容易就能在Flutter应用上实现下拉刷新以及上拉加载操作，它支持几乎所有的Flutter控件。它的功能与Android的SmartRefreshLayout很相似，同样也吸取了很多三方库的优点。EasyRefresh中集成了多种风格的Header和Footer，但是它并没有局限性，你可以很轻松的自定义。使用Flutter强大的动画，甚至随便一个简单的控件也可以完成。EasyRefresh的目标是为Flutter打造一个强大，稳定，成熟的下拉刷新框架。

Web版本移步：[vue-easyrefresh](https://github.com/xuelongqy/vue-easyrefresh)

Demo：[下载 apk](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/v2/art/pkg/EasyRefresh.apk) | [web](https://xuelongqy.github.io/flutter_easyrefresh/)

![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/apk_QRCode.png)

## 特点功能:

 - 支持绝大多数Widget
 - 支持自定义并且已经集成了很多炫酷的 Header 和 Footer
 - 支持下拉刷新、上拉加载(可控制触发)
 - 支持 Header 和 Footer 列表嵌入以及视图浮动两种形式
 - 支持列表事件监听，制作任何样子的 Header 和 Footer，并且能够放在任何位置
 - 支持首次刷新，并自定义视图
 - 支持自定义列表空视图

## 传送门

 - [属性文档](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/document/cn/PROPERTY.md)
 - [常见问题](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/document/cn/FQA.md)
 - [更新日志](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/CHANGELOG_CN.md)
 - [自定义Header和Footer](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/document/cn/CUSTOM_HEADER_FOOTER.md)


#### 项目演示
|基本样式|个人中心|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/basic.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/user_profile.gif)|
|[BasicPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/basic.dart)|[UserProfilePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/user_profile.dart)|

|NestedScrollView|Header连接器|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/nested_scroll_view.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/link_header.gif)|
|[NestedScrollViewPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/nested_scroll_view.dart)|[LinkHeaderPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/link_header.dart)|

|首次刷新|空视图|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/first_refresh.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/empty.gif)|
|[FirstRefreshPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/first_refresh.dart)|[EmptyPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/empty.dart)|

|二楼|聊天页面|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/second_floor.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/chat.gif)|
|[SecondFloorPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/second_floor.dart)|[ChatPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/chat.dart)|

#### 样式演示
|Material|BallPulse|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/material.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/ball_pulse.gif)|
|[MaterialPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/style/material.dart)|[BallPulsePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/style/ball_pulse.dart)|

|BezierCircle|BezierHourGlass|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/bezier_circle.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/bezier_hour_glass.gif)|
|[BezierCirclePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/style/bezier_circle.dart)|[BezierHourGlassPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/style/bezier_hour_glass.dart)|

|Phoenix|Delivery|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/phoenix.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/taurus.gif)|
|[PhoenixPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/style/phoenix.dart)|[TaurusPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/style/taurus.dart)|

|Space|Delivery|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/space.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/delivery.gif)|
|[SpacePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/style/space.dart)|[DeliveryPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/style/delivery.dart)|

## 简单用例
#### 1.在 pubspec.yaml 中添加依赖
```
//pub方式
dependencies:
  flutter_easyrefresh: ^2.1.1

//导入方式
dependencies:
  flutter_easyrefresh:
    path: 项目路径

//git方式
dependencies:
  flutter_easyrefresh:
    git:
      url: git://github.com/xuelongqy/flutter_easyrefresh.git
```
#### 2.在布局文件中添加 EasyreFresh
```dart
import 'package:flutter_easyrefresh/easy_refresh.dart';
....
  // 方式一
  EasyRefresh(
    child: ScrollView(),
    onRefresh: () async{
      ....
    },
    onLoad: () async {
      ....
    },
  )
  // 方式二
  EasyRefresh.custom(
    slivers: <Widget>[],
    onRefresh: () async{
      ....
    },
    onLoad: () async {
      ....
    },
  )
  // 方式三
  EasyRefresh.builder(
    builder: (context, physics, header, footer) {
      return CustomScrollView(
        physics: physics,
        slivers: <Widget>[
          ...
          header,
          ...
          footer,
        ],
      );
    }
    onRefresh: () async{
      ....
    },
    onLoad: () async {
      ....
    },
  )
```
#### 3.触发刷新和加载动作
```dart
  EasyRefreshController _controller = EasyRefreshController();
  ....
  EasyRefresh(
    controller: _controller,
    ....
  );
  ....
  _controller.callRefresh();
  _controller.callLoad();
```
#### 4.控制加载和刷新完成
```dart
  EasyRefreshController _controller = EasyRefreshController();
  ....
  EasyRefresh(
	enableControlFinishRefresh: true,
	enableControlFinishLoad: true,
    ....
  );
  ....
  _controller.finishRefresh(success: true);
  _controller.finishLoad(success： true, noMore: false);
```

## 使用指定的 Header 和 Footer
```dart
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
....
  new EasyRefresh(
    header: MaterialHeader(),
    footer: MaterialFooter(),
    child: ScrollView(),
    ....
  )
```

## 添加国际化支持
```dart
import 'package:flutter_easyrefresh/easy_refresh.dart';
....
  /// 如果没有您当前的语言支持
  /// 您可以使用strings_en.arb进行翻译并命名为strings_{languageCode}_{countryCode}.arb
  /// 然后进行Pull requests
  new MaterialApp(
    localizationsDelegates: [
      GlobalEasyRefreshLocalizations.delegate,
      ....
    ],
    supportedLocales: [
        Locale('en', ''),
        Locale('zh', 'CN'),
        ....
    ]
    ....
  )
```

# 捐赠
如果你喜欢我的项目，请在项目右上角 "Star" 一下。你的支持是我最大的鼓励！ ^_^
你也还可以扫描下面的二维码，或者通过[![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=334PPRBZTY3J8&source=url)，对作者进行打赏。  

![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_alipay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_wxpay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_tencent.jpg?raw=true)

如果在捐赠留言中备注名称，将会被记录到列表中~ 如果你也是github开源作者，捐赠时可以留下github项目地址或者个人主页地址，链接将会被添加到列表中起到互相推广的作用  
[捐赠列表](https://github.com/xuelongqy/donation/blob/master/DONATIONLIST.md)

### QQ讨论群 - 554981921
#### 进群须知
这个群不仅仅是解决EasyreFresh的问题，任何Flutter相关的问题都可以进行讨论。正如它的名字一样，有问必答，只要群主有时间，都会帮大家一起解决问题。

## 感谢
[flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh)  
[SmartRefreshLayout](https://github.com/scwang90/SmartRefreshLayout)  
[flutter_spinkit](https://github.com/jogboms/flutter_spinkit)  

## 开源协议

```
 
MIT License

Copyright (c) 2018 xuelongqy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

 
```
