# flutter_easyrefresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![Pub](https://img.shields.io/badge/pub-v1.0.8-orange.svg)](https://pub.dartlang.org/packages/flutter_easyrefresh)

## English | [中文](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/README.md)

Just like the name, EasyRefresh can easily implement pull-down refresh and upload operations on Flutter applications. It supports almost all Flutter controls, but only if they are wrapped in ScrollView. Its functions are similar to Android's Smart Refresh Layout, and it also draws on the advantages of many tripartite libraries. EasyRefresh integrates various styles of Headers and Footers, but it has no limitations. You can easily customize it. Using Flutter's powerful animation, even a simple control can be done. EasyRefresh aims to build a strong, stable and mature drop-down refresh framework for Flutter.

## Features:

 - Support android (halo), ios (cross springback) effect
 - Support arbitrary ScrollView controls, if not for easy encapsulation (so the theory is that all controls)
 - Support custom and has integrated a lot of cool Header and Footer
 - Support pull refresh, on the load (automatically)
 - Support the Header and Footer list embedded and view the floating two forms
 
## Portal

 - [Properties document](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/en/PROPERTY.md)
 - [FAQ](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/en/FAQ.md)
 - [Change log](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/en/CHANGELOG.md)
 - [Custom Header and Footer](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/en/CUSTOM_HEADER_FOOTER.md)

## Demo
[Download APK-Demo](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/pkg/EasyRefresh.apk)

![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/apk_QRCode.png)

#### Project presentations
|Basic styles|Auto load|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/basic.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/auto_load.gif)|
|[BasicPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/basic_page.dart)|[AutoLoadPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/auto_load_page.dart)|

|Floating effect|User profile|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/float.gif)|![](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/image/user_profile.gif)|
|[FloatPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/float_page.dart)|[UserProfilePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/user_profile_page.dart)|

#### Style presentations
|Material|BallPulse|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/material.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/ball_pulse.gif)|
|[MaterialPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/material_page.dart)|[BallPulsePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/ball_pulse_page.dart)|

|BezierCircle|BezierHourGlass|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/bezier_circle.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/bezier_hour_glass.gif)|
|[BezierCirclePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/bezier_circle_page.dart)|[BezierHourGlassPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/bezier_hour_glass_page.dart)|
 
## Sample
#### 1.Adding dependencies to pubspec. yaml
```
//pub
dependencies:
  flutter_easyrefresh: ^1.0.8

//import
dependencies:
  flutter_easyrefresh:
    path: Your path
```
#### 2.Add EasyreFresh
```dart
import 'package:flutter_easyrefresh/easy_refresh.dart';
....
  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
....
  new EasyRefresh(
    key: _easyRefreshKey,
    child: ScrollView(),
    onRefresh: () async{
      ....
    },
    loadMore: () async {
      ....
    },
  )
```
#### 3.Trigger refresh and load action
```dart
  // If you don't need to set the key of EasyRefresh
  _easyRefreshKey.currentState.callRefresh();
  _easyRefreshKey.currentState.callLoadMore();
```

## Use the specified Header and Footer
```dart
import 'package:flutter_easyrefresh/easy_refresh.dart';
....
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
....
  // For the Header and Footer EasyRefresh will update, in order to maintain unity with the user operating state, you must set up the key
  // Different Header and Footer may have different parameter Settings
  new EasyRefresh(
    refreshHeader: MaterialHeader(
        key: _headerKey,
    ),
    refreshFooter: MaterialFooter(
        key: _footerKey,
    ),
    child: ScrollView(),
    ....
  )
```

# Donation
If you like my project, please in the upper right corner of the project "Star". Your support is my biggest encouragement! ^_^
You can also scan the qr code below or [![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=334PPRBZTY3J8&source=url), donation to Author.

![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_alipay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_wxpay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_tencent.jpg?raw=true)

If in donation message note name, will be record to the list if you are making open source authors, donation can leave when making project address or personal home page, a link will be added to the list have the effect of promoting each other
[Donation list](https://github.com/xuelongqy/donation/blob/master/flutter_easyrefresh.md)

### QQ Group - 554981921
#### Into the group of instructions
The group is not only solve the problem of EasyreFresh, any Flutter related issues can be discussed. Just as its name, craigslist, as long as there is time, group of Lord will help you solve problems together.

## Thanks
[PullToRefresh_Flutter](https://github.com/baoolong/PullToRefresh_Flutter)  
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
