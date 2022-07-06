# flutter_easy_refresh

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter?sort=votes)
[![Pub](https://img.shields.io/pub/v/flutter_easy_refresh)](https://pub.flutter-io.cn/packages/flutter_easy_refresh)

## [English](/README_EN.md) | 中文

正如名字一样，EasyRefresh很容易就能在Flutter应用上实现下拉刷新以及上拉加载操作，它支持几乎所有的Flutter控件。它的功能与Android的SmartRefreshLayout很相似，同样也吸取了很多三方库的优点。EasyRefresh中集成了多种风格的Header和Footer，但是它并没有局限性，你可以很轻松的自定义。使用Flutter强大的动画，甚至随便一个简单的控件也可以完成。EasyRefresh的目标是为Flutter打造一个强大，稳定，成熟的下拉刷新框架。

### [在线演示](https://xuelongqy.github.io/flutter_easy_refresh/)
### [APK下载](https://github.com/xuelongqy/flutter_easyrefresh/raw/master/v2/art/pkg/EasyRefresh.apk)


## 特点功能:

 - 支持所有的滚动组件
 - 滚动物理作用域，精确匹配滚动组件
 - 集成多个炫酷的 Header 和 Footer
 - 支持自定义样式，实现各种动画效果
 - 支持下拉刷新、上拉加载(可使用控制器触发和结束)
 - 支持指示器位置设定，结合监听器也放置在任何位置
 - 支持页面启动时刷新，并自定义视图
 - 支持安全区域，不再有遮挡
 - 自定义滚动参数，让列表具有不同的滚动反馈和惯性

## 简单用例
#### 1.在 pubspec.yaml 中添加依赖
```
//pub方式
dependencies:
  flutter_easyrefresh: version

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


# 捐赠
如果你喜欢我的项目，请在项目右上角 "Star" 一下。你的支持是我最大的鼓励！ ^_^
你也还可以扫描下面的二维码，或者通过[![Donate to this project using Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://www.paypal.com/paypalme/xuelongqy)，对作者进行打赏。  

![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_alipay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_wxpay.jpg?raw=true) ![](https://raw.githubusercontent.com/xuelongqy/donation/master/pay_tencent.jpg?raw=true)

如果在捐赠留言中备注名称，将会被记录到列表中~ 如果你也是github开源作者，捐赠时可以留下github项目地址或者个人主页地址，链接将会被添加到列表中起到互相推广的作用  
[捐赠列表](https://github.com/xuelongqy/donation/blob/master/DONATIONLIST.md)

### QQ讨论群 - 554981921
#### 进群须知
这个群不仅仅是解决EasyreFresh的问题，任何Flutter相关的问题都可以进行讨论。正如它的名字一样，有问必答，只要群主有时间，都会帮大家一起解决问题。

## 感谢
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
