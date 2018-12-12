# flutter_easyrefresh

## [English](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/README.md) | 中文

正如名字一样，EasyreFresh很容易就能在Flutter应用上实现下拉刷新以及上拉加载操作，它支持几乎所有的Flutter控件，但前提是需要包裹成ScrollView。它的功能与Android的SmartRefreshLayout很相似，同样也吸取了很多三方库的优点。EasyreFresh中集成了多种风格的Header和Footer，但是它并没有局限性，你可以很轻松的自定义。使用Flutter强大的动画，甚至随便一个简单的控件也可以完成。EasyreFresh的目标是为Flutter打造一个强大，稳定，成熟的下拉刷新框架。

## 特点功能:

 - 支持Andorid(光晕)，ios(越界回弹)效果
 - 支持任意的ScrollView控件，如果不是进行简单封装即可(所以理论是所有控件)
 - 支持自定义并且已经集成了很多炫酷的 Header 和 Footer.
 - 支持下拉刷新、上拉加载(可自动)
 - 支持 Header 和 Footer 列表嵌入以及视图浮动两种形式
 
## 传送门

 - [属性文档](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/cn/PROPERTY.md)
 - [更新日志](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/art/md/cn/CHANGELOG.md)
 - [自定义Header和Footer](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/README.md)

## Demo
[下载 APK-Demo](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/pkg/EasyRefresh.apk)

#### 项目演示
|基本样式|自动加载|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/basic.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/auto_load.gif)|
|[BasicPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/basic_page.dart)|[AutoLoadPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/auto_load_page.dart)|

|浮动效果|个人中心|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/float.gif)|![](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/art/image/user_profile.gif)|
|[FloatPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/float_page.dart)|[UserProfilePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/user_profile_page.dart)|

#### 样式演示 Style
|Material|BallPulse|
|:---:|:---:|
|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/material.gif)|![](https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/image/ball_pulse.gif)|
|[MaterialPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/material_page.dart)|[BallPulsePage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/ball_pulse_page.dart)|
 
## 简单用例
#### 1.在 pubspec.yaml 中添加依赖
```
//pub方式
待上传

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

### QQ讨论群 - 554981921
#### 进群须知
这个群不仅仅是解决EasyreFresh的问题，任何Flutter相关的问题都可以进行讨论。正如它的名字一样，有问必答，只要群主有时间，都会帮大家一起解决问题。

## 感谢
[PullToRefresh_Flutter](https://github.com/baoolong/PullToRefresh_Flutter)  
[flutter_pulltorefresh](https://github.com/peng8350/flutter_pulltorefresh)  
[SmartRefreshLayout](https://github.com/scwang90/SmartRefreshLayout)  

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
