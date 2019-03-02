# flutter_easyrefresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![Pub](https://img.shields.io/badge/pub-v1.2.7-orange.svg)](https://pub.dartlang.org/packages/flutter_easyrefresh)

## [English](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/README_EN.md) | 中文

正如名字一样，EasyRefresh很容易就能在Flutter应用上实现下拉刷新以及上拉加载操作，它支持几乎所有的Flutter控件，但前提是需要包裹成ScrollView。它的功能与Android的SmartRefreshLayout很相似，同样也吸取了很多三方库的优点。EasyRefresh中集成了多种风格的Header和Footer，但是它并没有局限性，你可以很轻松的自定义。使用Flutter强大的动画，甚至随便一个简单的控件也可以完成。EasyRefresh的目标是为Flutter打造一个强大，稳定，成熟的下拉刷新框架。

## 特点功能:

 - 支持Andorid(光晕)，ios(越界回弹)效果
 - 支持绝大多数Widget
 - 支持自定义并且已经集成了很多炫酷的 Header 和 Footer
 - 支持下拉刷新、上拉加载(可自动)
 - 支持 Header 和 Footer 列表嵌入以及视图浮动两种形式
 - 支持列表事件监听，制作任何样子的 Header 和 Footer，并且能够放在任何位置
 - 支持首次刷新，并自定义视图
 - 支持自定义列表为空时的视图，仅限于ScrollView
 
## 传送门

 - [属性文档](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/cn/PROPERTY.md)
 - [常见问题](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/cn/FAQ.md)
 - [更新日志](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/cn/CHANGELOG.md)
 - [自定义Header和Footer](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/cn/CUSTOM_HEADER_FOOTER.md)

## Demo
[下载 APK-Demo](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/pkg/EasyRefresh.apk)

![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/apk_QRCode.png)

#### 项目演示
|基本样式|自动加载|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/basic.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/auto_load.gif)|
|[BasicPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sample/basic_page.dart)|[AutoLoadPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sample/auto_load_page.dart)|

|浮动效果|个人中心|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/float.gif)|![](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/image/user_profile.gif)|
|[FloatPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sample/float_page.dart)|[UserProfilePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sample/user_profile_page.dart)|

|CustomScroolView|Swiper|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/sliver.gif)|![](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/image/swiper.gif)|
|[SliverPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sample/sliver_page.dart)|[SwiperPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sample/swiper_page.dart)|

|列表嵌入|Cupertino|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/list_embed.gif)|![](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/image/cupertino.gif)|
|[ListEmbedPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sample/list_embed_page.dart)|[CupertinoPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sample/cupertino_page.dart)|

#### 样式演示
|Material|BallPulse|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/material.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/ball_pulse.gif)|
|[MaterialPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/style/material_page.dart)|[BallPulsePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/style/ball_pulse_page.dart)|

|BezierCircle|BezierHourGlass|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/bezier_circle.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/bezier_hour_glass.gif)|
|[BezierCirclePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/style/bezier_circle_page.dart)|[BezierHourGlassPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/style/bezier_hour_glass_page.dart)|

|Phoenix|Delivery|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/phoenix.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/taurus.gif)|
|[PhoenixPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/style/phoenix_page.dart)|[TaurusPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/style/taurus_page.dart)|

|Space|Delivery|
|:---:|:---:|
|![](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/image/space.gif)|![](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/image/delivery.gif)|
|[SpacePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/style/space_page.dart)|[DeliveryPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/style/delivery_page.dart)|
 
## 简单用例
#### 1.在 pubspec.yaml 中添加依赖
```
//pub方式
dependencies:
  flutter_easyrefresh: ^1.2.7

//导入方式
dependencies:
  flutter_easyrefresh:
    path: 项目路径
```
#### 2.在布局文件中添加 EasyreFresh
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
#### 3.触发刷新和加载动作
```dart
  // 如果不需要可以不用设置EasyRefresh的key
  _easyRefreshKey.currentState.callRefresh();
  _easyRefreshKey.currentState.callLoadMore();
```

## 使用指定的 Header 和 Footer
```dart
import 'package:flutter_easyrefresh/easy_refresh.dart';
....
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
....
  // 因为EasyRefresh会对Header和Footer进行更新，为了与用户保持统一的操作状态，必须设置key
  // 不同的Header和Footer可能有不同的参数设置
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

# 捐赠
如果你喜欢我的项目，请在项目右上角 "Star" 一下。你的支持是我最大的鼓励！ ^_^
你也还可以扫描下面的二维码，或者通过[![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=334PPRBZTY3J8&source=url)，对作者进行打赏。  

![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_alipay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_wxpay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_tencent.jpg?raw=true)

如果在捐赠留言中备注名称，将会被记录到列表中~ 如果你也是github开源作者，捐赠时可以留下github项目地址或者个人主页地址，链接将会被添加到列表中起到互相推广的作用  
[捐赠列表](https://github.com/xuelongqy/donation/blob/master/flutter_easyrefresh.md)

### QQ讨论群 - 554981921
#### 进群须知
这个群不仅仅是解决EasyreFresh的问题，任何Flutter相关的问题都可以进行讨论。正如它的名字一样，有问必答，只要群主有时间，都会帮大家一起解决问题。

## 感谢
[PullToRefresh_Flutter](https://github.com/baoolong/PullToRefresh_Flutter)  
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
