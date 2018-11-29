import 'package:flutter/widgets.dart';

/// 上拉加载视图抽象类
/// 自定义视图需要实现此类中的方法

typedef Future OnLoading();
typedef Future OnLoaded();
typedef Future OnFooterHide();

abstract class RefreshFooter extends StatefulWidget {
  // 高度
  final double height;
  // 是否浮动
  final bool isFloat;
  // 开始加载回调方法
  final OnLoading onLoading;
  // 完成加载回调方法
  final OnLoaded onLoaded;
  // 顶部视图隐藏回调方法
  final OnFooterHide onFooterHide;

  const RefreshFooter({
    Key key,
    @required this.height,
    this.isFloat: false,
    this.onLoading,
    this.onLoaded,
    this.onFooterHide
  }) : super(key: key);

  // 回调开始加载方法
  void callOnLoading() async {
    if (onLoading != null) {
      await onLoading();
    }
  }

  // 回调加载完成方法
  void callOnLoaded() async {
    if (onLoaded != null) {
      await onLoaded();
    }
  }

  // 回调底部隐藏方法方法
  void callOnFooterHide() async {
    if (onFooterHide != null) {
      await onFooterHide();
    }
  }
}