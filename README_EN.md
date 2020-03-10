# flutter_easyrefresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![Pub](https://img.shields.io/badge/pub-v2.1.0-orange.svg)](https://pub.dartlang.org/packages/flutter_easyrefresh)

## English | [中文](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/README.md)

Just like the name, EasyRefresh can easily implement pull-down refresh and upload operations on Flutter applications. It supports almost all Flutter controls. Its functions are similar to Android's Smart Refresh Layout, and it also draws on the advantages of many tripartite libraries. EasyRefresh integrates various styles of Headers and Footers, but it has no limitations. You can easily customize it. Using Flutter's powerful animation, even a simple control can be done. EasyRefresh aims to build a strong, stable and mature drop-down refresh framework for Flutter.

Web version: [vue-easyrefresh](https://github.com/xuelongqy/vue-easyrefresh)

Demo：[Download APK-Demo](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/v2/art/pkg/EasyRefresh.apk)

![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/apk_QRCode.png)

## Features:

 - Support for most Widgets
 - Support custom and has integrated a lot of cool Header and Footer
 - Support pull refresh, on the load (controllable trigger)
 - Support the Header and Footer list embedded and view the floating two forms
 - Support list event listener, make any look of Header and Footer, and can be placed anywhere
 - Support for first refresh and custom view
 - Support for custom list empty view

## Portal

 - [Properties document](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/document/en/PROPERTY.md)
 - [FAQ](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/document/en/FQA.md)
 - [Change log](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/CHANGELOG.md)
 - [Custom Header and Footer](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/document/en/CUSTOM_HEADER_FOOTER.md)

#### Project presentations
|Basic|User profile|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/basic.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/user_profile.gif)|
|[BasicPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/basic.dart)|[UserProfilePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/user_profile.dart)|

|NestedScrollView|Link header|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/nested_scroll_view.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/link_header.gif)|
|[NestedScrollViewPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/nested_scroll_view.dart)|[LinkHeaderPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/link_header.dart)|

|First refresh|Empty widget|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/first_refresh.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/empty.gif)|
|[FirstRefreshPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/first_refresh.dart)|[EmptyPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/empty.dart)|

|Second floor|Chat demo|
|Second floor|Chat demo|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/second_floor.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/v2/art/image/chat.gif)|
|[SecondFloorPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/second_floor.dart)|[ChatPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/v2/example/lib/page/sample/chat.dart)|

#### Style presentations
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

## Sample
#### 1.Adding dependencies to pubspec. yaml
```
//pub
dependencies:
  flutter_easyrefresh: ^2.1.0

//import
dependencies:
  flutter_easyrefresh:
    path: Your path

//git
dependencies:
  flutter_easyrefresh:
    git:
      url: git://github.com/xuelongqy/flutter_easyrefresh.git
```
#### 2.Add EasyreFresh
```dart
import 'package:flutter_easyrefresh/easy_refresh.dart';
....
  // Way one
  EasyRefresh(
    child: ScrollView(),
    onRefresh: () async{
      ....
    },
    onLoad: () async {
      ....
    },
  )
  // Way two
  EasyRefresh.custom(
    slivers: <Widget>[],
    onRefresh: () async{
      ....
    },
    onLoad: () async {
      ....
    },
  )
  // Way three
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
#### 3.Trigger refresh and load action
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
#### 4.Control loading and refreshing completed
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

## Use the specified Header and Footer
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

## Add globalization support
```dart
import 'package:flutter_easyrefresh/easy_refresh.dart';
....
  /// Without your current language support
  /// You can use strings_en.arb for translation and name it strings_{languageCode}_{countryCode}.arb
  /// then pull requests
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

# Donation
If you like my project, please in the upper right corner of the project "Star". Your support is my biggest encouragement! ^_^
You can also scan the qr code below or [![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=334PPRBZTY3J8&source=url), donation to Author.

![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_alipay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_wxpay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_tencent.jpg?raw=true)

If in donation message note name, will be record to the list if you are making open source authors, donation can leave when making project address or personal home page, a link will be added to the list have the effect of promoting each other
[Donation list](https://github.com/xuelongqy/donation/blob/master/DONATIONLIST.md)

### QQ Group - 554981921
#### Into the group of instructions
The group is not only solve the problem of EasyreFresh, any Flutter related issues can be discussed. Just as its name, craigslist, as long as there is time, group of Lord will help you solve problems together.

## Thanks 
[flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh)  
[SmartRefreshLayout](https://github.com/scwang90/SmartRefreshLayout)  
[flutter_spinkit](https://github.com/jogboms/flutter_spinkit)  

## Open source licenses

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
